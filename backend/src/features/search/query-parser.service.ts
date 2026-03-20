import { Injectable } from '@nestjs/common';

export interface ParsedQuery {
    rawQuery: string;
    productTypes: string[];
    colors: string[];
    materials: string[];
    styles: string[];
    priceMin: number | null;
    priceMax: number | null;
}

@Injectable()
export class QueryParserService {
    private static readonly PRODUCT_TYPES: Record<string, string[]> = {
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

    private static readonly COLORS: Set<string> = new Set([
        'pink',
        'magenta',
        'fuchsia',
        'rose',
        'blush',
        'purple',
        'violet',
        'lavender',
        'plum',
        'grey',
        'gray',
        'silver',
        'charcoal',
        'black',
        'white',
        'cream',
        'ivory',
        'beige',
        'tan',
        'brown',
        'walnut',
        'oak',
        'teak',
        'blue',
        'navy',
        'cyan',
        'green',
        'olive',
        'red',
        'burgundy',
        'maroon',
        'yellow',
        'gold',
        'golden',
        'orange',
        'coral',
        'salmon',
        'clear',
        'transparent',
    ]);

    private static readonly MATERIALS: Set<string> = new Set([
        'wood',
        'wooden',
        'oak',
        'walnut',
        'teak',
        'metal',
        'metallic',
        'steel',
        'iron',
        'fabric',
        'cloth',
        'textile',
        'leather',
        'genuine leather',
        'velvet',
        'velvety',
        'glass',
        'tempered glass',
        'marble',
        'stone',
        'plastic',
        'acrylic',
        'engineered wood',
        'mdf',
    ]);

    private static readonly STYLES: Set<string> = new Set([
        'modern',
        'contemporary',
        'classic',
        'traditional',
        'minimalist',
        'minimal',
        'simple',
        'industrial',
        'scandinavian',
        'scandi',
        'nordic',
        'luxury',
        'premium',
        'elegant',
        'casual',
        'relaxed',
    ]);

    private productTypeLookup: Map<string, string>;

    constructor() {
        this.productTypeLookup = new Map<string, string>();
        for (const [canonical, variants] of Object.entries(
            QueryParserService.PRODUCT_TYPES,
        )) {
            for (const variant of variants) {
                this.productTypeLookup.set(variant.toLowerCase(), canonical);
            }
        }
    }

    public parse(query: string): ParsedQuery {
        const normalized = this.normalize(query);
        const tokens = normalized.split(/\s+/);

        const parsed: ParsedQuery = {
            rawQuery: query,
            productTypes: this.extractProductTypes(tokens, normalized),
            colors: this.extractColors(tokens),
            materials: this.extractMaterials(tokens, normalized),
            styles: this.extractStyles(tokens),
            ...this.extractPriceRange(normalized),
        };

        return parsed;
    }

    private normalize(text: string): string {
        text = text.toLowerCase().trim();
        text = text.replace(/[^\w\s-]/g, ' ');
        text = text.replace(/\s+/g, ' ');
        return text;
    }

    private extractProductTypes(tokens: string[], text: string): string[] {
        const found = new Set<string>();

        for (const token of tokens) {
            if (this.productTypeLookup.has(token)) {
                found.add(this.productTypeLookup.get(token)!);
            }
        }

        for (const [canonical, variants] of Object.entries(
            QueryParserService.PRODUCT_TYPES,
        )) {
            for (const variant of variants) {
                if (text.includes(variant)) {
                    found.add(canonical);
                }
            }
        }

        return Array.from(found);
    }

    private extractColors(tokens: string[]): string[] {
        const colors: string[] = [];
        for (const token of tokens) {
            if (QueryParserService.COLORS.has(token)) {
                colors.push(token);
            }
        }
        return colors;
    }

    private extractMaterials(tokens: string[], text: string): string[] {
        const materials: string[] = [];

        for (const material of [
            'engineered wood',
            'genuine leather',
            'tempered glass',
        ]) {
            if (text.includes(material)) {
                materials.push(material);
            }
        }

        for (const token of tokens) {
            if (
                QueryParserService.MATERIALS.has(token) &&
                !materials.includes(token)
            ) {
                materials.push(token);
            }
        }

        return materials;
    }

    private extractStyles(tokens: string[]): string[] {
        const styles: string[] = [];
        for (const token of tokens) {
            if (QueryParserService.STYLES.has(token)) {
                styles.push(token);
            }
        }
        return styles;
    }

    private extractPriceRange(text: string): {
        priceMin: number | null;
        priceMax: number | null;
    } {
        let priceMin: number | null = null;
        let priceMax: number | null = null;

        const underMatch = text.match(
            /(?:under|below|less than|max)\s+(\d+(?:,\d+)*)/,
        );
        if (underMatch) {
            priceMax = parseFloat(underMatch[1].replace(/,/g, ''));
        }

        const overMatch = text.match(
            /(?:over|above|more than|min)\s+(\d+(?:,\d+)*)/,
        );
        if (overMatch) {
            priceMin = parseFloat(overMatch[1].replace(/,/g, ''));
        }

        const betweenMatch = text.match(
            /between\s+(\d+(?:,\d+)*)\s+and\s+(\d+(?:,\d+)*)/,
        );
        if (betweenMatch) {
            priceMin = parseFloat(betweenMatch[1].replace(/,/g, ''));
            priceMax = parseFloat(betweenMatch[2].replace(/,/g, ''));
        }

        return { priceMin, priceMax };
    }
}
