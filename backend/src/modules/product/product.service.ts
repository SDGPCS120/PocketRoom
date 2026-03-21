import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { generateMeaningfulId } from '../../common/utils/generate-id.util';
import { FirebaseService } from '../../firebase/firebase.service';
import { StoreService } from '../store/store.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductService {
    constructor(
        private readonly firebase: FirebaseService,
        private readonly storeService: StoreService,
    ) { }

    private collection() {
        return this.firebase.firestore.collection('products');
    }

    async createProduct(storeId: string, sellerId: string, dto: CreateProductDto) {
        const store = await this.storeService.getStoreById(storeId);

        if (store?.sellerId !== sellerId) {
            throw new ForbiddenException('You do not own this store');
        }

        const customId = generateMeaningfulId(dto.name);
        const docRef = this.collection().doc(customId);

        const data = {
            productId: docRef.id,
            storeId,
            storeName: store?.storeName || 'Unknown Store',
            ...dto,
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        await docRef.set(data);
        return data;
    }

    async getAllProducts() {
        const snapshot = await this.collection().get();
        return snapshot.docs.map((doc) => doc.data());
    }

    async getProductById(productId: string) {
        const doc = await this.collection().doc(productId).get();

        if (!doc.exists) {
            throw new NotFoundException('Product not found');
        }

        return doc.data();
    }

    async updateProduct(
        productId: string,
        sellerId: string,
        dto: UpdateProductDto,
    ) {
        const docRef = this.collection().doc(productId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new NotFoundException('Product not found');
        }

        const product = doc.data();
        const store = await this.storeService.getStoreById(product?.storeId);

        if (store?.sellerId !== sellerId) {
            throw new ForbiddenException('You do not own this product');
        }

        await docRef.update({
            ...dto,
            updatedAt: new Date(),
        });

        return { message: 'Product updated successfully' };
    }

    async deleteProduct(productId: string, sellerId: string) {
        const docRef = this.collection().doc(productId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new NotFoundException('Product not found');
        }

        const product = doc.data();
        const store = await this.storeService.getStoreById(product?.storeId);

        if (store?.sellerId !== sellerId) {
            throw new ForbiddenException('You do not own this product');
        }

        await docRef.delete();

        return { message: 'Product deleted successfully' };
    }

    async getProductsByStore(storeId: string) {
        const snapshot = await this.collection()
            .where('storeId', '==', storeId)
            .get();

        return snapshot.docs.map((doc) => doc.data());
    }
}