import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ProductLoaderService } from './product-loader.service';
import { QueryParserService } from './query-parser.service';
import { ColorMatcherService } from './color-matcher.service';
import { RelevanceScorerService } from './relevance-scorer.service';

// Import only TF-IDF to avoid loading natural's ESM-only sentiment dependencies under ts-node.
import TfIdf = require('natural/lib/natural/tfidf/tfidf');

@Injectable()
export class SearchService implements OnModuleInit {
    private readonly logger = new Logger(SearchService.name);
    private products: any[] = [];
    private docs: string[] = [];
    private tfidf = new TfIdf();

    private readonly STOP_WORDS = new Set([
        'i',
        'want',
        'a',
        'an',
        'the',
        'to',
        'for',
        'with',
        'need',
        'looking',
        'please',
        'show',
        'me',
        'some',
        'any',
        'of',
        'and',
        'or',
        'that',
        'this',
        'give',
    ]);

    private readonly SYNONYMS: Record<string, string[]> = {
        magenta: ['pink', 'fuchsia', 'purple'],
        fuchsia: ['magenta', 'pink', 'purple'],
        couch: ['sofa'],
        sofa: ['couch'],
        grey: ['gray'],
        gray: ['grey'],
        shelf: ['shelves', 'bookshelf', 'bookcase'],
        shelves: ['shelf', 'bookshelf', 'bookcase'],
        bookshelf: ['shelf', 'shelves', 'bookcase'],
        bookcase: ['shelf', 'shelves', 'bookshelf'],
    };

    constructor(
        private readonly productLoader: ProductLoaderService,
        private readonly queryParser: QueryParserService,
        private readonly colorMatcher: ColorMatcherService,
        private readonly relevanceScorer: RelevanceScorerService,
    ) { }

    async onModuleInit() {
        try {
            await this.rebuildSearchIndex();
        } catch (error) {
            const message =
                error instanceof Error ? error.message : 'Unknown startup error';
            this.logger.error(`Failed to build initial search index: ${message}`);
            this.products = [];
            this.docs = [];
            this.tfidf = new TfIdf();
        }
    }

    async rebuildSearchIndex() {
        this.products = await this.productLoader.loadProductsFromFirestore();
        this.docs = this.products.map((p) => this.getProductDoc(p));

        this.tfidf = new TfIdf();
        this.docs.forEach((doc) => this.tfidf.addDocument(doc));

        this.logger.log(`Loaded ${this.products.length} products from Firestore`);
    }

    private getProductDoc(p: any): string {
        const dims = p.dimensions_cm || {};
        const parts = [
            String(p.name || ''),
            String(p.color || ''),
            String(p.material || ''),
            String(p.style || ''),
            String(p.description || ''),
            String(p.brand || ''),
            `rating ${p.rating || ''}`,
            `price ${p.price || ''}`,
            `dimensions ${dims.l || ''} ${dims.w || ''} ${dims.h || ''}`,
        ];

        return parts.join(' ').trim();
    }

    private getQuerySimilarities(query: string): number[] {
        const similarities: number[] = new Array(this.products.length).fill(0);
        this.tfidf.tfidfs(query, (i: any, measure: any) => {
            similarities[i] = measure;
        });

        const max = Math.max(...similarities) || 1;
        return similarities.map((score) => score / max);
    }

    private normalize(s: string): string {
        let str = s.toLowerCase().trim();
        str = str.replace(/[^a-z0-9\s-]/g, ' ');
        str = str.replace(/\s+/g, ' ');
        return str;
    }

    private keywordsFromQuery(q: string): string[] {
        const tokens = this.normalize(q)
            .split(/\s+/)
            .filter((t) => t && !this.STOP_WORDS.has(t));
        const expanded: string[] = [];

        for (const t of tokens) {
            expanded.push(t);
            if (this.SYNONYMS[t]) {
                expanded.push(...this.SYNONYMS[t]);
            }
        }

        return [...new Set(expanded)];
    }

    private heuristicMLProbability(
        queryKw: string[],
        p: any,
        sim: number,
    ): number {
        const col = this.normalize(String(p.color || ''));
        const mat = this.normalize(String(p.material || ''));
        const sty = this.normalize(String(p.style || ''));

        const colorHit = queryKw.includes(col) ? 1.0 : 0.0;
        const matHit = queryKw.includes(mat) ? 1.0 : 0.0;
        const styHit = queryKw.includes(sty) ? 1.0 : 0.0;

        let score = sim * 2.0 + colorHit * 1.0 + matHit * 0.5 + styHit * 0.5;
        return Math.min(Math.max(score / 5.0, 0), 1);
    }

    async search(query: string, topK: number = 10, debug: boolean = false) {
        const parsed = this.queryParser.parse(query);

        const filteredProducts: any[] = [];
        const filteredIndices: number[] = [];

        for (let idx = 0; idx < this.products.length; idx++) {
            const p = this.products[idx];
            if (this.relevanceScorer.shouldInclude(p, parsed)) {
                filteredProducts.push(p);
                filteredIndices.push(idx);
            }
        }

        if (filteredProducts.length === 0) {
            const response: any = {
                query: query,
                semantic_mode: 'tfidf_ts_nest',
                count: 0,
                results: [],
            };

            if (debug) {
                response.debug = {
                    parsed,
                    filtered_count: 0,
                    total_products: this.products.length,
                    message: 'No products match all constraints',
                };
            }
            return response;
        }

        const qkw = this.keywordsFromQuery(query);
        const semanticQuery = qkw.length > 0 ? qkw.join(' ') : query;
        const allSims = this.getQuerySimilarities(semanticQuery);

        const scored: Array<{ score: number; p: any; tags: string[] }> = [];

        for (let i = 0; i < filteredProducts.length; i++) {
            const p = filteredProducts[i];
            const originalIdx = filteredIndices[i];
            const sim = allSims[originalIdx] || 0;

            const mlProba = this.heuristicMLProbability(qkw, p, sim);
            const { score: relevanceScore, tags } = this.relevanceScorer.score(
                p,
                parsed,
                sim,
                mlProba,
            );

            scored.push({ score: relevanceScore, p, tags });
        }

        scored.sort((a, b) => b.score - a.score);
        const top = scored.filter((item) => item.score > 0).slice(0, topK);

        const response: any = {
            query: query,
            semantic_mode: 'tfidf_ts_nest',
            count: top.length,
            results: top.map((item) => ({
                score: parseFloat(item.score.toFixed(4)),
                matchedTags: item.tags,
                product: item.p,
            })),
        };

        if (debug) {
            response.debug = {
                parsed,
                filtered_count: filteredProducts.length,
                total_products: this.products.length,
            };
        }

        return response;
    }

    getProducts() {
        return this.products.map((p) => ({
            name: p.name,
            style: p.style,
            color: p.color,
            furnitureType: p.furnitureType,
            searchDoc: this.getProductDoc(p),
        }));
    }

    getHealth() {
        return {
            status: 'ok',
            items: this.products.length,
            semantic_mode: 'tfidf_ts_nest',
            debug: {
                cwd: process.cwd(),
                dirname: __dirname,
                node_version: process.version,
            }
        };
    }
}
