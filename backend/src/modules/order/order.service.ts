import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import type { AuthUser } from '../auth/types/auth-user.type';
import { isAdministrator, requireAdministrator } from '../auth/types/authenticated-request';
import { CreateOrderDto, OrderStatus } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderFulfillmentDto } from './dto/update-order-fulfillment.dto';
import { authenticatedUid, CATALOG_PRICING, FULFILLMENTS_COLLECTION, requireCustomer, requireDocumentId } from './order-access';

const fulfillmentProgress = [OrderStatus.CONFIRMED, OrderStatus.PROCESSING, OrderStatus.SHIPPED, OrderStatus.DELIVERED];

type PricedItem = { productId: string; productName: string; quantity: number; unitPrice: number; itemTotal: number };
type StoreItems = { items: PricedItem[]; totalMinor: number };

@Injectable()
export class OrderService {
  constructor(private readonly firebase: FirebaseService) {}

  private get firestore() { return this.firebase.firestore; }
  private collection() { return this.firestore.collection('orders'); }
  private fulfillments() { return this.firestore.collection(FULFILLMENTS_COLLECTION); }

  private checkStore(actor: AuthUser, snapshot: FirebaseFirestore.DocumentSnapshot) {
    if (!snapshot.exists || (!isAdministrator(actor) && snapshot.data()?.sellerId !== actor.uid)) {
      throw new NotFoundException('Store not found');
    }
  }

  private async checkAddresses(authUid: string, ids: string[], transaction: FirebaseFirestore.Transaction) {
    // The current cart supports checkout before the customer saves an address.
    const refs = [...new Set(ids)].filter((id) => id !== 'mock-address')
      .map((id) => this.firestore.collection('addresses').doc(requireDocumentId(id)));
    if (!refs.length) return;
    const snapshots = await transaction.getAll(...refs);
    for (const snapshot of snapshots) {
      const address = snapshot.data();
      if (!address || address.isDeleted || address.userId !== authUid) {
        throw new NotFoundException('Address not found');
      }
    }
  }

  async createOrder(actor: AuthUser, dto: CreateOrderDto) {
    const authUid = authenticatedUid(actor);
    if (dto.currency !== undefined && dto.currency !== 'LKR') throw new BadRequestException('Orders are priced in LKR');
    if (!dto.items.length) throw new BadRequestException('Add at least one product');
    const ref = this.collection().doc();
    return this.firestore.runTransaction(async (transaction) => {
      const ids = [...new Set(dto.items.map((item) => requireDocumentId(item.productId)))];
      const products = new Map((await transaction.getAll(
        ...ids.map((id) => this.firestore.collection('products').doc(id)),
      )).map((snapshot) => [snapshot.id, snapshot.data()]));
      const stores = new Map<string, StoreItems>();
      let totalMinor = 0;
      for (const requested of dto.items) {
        const product = products.get(requested.productId);
        if (!product || typeof product.name !== 'string' || typeof product.storeId !== 'string') {
          throw new BadRequestException('A product is unavailable');
        }
        if (requested.variantId) throw new BadRequestException('Product variants are not supported at checkout');
        const unitMinor = typeof product.price === 'number' ? Math.round(product.price * 100) : NaN;
        const itemMinor = unitMinor * requested.quantity;
        if (unitMinor <= 0 || !Number.isSafeInteger(unitMinor) || !Number.isSafeInteger(itemMinor) ||
            !Number.isSafeInteger(requested.quantity) || requested.quantity < 1) {
          throw new BadRequestException('Invalid catalog price or quantity');
        }
        const group = stores.get(product.storeId) ?? { items: [], totalMinor: 0 };
        group.items.push({
          productId: requested.productId, productName: product.name, quantity: requested.quantity,
          unitPrice: unitMinor / 100, itemTotal: itemMinor / 100,
        });
        group.totalMinor += itemMinor;
        stores.set(product.storeId, group);
        totalMinor += itemMinor;
      }
      if (stores.size > 100 || !Number.isSafeInteger(totalMinor)) throw new BadRequestException('Order is too large');
      const activeStores = await transaction.getAll(
        ...[...stores.keys()].map((id) => this.firestore.collection('stores').doc(requireDocumentId(id))),
      );
      if (activeStores.some((snapshot) => {
        const store = snapshot.data();
        return !store?.sellerId || store.isActive === false;
      })) {
        throw new BadRequestException('A store is unavailable');
      }
      await this.checkAddresses(authUid, [dto.shippingAddressId, dto.billingAddressId], transaction);

      const timestamp = new Date();
      const order = {
        orderId: ref.id,
        customerId: actor.uid,
        customerAuthUid: authUid,
        shippingAddressId: dto.shippingAddressId,
        billingAddressId: dto.billingAddressId,
        items: [...stores.values()].flatMap((group) => group.items),
        totalAmount: totalMinor / 100,
        totalMinor,
        pricingSource: CATALOG_PRICING,
        currency: 'LKR',
        orderStatus: OrderStatus.PENDING_PAYMENT,
        storeId: stores.size === 1 ? [...stores.keys()][0] : null,
        createdAt: timestamp,
        updatedAt: timestamp,
      };
      transaction.create(ref, order);
      for (const [storeId, group] of stores) {
        const fulfillment = this.fulfillments().doc();
        transaction.create(fulfillment, {
          orderId: fulfillment.id,
          parentOrderId: ref.id,
          customerId: actor.uid,
          storeId,
          items: group.items,
          totalAmount: group.totalMinor / 100,
          currency: order.currency,
          orderStatus: order.orderStatus,
          createdAt: timestamp,
          updatedAt: timestamp,
        });
      }
      return this.customerView(order);
    });
  }

  private customerView(data: FirebaseFirestore.DocumentData) {
    const { customerAuthUid, ...view } = data;
    return view;
  }

  private byNewest(docs: FirebaseFirestore.QueryDocumentSnapshot[]) {
    return docs.sort((a, b) => (b.get('createdAt')?.toMillis?.() ?? 0) - (a.get('createdAt')?.toMillis?.() ?? 0));
  }

  async getUserOrders(actor: AuthUser) {
    const authUid = authenticatedUid(actor);
    const queries = [
      this.collection().where('customerAuthUid', '==', authUid),
      ...[...new Set([actor.uid, authUid])].map((id) => this.collection().where('customerId', '==', id)),
    ];
    const snapshots = await Promise.all(queries.map((query) => query.get()));
    const docs = new Map(snapshots.flatMap((snapshot) => snapshot.docs).map((doc) => [doc.id, doc]));
    return this.byNewest([...docs.values()]).filter((doc) => {
      const data = doc.data();
      return data.customerAuthUid === undefined || data.customerAuthUid === authUid;
    }).map((doc) => this.customerView(doc.data()));
  }

  async getOrdersByStore(actor: AuthUser, storeId: string) {
    const store = this.firestore.collection('stores').doc(requireDocumentId(storeId));
    const query = this.fulfillments().where('storeId', '==', storeId);
    return this.firestore.runTransaction(async (transaction) => {
      this.checkStore(actor, await transaction.get(store));
      const { docs } = await transaction.get(query);
      return this.byNewest(docs).map((doc) => doc.data());
    }, { readOnly: true });
  }

  async getAllOrders(actor: AuthUser) {
    requireAdministrator(actor);
    const { docs } = await this.collection().orderBy('createdAt', 'desc').get();
    return docs.map((doc) => this.customerView(doc.data()));
  }

  async getOrderById(actor: AuthUser, id: string) {
    const order = await this.collection().doc(requireDocumentId(id)).get();
    const data = order.data();
    if (data) {
      if (!isAdministrator(actor)) requireCustomer(actor, data);
      return this.customerView(data);
    }
    const ref = this.fulfillments().doc(id);
    return this.firestore.runTransaction(async (transaction) => {
      const fulfillment = (await transaction.get(ref)).data();
      if (!fulfillment) throw new NotFoundException('Order not found');
      this.checkStore(actor, await transaction.get(this.firestore.collection('stores').doc(fulfillment.storeId)));
      return fulfillment;
    }, { readOnly: true });
  }

  async updateOrder(actor: AuthUser, id: string, dto: UpdateOrderDto) {
    const authUid = authenticatedUid(actor);
    const ref = this.collection().doc(requireDocumentId(id));
    await this.firestore.runTransaction(async (transaction) => {
      const data = (await transaction.get(ref)).data();
      requireCustomer(actor, data);
      if (data!.orderStatus !== OrderStatus.PENDING_PAYMENT || data!.paymentAttemptId) {
        throw new ConflictException('Order is locked for checkout');
      }
      const { shippingAddressId, billingAddressId } = dto;
      await this.checkAddresses(authUid, [shippingAddressId, billingAddressId].filter((value): value is string => value !== undefined), transaction);
      transaction.update(ref, {
        ...(shippingAddressId !== undefined && { shippingAddressId }),
        ...(billingAddressId !== undefined && { billingAddressId }),
        updatedAt: new Date(),
      });
    });
    return this.getOrderById(actor, id);
  }

  async updateOrderFulfillment(actor: AuthUser, id: string, dto: UpdateOrderFulfillmentDto) {
    const ref = this.fulfillments().doc(requireDocumentId(id));
    return this.firestore.runTransaction(async (transaction) => {
      const fulfillment = (await transaction.get(ref)).data();
      if (!fulfillment) throw new NotFoundException('Order not found');
      this.checkStore(actor, await transaction.get(this.firestore.collection('stores').doc(fulfillment.storeId)));
      const parent = this.collection().doc(fulfillment.parentOrderId);
      const parentData = (await transaction.get(parent)).data();
      if (!parentData || !fulfillmentProgress.includes(parentData.orderStatus)) throw new ConflictException('Order is awaiting payment');
      const current = fulfillmentProgress.indexOf(fulfillment.orderStatus);
      const next = fulfillmentProgress.indexOf(dto.orderStatus);
      if (current < 0 || next < 0 || (next !== current + 1 && next !== current)) {
        throw new ConflictException('Invalid fulfillment transition');
      }
      const siblings = await transaction.get(this.fulfillments().where('parentOrderId', '==', parent.id));
      const parentProgress = Math.min(next, ...siblings.docs.filter((doc) => doc.id !== id)
        .map((doc) => fulfillmentProgress.indexOf(doc.get('orderStatus'))));
      if (parentProgress < 0) throw new ConflictException('Invalid fulfillment state');
      const timestamp = new Date();
      const update = {
        orderStatus: dto.orderStatus,
        ...(dto.trackingNumber !== undefined && { trackingNumber: dto.trackingNumber }),
        ...(dto.courierName !== undefined && { courierName: dto.courierName }),
        ...(dto.estimatedDelivery !== undefined && { estimatedDelivery: dto.estimatedDelivery }),
        ...(next !== current && dto.orderStatus === OrderStatus.SHIPPED && { shippedAt: timestamp }),
        ...(next !== current && dto.orderStatus === OrderStatus.DELIVERED && { deliveredAt: timestamp }),
        updatedAt: timestamp,
      };
      transaction.update(ref, update);
      transaction.update(parent, { orderStatus: fulfillmentProgress[parentProgress], updatedAt: timestamp });
      return { ...fulfillment, ...update };
    });
  }

  async cancelOrder(actor: AuthUser, id: string) {
    const ref = this.collection().doc(requireDocumentId(id));
    return this.firestore.runTransaction(async (transaction) => {
      const data = (await transaction.get(ref)).data();
      if (!data) throw new NotFoundException('Order not found');
      if (!isAdministrator(actor)) requireCustomer(actor, data);
      if (data.orderStatus === OrderStatus.CANCELLED) return { orderId: id, orderStatus: OrderStatus.CANCELLED };
      if (data.orderStatus !== OrderStatus.PENDING_PAYMENT || data.paymentAttemptId) {
        throw new ConflictException('Only orders that have not started payment can be cancelled');
      }
      const fulfillments = await transaction.get(this.fulfillments().where('parentOrderId', '==', id));
      const update = { orderStatus: OrderStatus.CANCELLED, updatedAt: new Date() };
      transaction.update(ref, update);
      for (const fulfillment of fulfillments.docs) transaction.update(fulfillment.ref, update);
      return { orderId: id, orderStatus: OrderStatus.CANCELLED };
    });
  }
}
