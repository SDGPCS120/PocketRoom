import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';

@Injectable()
export class StoreService {
    constructor(private readonly firebase: FirebaseService) { }

    private collection() {
        return this.firebase.firestore.collection('stores');
    }

    async createStore(sellerId: string, dto: CreateStoreDto) {
        const docRef = this.collection().doc();

        const data = {
            storeId: docRef.id,
            ...dto,
            sellerId: sellerId,
            createdAt: new Date(),
        };

        await docRef.set(data);

        return data;
    }

    async getMyStore(sellerId: string) {
        const snapshot = await this.collection()
            .where('sellerId', '==', sellerId)
            .limit(1)
            .get();

        if (snapshot.empty) {
            throw new NotFoundException('Store not found');
        }

        return snapshot.docs[0].data();
    }

    async getStoreById(storeId: string) {
        const doc = await this.collection().doc(storeId).get();

        if (!doc.exists) {
            throw new NotFoundException('Store not found');
        }

        return doc.data();
    }

    async updateStore(storeId: string, sellerId: string, dto: UpdateStoreDto) {
        const docRef = this.collection().doc(storeId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new NotFoundException('Store not found');
        }

        const store = doc.data();

        if (store?.sellerId !== sellerId) {
            throw new ForbiddenException('You do not own this store');
        }

        await docRef.update({
            ...dto,
            updatedAt: new Date(),
        });

        return { message: 'Store updated successfully' };
    }

    async deleteStore(storeId: string, sellerId: string) {
        const docRef = this.collection().doc(storeId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new NotFoundException('Store not found');
        }

        const store = doc.data();

        if (store?.sellerId !== sellerId) {
            throw new ForbiddenException('You do not own this store');
        }

        await docRef.delete();

        return { message: 'Store deleted successfully' };
    }
}