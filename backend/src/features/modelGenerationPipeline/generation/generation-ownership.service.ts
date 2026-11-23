import { ForbiddenException, HttpException, HttpStatus, Injectable, NotFoundException } from '@nestjs/common';
import type { firestore } from 'firebase-admin';
import { createHash } from 'node:crypto';
import { FirebaseService } from '../../../firebase/firebase.service.js';

export type GenerationRequest = {
  productId: string;
  sellerId: string;
  requestId: string;
};

@Injectable()
export class GenerationOwnershipService {
  constructor(private readonly firebase: FirebaseService) {}

  withOwnedProduct<T>(
    productId: string,
    sellerId: string,
    action: (transaction: firestore.Transaction, product: firestore.DocumentSnapshot) => T | Promise<T>,
  ): Promise<T> {
    const db = this.firebase.firestore;
    return db.runTransaction(async (transaction) => {
      const product = await transaction.get(db.collection('products').doc(productId));
      if (!product.exists) {
        throw new NotFoundException('Product not found');
      }
      const storeId: unknown = product.get('storeId');
      if (typeof storeId !== 'string' || !storeId || storeId.includes('/')) {
        throw new ForbiddenException('Product is not owned by your store');
      }
      const store = await transaction.get(db.collection('stores').doc(storeId));
      if (!store.exists || store.get('sellerId') !== sellerId) {
        throw new ForbiddenException('Product is not owned by your store');
      }
      return action(transaction, product);
    });
  }

  async admit(request: GenerationRequest): Promise<void> {
    const day = new Date().toISOString().slice(0, 10);
    const db = this.firebase.firestore;
    await this.withOwnedProduct(request.productId, request.sellerId, async (transaction, product) => {
      const sellerKey = createHash('sha256').update(request.sellerId).digest('hex');
      const sellerRef = db.collection('generation-quotas').doc(`seller_${day}_${sellerKey}`);
      const globalRef = db.collection('generation-quotas').doc(`global_${day}`);
      const [sellerQuota, globalQuota] = await Promise.all([
        transaction.get(sellerRef), transaction.get(globalRef),
      ]);
      const sellerCount = Number(sellerQuota.get('count') ?? 0);
      const globalCount = Number(globalQuota.get('count') ?? 0);
      if (sellerCount >= 5 || globalCount >= 100) {
        throw new HttpException('Model generation quota reached for today', HttpStatus.TOO_MANY_REQUESTS);
      }
      const requestedAt = product.get('generationRequestedAt');
      if (product.get('modelStatus') === 'processing'
          && typeof requestedAt === 'number' && Date.now() - requestedAt < 15 * 60 * 1000) {
        throw new HttpException('A model is already being generated for this product', HttpStatus.CONFLICT);
      }
      transaction.set(sellerRef, { count: sellerCount + 1 }, { merge: true });
      transaction.set(globalRef, { count: globalCount + 1 }, { merge: true });
      transaction.update(product.ref, {
        generationRequestId: request.requestId,
        generationRequestedAt: Date.now(),
        modelStatus: 'processing',
        modelError: null,
        updatedAt: new Date(),
      });
    });
  }

  async updateCurrent(
    request: GenerationRequest,
    changes?: Record<string, unknown>,
  ): Promise<boolean> {
    try {
      return await this.withOwnedProduct(request.productId, request.sellerId, (transaction, product) => {
        if (product.get('generationRequestId') !== request.requestId || product.get('modelStatus') !== 'processing') {
          return false;
        }
        if (changes) transaction.update(product.ref, changes);
        return true;
      });
    } catch (error) {
      if (error instanceof ForbiddenException || error instanceof NotFoundException) return false;
      throw error;
    }
  }
}
