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

      let userUid = decoded.uid;

      // Look up if this user has a meaningful ID (authUid points to their Firebase UID)
      try {
        const snap = await this.firebaseService.firestore
          .collection('users')
          .where('authUid', '==', decoded.uid)
          .limit(1)
          .get();

        if (!snap.empty) {
          userUid = snap.docs[0].id;
        }
      } catch (err) {
        // Fallback to raw firebase uid
      }

      // Attach decoded user to request
      req.user = {
        uid: userUid,
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
