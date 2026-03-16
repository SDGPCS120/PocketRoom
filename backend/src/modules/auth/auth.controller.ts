import { Controller, Get, Req, UseGuards, Query } from '@nestjs/common';
import { Request } from 'express';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiQuery,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard';
import { AuthService, UserRole } from './auth.service';
import { AuthUser } from './types/auth-user.type';

type AuthedRequest = Request & { user?: AuthUser };

@ApiTags('Auth')
@ApiBearerAuth('firebase-auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('me')
  @UseGuards(FirebaseAuthGuard)
  @ApiOperation({ summary: 'Get currently authenticated Firebase user' })
  @ApiOkResponse({
    description: 'Decoded Firebase user payload attached by auth guard',
    schema: {
      type: 'object',
      properties: {
        uid: { type: 'string', example: 'firebase-uid-123' },
        email: { type: 'string', nullable: true, example: 'user@example.com' },
        isAnonymous: { type: 'boolean', example: false },
        claims: {
          type: 'object',
          additionalProperties: true,
          example: { aud: 'project-id', sub: 'firebase-uid-123' },
        },
      },
      required: ['uid'],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  me(@Req() req: AuthedRequest) {
    return req.user ?? null;
  }

  @Get('sync')
  @UseGuards(FirebaseAuthGuard)
  @ApiOperation({
    summary: 'Sync authenticated user into Firestore users collection',
  })
  @ApiQuery({ name: 'role', required: false, enum: ['customer', 'vendor'] })
  @ApiOkResponse({
    description: 'User was created or already existed in Firestore',
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string', enum: ['created', 'exists'] },
        user: {
          type: 'object',
          properties: {
            uid: { type: 'string', example: 'firebase-uid-123' },
            email: {
              type: 'string',
              nullable: true,
              example: 'user@example.com',
            },
            role: {
              type: 'string',
              enum: ['anonymous', 'customer', 'vendor'],
              example: 'customer',
            },
          },
          required: ['uid', 'email', 'role'],
        },
      },
      required: ['status', 'user'],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  sync(@Req() req: AuthedRequest, @Query('role') role?: string) {
    const u = req.user;
    if (!u) return { status: 'error', message: 'No user on request' };

    const requestedRole = (role === 'vendor' || role === 'customer') ? role as UserRole : undefined;

    return this.authService.syncUser(u.uid, u.email ?? null, u.isAnonymous ?? false, requestedRole);
  }
}
