import { ForbiddenException } from '@nestjs/common';
import type { Request } from 'express';
import type { AuthUser } from './auth-user.type';

export type AuthenticatedRequest = Request & { user: AuthUser };

export function isAdministrator(user: AuthUser): boolean {
  return Boolean(user.authUid && !user.isAnonymous && user.claims?.admin === true);
}

export function requireAdministrator(user: AuthUser): void {
  if (!isAdministrator(user)) throw new ForbiddenException('Administrator access required');
}
