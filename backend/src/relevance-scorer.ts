import { ParsedQuery } from './query-parser';
import { ColorMatcher } from './color-matcher';

export class RelevanceScorer {
    private colorMatcher: ColorMatcher;

    constructor() {
        this.colorMatcher = new ColorMatcher();
    }

    public score(
        product: any,
        parsedQuery: ParsedQuery,
        semanticSimilarity: number,
        mlProbability: number = 0.0
    ): { score: number; tags: string[] } {
        let score = 0.0;
        const tags: string[] = [];

        // Base semantic score
        score += semanticSimilarity * 15;
        tags.push(`semantic=${semanticSimilarity.toFixed(3)}`);

        // ML probability (optional/simulated)
        if (mlProbability > 0) {
            score += mlProbability * 10;
            tags.push(`ml=${mlProbability.toFixed(3)}`);
        }

        // Color matching
        if (parsedQuery.colors && parsedQuery.colors.length > 0) {
            const productColor = product.color || '';
            const { matches, matchType } = this.colorMatcher.matches(productColor, parsedQuery.colors);

            if (matches) {
                if (matchType === 'exact') {
                    score += 30;
                    tags.push('color_exact');
                } else if (matchType === 'similar') {
                    score += 20;
                    tags.push('color_similar');
                }
            } else {
                // Penalty for color mismatch
                score -= 20;
                tags.push('color_mismatch');
            }
        }

        // Material matching
        if (parsedQuery.materials && parsedQuery.materials.length > 0) {
            const productMaterial = (product.material || '').toLowerCase();
            for (const material of parsedQuery.materials) {
                const materialLower = material.toLowerCase();
                if (productMaterial.includes(materialLower) || materialLower.includes(productMaterial)) {
                    score += 10;
                    tags.push('material_match');
                    break;
                }
            }
        }

        // Style matching
        if (parsedQuery.styles && parsedQuery.styles.length > 0) {
            const productStyle = (product.style || '').toLowerCase();
            for (const style of parsedQuery.styles) {
                const styleLower = style.toLowerCase();
                if (productStyle.includes(styleLower) || styleLower.includes(productStyle)) {
                    score += 10;
                    tags.push('style_match');
                    break;
                }
            }
        }

        // Price range matching
        const productPrice = typeof product.price === 'number' ? product.price : parseFloat(product.price) || 0;
        if (productPrice > 0) {
            if (parsedQuery.priceMin && productPrice < parsedQuery.priceMin) {
                score -= 30;
                tags.push('price_too_low');
            } else if (parsedQuery.priceMax && productPrice > parsedQuery.priceMax) {
                score -= 30;
                tags.push('price_too_high');
            } else if (parsedQuery.priceMin || parsedQuery.priceMax) {
                tags.push('price_match');
            }
        }

        return { score, tags };
    }

    public shouldInclude(product: any, parsedQuery: ParsedQuery): boolean {

        // Hard constraint: color must match (exact or similar) if specified
        if (parsedQuery.colors && parsedQuery.colors.length > 0) {
            const productColor = product.color || '';
            const { matches } = this.colorMatcher.matches(productColor, parsedQuery.colors);
            if (!matches) {
                return false;
            }
        }

        // Hard constraint: price must be within range if specified
        const productPrice = typeof product.price === 'number' ? product.price : parseFloat(product.price) || 0;
        if (productPrice > 0) {
            if (parsedQuery.priceMin && productPrice < parsedQuery.priceMin) {
                return false;
            }
            if (parsedQuery.priceMax && productPrice > parsedQuery.priceMax) {
                return false;
            }
        }

        return true;
    }
}
