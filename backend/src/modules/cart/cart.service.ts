import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { CreateCartDto, CartStatus } from './dto/create-cart.dto';
import { UpdateCartDto } from './dto/update-cart.dto';

type CartDoc = {
  id: string;
  userId: string;
  status: CartStatus;
  totalAmount: number;
  currency: string;
  isDeleted: boolean;
  createdAt: any;
  updatedAt: any;
  deletedAt?: any;
};

@Injectable()
export class CartService {
  private readonly colName = 'carts';

  constructor(private readonly firebaseService: FirebaseService) {}

  private col() {
    return this.firebaseService.firestore.collection(this.colName);
  }

  async create(dto: CreateCartDto) {
    // optional business rule: only one ACTIVE cart per user
    const activeCart = await this.col()
      .where('userId', '==', dto.userId)
      .where('status', '==', CartStatus.ACTIVE)
      .where('isDeleted', '==', false)
      .limit(1)
      .get();

    if (!activeCart.empty) {
      throw new ConflictException('User already has an active cart');
    }

    const ref = this.col().doc();

    const data: CartDoc = {
      id: ref.id,
      userId: dto.userId,
      status: dto.status ?? CartStatus.ACTIVE,
      totalAmount: dto.totalAmount ?? 0,
      currency: dto.currency ?? 'LKR',
      isDeleted: false,
      createdAt: this.firebaseService.fieldValue.serverTimestamp(),
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    await ref.set(data);

    const created = await ref.get();
    return created.data();
  }

  async findAll(userId?: string, status?: CartStatus) {
    let q = this.col().where('isDeleted', '==', false);

    if (userId) q = q.where('userId', '==', userId);
    if (status) q = q.where('status', '==', status);

    const snap = await q.get();
    return snap.docs.map((d) => d.data());
  }

  async findOne(id: string) {
    const ref = this.col().doc(id);
    const snap = await ref.get();

    if (!snap.exists) throw new NotFoundException('Cart not found');

    const data = snap.data() as any;
    if (data?.isDeleted) throw new NotFoundException('Cart not found');

    return data;
  }

  async update(id: string, dto: UpdateCartDto) {
    const ref = this.col().doc(id);
    const snap = await ref.get();

    if (!snap.exists) throw new NotFoundException('Cart not found');

    const current = snap.data() as any;
    if (current?.isDeleted) throw new NotFoundException('Cart not found');

    // optional business rule: if setting ACTIVE, user should not have another active cart
    if (dto.status === CartStatus.ACTIVE && current.status !== CartStatus.ACTIVE) {
      const activeCart = await this.col()
        .where('userId', '==', current.userId)
        .where('status', '==', CartStatus.ACTIVE)
        .where('isDeleted', '==', false)
        .limit(1)
        .get();

      const otherActiveExists = activeCart.docs.some((doc) => doc.id !== id);
      if (otherActiveExists) {
        throw new ConflictException('User already has another active cart');
      }
    }

    const updateData: any = {
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    if (dto.userId !== undefined) updateData.userId = dto.userId;
    if (dto.status !== undefined) updateData.status = dto.status;
    if (dto.totalAmount !== undefined) updateData.totalAmount = dto.totalAmount;
    if (dto.currency !== undefined) updateData.currency = dto.currency;

    await ref.update(updateData);

    const updated = await ref.get();
    return updated.data();
  }

  async remove(id: string) {
    await this.findOne(id);

    const ref = this.col().doc(id);
    await ref.update({
      isDeleted: true,
      deletedAt: this.firebaseService.fieldValue.serverTimestamp(),
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    });

    return { deleted: true, id };
  }
}