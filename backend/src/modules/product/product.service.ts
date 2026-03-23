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

    private serializeDimensions(dto: CreateProductDto | UpdateProductDto) {
        if (!dto.dimensions) return undefined;

        const { width, height, length } = dto.dimensions;
        return {
            ...(width !== undefined ? { width } : {}),
            ...(height !== undefined ? { height } : {}),
            ...(length !== undefined ? { length } : {}),
        };
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
            ...(dto.dimensions ? { dimensions: this.serializeDimensions(dto) } : {}),
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        await docRef.set(data);
        return data;
    }

    async getAllProducts() {
        const snapshot = await this.collection().get();
        return snapshot.docs.map((doc) => ({ productId: doc.id, ...doc.data() }));
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
            ...(dto.dimensions ? { dimensions: this.serializeDimensions(dto) } : {}),
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

        // 1. Delete associated files in Firebase Storage
        const bucketName = this.firebase.storageBucketName;
        if (bucketName) {
            const bucket = this.firebase.storage.bucket(bucketName);

            // Delete images
            try {
                await bucket.deleteFiles({ prefix: `products/${productId}/` });
            } catch (e) {
                console.error(`Failed to delete product images for ${productId}`, e);
            }

            // Delete 3D models (prefix format used in generation.processor.ts)
            try {
                await bucket.deleteFiles({ prefix: `3DModel/${productId}_` });
            } catch (e) {
                console.error(`Failed to delete product 3D models for ${productId}`, e);
            }
        } else {
            console.warn(`FIREBASE_STORAGE_BUCKET is not configured; skipping storage cleanup for ${productId}`);
        }

        // 2. Delete database document
        await docRef.delete();

        return { message: 'Product deleted successfully' };
    }

    async getProductsByStore(storeId: string) {
        const snapshot = await this.collection()
            .where('storeId', '==', storeId)
            .get();

        return snapshot.docs.map((doc) => ({ productId: doc.id, ...doc.data() }));
    }
}
