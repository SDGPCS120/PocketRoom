import { Injectable, Logger } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class ProductLoaderService {
    private readonly logger = new Logger(ProductLoaderService.name);

    constructor(private readonly firebaseService: FirebaseService) { }

    private ensureString(val: any): string {
        if (Array.isArray(val)) {
            return val.join(', ');
        }
        if (typeof val === 'string') {
            return val;
        }
        if (val === null || val === undefined) {
            return '';
        }
        return String(val);
    }

    async loadProductsFromFirestore(): Promise<any[]> {
        this.logger.log('Attempting to load products from Firestore...');

        let products: any[] = [];
        const isReady = await this.firebaseService.waitForInitialization();

        if (isReady) {
            try {
                const snapshot = await this.firebaseService.db.collection('products').get();
                this.logger.log(`Firestore query successful. Found ${snapshot.docs.length} documents.`);

                if (snapshot.docs.length > 0) {
                    products = snapshot.docs.map((doc) => {
                        const data = doc.data();
                        return {
                            id: String(data.productID || doc.id),
                            name: this.ensureString(data.name),
                            furnitureType: this.ensureString(data.furnitureType || data.category),
                            color: this.ensureString(data.primaryColor || data.color),
                            material: this.ensureString(data.material),
                            style: Array.isArray(data.styleTags)
                                ? data.styleTags.join(' ')
                                : this.ensureString(data.style),
                            description: this.ensureString(data.description),
                            price: typeof data.price === 'number' ? data.price : parseFloat(data.price) || 0,
                            imageUrl: this.ensureString(data.imageUrl || data.image),
                            brand: this.ensureString(data.brand),
                            rating: typeof data.rating === 'number' ? data.rating : parseFloat(data.rating) || 0,
                            dimensions_cm: {
                                l: data.dimensions?.length || 0,
                                w: data.dimensions?.width || 0,
                                h: data.dimensions?.height || 0,
                            },
                        };
                    });
                }
            } catch (error) {
                const message = error instanceof Error ? error.message : String(error);
                this.logger.error(`Error loading products from Firestore: ${message}`);
            }
        } else {
            this.logger.warn('Firebase not initialized. Will attempt fallback to local data.');
        }

        return products;
    }
}
