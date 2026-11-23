import { Controller, Get, Post, Body, HttpStatus, HttpCode, Req, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../../modules/auth/guards/firebase-auth.guard';
import { requireAdministrator, type AuthenticatedRequest } from '../../modules/auth/types/authenticated-request';
import { SearchService } from './search.service';

@Controller('search')
export class SearchController {
    constructor(private readonly searchService: SearchService) { }

    @Get('health')
    getHealth() {
        return this.searchService.getHealth();
    }

    @Post()
    @HttpCode(HttpStatus.OK)
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
    @UseGuards(FirebaseAuthGuard)
    async reloadProducts(@Req() request: AuthenticatedRequest) {
        requireAdministrator(request.user);
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
