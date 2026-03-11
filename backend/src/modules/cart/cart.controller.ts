import { Body, Controller, Delete, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard.js';
import { CartService } from './cart.service.js';
import { CreateCartDto } from './dto/create-cart.dto.js';
import { UpdateCartItemDto } from './dto/update-cart.dto.js';

type AuthedRequest = Request & { user?: { uid: string } };

@ApiTags('Cart')
@ApiBearerAuth('firebase-auth')
@UseGuards(FirebaseAuthGuard)
@Controller('cart')
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Post()
  @ApiOperation({ summary: 'Create or replace a cart item for the authenticated user' })
  @ApiCreatedResponse({
    description: 'Cart item saved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', example: 'product-123' },
        quantity: { type: 'number', example: 2 },
        furniture: { type: 'object', nullable: true, additionalProperties: true },
        updatedAt: { nullable: true },
      },
      required: ['id', 'quantity'],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  create(@Req() req: AuthedRequest, @Body() dto: CreateCartDto) {
    return this.cartService.create(req.user!.uid, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all cart items for the authenticated user' })
  @ApiOkResponse({
    description: 'Current authenticated cart items',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', example: 'product-123' },
          quantity: { type: 'number', example: 2 },
          furniture: { type: 'object', nullable: true, additionalProperties: true },
          updatedAt: { nullable: true },
        },
        required: ['id', 'quantity'],
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  findAll(@Req() req: AuthedRequest) {
    return this.cartService.findAll(req.user!.uid);
  }

  @Get('me')
  @ApiOperation({ summary: 'Get the authenticated user cart' })
  @ApiOkResponse({
    description: 'Current authenticated cart items',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', example: 'product-123' },
          quantity: { type: 'number', example: 2 },
          furniture: { type: 'object', nullable: true, additionalProperties: true },
          updatedAt: { nullable: true },
        },
        required: ['id', 'quantity'],
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  getMyCart(@Req() req: AuthedRequest) {
    return this.cartService.getMyCart(req.user!.uid);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get one cart item for the authenticated user' })
  @ApiParam({ name: 'id', description: 'Cart item id', example: 'product-123' })
  @ApiOkResponse({
    description: 'Cart item found',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', example: 'product-123' },
        quantity: { type: 'number', example: 2 },
        furniture: { type: 'object', nullable: true, additionalProperties: true },
        updatedAt: { nullable: true },
      },
      required: ['id', 'quantity'],
    },
  })
  @ApiNotFoundResponse({ description: 'Cart item not found' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  async findOne(@Req() req: AuthedRequest, @Param('id') id: string) {
    return this.cartService.findOne(req.user!.uid, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a cart item for the authenticated user' })
  @ApiParam({ name: 'id', description: 'Cart item id', example: 'product-123' })
  @ApiOkResponse({
    description: 'Cart item updated successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', example: 'product-123' },
        quantity: { type: 'number', example: 3 },
        furniture: { type: 'object', nullable: true, additionalProperties: true },
        updatedAt: { nullable: true },
      },
      required: ['id', 'quantity'],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  update(
    @Req() req: AuthedRequest,
    @Param('id') id: string,
    @Body() dto: UpdateCartItemDto,
  ) {
    return this.cartService.update(req.user!.uid, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a cart item for the authenticated user' })
  @ApiParam({ name: 'id', description: 'Cart item id', example: 'product-123' })
  @ApiOkResponse({
    description: 'Cart item deleted successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', example: 'product-123' },
        deleted: { type: 'boolean', example: true },
      },
      required: ['id', 'deleted'],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  remove(@Req() req: AuthedRequest, @Param('id') id: string) {
    return this.cartService.remove(req.user!.uid, id);
  }
}
