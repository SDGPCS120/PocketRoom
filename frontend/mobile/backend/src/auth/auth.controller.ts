import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard';

@Controller('auth')
export class AuthController {
  constructor() {
    console.log('AuthController registered');
  }

  @Get('me')
  @UseGuards(FirebaseAuthGuard)
  me(@Req() req: Request & { user?: unknown }) {
    return req.user ?? null;
  }
}
