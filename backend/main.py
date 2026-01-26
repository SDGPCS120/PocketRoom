from __future__ import annotations

import json
import math
import random
import re
from pathlib import Path
from typing import Any, Dict, List

import numpy as np
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics.pairwise import cosine_similarity

# Import new modules
from query_parser import QueryParser, ParsedQuery
from color_matcher import ColorMatcher
from relevance_scorer import RelevanceScorer


# -------------------------
# App
# -------------------------
app = FastAPI(title="AI Search Demo (Semantic + ML Ranking)", version="2.0")

# ✅ CORS (required for Flutter Web / browser calls)
# NOTE: "*" is fine for local development. Restrict this in production.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -------------------------
# Load dataset
# -------------------------
DATA_PATH = Path(__file__).parent / "data" / "products.json"
PRODUCTS: List[Dict[str, Any]] = json.loads(DATA_PATH.read_text(encoding="utf-8"))


# Build a "document" per product for semantic search
def product_doc(p: Dict[str, Any]) -> str:
    dims = p.get("dimensions_cm") or {}
    parts = [
        str(p.get("name", "")),
        str(p.get("category", "")),
        str(p.get("color", "")),
        str(p.get("material", "")),
        str(p.get("style", "")),
        str(p.get("description", "")),
        f"price {p.get('price','')}",
        f"dimensions {dims.get('l','')} {dims.get('w','')} {dims.get('h','')}",
    ]
    return " ".join(parts).strip()


DOCS = [product_doc(p) for p in PRODUCTS]


# -------------------------
# Basic NLP helpers
# -------------------------
STOP_WORDS = {
    "i",
    "want",
    "a",
    "an",
    "the",
    "to",
    "for",
    "with",
    "need",
    "looking",
    "please",
    "show",
    "me",
    "some",
    "any",
    "of",
    "and",
    "or",
    "that",
    "this",
    "give",
}

SYNONYMS = {
    "magenta": ["pink", "fuchsia", "purple"],
    "fuchsia": ["magenta", "pink", "purple"],
    "couch": ["sofa"],
    "sofa": ["couch"],
    "grey": ["gray"],
    "gray": ["grey"],
}


def normalize(s: str) -> str:
    s = s.lower().strip()
    s = re.sub(r"[^a-z0-9\s\-]", " ", s)
    s = re.sub(r"\s+", " ", s)
    return s


def keywords_from_query(q: str) -> List[str]:
    tokens = [t for t in normalize(q).split(" ") if t and t not in STOP_WORDS]
    expanded: List[str] = []
    for t in tokens:
        expanded.append(t)
        for syn in SYNONYMS.get(t, []):
            expanded.append(syn)
    # unique preserve order
    seen = set()
    out: List[str] = []
    for t in expanded:
        if t not in seen:
            seen.add(t)
            out.append(t)
    return out


# -------------------------
# Semantic Engine (embeddings OR TF-IDF fallback)
# -------------------------
class SemanticEngine:
    def __init__(self, docs: List[str]):
        self.mode = "tfidf"  # default fallback
        self.model = None
        self.doc_vecs = None
        self.vectorizer = None

        # Try true embeddings
        try:
            from sentence_transformers import SentenceTransformer  # type: ignore

            self.model = SentenceTransformer("all-MiniLM-L6-v2")
            self.doc_vecs = self.model.encode(docs, normalize_embeddings=True)
            self.mode = "embeddings"
            print("✅ SemanticEngine: Using sentence-transformers embeddings")
        except Exception:
            # Fallback: TF-IDF
            self.vectorizer = TfidfVectorizer(stop_words="english")
            self.doc_vecs = self.vectorizer.fit_transform(docs)
            self.mode = "tfidf"
            print("⚠️ SemanticEngine: sentence-transformers not available, using TF-IDF fallback")

    def query_similarities(self, query: str) -> np.ndarray:
        if self.mode == "embeddings":
            qv = self.model.encode([query], normalize_embeddings=True)
            sims = cosine_similarity(qv, self.doc_vecs)[0]
            return sims
        else:
            qv = self.vectorizer.transform([query])
            sims = cosine_similarity(qv, self.doc_vecs)[0]
            return sims


SEM = SemanticEngine(DOCS)


# -------------------------
# ML Ranker (Logistic Regression)
# -------------------------
def extract_features(query_kw: List[str], p: Dict[str, Any], sim: float) -> List[float]:
    cat = normalize(str(p.get("category", "")))
    col = normalize(str(p.get("color", "")))
    mat = normalize(str(p.get("material", "")))
    sty = normalize(str(p.get("style", "")))

    color_hit = 1.0 if any(k == col for k in query_kw) else 0.0
    cat_hit = 1.0 if any(k == cat for k in query_kw) else 0.0
    mat_hit = 1.0 if any(k == mat for k in query_kw) else 0.0
    style_hit = 1.0 if any(k == sty for k in query_kw) else 0.0

    price = p.get("price")
    price_norm = float(price) / 200000.0 if isinstance(price, (int, float)) else 0.0

    qlen = float(len(query_kw))
    return [float(sim), color_hit, cat_hit, mat_hit, style_hit, price_norm, qlen]


def train_ranker(products: List[Dict[str, Any]]) -> LogisticRegression:
    X: List[List[float]] = []
    y: List[int] = []

    random.seed(42)
    n = min(200, len(products))
    sample = random.sample(products, n) if len(products) >= n else products[:]

    pseudo_queries: List[str] = []
    for p in sample:
        q = f"{p.get('color','')} {p.get('category','')} {p.get('material','')}".strip()
        pseudo_queries.append(normalize(q))

    # Cache product indices for stable/fast lookup
    idx_map = {id(p): i for i, p in enumerate(PRODUCTS)}

    for i, q in enumerate(pseudo_queries):
        sims = SEM.query_similarities(q)
        qkw = keywords_from_query(q)

        p_pos = sample[i]
        pos_idx = idx_map.get(id(p_pos), None)
        sim_pos = float(sims[pos_idx]) if pos_idx is not None else 0.0
        X.append(extract_features(qkw, p_pos, sim_pos))
        y.append(1)

        for _ in range(2):
            p_neg = random.choice(sample)
            if p_neg == p_pos:
                continue
            neg_idx = idx_map.get(id(p_neg), None)
            sim_neg = float(sims[neg_idx]) if neg_idx is not None else 0.0
            X.append(extract_features(qkw, p_neg, sim_neg))
            y.append(0)

    X_np = np.array(X, dtype=float)
    y_np = np.array(y, dtype=int)

    model = LogisticRegression(max_iter=500)
    model.fit(X_np, y_np)
    print("✅ ML Ranker trained (LogisticRegression)")
    return model


RANKER = train_ranker(PRODUCTS)

# -------------------------
# Initialize new modules
# -------------------------
QUERY_PARSER = QueryParser()
RELEVANCE_SCORER = RelevanceScorer()


# -------------------------
# API Schemas
# -------------------------
class SearchRequest(BaseModel):
    query: str = Field(..., min_length=1)
    top_k: int = Field(default=10, ge=1, le=50)
    debug: bool = Field(default=False)  # Optional debug mode


@app.get("/health")
def health():
    return {"status": "ok", "items": len(PRODUCTS), "semantic_mode": SEM.mode}


@app.post("/search")
def search(req: SearchRequest):
    query = req.query
    
    # ✅ STEP 1: Parse query to extract structured filters
    parsed = QUERY_PARSER.parse(query)
    
    # ✅ STEP 2: Apply hard constraints to filter products (STRICT MODE)
    filtered_products = []
    filtered_indices = []
    
    for idx, p in enumerate(PRODUCTS):
        if RELEVANCE_SCORER.should_include(p, parsed):
            filtered_products.append(p)
            filtered_indices.append(idx)
    
    # ✅ STRICT MODE: If no results match constraints, return empty
    # (No fallback - user wants to see "no results" instead of relaxed matches)
    if len(filtered_products) == 0:
        return {
            "query": query,
            "semantic_mode": SEM.mode,
            "count": 0,
            "results": [],
            "debug": {
                "parsed": {
                    "product_type": parsed.product_type,
                    "colors": parsed.colors,
                    "expanded_colors": list(ColorMatcher().expand_colors(parsed.colors)) if parsed.colors else [],
                    "materials": parsed.materials,
                    "styles": parsed.styles,
                    "price_range": {
                        "min": parsed.price_min,
                        "max": parsed.price_max,
                    },
                },
                "filtered_count": 0,
                "total_products": len(PRODUCTS),
                "message": "No products match all constraints"
            } if req.debug else None
        }
    
    # ✅ STEP 3: Compute semantic similarities for filtered products
    qkw = keywords_from_query(query)
    semantic_query = " ".join(qkw) if qkw else query
    all_sims = SEM.query_similarities(semantic_query)
    
    # ✅ STEP 4: Score and rank filtered products
    scored = []
    for i, p in enumerate(filtered_products):
        original_idx = filtered_indices[i]
        sim = float(all_sims[original_idx])
        
        # Get ML probability
        feats = extract_features(qkw, p, sim)
        ml_proba = float(RANKER.predict_proba([feats])[0][1])
        
        # ✅ Use new relevance scorer
        relevance_score, tags = RELEVANCE_SCORER.score(p, parsed, sim, ml_proba)
        
        scored.append((relevance_score, p, tags))
    
    # Sort by relevance score (highest first)
    scored.sort(key=lambda x: x[0], reverse=True)
    top = scored[: req.top_k]
    
    # Build response
    response = {
        "query": query,
        "semantic_mode": SEM.mode,
        "count": len(top),
        "results": [
            {"score": round(s, 4), "matchedTags": tags, "product": p}
            for (s, p, tags) in top
        ],
    }
    
    # ✅ Add debug info if requested
    if req.debug:
        color_matcher = ColorMatcher()
        expanded_colors = list(color_matcher.expand_colors(parsed.colors)) if parsed.colors else []
        
        response["debug"] = {
            "parsed": {
                "product_type": parsed.product_type,
                "colors": parsed.colors,
                "expanded_colors": expanded_colors,
                "materials": parsed.materials,
                "styles": parsed.styles,
                "price_range": {
                    "min": parsed.price_min,
                    "max": parsed.price_max,
                },
            },
            "filtered_count": len(filtered_products),
            "total_products": len(PRODUCTS),
        }
    
    return response
