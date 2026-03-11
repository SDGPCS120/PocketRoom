import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';

type CartDoc = {
  quantity?: number;
  furniture?: Record<string, unknown>;
  updatedAt?: unknown;
};

@Injectable()
export class CartService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async getMyCart(userId: string) {
    const snapshot = await this.firebaseService.firestore
      .collection('users')
      .doc(userId)
      .collection('cart')
      .get();

    return snapshot.docs.map((doc) => {
      const data = (doc.data() as CartDoc | undefined) ?? {};
      return {
        id: doc.id,
        quantity: typeof data.quantity === 'number' ? data.quantity : 1,
        furniture:
          data.furniture && typeof data.furniture === 'object'
            ? data.furniture
            : null,
        updatedAt: data.updatedAt ?? null,
      };
    });
  }
}
