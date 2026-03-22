import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { generateMeaningfulId } from '../../common/utils/generate-id.util';
import { FirebaseService } from '../../firebase/firebase.service';
import { CreateOrderDto, OrderStatus } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderFulfillmentDto } from './dto/update-order-fulfillment.dto';

@Injectable()
export class OrderService {
  constructor(private readonly firebase: FirebaseService) {}

  private collection() {
    return this.firebase.firestore.collection('orders');
  }

  async createOrder(userId: string, dto: CreateOrderDto) {
    let totalAmount = dto.totalAmount;

    if (totalAmount === undefined) {
      totalAmount = dto.items.reduce((sum, item) => {
        const itemTotal = item.itemTotal ?? (item.unitPrice ?? 0) * item.quantity;
        return sum + itemTotal;
      }, 0);
    }

    const customId = generateMeaningfulId('order-' + Date.now());
    const docRef = this.collection().doc(customId);

    const data = {
      orderId: docRef.id,
      ...dto,
      customerId: userId,
      orderStatus: OrderStatus.PENDING_PAYMENT,
      totalAmount,
      trackingNumber: null,
      courierName: null,
      estimatedDelivery: dto.estimatedDelivery ?? null,
      shippedAt: null,
      deliveredAt: null,
      storeId: dto.storeId ?? null,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    try {
      await docRef.set(data);
      return data;
    } catch (error) {
      console.error('[OrderService] Create Order Error:', error);
      const message = error instanceof Error ? error.message : 'Unknown error';
      throw new InternalServerErrorException(`Failed to create order: ${message}`);
    }
  }

  async getUserOrders(userId: string) {
    const snapshot = await this.collection()
      .where('customerId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => doc.data());
  }

  async getOrdersByStore(storeId: string) {
    const snapshot = await this.collection()
      .where('storeId', '==', storeId)
      .orderBy('createdAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => doc.data());
  }

  async getAllOrders() {
    const snapshot = await this.collection().orderBy('createdAt', 'desc').get();
    return snapshot.docs.map((doc) => doc.data());
  }

  async getOrderById(orderId: string) {
    const doc = await this.collection().doc(orderId).get();

    if (!doc.exists) {
      throw new NotFoundException('Order not found');
    }

    return doc.data();
  }

  async updateOrder(orderId: string, dto: UpdateOrderDto) {
    const docRef = this.collection().doc(orderId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException('Order not found');
    }

    const updateData = {
      ...dto,
      updatedAt: new Date(),
    };

    try {
      await docRef.update(updateData);
      const updatedDoc = await docRef.get();
      return updatedDoc.data();
    } catch (error) {
      throw new InternalServerErrorException('Failed to update order');
    }
  }

  async updateOrderFulfillment(orderId: string, dto: UpdateOrderFulfillmentDto) {
    const docRef = this.collection().doc(orderId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException('Order not found');
    }

    const updateData: any = {
      orderStatus: dto.orderStatus,
      updatedAt: new Date(),
    };

    if (dto.trackingNumber !== undefined) {
      updateData.trackingNumber = dto.trackingNumber;
    }

    if (dto.courierName !== undefined) {
      updateData.courierName = dto.courierName;
    }

    if (dto.estimatedDelivery !== undefined) {
      updateData.estimatedDelivery = dto.estimatedDelivery;
    }

    if (dto.orderStatus === OrderStatus.SHIPPED) {
      updateData.shippedAt = new Date();
    }

    if (dto.orderStatus === OrderStatus.DELIVERED) {
      updateData.deliveredAt = new Date();
    }

    try {
      await docRef.update(updateData);
      const updatedDoc = await docRef.get();
      return updatedDoc.data();
    } catch (error) {
      throw new InternalServerErrorException('Failed to update order fulfillment');
    }
  }

  async deleteOrder(orderId: string) {
    const docRef = this.collection().doc(orderId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException('Order not found');
    }

    try {
      await docRef.delete();
      return { message: 'Order deleted successfully' };
    } catch (error) {
      throw new InternalServerErrorException('Failed to delete order');
    }
  }
}