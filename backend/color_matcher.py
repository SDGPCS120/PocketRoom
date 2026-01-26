"""
Color Matching Module
Handles color similarity and shade expansion for better search results.
"""

from __future__ import annotations
from typing import List, Set


class ColorMatcher:
    """Matches colors with similar shades and color families."""
    
    # Color families - each color maps to its similar shades
    COLOR_FAMILIES = {
        'pink': ['pink', 'magenta', 'fuchsia', 'rose', 'blush', 'salmon', 'coral'],
        'magenta': ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],
        'fuchsia': ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],
        'rose': ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],
        'blush': ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],
        
        'purple': ['purple', 'violet', 'lavender', 'plum', 'magenta'],
        'violet': ['purple', 'violet', 'lavender', 'plum'],
        'lavender': ['purple', 'violet', 'lavender', 'plum'],
        'plum': ['purple', 'violet', 'lavender', 'plum'],
        
        'grey': ['grey', 'gray', 'silver', 'charcoal'],
        'gray': ['grey', 'gray', 'silver', 'charcoal'],
        'silver': ['grey', 'gray', 'silver'],
        'charcoal': ['grey', 'gray', 'charcoal', 'black'],
        
        'beige': ['beige', 'tan', 'cream', 'ivory', 'off-white'],
        'tan': ['beige', 'tan', 'cream', 'brown'],
        'cream': ['beige', 'tan', 'cream', 'ivory', 'white'],
        'ivory': ['beige', 'cream', 'ivory', 'white'],
        
        'brown': ['brown', 'tan', 'walnut', 'teak', 'oak'],
        'walnut': ['brown', 'walnut', 'teak'],
        'oak': ['brown', 'oak', 'tan', 'beige'],
        'teak': ['brown', 'teak', 'walnut'],
        
        'white': ['white', 'cream', 'ivory', 'off-white'],
        'black': ['black', 'charcoal'],
        
        'blue': ['blue', 'navy', 'cyan'],
        'navy': ['blue', 'navy'],
        'cyan': ['blue', 'cyan'],
        
        'green': ['green', 'olive'],
        'olive': ['green', 'olive'],
        
        'red': ['red', 'burgundy', 'maroon'],
        'burgundy': ['red', 'burgundy', 'maroon'],
        'maroon': ['red', 'burgundy', 'maroon'],
        
        'yellow': ['yellow', 'gold', 'golden'],
        'gold': ['yellow', 'gold', 'golden'],
        'golden': ['yellow', 'gold', 'golden'],
        
        'orange': ['orange', 'coral', 'salmon'],
        'coral': ['orange', 'coral', 'salmon', 'pink'],
        'salmon': ['orange', 'coral', 'salmon', 'pink'],
        
        'clear': ['clear', 'transparent'],
        'transparent': ['clear', 'transparent'],
    }
    
    def expand_colors(self, colors: List[str]) -> Set[str]:
        """
        Expand a list of colors to include all similar shades.
        
        Args:
            colors: List of color names from query
            
        Returns:
            Set of all colors including similar shades
        """
        expanded = set()
        
        for color in colors:
            color_lower = color.lower()
            if color_lower in self.COLOR_FAMILIES:
                # Add all shades in the family
                expanded.update(self.COLOR_FAMILIES[color_lower])
            else:
                # Unknown color, just add as-is
                expanded.add(color_lower)
        
        return expanded
    
    def matches(self, product_color: str, query_colors: List[str]) -> tuple[bool, str]:
        """
        Check if product color matches any query color or similar shade.
        
        Args:
            product_color: Color of the product
            query_colors: List of colors from the query
            
        Returns:
            Tuple of (matches: bool, match_type: str)
            match_type can be 'exact' or 'similar'
        """
        if not query_colors:
            return False, ''
        
        product_color_lower = product_color.lower()
        
        # Check for exact match first
        for query_color in query_colors:
            if product_color_lower == query_color.lower():
                return True, 'exact'
        
        # Check for similar shade match
        expanded = self.expand_colors(query_colors)
        if product_color_lower in expanded:
            return True, 'similar'
        
        return False, ''
    
    def get_color_family(self, color: str) -> List[str]:
        """Get the color family for a given color."""
        color_lower = color.lower()
        return self.COLOR_FAMILIES.get(color_lower, [color_lower])
