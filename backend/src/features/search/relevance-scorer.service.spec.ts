import { ColorMatcherService } from './color-matcher.service';
import { ParsedQuery } from './query-parser.service';
import { RelevanceScorerService } from './relevance-scorer.service';

describe('RelevanceScorerService', () => {
    let service: RelevanceScorerService;

    const whiteSofaQuery: ParsedQuery = {
        rawQuery: 'white sofa',
        productTypes: ['sofa'],
        colors: ['white'],
        materials: [],
        styles: [],
        priceMin: null,
        priceMax: null,
    };

    beforeEach(() => {
        service = new RelevanceScorerService(new ColorMatcherService());
    });

    it('excludes a white desk from a white sofa query', () => {
        expect(
            service.shouldInclude(
                {
                    name: 'Minimal White Desk',
                    category: 'desk',
                    furnitureType: 'desk',
                    color: 'white',
                },
                whiteSofaQuery,
            ),
        ).toBe(false);
    });

    it('excludes a non-white sofa from a white sofa query', () => {
        expect(
            service.shouldInclude(
                {
                    name: 'Blue Sofa',
                    category: 'sofa',
                    furnitureType: 'sofa',
                    color: 'blue',
                },
                whiteSofaQuery,
            ),
        ).toBe(false);
    });

    it('includes an exact white sofa match', () => {
        expect(
            service.shouldInclude(
                {
                    name: 'White Sofa',
                    category: 'sofa',
                    furnitureType: 'sofa',
                    color: 'white',
                },
                whiteSofaQuery,
            ),
        ).toBe(true);
    });

    it('includes sofa variants with matching color options', () => {
        expect(
            service.shouldInclude(
                {
                    name: 'Cloud Couch',
                    category: 'living room',
                    furnitureType: 'couch',
                    color: 'blue',
                    colors: ['blue', 'ivory'],
                },
                whiteSofaQuery,
            ),
        ).toBe(true);
    });

    it('does not apply type or color filtering when the query is broad', () => {
        expect(
            service.shouldInclude(
                {
                    name: 'Minimal White Desk',
                    category: 'desk',
                    furnitureType: 'desk',
                    color: 'white',
                },
                { ...whiteSofaQuery, rawQuery: 'furniture', productTypes: [], colors: [] },
            ),
        ).toBe(true);
    });
});
