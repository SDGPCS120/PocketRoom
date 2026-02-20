import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard';
import { AuthService } from './auth.service';
import { AuthUser } from './types/auth-user.type';

type AuthedRequest = Request & { user?: AuthUser };

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('me')
  @UseGuards(FirebaseAuthGuard)
  me(@Req() req: AuthedRequest) {
    return req.user ?? null;
  }

  @Get('sync')
  @UseGuards(FirebaseAuthGuard)
  sync(@Req() req: AuthedRequest) {
    const u = req.user;
    if (!u) return { status: 'error', message: 'No user on request' };

    // Return the Promise directly (no need for async/await)
    return this.authService.syncUser(u.uid, u.email ?? null);
  }
}
