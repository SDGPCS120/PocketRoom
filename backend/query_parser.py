"""
Query Parser Module
Extracts structured entities from natural language search queries.
"""

from __future__ import annotations
import re
from dataclasses import dataclass
from typing import Optional, List, Set


@dataclass
class ParsedQuery:
    """Structured representation of a search query."""
    raw_query: str
    product_type: Optional[str] = None
    colors: List[str] = None
    materials: List[str] = None
    styles: List[str] = None
    price_max: Optional[float] = None
    price_min: Optional[float] = None
    
    def __post_init__(self):
        if self.colors is None:
            self.colors = []
        if self.materials is None:
            self.materials = []
        if self.styles is None:
            self.styles = []


class QueryParser:
    """Parses natural language queries into structured filters."""
    
    # Product type keywords (singular and plural)
    PRODUCT_TYPES = {
        'chair': ['chair', 'chairs', 'seating', 'seat'],
        'sofa': ['sofa', 'sofas', 'couch', 'couches', 'loveseat', 'loveseats'],
        'table': ['table', 'tables'],
        'desk': ['desk', 'desks', 'workstation', 'workstations'],
        'bed': ['bed', 'beds', 'bedframe', 'bedframes'],
        'storage': ['storage', 'shelf', 'shelves', 'bookshelf', 'bookshelves', 
                    'cabinet', 'cabinets', 'wardrobe', 'wardrobes', 'console'],
        'decor': ['decor', 'decoration', 'rug', 'rugs', 'lamp', 'lamps'],
    }
    
    # Color keywords
    COLORS = {
        'pink', 'magenta', 'fuchsia', 'rose', 'blush',
        'purple', 'violet', 'lavender', 'plum',
        'grey', 'gray', 'silver', 'charcoal',
        'black', 'white', 'cream', 'ivory',
        'beige', 'tan', 'brown', 'walnut', 'oak', 'teak',
        'blue', 'navy', 'cyan',
        'green', 'olive',
        'red', 'burgundy', 'maroon',
        'yellow', 'gold', 'golden',
        'orange', 'coral', 'salmon',
        'clear', 'transparent',
    }
    
    # Material keywords
    MATERIALS = {
        'wood', 'wooden', 'oak', 'walnut', 'teak',
        'metal', 'metallic', 'steel', 'iron',
        'fabric', 'cloth', 'textile',
        'leather', 'genuine leather',
        'velvet', 'velvety',
        'glass', 'tempered glass',
        'marble', 'stone',
        'plastic', 'acrylic',
        'engineered wood', 'mdf',
    }
    
    # Style keywords
    STYLES = {
        'modern', 'contemporary',
        'classic', 'traditional',
        'minimalist', 'minimal', 'simple',
        'industrial',
        'scandinavian', 'scandi', 'nordic',
        'luxury', 'premium', 'elegant',
        'casual', 'relaxed',
    }
    
    def __init__(self):
        # Build reverse lookup for product types
        self._product_type_lookup = {}
        for canonical, variants in self.PRODUCT_TYPES.items():
            for variant in variants:
                self._product_type_lookup[variant.lower()] = canonical
    
    def parse(self, query: str) -> ParsedQuery:
        """Parse a natural language query into structured filters."""
        normalized = self._normalize(query)
        tokens = normalized.split()
        
        parsed = ParsedQuery(raw_query=query)
        
        # Extract product type
        parsed.product_type = self._extract_product_type(tokens)
        
        # Extract colors
        parsed.colors = self._extract_colors(tokens)
        
        # Extract materials
        parsed.materials = self._extract_materials(tokens)
        
        # Extract styles
        parsed.styles = self._extract_styles(tokens)
        
        # Extract price range
        parsed.price_min, parsed.price_max = self._extract_price_range(normalized)
        
        return parsed
    
    def _normalize(self, text: str) -> str:
        """Normalize text for parsing."""
        text = text.lower().strip()
        # Remove punctuation except hyphens (for multi-word terms)
        text = re.sub(r'[^\w\s\-]', ' ', text)
        # Collapse multiple spaces
        text = re.sub(r'\s+', ' ', text)
        return text
    
    def _extract_product_type(self, tokens: List[str]) -> Optional[str]:
        """Extract product type from tokens."""
        # Check for exact matches first
        for token in tokens:
            if token in self._product_type_lookup:
                return self._product_type_lookup[token]
        
        # Check for multi-word matches (e.g., "dining table")
        text = ' '.join(tokens)
        for canonical, variants in self.PRODUCT_TYPES.items():
            for variant in variants:
                if variant in text:
                    return canonical
        
        return None
    
    def _extract_colors(self, tokens: List[str]) -> List[str]:
        """Extract color keywords from tokens."""
        colors = []
        for token in tokens:
            if token in self.COLORS:
                colors.append(token)
        return colors
    
    def _extract_materials(self, tokens: List[str]) -> List[str]:
        """Extract material keywords from tokens."""
        materials = []
        text = ' '.join(tokens)
        
        # Check multi-word materials first
        for material in ['engineered wood', 'genuine leather', 'tempered glass']:
            if material in text:
                materials.append(material)
        
        # Check single-word materials
        for token in tokens:
            if token in self.MATERIALS and token not in materials:
                materials.append(token)
        
        return materials
    
    def _extract_styles(self, tokens: List[str]) -> List[str]:
        """Extract style keywords from tokens."""
        styles = []
        for token in tokens:
            if token in self.STYLES:
                styles.append(token)
        return styles
    
    def _extract_price_range(self, text: str) -> tuple[Optional[float], Optional[float]]:
        """Extract price range from text."""
        price_min = None
        price_max = None
        
        # Pattern: "under 50000", "below 100000", "less than 75000"
        under_match = re.search(r'(?:under|below|less than|max)\s+(\d+(?:,\d+)*)', text)
        if under_match:
            price_max = float(under_match.group(1).replace(',', ''))
        
        # Pattern: "over 50000", "above 100000", "more than 75000"
        over_match = re.search(r'(?:over|above|more than|min)\s+(\d+(?:,\d+)*)', text)
        if over_match:
            price_min = float(over_match.group(1).replace(',', ''))
        
        # Pattern: "between 50000 and 100000"
        between_match = re.search(r'between\s+(\d+(?:,\d+)*)\s+and\s+(\d+(?:,\d+)*)', text)
        if between_match:
            price_min = float(between_match.group(1).replace(',', ''))
            price_max = float(between_match.group(2).replace(',', ''))
        
        return price_min, price_max
