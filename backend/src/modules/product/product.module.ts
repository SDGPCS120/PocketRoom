import { Module } from '@nestjs/common';
import { ProductController } from './product.controller';
import { ProductService } from './product.service';
import { StoreService } from '../store/store.service';

@Module({
    controllers: [ProductController],
    providers: [ProductService, StoreService],
    exports: [ProductService],
})
export class ProductModule { }