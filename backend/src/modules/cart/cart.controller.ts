import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard.js';
import { CartService } from './cart.service.js';

type AuthedRequest = Request & { user?: { uid: string } };

@ApiTags('Cart')
@ApiBearerAuth('firebase-auth')
@UseGuards(FirebaseAuthGuard)
@Controller('cart')
export class CartController {
  constructor(private readonly cartService: CartService) {}

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
}
