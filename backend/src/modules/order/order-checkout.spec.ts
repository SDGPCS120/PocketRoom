import { createHash } from 'node:crypto';
import type { FirebaseService } from '../../firebase/firebase.service';
import type { AuthUser } from '../auth/types/auth-user.type';
import { PaymentService } from '../payment/payment.service';
import { UserService } from '../user/user.service';
import { OrderStatus } from './dto/create-order.dto';
import { OrderService } from './order.service';

type Data = Record<string, unknown>;

function fakeFirestore() {
  const rows = new Map<string, Data>();
  let sequence = 0;

  function ref(name: string, id?: string) {
    const key = id ?? String(++sequence).padStart(20, '0');
    const path = name + '/' + key;
    return { id: key, path, get: async () => snapshot({ id: key, path }) };
  }

  function snapshot(reference: { id: string; path: string }) {
    const data = rows.get(reference.path);
    return { id: reference.id, ref: reference, exists: Boolean(data), data: () => data,
      get: (key: string) => data?.[key] };
  }

  function collection(name: string) {
    return {
      doc: (id?: string) => ref(name, id),
      where: (key: string, operator: string, value: unknown) => {
        if (operator !== '==') throw new Error('Unsupported test query');
        return {
          get: async () => {
            const docs = [...rows.keys()].filter((path) => path.startsWith(name + '/'))
              .map((path) => snapshot(ref(name, path.split('/')[1])))
              .filter((doc) => doc.get(key) === value);
            return { docs, empty: docs.length === 0 };
          },
        };
      },
    };
  }

  function firebase() {
    return {
      firestore: {
        collection,
        async runTransaction<T>(callback: (transaction: unknown) => Promise<T>) {
          const writes: (() => void)[] = [];
          const transaction = {
            get: (item: { get: () => unknown }) => item.get(),
            getAll: (...refs: { id: string; path: string }[]) => refs.map(snapshot),
            create: (reference: { path: string }, data: Data) => {
              if (rows.has(reference.path)) throw new Error('Already exists');
              writes.push(() => rows.set(reference.path, data));
            },
            update: (reference: { path: string }, data: Data) => {
              writes.push(() => rows.set(reference.path, { ...rows.get(reference.path), ...data }));
            },
          };
          const result = await callback(transaction);
          for (const write of writes) write();
          return result;
        },
      },
      fieldValue: { serverTimestamp: () => new Date(), delete: () => undefined },
    } as unknown as FirebaseService;
  }
  return { rows, firebase: firebase() };
}

const buyer: AuthUser = { uid: 'buyer-profile', authUid: 'buyer-firebase' };
const other: AuthUser = { uid: 'other-profile', authUid: 'other-firebase' };
const sellerA: AuthUser = { uid: 'seller-a', authUid: 'seller-a-firebase' };
const sellerB: AuthUser = { uid: 'seller-b', authUid: 'seller-b-firebase' };

describe('order, payment and account authorization', () => {
  const env = process.env;

  beforeEach(() => {
    process.env = {
      ...env, PAYHERE_MODE: 'sandbox', PAYHERE_MERCHANT_ID: '1234567',
      PAYHERE_MERCHANT_SECRET: 'local-unit-test-only',
      PAYHERE_PUBLIC_BASE_URL: 'https://checkout.example.invalid',
    };
  });

  afterEach(() => { process.env = env; });

  it('does not allow profile owners to change administrative fields', async () => {
    const { rows, firebase } = fakeFirestore();
    rows.set('users/buyer-profile', { authUid: buyer.authUid, role: 'ADMIN', fullName: 'Buyer' });
    const service = new UserService(firebase);
    await expect(service.findOne(other, 'buyer-profile')).rejects.toThrow('User not found');
    expect((await service.findOne({ ...other, claims: { admin: true } }, 'buyer-profile')).fullName).toBe('Buyer');
    await expect(service.findAll(buyer)).rejects.toThrow('Administrator access required');
    await expect(service.update(buyer, 'buyer-profile', { isActive: false })).rejects.toThrow('Only administrators');
    await service.update(buyer, 'buyer-profile', { fullName: 'Renamed' });
    expect((await service.findOne(buyer, 'buyer-profile')).fullName).toBe('Renamed');
    expect(await service.findOne(buyer, 'buyer-profile')).not.toHaveProperty('authUid');
  });

  it('settles catalog-priced store fulfillments only through verified payment', async () => {
    const { rows, firebase } = fakeFirestore();
    const orders = new OrderService(firebase);
    const payments = new PaymentService(firebase);
    rows.set('stores/store-a', { sellerId: sellerA.uid });
    rows.set('stores/store-b', { sellerId: sellerB.uid });
    rows.set('products/chair', { name: 'Chair', storeId: 'store-a', price: 2.5 });
    rows.set('products/desk', { name: 'Desk', storeId: 'store-b', price: 7.5 });
    const order = await orders.createOrder(buyer, {
      shippingAddressId: 'mock-address', billingAddressId: 'mock-address',
      storeId: 'caller-supplied', totalAmount: 1,
      items: [
        { productId: 'chair', productName: 'Placeholder', quantity: 1, unitPrice: 0.01 },
        { productId: 'desk', productName: 'Placeholder', quantity: 1, unitPrice: 0.01 },
      ],
    });

    expect(order.totalAmount).toBe(10);
    await expect(orders.getOrderById(other, order.orderId)).rejects.toThrow('Order not found');
    await expect(orders.getAllOrders(buyer)).rejects.toThrow('Administrator access required');
    await expect(orders.getOrdersByStore(sellerA, 'store-b')).rejects.toThrow('Store not found');
    const [a] = await orders.getOrdersByStore(sellerA, 'store-a');
    const [b] = await orders.getOrdersByStore(sellerB, 'store-b');
    expect(a.items.map((item: Data) => item.productName)).toEqual(['Chair']);
    expect(b.items.map((item: Data) => item.productName)).toEqual(['Desk']);
    await expect(orders.updateOrderFulfillment(sellerA, a.orderId, { orderStatus: OrderStatus.PROCESSING }))
      .rejects.toThrow('awaiting payment');

    await expect(payments.createPayment(other, order.orderId)).rejects.toThrow('Order not found');
    const session = await payments.createPayment(buyer, order.orderId);
    expect((await payments.verifyPayment(buyer, order.orderId)).paymentStatus).toBe('PENDING');
    expect(rows.get('orders/' + order.orderId)?.orderStatus).toBe(OrderStatus.PENDING_PAYMENT);

    const token = new URL(session.checkoutUrl!).hash.slice(1);
    expect(await payments.openCheckout(session.paymentId, token)).toContain('10.00');
    await expect(payments.openCheckout(session.paymentId, token)).rejects.toThrow('Checkout link unavailable');

    const notice = {
      merchant_id: '1234567', order_id: session.paymentId,
      payhere_amount: '10.00', payhere_currency: 'LKR', status_code: '2',
      md5sig: '0'.repeat(32),
    };
    await expect(payments.handleNotify(notice)).rejects.toThrow('Invalid payment notification signature');

    const md5 = (value: string) => createHash('md5').update(value).digest('hex').toUpperCase();
    const signature = (amount: string) =>
      md5('1234567' + session.paymentId + amount + 'LKR2' + md5('local-unit-test-only'));
    await expect(payments.handleNotify({ ...notice, payhere_amount: '1.00', md5sig: signature('1.00') }))
      .rejects.toThrow('Notification does not match a payment attempt');
    expect((await payments.verifyPayment(buyer, order.orderId)).paymentStatus).toBe('PENDING');
    const settled = { ...notice, md5sig: signature('10.00') };
    await payments.handleNotify(settled);
    const paid = rows.get('payments/' + session.paymentId)?.paidAt;
    await payments.handleNotify(settled);
    expect(rows.get('payments/' + session.paymentId)?.paidAt).toBe(paid);
    expect((await payments.verifyPayment(buyer, order.orderId)).paymentStatus).toBe('SUCCESS');
    expect(rows.get('orders/' + order.orderId)?.orderStatus).toBe(OrderStatus.CONFIRMED);

    await expect(orders.updateOrderFulfillment(sellerA, b.orderId, { orderStatus: OrderStatus.PROCESSING }))
      .rejects.toThrow('Store not found');
    await orders.updateOrderFulfillment(sellerA, a.orderId, { orderStatus: OrderStatus.PROCESSING });
    expect(rows.get('orders/' + order.orderId)?.orderStatus).toBe(OrderStatus.CONFIRMED);
    await orders.updateOrderFulfillment(sellerB, b.orderId, { orderStatus: OrderStatus.PROCESSING });
    expect(rows.get('orders/' + order.orderId)?.orderStatus).toBe(OrderStatus.PROCESSING);
  });
});
