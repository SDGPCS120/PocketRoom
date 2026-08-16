import { Injectable } from '@nestjs/common';
import { ColorMatcherService } from './color-matcher.service';
import { ParsedQuery } from './query-parser.service';

@Injectable()
export class RelevanceScorerService {
    private static readonly PRODUCT_TYPE_TERMS: Record<string, string[]> = {
        chair: ['chair', 'chairs', 'seating', 'seat', 'armchair', 'armchairs', 'stool', 'stools'],
        sofa: ['sofa', 'sofas', 'couch', 'couches', 'loveseat', 'loveseats', 'sectional', 'sectionals'],
        table: ['table', 'tables', 'dining table', 'coffee table', 'console table', 'side table', 'nightstand'],
        desk: ['desk', 'desks', 'workstation', 'workstations', 'study desk', 'office desk'],
        bed: ['bed', 'beds', 'bedframe', 'bedframes', 'mattress'],
        storage: [
            'storage',
            'shelf',
            'shelves',
            'bookshelf',
            'bookshelves',
            'cabinet',
            'cabinets',
            'wardrobe',
            'wardrobes',
            'console',
            'dresser',
            'chest',
        ],
        decor: ['decor', 'decoration', 'rug', 'rugs', 'lamp', 'lamps', 'mirror', 'mirrors'],
    };

    constructor(private readonly colorMatcher: ColorMatcherService) { }

    private normalize(value: unknown): string {
        return String(value || '')
            .toLowerCase()
            .replace(/[^\w\s-]/g, ' ')
            .replace(/\s+/g, ' ')
            .trim();
    }

    private containsTerm(text: string, term: string): boolean {
        const normalizedText = this.normalize(text);
        const normalizedTerm = this.normalize(term);
        if (!normalizedText || !normalizedTerm) {
            return false;
        }

        const escaped = normalizedTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        return new RegExp(`(^|\\s)${escaped}(\\s|$)`, 'i').test(normalizedText);
    }

    private getProductColorValues(product: any): string[] {
        const values: string[] = [];

        if (product.color) {
            values.push(String(product.color));
        }

        if (Array.isArray(product.colors)) {
            for (const color of product.colors) {
                if (color) {
                    values.push(String(color));
                }
            }
        }

        return [...new Set(values.map((value) => value.trim()).filter(Boolean))];
    }

    private productMatchesColor(
        product: any,
        queryColors: string[],
    ): { matches: boolean; matchType: 'exact' | 'similar' | '' } {
        let bestMatch: { matches: boolean; matchType: 'exact' | 'similar' | '' } = {
            matches: false,
            matchType: '',
        };

        for (const productColor of this.getProductColorValues(product)) {
            const match = this.colorMatcher.matches(productColor, queryColors);
            if (match.matchType === 'exact') {
                return match;
            }
            if (match.matches) {
                bestMatch = match;
            }
        }

        if (bestMatch.matches) {
            return bestMatch;
        }

        const searchableText = `${product.name || ''} ${product.description || ''}`;
        for (const queryColor of queryColors) {
            if (this.containsTerm(searchableText, queryColor)) {
                return { matches: true, matchType: 'similar' };
            }
        }

        return bestMatch;
    }

    private productMatchesType(product: any, productTypes: string[]): boolean {
        const searchableText = [
            product.name,
            product.category,
            product.furnitureType,
            product.type,
            product.style,
        ].join(' ');

        for (const productType of productTypes) {
            const terms =
                RelevanceScorerService.PRODUCT_TYPE_TERMS[productType.toLowerCase()] ||
                [productType];

            if (terms.some((term) => this.containsTerm(searchableText, term))) {
                return true;
            }
        }

        return false;
    }

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
            const { matches, matchType } = this.productMatchesColor(
                product,
                parsedQuery.colors,
            );

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
            if (this.productMatchesType(product, parsedQuery.productTypes)) {
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
        if (
            parsedQuery.productTypes.length > 0 &&
            !this.productMatchesType(product, parsedQuery.productTypes)
        ) {
            return false;
        }

        if (parsedQuery.colors && parsedQuery.colors.length > 0) {
            const { matches } = this.productMatchesColor(product, parsedQuery.colors);
            if (!matches) {
                return false;
            }
        }

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
