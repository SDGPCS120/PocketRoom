import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateProductDto } from './dto/create-product.dto';

@Injectable()
export class ProductsService {
  constructor(private readonly firebaseService: FirebaseService) { }

  async create(createProductDto: CreateProductDto) {
    try {
      const db = this.firebaseService.getFirestore();
      const docRef = await db.collection('products').add({
        ...createProductDto,
        createdAt: new Date(),
        modelStatus: 'pending' // Default status for 3D pipeline
      });
      return { id: docRef.id, message: 'Product created' };
    } catch (error) {
      console.error('Error creating product:', error);
      throw error;
    }
  }

  async findAll() {
    const db = this.firebaseService.getFirestore();
    const snapshot = await db.collection('products').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  async findOne(id: string) {
    const db = this.firebaseService.getFirestore();
    const doc = await db.collection('products').doc(id).get();

    if (!doc.exists) {
      throw new Error(`Product with ID ${id} not found`);
    }

    return { id: doc.id, ...doc.data() };
  }

  async update(id: string, updateProductDto: any) {
    const db = this.firebaseService.getFirestore();
    const docRef = db.collection('products').doc(id);

    // Check if document exists first
    const doc = await docRef.get();
    if (!doc.exists) {
      throw new Error(`Product with ID ${id} not found`);
    }

    await docRef.update({
      ...updateProductDto,
      updatedAt: new Date(),
    });

    return { id, message: 'Product updated successfully' };
  }

  async remove(id: string) {
    const db = this.firebaseService.getFirestore();
    const docRef = db.collection('products').doc(id);

    // Check if document exists first
    const doc = await docRef.get();
    if (!doc.exists) {
      throw new Error(`Product with ID ${id} not found`);
    }

    await docRef.delete();
    return { id, message: 'Product deleted successfully' };
  }
}