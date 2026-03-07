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
  constructor(private readonly firebaseService: FirebaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<
      Request & {
        user?: {
          uid: string;
          email: string | null;
          claims: Record<string, unknown>;
          isAnonymous: boolean;
        };
      }
    >();

    const authHeader = req.headers['authorization'];
    if (!authHeader || Array.isArray(authHeader)) {
      throw new UnauthorizedException('Missing Authorization header');
    }

    const match = authHeader.match(/^Bearer (.+)$/);
    if (!match) throw new UnauthorizedException('Expected: Bearer <token>');

    const token = match[1];

    try {
      const decoded = await this.firebaseService.auth.verifyIdToken(token);
      const signInProvider =
        typeof decoded.firebase?.sign_in_provider === 'string'
          ? decoded.firebase.sign_in_provider
          : null;

      // Attach decoded user to request
      req.user = {
        uid: decoded.uid,
        email: decoded.email ?? null,
        claims: decoded as unknown as Record<string, unknown>,
        isAnonymous: signInProvider === 'anonymous',
      };

      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired Firebase token');
    }
  }
}
