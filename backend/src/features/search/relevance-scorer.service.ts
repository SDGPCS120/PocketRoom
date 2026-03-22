import { Injectable } from '@nestjs/common';
import { ColorMatcherService } from './color-matcher.service';
import { ParsedQuery } from './query-parser.service';

@Injectable()
export class RelevanceScorerService {
    constructor(private readonly colorMatcher: ColorMatcherService) { }

    public score(
        product: any,
        parsedQuery: ParsedQuery,
        semanticSimilarity: number,
        mlProbability: number = 0.0,
    ): { score: number; tags: string[] } {
        let score = 0.0;
        const tags: string[] = [];

        // Base semantic score - increased weight
        score += semanticSimilarity * 30;
        tags.push(`semantic=${semanticSimilarity.toFixed(3)}`);

        // ML probability (optional/simulated)
        if (mlProbability > 0) {
            score += mlProbability * 10;
            tags.push(`ml=${mlProbability.toFixed(3)}`);
        }

        // Color matching
        if (parsedQuery.colors && parsedQuery.colors.length > 0) {
            const productColor = product.color || '';
            const name = (product.name || '').toLowerCase();
            const desc = (product.description || '').toLowerCase();

            let { matches, matchType } = this.colorMatcher.matches(
                productColor,
                parsedQuery.colors,
            );

            // Fallback: Check name and description if direct color field didn't match
            if (!matches) {
                for (const queryColor of parsedQuery.colors) {
                    const qc = queryColor.toLowerCase();
                    if (name.includes(qc) || desc.includes(qc)) {
                        matches = true;
                        matchType = 'similar'; // Treat text-based match as similar
                        break;
                    }
                }
            }

            if (matches) {
                if (matchType === 'exact') {
                    score += 25; // Increased boost
                    tags.push('color_exact');
                } else if (matchType === 'similar') {
                    score += 15;
                    tags.push('color_similar');
                }
            } else {
                // Only penalize if it's a clear mismatch (we'll be less punishing now)
                score -= 10;
                tags.push('color_neutral_or_mismatch');
            }
        }

        // Product type matching (Category/Type boost)
        if (parsedQuery.productTypes.length > 0) {
            const name = (product.name || '').toLowerCase();
            const category = (product.category || '').toLowerCase();
            const style = (product.style || '').toLowerCase();

            let typeMatched = false;
            for (const type of parsedQuery.productTypes) {
                const typeLower = type.toLowerCase();
                const typeRegex = new RegExp(`\\b${typeLower}\\b`, 'i');
                if (typeRegex.test(name) || typeRegex.test(category) || typeRegex.test(style)) {
                    typeMatched = true;
                    break;
                }
            }

            if (typeMatched) {
                score += 50;
                tags.push('product_type_match');
            }
        }

        // Material matching
        if (parsedQuery.materials && parsedQuery.materials.length > 0) {
            const productMaterial = (product.material || '').toLowerCase();
            for (const material of parsedQuery.materials) {
                const materialLower = material.toLowerCase();
                if (
                    productMaterial.includes(materialLower) ||
                    materialLower.includes(productMaterial)
                ) {
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
                if (
                    productStyle.includes(styleLower) ||
                    styleLower.includes(productStyle)
                ) {
                    score += 10;
                    tags.push('style_match');
                    break;
                }
            }
        }

        // Price range matching
        const productPrice =
            typeof product.price === 'number'
                ? product.price
                : parseFloat(product.price) || 0;
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
        // Soft constraints: We no longer discard items for color or type mismatches.
        // This ensures natural language prompts like "pink chair" show the best items
        // available even if the metadata is sparse.

        // Hard constraint: price must be within range if specified (if the user says "under 50k", we should respect it)
        const productPrice =
            typeof product.price === 'number'
                ? product.price
                : parseFloat(product.price) || 0;
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
