import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { CreateOrderDto, OrderStatus } from './dto/create-order.dto';

@Injectable()
export class OrderService {
    constructor(private readonly firebase: FirebaseService) { }

    private collection() {
        return this.firebase.firestore.collection('orders');
    }

    async createOrder(userId: string, dto: CreateOrderDto) {
        // Calculate total if not provided
        let totalAmount = dto.totalAmount;
        if (totalAmount === undefined) {
            totalAmount = dto.items.reduce((sum, item) => {
                const itemTotal = item.itemTotal ?? (item.unitPrice ?? 0) * item.quantity;
                return sum + itemTotal;
            }, 0);
        }

        const docRef = this.collection().doc();
        const data = {
            orderId: docRef.id,
            ...dto,
            customerId: userId, // Enforce the authenticated user as the customer
            orderStatus: OrderStatus.PENDING,
            totalAmount,
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        try {
            await docRef.set(data);
            return data;
        } catch (error) {
            throw new InternalServerErrorException('Failed to create order');
        }
    }

    async getUserOrders(userId: string) {
        const snapshot = await this.collection()
            .where('customerId', '==', userId)
            .orderBy('createdAt', 'desc')
            .get();

        return snapshot.docs.map((doc) => doc.data());
    }

    async getOrderById(orderId: string) {
        const doc = await this.collection().doc(orderId).get();

        if (!doc.exists) {
            throw new NotFoundException('Order not found');
        }

        return doc.data();
    }

    async updateOrderStatus(orderId: string, status: OrderStatus) {
        const docRef = this.collection().doc(orderId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new NotFoundException('Order not found');
        }

        await docRef.update({
            orderStatus: status,
            updatedAt: new Date(),
        });

        return { message: 'Order status updated successfully', status };
    }
}
