import express from 'express';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import natural from 'natural';

import { QueryParser } from './query-parser';
import { ColorMatcher } from './color-matcher';
import { RelevanceScorer } from './relevance-scorer';

const app = express();
const port = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

// -------------------------
// Load dataset
// -------------------------
const DATA_PATH = path.join(__dirname, '..', 'data', 'products.json');
let products: any[] = [];
try {
    const data = fs.readFileSync(DATA_PATH, 'utf-8');
    products = JSON.parse(data);
    console.log(`Loaded ${products.length} products`);
} catch (e) {
    console.error('Failed to load products.json', e);
}

// Build a "document" per product for semantic search
function getProductDoc(p: any): string {
    const dims = p.dimensions_cm || {};
    const parts = [
        String(p.name || ''),
        String(p.category || ''),
        String(p.color || ''),
        String(p.material || ''),
        String(p.style || ''),
        String(p.description || ''),
        `price ${p.price || ''}`,
        `dimensions ${dims.l || ''} ${dims.w || ''} ${dims.h || ''}`,
    ];
    return parts.join(' ').trim();
}

const docs = products.map(getProductDoc);

// -------------------------
// Semantic Engine (TF-IDF fallback)
// -------------------------
const TfIdf = natural.TfIdf;
const tfidf = new TfIdf();

docs.forEach((doc) => tfidf.addDocument(doc));

function getQuerySimilarities(query: string): number[] {
    const similarities: number[] = new Array(products.length).fill(0);
    tfidf.tfidfs(query, function (i, measure) {
        similarities[i] = measure;
    });

    // Normalize TF-IDF measures roughly to 0-1 for scoring consistency
    const max = Math.max(...similarities) || 1;
    return similarities.map(score => score / max);
}


// -------------------------
// Basic NLP helpers 
// -------------------------
const STOP_WORDS = new Set([
    'i', 'want', 'a', 'an', 'the', 'to', 'for', 'with', 'need',
    'looking', 'please', 'show', 'me', 'some', 'any', 'of',
    'and', 'or', 'that', 'this', 'give',
]);

const SYNONYMS: Record<string, string[]> = {
    magenta: ['pink', 'fuchsia', 'purple'],
    fuchsia: ['magenta', 'pink', 'purple'],
    couch: ['sofa'],
    sofa: ['couch'],
    grey: ['gray'],
    gray: ['grey'],
};

function normalize(s: string): string {
    let str = s.toLowerCase().trim();
    str = str.replace(/[^a-z0-9\s-]/g, ' ');
    str = str.replace(/\s+/g, ' ');
    return str;
}

function keywordsFromQuery(q: string): string[] {
    const tokens = normalize(q).split(/\s+/).filter(t => t && !STOP_WORDS.has(t));
    const expanded: string[] = [];

    for (const t of tokens) {
        expanded.push(t);
        if (SYNONYMS[t]) {
            expanded.push(...SYNONYMS[t]);
        }
    }

    return [...new Set(expanded)];
}

// -------------------------
// ML Ranker Heuristic (Replaces Logistic Regression)
// -------------------------
function heuristicMLProbability(queryKw: string[], p: any, sim: number): number {
    // Rather than running a full sklearn Logistic Regression,
    // we approximate the probability based on feature match density.

    const cat = normalize(String(p.category || ''));
    const col = normalize(String(p.color || ''));
    const mat = normalize(String(p.material || ''));
    const sty = normalize(String(p.style || ''));

    const colorHit = queryKw.includes(col) ? 1.0 : 0.0;
    const catHit = queryKw.includes(cat) ? 1.0 : 0.0;
    const matHit = queryKw.includes(mat) ? 1.0 : 0.0;
    const styHit = queryKw.includes(sty) ? 1.0 : 0.0;

    // A rough approximation of the feature weights the ML model learned
    let score = (sim * 2.0) + (catHit * 1.5) + (colorHit * 1.0) + (matHit * 0.5) + (styHit * 0.5);

    // normalize to roughly 0-1
    return Math.min(Math.max(score / 5.0, 0), 1);
}

// -------------------------
// Initialize modules
// -------------------------
const queryParser = new QueryParser();
const relevanceScorer = new RelevanceScorer();
const colorMatcher = new ColorMatcher();

// -------------------------
// API Endpoints
// -------------------------

app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        items: products.length,
        semantic_mode: 'tfidf_ts',
    });
});

app.post('/search', (req, res) => {
    const query = req.body.query;
    const topK = req.body.top_k || 10;
    const debug = req.body.debug || false;

    if (!query || typeof query !== 'string') {
        return res.status(400).json({ error: 'Query is required' });
    }

    // STEP 1: Parse query
    const parsed = queryParser.parse(query);

    // STEP 2: Apply hard constraints (STRICT MODE)
    const filteredProducts: any[] = [];
    const filteredIndices: number[] = [];

    for (let idx = 0; idx < products.length; idx++) {
        const p = products[idx];
        if (relevanceScorer.shouldInclude(p, parsed)) {
            filteredProducts.push(p);
            filteredIndices.push(idx);
        }
    }

    // STRICT MODE: return empty if no result matches absolute constraints
    if (filteredProducts.length === 0) {
        const response: any = {
            query: query,
            semantic_mode: 'tfidf_ts',
            count: 0,
            results: [],
        };

        if (debug) {
            response.debug = {
                parsed: {
                    product_type: parsed.productType,
                    colors: parsed.colors,
                    expanded_colors: parsed.colors ? Array.from(colorMatcher.expandColors(parsed.colors)) : [],
                    materials: parsed.materials,
                    styles: parsed.styles,
                    price_range: {
                        min: parsed.priceMin,
                        max: parsed.priceMax,
                    },
                },
                filtered_count: 0,
                total_products: products.length,
                message: 'No products match all constraints',
            };
        }

        return res.json(response);
    }

    // STEP 3: Compute semantic similarities
    const qkw = keywordsFromQuery(query);
    const semanticQuery = qkw.length > 0 ? qkw.join(' ') : query;
    const allSims = getQuerySimilarities(semanticQuery);

    // STEP 4: Score and rank
    const scored: Array<{ score: number; p: any; tags: string[] }> = [];

    for (let i = 0; i < filteredProducts.length; i++) {
        const p = filteredProducts[i];
        const originalIdx = filteredIndices[i];
        const sim = allSims[originalIdx] || 0;

        const mlProba = heuristicMLProbability(qkw, p, sim);

        const { score: relevanceScore, tags } = relevanceScorer.score(p, parsed, sim, mlProba);

        scored.push({ score: relevanceScore, p, tags });
    }

    // Sort by highest score first
    scored.sort((a, b) => b.score - a.score);
    const top = scored.slice(0, topK);

    const response: any = {
        query: query,
        semantic_mode: 'tfidf_ts',
        count: top.length,
        results: top.map((item) => ({
            score: parseFloat(item.score.toFixed(4)),
            matchedTags: item.tags,
            product: item.p,
        })),
    };

    if (debug) {
        response.debug = {
            parsed: {
                product_type: parsed.productType,
                colors: parsed.colors,
                expanded_colors: parsed.colors ? Array.from(colorMatcher.expandColors(parsed.colors)) : [],
                materials: parsed.materials,
                styles: parsed.styles,
                price_range: {
                    min: parsed.priceMin,
                    max: parsed.priceMax,
                },
            },
            filtered_count: filteredProducts.length,
            total_products: products.length,
        };
    }

    res.json(response);
});

app.listen(port, () => {
    console.log(`TypeScript AI Search Server running on http://localhost:${port}`);
    console.log(`✅ ML Ranker replaced with local heuristic probability`);
    console.log(`✅ SemanticEngine: Using TF-IDF via "natural" package`);
});
