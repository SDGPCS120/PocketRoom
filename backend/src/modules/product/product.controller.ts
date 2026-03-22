import {
    Body,
    Controller,
    Delete,
    Get,
    Param,
    Post,
    Put,
    Req,
    UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ProductService } from './product.service';

@Controller('products')
export class ProductController {
    constructor(private readonly productService: ProductService) { }

    // @UseGuards(FirebaseAuthGuard)
    @Post('/store/:storeId')
    createProduct(
        @Param('storeId') storeId: string,
        @Req() req: Request & { user?: { uid: string } },
        @Body() dto: CreateProductDto,
    ) {
        const sellerId = (req.headers['x-user-id'] as string) || (req.user ? req.user.uid : 'N0SSwkE6JuP5IRIUu5wwEcXsWfa2');

        return this.productService.createProduct(storeId, sellerId, dto);
    }

    @Get('store/:storeId')
    getProductsByStore(@Param('storeId') storeId: string) {
        return this.productService.getProductsByStore(storeId);
    }

    @Get()
    getAllProducts() {
        return this.productService.getAllProducts();
    }

    @Get(':id')
    getProductById(@Param('id') productId: string) {
        return this.productService.getProductById(productId);
    }

    @UseGuards(FirebaseAuthGuard)
    @Put(':id')
    updateProduct(
        @Param('id') productId: string,
        @Req() req: Request & { user?: { uid: string } },
        @Body() dto: UpdateProductDto,
    ) {
        const sellerId = req.user!.uid;

        return this.productService.updateProduct(productId, sellerId, dto);
    }

    @UseGuards(FirebaseAuthGuard)
    @Delete(':id')
    deleteProduct(
        @Param('id') productId: string,
        @Req() req: Request & { user?: { uid: string } },
    ) {
        const sellerId = req.user!.uid;

        return this.productService.deleteProduct(productId, sellerId);
    }
}