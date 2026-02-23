import { Controller, Get, Param } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiNotFoundResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ProductService } from './product.service.js';

@ApiTags('Products')
@Controller('products')
export class ProductController {
  constructor(private readonly productService: ProductService) {}

  @Get()
  @ApiOperation({ summary: 'Get all products from Firestore' })
  @ApiOkResponse({ description: 'List of all products' })
  findAll() {
    return this.productService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a single product by document ID' })
  @ApiOkResponse({ description: 'The product with the given ID' })
  @ApiNotFoundResponse({ description: 'Product not found' })
  findOne(@Param('id') id: string) {
    return this.productService.findOne(id);
  }
}
