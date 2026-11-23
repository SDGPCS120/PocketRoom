import { randomBytes, timingSafeEqual } from 'node:crypto';
import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import type { AuthUser } from '../auth/types/auth-user.type';
import { isAdministrator, requireAdministrator } from '../auth/types/authenticated-request';
import { OrderStatus } from '../order/dto/create-order.dto';
import { authenticatedUid, CATALOG_PRICING, FULFILLMENTS_COLLECTION, requireCustomer, requireDocumentId } from '../order/order-access';
import { PaymentStatus } from './dto/update-payment-status.dto';
import { checkoutPage, checkoutTokenHash, parseNotification, payHereConfig } from './payhere-checkout';

const CHECKOUT_LINK_TTL_MS = 15 * 60 * 1000;

@Injectable()
export class PaymentService {
  constructor(private readonly firebase: FirebaseService) {}

  private get firestore() { return this.firebase.firestore; }
  private payments() { return this.firestore.collection('payments'); }
  private orders() { return this.firestore.collection('orders'); }

  private paymentView(data: FirebaseFirestore.DocumentData) {
    const { paymentId, orderId, amount, currency, paymentMethod, paymentStatus, settlementSource,
      merchantMode, paidAt, createdAt, updatedAt, chargebackAt } = data;
    const verified = settlementSource === 'payhere-notify';
    return { paymentId, orderId, amount, currency, paymentMethod,
      paymentStatus: paymentStatus === PaymentStatus.SUCCESS && !verified ? 'UNVERIFIED' : paymentStatus,
      merchantMode, paidAt: verified ? paidAt : null, createdAt, updatedAt, chargebackAt };
  }

  async createPayment(actor: AuthUser, orderId: string) {
    const config = payHereConfig();
    const authUid = authenticatedUid(actor);
    const orderRef = this.orders().doc(requireDocumentId(orderId));
    const newPayment = this.payments().doc();
    const token = randomBytes(32).toString('hex');
    const checkoutToken = checkoutTokenHash(token);
    return this.firestore.runTransaction(async (transaction) => {
      const order = (await transaction.get(orderRef)).data();
      requireCustomer(actor, order);
      if (!order || order.pricingSource !== CATALOG_PRICING || !Number.isSafeInteger(order.totalMinor) ||
          order.totalMinor <= 0 || order.totalMinor >= 10 ** 15 || order.currency !== 'LKR' ||
          order.orderStatus !== OrderStatus.PENDING_PAYMENT) {
        throw new ConflictException('Create a new catalog-priced order before payment');
      }
      let ref = newPayment;
      if (order.paymentAttemptId) {
        ref = this.payments().doc(order.paymentAttemptId);
        const payment = (await transaction.get(ref)).data();
        if (payment?.orderId !== orderId || payment.merchantId !== config.merchantId ||
            payment.totalMinor !== order.totalMinor || payment.currency !== order.currency) {
          throw new ConflictException('Payment attempt no longer matches the order');
        }
        if (payment.checkoutOpenedAt || payment.paymentStatus !== PaymentStatus.PENDING) {
          return { paymentId: ref.id, paymentStatus: payment.paymentStatus, checkoutUrl: null };
        }
      }
      const timestamp = new Date();
      const link = { checkoutToken, checkoutExpiresAtMs: timestamp.getTime() + CHECKOUT_LINK_TTL_MS, updatedAt: timestamp };
      if (order.paymentAttemptId) {
        transaction.update(ref, link);
      } else {
        transaction.create(ref, {
          ...link, paymentId: ref.id, orderId, customerId: actor.uid, customerAuthUid: authUid,
          amount: order.totalAmount, totalMinor: order.totalMinor, currency: order.currency,
          merchantId: config.merchantId, merchantMode: 'sandbox', paymentMethod: 'PAYHERE',
          paymentStatus: PaymentStatus.PENDING, createdAt: timestamp,
        });
        transaction.update(orderRef, { paymentAttemptId: ref.id, updatedAt: timestamp });
      }
      return { paymentId: ref.id, paymentStatus: PaymentStatus.PENDING,
        checkoutUrl: config.origin + '/payments/checkout/' + ref.id + '#' + token };
    });
  }

  async openCheckout(paymentId: string, token: unknown) {
    const config = payHereConfig();
    if (typeof token !== 'string' || !/^[a-f0-9]{64}$/.test(token) || !/^[A-Za-z0-9]{20}$/.test(paymentId)) {
      throw new NotFoundException('Checkout link unavailable');
    }
    const ref = this.payments().doc(paymentId);
    return this.firestore.runTransaction(async (transaction) => {
      const data = (await transaction.get(ref)).data();
      if (!data || data.merchantId !== config.merchantId || data.merchantMode !== 'sandbox' ||
          data.checkoutOpenedAt || data.paymentStatus !== PaymentStatus.PENDING ||
          !(data.checkoutExpiresAtMs > Date.now()) || typeof data.checkoutToken !== 'string' ||
          !/^[a-f0-9]{64}$/.test(data.checkoutToken) ||
          !timingSafeEqual(Buffer.from(data.checkoutToken, 'hex'), Buffer.from(checkoutTokenHash(token), 'hex'))) {
        throw new NotFoundException('Checkout link unavailable');
      }
      transaction.update(ref, { checkoutOpenedAt: new Date(), checkoutToken: this.firebase.fieldValue.delete() });
      return checkoutPage(config, ref.id, data.totalMinor);
    });
  }

  async getAllPayments(actor: AuthUser) {
    requireAdministrator(actor);
    const { docs } = await this.payments().orderBy('createdAt', 'desc').get();
    return docs.map((doc) => this.paymentView(doc.data()));
  }

  async getPaymentsByUser(actor: AuthUser) {
    const authUid = authenticatedUid(actor);
    // Older payments stored a caller-selected order ID; they do not prove ownership.
    const { docs } = await this.payments().where('customerAuthUid', '==', authUid).get();
    return docs.map((doc) => this.paymentView(doc.data()));
  }

  async getPaymentById(actor: AuthUser, paymentId: string) {
    const authUid = authenticatedUid(actor);
    const data = (await this.payments().doc(requireDocumentId(paymentId)).get()).data();
    if (!data || (!isAdministrator(actor) && data.customerAuthUid !== authUid)) {
      throw new NotFoundException('Payment not found');
    }
    return this.paymentView(data);
  }

  async verifyPayment(actor: AuthUser, orderId: string) {
    const order = (await this.orders().doc(requireDocumentId(orderId)).get()).data();
    requireCustomer(actor, order);
    if (!order?.paymentAttemptId) return { orderId, paymentStatus: PaymentStatus.PENDING };
    return this.getPaymentById(actor, order.paymentAttemptId);
  }

  async handleNotify(body: unknown) {
    const config = payHereConfig();
    const notice = parseNotification(config, body);
    const paymentRef = this.payments().doc(notice.id);
    await this.firestore.runTransaction(async (transaction) => {
      const payment = (await transaction.get(paymentRef)).data();
      if (!payment || !payment.checkoutOpenedAt || payment.merchantId !== config.merchantId ||
          payment.merchantMode !== 'sandbox' || payment.totalMinor !== notice.totalMinor ||
          payment.currency !== notice.currency) {
        throw new ConflictException('Notification does not match a payment attempt');
      }
      const orderRef = this.orders().doc(payment.orderId);
      const order = (await transaction.get(orderRef)).data();
      if (!order || order.paymentAttemptId !== paymentRef.id || order.pricingSource !== CATALOG_PRICING ||
          order.customerAuthUid !== payment.customerAuthUid || order.totalMinor !== notice.totalMinor ||
          order.currency !== notice.currency) {
        throw new ConflictException('Notification does not match the order');
      }
      const timestamp = new Date();
      if (payment.paymentStatus === PaymentStatus.SUCCESS) {
        if (notice.code === '-3' && !payment.chargebackAt) {
          transaction.update(paymentRef, { chargebackAt: timestamp, updatedAt: timestamp });
        }
        return;
      }
      if (notice.code === '0' || notice.code === '-3') return;
      if (notice.code !== '2') {
        transaction.update(paymentRef, {
          paymentStatus: notice.code === '-1' ? PaymentStatus.CANCELLED : PaymentStatus.FAILED,
          updatedAt: timestamp,
        });
        return;
      }
      if (order.orderStatus !== OrderStatus.PENDING_PAYMENT) {
        throw new ConflictException('Order cannot be confirmed');
      }
      const fulfillments = await transaction.get(this.firestore.collection(FULFILLMENTS_COLLECTION)
        .where('parentOrderId', '==', orderRef.id));
      if (fulfillments.empty || fulfillments.docs.some((doc) => doc.get('orderStatus') !== OrderStatus.PENDING_PAYMENT)) {
        throw new ConflictException('Order fulfillments cannot be confirmed');
      }
      const orderUpdate = { orderStatus: OrderStatus.CONFIRMED, paymentEnvironment: 'sandbox', updatedAt: timestamp };
      transaction.update(paymentRef, {
        paymentStatus: PaymentStatus.SUCCESS,
        settlementSource: 'payhere-notify',
        paidAt: timestamp,
        updatedAt: timestamp,
      });
      transaction.update(orderRef, orderUpdate);
      for (const fulfillment of fulfillments.docs) transaction.update(fulfillment.ref, orderUpdate);
    });
    return { status: 'acknowledged' };
  }
}
