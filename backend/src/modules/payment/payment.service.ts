import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { generateMeaningfulId } from '../../common/utils/generate-id.util';
import { FirebaseService } from '../../firebase/firebase.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import {
  PaymentStatus,
  UpdatePaymentStatusDto,
} from './dto/update-payment-status.dto';
import { OrderStatus } from '../order/dto/create-order.dto';
import * as crypto from 'crypto';

@Injectable()
export class PaymentService {
  private readonly MERCHANT_ID = '4OVybzavqDY4JH5Ex7E22E3PM';
  private readonly APP_SECRET = '8RiWi2kyWOY49Y1ZRVq2sP4OfEWgFMnh44aBQAfI5uHB';
  private readonly NOTIFY_URL = 'https://pocketroom-backend-93470454666.asia-south1.run.app/payments/notify';

  constructor(private readonly firebase: FirebaseService) {}

  private paymentCollection() {
    return this.firebase.firestore.collection('payments');
  }

  private orderCollection() {
    return this.firebase.firestore.collection('orders');
  }

  private generatePayHereHash(orderId: string, amount: number, currency: string): string {
    const hashedSecret = crypto
      .createHash('md5')
      .update(this.APP_SECRET)
      .digest('hex')
      .toUpperCase();
    
    // Amount must be formatted to 2 decimal places for PayHere hash
    const amountFormatted = amount.toFixed(2);
    
    const mainHashString = 
      this.MERCHANT_ID + 
      orderId + 
      amountFormatted + 
      currency + 
      hashedSecret;
    
    return crypto
      .createHash('md5')
      .update(mainHashString)
      .digest('hex')
      .toUpperCase();
  }

  async createPayment(userId: string, dto: CreatePaymentDto) {
    const orderDoc = await this.orderCollection().doc(dto.orderId).get();

    if (!orderDoc.exists) {
      throw new NotFoundException('Order not found');
    }

    const orderData = orderDoc.data()!;
    const amount = dto.amount ?? orderData.totalAmount;
    const currency = dto.currency ?? orderData.currency ?? 'LKR';

    if (amount === undefined || amount === null || isNaN(Number(amount))) {
      throw new InternalServerErrorException(
        `Order ${dto.orderId} has no totalAmount. Cannot create payment.`,
      );
    }

    const customId = generateMeaningfulId('payment-' + Date.now());
    const docRef = this.paymentCollection().doc(customId);

    const hash = this.generatePayHereHash(dto.orderId, amount, currency);

    const paymentData = {
      paymentId: docRef.id,
      orderId: dto.orderId,
      customerId: userId,
      amount: amount,
      currency: currency,
      paymentMethod: dto.paymentMethod ?? 'PAYHERE',
      paymentStatus: PaymentStatus.PENDING,
      transactionReference: null,
      paidAt: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    try {
      await docRef.set(paymentData);
      
      // Return PayHere specific object format for mobile SDK
      return {
        merchant_id: this.MERCHANT_ID,
        order_id: dto.orderId,
        amount: amount,
        currency: currency,
        hash: hash,
        // PayHere requires non-empty strings — use order data with hardcoded fallbacks
        first_name: orderData.firstName ?? orderData.customerName ?? 'PocketRoom',
        last_name: orderData.lastName ?? 'Customer',
        email: orderData.email ?? 'orders@pocketroom.app',
        phone: orderData.phone ?? '0771234567',
        notify_url: this.NOTIFY_URL,
        items: `Order ${dto.orderId}`,
      };
    } catch (error) {
      console.error('[PaymentService] Create Payment Error:', error);
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
      console.error('[PaymentService] Update Payment Status Error:', error);
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
      console.error('[PaymentService] Delete Payment Error:', error);
      throw new InternalServerErrorException('Failed to delete payment');
    }
  }

  async verifyPayment(orderId: string) {
    const payment = (await this.getPaymentByOrderId(orderId)) as any;
    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (payment.paymentStatus !== PaymentStatus.SUCCESS) {
      return this.updatePaymentStatus(payment.paymentId, {
        paymentStatus: PaymentStatus.SUCCESS,
        transactionReference: 'VERIFIED_BY_CLIENT',
      });
    }

    return payment;
  }

  async handleNotify(data: any) {
    const { order_id, status_code, payment_id: transactionReference } = data;

    // status_code 2 means success in PayHere
    if (status_code == 2 || status_code === '2') {
      try {
        const payment = await this.getPaymentByOrderId(order_id);
        if (payment) {
          await this.updatePaymentStatus(payment.paymentId, {
            paymentStatus: PaymentStatus.SUCCESS,
            transactionReference: transactionReference,
          });
        }
      } catch (error) {
        // Payment might not exist yet or already updated
        console.error('[PaymentService] Notify error:', error);
      }
    }
    
    return { status: 'acknowledged' };
  }
}