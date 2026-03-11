import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import {
  PaymentStatus,
  UpdatePaymentStatusDto,
} from './dto/update-payment-status.dto';
import { OrderStatus } from '../order/dto/create-order.dto';

@Injectable()
export class PaymentService {
  constructor(private readonly firebase: FirebaseService) {}

  private paymentCollection() {
    return this.firebase.firestore.collection('payments');
  }

  private orderCollection() {
    return this.firebase.firestore.collection('orders');
  }

  async createPayment(userId: string, dto: CreatePaymentDto) {
    const orderDoc = await this.orderCollection().doc(dto.orderId).get();

    if (!orderDoc.exists) {
      throw new NotFoundException('Order not found');
    }

    const docRef = this.paymentCollection().doc();

    const data = {
      paymentId: docRef.id,
      orderId: dto.orderId,
      customerId: userId,
      amount: dto.amount,
      currency: dto.currency ?? 'LKR',
      paymentMethod: dto.paymentMethod,
      paymentStatus: PaymentStatus.PENDING,
      transactionReference: null,
      paidAt: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    try {
      await docRef.set(data);
      return data;
    } catch (error) {
      throw new InternalServerErrorException('Failed to create payment');
    }
  }

  async getAllPayments() {
    const snapshot = await this.paymentCollection()
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => doc.data());
  }

  async getPaymentById(paymentId: string) {
    const doc = await this.paymentCollection().doc(paymentId).get();

    if (!doc.exists) {
      throw new NotFoundException('Payment not found');
    }

    return doc.data();
  }

  async getPaymentsByUser(userId: string) {
    const snapshot = await this.paymentCollection()
      .where('customerId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => doc.data());
  }

  async getPaymentByOrderId(orderId: string) {
    const snapshot = await this.paymentCollection()
      .where('orderId', '==', orderId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      throw new NotFoundException('Payment not found for this order');
    }

    return snapshot.docs[0].data();
  }

  async updatePaymentStatus(paymentId: string, dto: UpdatePaymentStatusDto) {
    const paymentRef = this.paymentCollection().doc(paymentId);
    const paymentDoc = await paymentRef.get();

    if (!paymentDoc.exists) {
      throw new NotFoundException('Payment not found');
    }

    const paymentData = paymentDoc.data()!;
    const updateData: any = {
      paymentStatus: dto.paymentStatus,
      updatedAt: new Date(),
    };

    if (dto.transactionReference !== undefined) {
      updateData.transactionReference = dto.transactionReference;
    }

    if (dto.paymentStatus === PaymentStatus.SUCCESS) {
      updateData.paidAt = new Date();
    }

    try {
      await paymentRef.update(updateData);

      if (dto.paymentStatus === PaymentStatus.SUCCESS) {
        await this.orderCollection().doc(paymentData.orderId).update({
          orderStatus: OrderStatus.CONFIRMED,
          updatedAt: new Date(),
        });
      }

      if (
        dto.paymentStatus === PaymentStatus.FAILED ||
        dto.paymentStatus === PaymentStatus.CANCELLED
      ) {
        await this.orderCollection().doc(paymentData.orderId).update({
          orderStatus: OrderStatus.CANCELLED,
          updatedAt: new Date(),
        });
      }

      const updatedDoc = await paymentRef.get();
      return updatedDoc.data();
    } catch (error) {
      throw new InternalServerErrorException('Failed to update payment status');
    }
  }

  async deletePayment(paymentId: string) {
    const docRef = this.paymentCollection().doc(paymentId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException('Payment not found');
    }

    try {
      await docRef.delete();
      return { message: 'Payment deleted successfully' };
    } catch (error) {
      throw new InternalServerErrorException('Failed to delete payment');
    }
  }
}