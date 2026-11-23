import { BadRequestException, NotFoundException, UnauthorizedException } from '@nestjs/common';
import type { AuthUser } from '../auth/types/auth-user.type';

export const CATALOG_PRICING = 'catalog-v1';
export const FULFILLMENTS_COLLECTION = 'orderFulfillments';

export function authenticatedUid(actor: AuthUser): string {
  if (!actor.authUid) throw new UnauthorizedException();
  return actor.authUid;
}

export function requireCustomer(actor: AuthUser, order: FirebaseFirestore.DocumentData | undefined): void {
  const authUid = authenticatedUid(actor);
  const ownerMatches = order?.customerAuthUid !== undefined
    ? order.customerAuthUid === authUid
    : order?.customerId === actor.uid || order?.customerId === authUid;
  if (!order || !ownerMatches) throw new NotFoundException('Order not found');
}

export function requireDocumentId(id: string) {
  if (typeof id !== 'string' || !id || id === '.' || id === '..' || id.includes('/') || Buffer.byteLength(id) > 1500) {
    throw new BadRequestException('Invalid record identifier');
  }
  return id;
}
