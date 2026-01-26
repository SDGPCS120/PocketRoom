"""
Relevance Scoring Module
Scores and ranks search results based on query match quality.
"""

from __future__ import annotations
from typing import Dict, Any, List
from query_parser import ParsedQuery
from color_matcher import ColorMatcher


class RelevanceScorer:
    """Scores products based on how well they match the parsed query."""
    
    def __init__(self):
        self.color_matcher = ColorMatcher()
    
    def score(
        self,
        product: Dict[str, Any],
        parsed_query: ParsedQuery,
        semantic_similarity: float,
        ml_probability: float = 0.0
    ) -> tuple[float, List[str]]:
        """
        Calculate relevance score for a product.
        
        Args:
            product: Product dictionary
            parsed_query: Parsed query with extracted entities
            semantic_similarity: Semantic similarity score (0-1)
            ml_probability: ML model probability (0-1)
            
        Returns:
            Tuple of (score: float, match_tags: List[str])
        """
        score = 0.0
        tags = []
        
        # Base semantic score (weighted lower now)
        score += semantic_similarity * 15
        tags.append(f"semantic={semantic_similarity:.3f}")
        
        # ML probability (if available)
        if ml_probability > 0:
            score += ml_probability * 10
            tags.append(f"ml={ml_probability:.3f}")
        
        # Product type matching (CRITICAL)
        if parsed_query.product_type:
            product_category = product.get('category', '').lower()
            
            if product_category == parsed_query.product_type:
                score += 50
                tags.append('category_match')
            else:
                # Strong penalty for category mismatch
                score -= 100
                tags.append('category_mismatch')
        
        # Color matching
        if parsed_query.colors:
            product_color = product.get('color', '')
            matches, match_type = self.color_matcher.matches(product_color, parsed_query.colors)
            
            if matches:
                if match_type == 'exact':
                    score += 30
                    tags.append('color_exact')
                elif match_type == 'similar':
                    score += 20
                    tags.append('color_similar')
            else:
                # Penalty for color mismatch (but not as severe as category)
                score -= 20
                tags.append('color_mismatch')
        
        # Material matching
        if parsed_query.materials:
            product_material = product.get('material', '').lower()
            for material in parsed_query.materials:
                if material.lower() in product_material or product_material in material.lower():
                    score += 10
                    tags.append('material_match')
                    break
        
        # Style matching
        if parsed_query.styles:
            product_style = product.get('style', '').lower()
            for style in parsed_query.styles:
                if style.lower() in product_style or product_style in style.lower():
                    score += 10
                    tags.append('style_match')
                    break
        
        # Price range matching
        product_price = product.get('price', 0)
        if isinstance(product_price, (int, float)):
            if parsed_query.price_min and product_price < parsed_query.price_min:
                score -= 30
                tags.append('price_too_low')
            elif parsed_query.price_max and product_price > parsed_query.price_max:
                score -= 30
                tags.append('price_too_high')
            elif parsed_query.price_min or parsed_query.price_max:
                tags.append('price_match')
        
        return score, tags
    
    def should_include(self, product: Dict[str, Any], parsed_query: ParsedQuery) -> bool:
        """
        Determine if a product should be included in results (hard constraints).
        
        Args:
            product: Product dictionary
            parsed_query: Parsed query
            
        Returns:
            True if product passes hard constraints
        """
        # Hard constraint: product type must match if specified
        if parsed_query.product_type:
            product_category = product.get('category', '').lower()
            if product_category != parsed_query.product_type:
                return False
        
        # Hard constraint: color must match (exact or similar) if specified
        if parsed_query.colors:
            product_color = product.get('color', '')
            matches, _ = self.color_matcher.matches(product_color, parsed_query.colors)
            if not matches:
                return False
        
        # Hard constraint: price must be within range if specified
        product_price = product.get('price', 0)
        if isinstance(product_price, (int, float)):
            if parsed_query.price_min and product_price < parsed_query.price_min:
                return False
            if parsed_query.price_max and product_price > parsed_query.price_max:
                return False
        
        return True
