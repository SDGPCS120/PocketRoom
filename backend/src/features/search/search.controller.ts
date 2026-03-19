import { Controller, Get, Post, Body, Query, Res, HttpStatus } from '@nestjs/common';
import { SearchService } from './search.service';

@Controller('search')
export class SearchController {
    constructor(private readonly searchService: SearchService) { }

    @Get('health')
    getHealth() {
        return this.searchService.getHealth();
    }

    @Post()
    async search(
        @Body('query') query: string,
        @Body('top_k') topK?: number,
        @Body('debug') debug?: boolean,
    ) {
        if (!query || typeof query !== 'string') {
            return { error: 'Query is required' };
        }
        return await this.searchService.search(query, topK, debug);
    }

    @Post('reload')
    async reloadProducts() {
        try {
            await this.searchService.rebuildSearchIndex();
            return {
                message: 'Products reloaded successfully',
            };
        } catch (error) {
            return { error: 'Failed to reload products' };
        }
    }

    @Get('products')
    getProducts() {
        return this.searchService.getProducts();
    }
}
