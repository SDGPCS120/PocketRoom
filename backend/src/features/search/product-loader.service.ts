import { Injectable, Logger } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class ProductLoaderService {
    private readonly logger = new Logger(ProductLoaderService.name);

    constructor(private readonly firebaseService: FirebaseService) { }

    private ensureStringList(val: any): string[] {
        if (Array.isArray(val)) {
            return val
                .map((item) => this.ensureString(item).trim())
                .filter((item) => item.length > 0);
        }
        if (typeof val === 'string') {
            const trimmed = val.trim();
            return trimmed ? [trimmed] : [];
        }
        return [];
    }

    private ensureImagesByColor(val: any): Record<string, string[]> {
        const result: Record<string, string[]> = {};
        if (!val || typeof val !== 'object' || Array.isArray(val)) {
            return result;
        }

        for (const [key, rawValue] of Object.entries(val)) {
            const normalized = this.ensureStringList(rawValue);
            if (normalized.length > 0) {
                result[String(key).trim()] = normalized;
            }
        }

        return result;
    }

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
        try {
            const snapshot = await this.firebaseService.firestore.collection('products').get();
            this.logger.log(`Firestore query successful. Found ${snapshot.docs.length} documents.`);

            if (snapshot.docs.length > 0) {
                products = snapshot.docs.map((doc) => {
                    const data = doc.data();
                    return {
                        id: String(data.productID || doc.id),
                        name: this.ensureString(data.name),
                        category: this.ensureString(data.category),
                        color: this.ensureString(data.primaryColor || data.color),
                        colors: Array.isArray(data.colors)
                            ? data.colors
                            : (data.primaryColor || data.color ? [data.primaryColor || data.color] : []),
                        material: this.ensureString(data.material),
                        style: Array.isArray(data.styleTags)
                            ? data.styleTags.join(' ')
                            : this.ensureString(data.style),
                        description: this.ensureString(data.description),
                        price: typeof data.price === 'number' ? data.price : parseFloat(data.price) || 0,
                        imageUrl: Array.isArray(data.imageUrl)
                            ? this.ensureStringList(data.imageUrl)
                            : (Array.isArray(data.images)
                                ? this.ensureStringList(data.images)
                                : (this.ensureString(data.imageUrl || data.image).trim()
                                    ? [this.ensureString(data.imageUrl || data.image).trim()]
                                    : [])),
                        imagesByColor: this.ensureImagesByColor(
                            data.imagesByColor || data.images_by_color,
                        ),
                        imagePath: this.ensureString(data.imagePath || data.image_path),
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

        return products;
    }
}
