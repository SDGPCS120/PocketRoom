import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import { FirebaseService } from '../../../firebase/firebase.service.js';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private readonly firebaseService: FirebaseService) { }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request & { user?: any }>();

    const authHeader = req.headers['authorization'];
    if (!authHeader || Array.isArray(authHeader)) {
      throw new UnauthorizedException('Missing Authorization header');
    }

    const match = authHeader.match(/^Bearer (.+)$/);
    if (!match) throw new UnauthorizedException('Expected: Bearer <token>');

    const token = match[1];

    try {
      const decoded = await this.firebaseService.auth.verifyIdToken(token);

      // Attach decoded user to request
      req.user = {
        uid: decoded.uid,
        email: decoded.email ?? null,
        claims: decoded as unknown as Record<string, unknown>,
      };

      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired Firebase token');
    }
  }
}
