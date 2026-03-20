import { Module } from '@nestjs/common';
import { SearchController } from './search.controller';
import { SearchService } from './search.service';
import { QueryParserService } from './query-parser.service';
import { ColorMatcherService } from './color-matcher.service';
import { RelevanceScorerService } from './relevance-scorer.service';
import { ProductLoaderService } from './product-loader.service';
import { FirebaseService } from './firebase.service';

@Module({
    controllers: [SearchController],
    providers: [
        SearchService,
        QueryParserService,
        ColorMatcherService,
        RelevanceScorerService,
        ProductLoaderService,
        FirebaseService,
    ],
    exports: [SearchService],
})
export class SearchModule { }
