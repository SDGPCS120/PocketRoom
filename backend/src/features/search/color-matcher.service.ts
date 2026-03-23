import { Injectable } from '@nestjs/common';

@Injectable()
export class ColorMatcherService {
    private static readonly COLOR_FAMILIES: Record<string, string[]> = {
        pink: ['pink', 'magenta', 'fuchsia', 'rose', 'blush', 'salmon', 'coral'],
        magenta: ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],
        fuchsia: ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],
        rose: ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],
        blush: ['pink', 'magenta', 'fuchsia', 'rose', 'blush'],

        purple: ['purple', 'violet', 'lavender', 'plum', 'magenta'],
        violet: ['purple', 'violet', 'lavender', 'plum'],
        lavender: ['purple', 'violet', 'lavender', 'plum'],
        plum: ['purple', 'violet', 'lavender', 'plum'],

        grey: ['grey', 'gray', 'silver', 'charcoal'],
        gray: ['grey', 'gray', 'silver', 'charcoal'],
        silver: ['grey', 'gray', 'silver'],
        charcoal: ['grey', 'gray', 'charcoal', 'black'],

        beige: ['beige', 'tan', 'cream', 'ivory', 'off-white'],
        tan: ['beige', 'tan', 'cream', 'brown'],
        cream: ['beige', 'tan', 'cream', 'ivory', 'white'],
        ivory: ['beige', 'cream', 'ivory', 'white'],

        brown: ['brown', 'tan', 'walnut', 'teak', 'oak'],
        walnut: ['brown', 'walnut', 'teak'],
        oak: ['brown', 'oak', 'tan', 'beige'],
        teak: ['brown', 'teak', 'walnut'],

        white: ['white', 'cream', 'ivory', 'off-white'],
        black: ['black', 'charcoal'],

        blue: ['blue', 'navy', 'cyan'],
        navy: ['blue', 'navy'],
        cyan: ['blue', 'cyan'],

        green: ['green', 'olive'],
        olive: ['green', 'olive'],

        red: ['red', 'burgundy', 'maroon'],
        burgundy: ['red', 'burgundy', 'maroon'],
        maroon: ['red', 'burgundy', 'maroon'],

        yellow: ['yellow', 'gold', 'golden'],
        gold: ['yellow', 'gold', 'golden'],
        golden: ['yellow', 'gold', 'golden'],

        orange: ['orange', 'coral', 'salmon'],
        coral: ['orange', 'coral', 'salmon', 'pink'],
        salmon: ['orange', 'coral', 'salmon', 'pink'],

        clear: ['clear', 'transparent'],
        transparent: ['clear', 'transparent'],
    };

    public expandColors(colors: string[]): Set<string> {
        const expanded = new Set<string>();

        for (const color of colors) {
            const colorLower = color.toLowerCase();
            if (ColorMatcherService.COLOR_FAMILIES[colorLower]) {
                for (const shade of ColorMatcherService.COLOR_FAMILIES[colorLower]) {
                    expanded.add(shade);
                }
            } else {
                expanded.add(colorLower);
            }
        }

        return expanded;
    }

    public matches(
        productColor: string,
        queryColors: string[],
    ): { matches: boolean; matchType: 'exact' | 'similar' | '' } {
        if (!queryColors || queryColors.length === 0) {
            return { matches: false, matchType: '' };
        }

        const productColorLower = productColor.toLowerCase().trim();
        if (!productColorLower) return { matches: false, matchType: '' };

        // Check for exact word matches
        for (const queryColor of queryColors) {
            const qc = queryColor.toLowerCase();
            if (productColorLower === qc || productColorLower.includes(qc)) {
                return { matches: true, matchType: 'exact' };
            }
        }

        // Check for similar shade matches (family words)
        const expanded = this.expandColors(queryColors);
        for (const shade of expanded) {
            if (productColorLower.includes(shade)) {
                return { matches: true, matchType: 'similar' };
            }
        }

        return { matches: false, matchType: '' };
    }

    public getColorFamily(color: string): string[] {
        const colorLower = color.toLowerCase();
        return ColorMatcherService.COLOR_FAMILIES[colorLower] || [colorLower];
    }
}
