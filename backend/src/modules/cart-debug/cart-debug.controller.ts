import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { Request } from 'express';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard.js';
import { CartDebugService } from './cart-debug.service.js';

type AuthedRequest = Request & {
  user?: {
    uid: string;
    email: string | null;
  };
};

@ApiTags('Cart Debug')
@ApiBearerAuth('firebase-auth')
@UseGuards(FirebaseAuthGuard)
@Controller('cart-debug')
export class CartDebugController {
  constructor(private readonly cartDebugService: CartDebugService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get the current user cart payload as sent to Unity' })
  @ApiOkResponse({
    description: 'Current authenticated cart payload',
    schema: {
      type: 'object',
      properties: {
        uid: { type: 'string', example: 'firebase-uid' },
        email: { type: 'string', nullable: true, example: 'user@example.com' },
        cart: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string', example: 'product-123' },
              quantity: { type: 'number', example: 2 },
              furniture: { type: 'object', nullable: true, additionalProperties: true },
              updatedAt: { nullable: true },
            },
          },
        },
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  getMyCartDebug(@Req() req: AuthedRequest) {
    return this.cartDebugService.getUnityCartPayload(req.user!);
  }
}
