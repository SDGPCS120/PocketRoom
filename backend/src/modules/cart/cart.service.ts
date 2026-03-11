import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';
import { CreateCartDto } from './dto/create-cart.dto.js';
import { UpdateCartItemDto } from './dto/update-cart.dto.js';

type CartDoc = {
  quantity?: number;
  furniture?: Record<string, unknown>;
  updatedAt?: unknown;
};

@Injectable()
export class CartService {
  constructor(private readonly firebaseService: FirebaseService) {}

  private cartCollection(userId: string) {
    return this.firebaseService.firestore
      .collection('users')
      .doc(userId)
      .collection('cart');
  }

  private mapCartDoc(doc: FirebaseFirestore.QueryDocumentSnapshot | FirebaseFirestore.DocumentSnapshot) {
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
  }

  async create(userId: string, dto: CreateCartDto) {
    const docRef = this.cartCollection(userId).doc(dto.id);
    const payload = {
      quantity: dto.quantity ?? 1,
      furniture:
        dto.furniture && typeof dto.furniture === 'object'
          ? dto.furniture
          : null,
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    await docRef.set(payload, { merge: true });
    const snapshot = await docRef.get();
    return this.mapCartDoc(snapshot);
  }

  async findAll(userId: string) {
    const snapshot = await this.cartCollection(userId).get();
    return snapshot.docs.map((doc) => this.mapCartDoc(doc));
  }

  async getMyCart(userId: string) {
    return this.findAll(userId);
  }

  async findOne(userId: string, id: string) {
    const snapshot = await this.cartCollection(userId).doc(id).get();
    if (!snapshot.exists) {
      return null;
    }

    return this.mapCartDoc(snapshot);
  }

  async update(userId: string, id: string, dto: UpdateCartItemDto) {
    const docRef = this.cartCollection(userId).doc(id);
    const payload: CartDoc = {
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    if (dto.quantity !== undefined) {
      payload.quantity = dto.quantity;
    }

    if (dto.furniture !== undefined) {
      payload.furniture =
        dto.furniture && typeof dto.furniture === 'object'
          ? dto.furniture
          : undefined;
    }

    await docRef.set(payload, { merge: true });
    const snapshot = await docRef.get();
    return this.mapCartDoc(snapshot);
  }

  async remove(userId: string, id: string) {
    await this.cartCollection(userId).doc(id).delete();
    return { id, deleted: true };
  }
}
