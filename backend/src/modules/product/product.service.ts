import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';

export interface ProductDocument {
  id: string;
  name: string;
  description?: string;
  price: number;
  stock?: number;
  brand: string;
  rating: number;
  images: string[];
  furnitureType: string;
  dimensions: string;
}

@Injectable()
export class ProductService {
  private readonly logger = new Logger(ProductService.name);
  private readonly COLLECTION = 'products';

  constructor(private readonly firebaseService: FirebaseService) {}

  async findAll(): Promise<ProductDocument[]> {
    const db = this.firebaseService.firestore;
    const snapshot = await db.collection(this.COLLECTION).get();

    const products: ProductDocument[] = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...this.normalizeDoc(doc.data()),
    }));

    this.logger.log(`Fetched ${products.length} products from Firestore`);
    return products;
  }

  async findOne(id: string): Promise<ProductDocument> {
    const db = this.firebaseService.firestore;
    const doc = await db.collection(this.COLLECTION).doc(id).get();

    if (!doc.exists) {
      throw new NotFoundException(`Product with ID "${id}" not found`);
    }

    return { id: doc.id, ...this.normalizeDoc(doc.data()) };
  }

  /**
   * Normalize raw Firestore data into a predictable shape,
   * providing safe defaults for any missing fields.
   */
  private normalizeDoc(
    raw: FirebaseFirestore.DocumentData | undefined,
  ): Omit<ProductDocument, 'id'> {
    const data = raw ?? {};
    return {
      name: typeof data.name === 'string' ? data.name : '',
      description:
        typeof data.description === 'string' ? data.description : undefined,
      price: typeof data.price === 'number' ? data.price : 0,
      stock: typeof data.stock === 'number' ? data.stock : undefined,
      brand: typeof data.brand === 'string' ? data.brand : '',
      rating: typeof data.rating === 'number' ? data.rating : 0,
      images: Array.isArray(data.images) ? (data.images as string[]) : [],
      furnitureType:
        typeof data.furnitureType === 'string' ? data.furnitureType : '',
      dimensions: typeof data.dimensions === 'string' ? data.dimensions : '',
    };
  }
}
