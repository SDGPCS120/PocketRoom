import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateProductDto } from './dto/create-product.dto';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { GenerateModelDto } from './dto/generate-model.dto';

@Injectable()
export class ProductsService {
  constructor(
    private readonly firebaseService: FirebaseService,
    @InjectQueue('generation-queue') private readonly generationQueue: Queue,
  ) { }

  async create(createProductDto: CreateProductDto) {
    try {
      const db = this.firebaseService.getFirestore();
      const docRef = await db.collection('products').add({
        ...createProductDto,
        createdAt: new Date(),
        modelStatus: 'pending', // Default status for 3D pipeline
      });
      return { id: docRef.id, message: 'Product created' };
    } catch (error) {
      console.error('Error creating product:', error);
      throw error;
    }
  }

  /**
   * Generate 3D model for a product
   * Uploads image to Firebase Storage and adds job to queue
   */
  async generateModel(
    productId: string,
    imageFile: Express.Multer.File,
    dimensions: GenerateModelDto,
  ) {
    try {
      // Step 1: Verify product exists
      const db = this.firebaseService.getFirestore();
      const productDoc = await db.collection('products').doc(productId).get();

      if (!productDoc.exists) {
        throw new Error(`Product with ID ${productId} not found`);
      }

      // Step 2: Upload raw image to Firebase Storage
      const storage = this.firebaseService.getStorage();
      const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
      const imageFileName = `Images/${productId}_${Date.now()}.jpg`;
      const imageFileRef = bucket.file(imageFileName);

      await imageFileRef.save(imageFile.buffer, {
        metadata: {
          contentType: imageFile.mimetype,
        },
      });

      await imageFileRef.makePublic();
      const imageUrl = `https://storage.googleapis.com/${bucket.name}/${imageFileName}`;

      // Step 3: Update product status to 'processing'
      await db.collection('products').doc(productId).update({
        modelStatus: 'processing',
        imageUrl: imageUrl,
        updatedAt: new Date(),
      });

      // Step 4: Add job to generation queue
      const job = await this.generationQueue.add('generate-3d-model', {
        productId,
        imageUrl,
        dimensions,
      });

      console.log(`Added job ${job.id} to generation queue for product ${productId}`);

      return {
        message: 'Model generation started',
        jobId: job.id,
        productId,
        status: 'processing',
      };
    } catch (error) {
      console.error('Error initiating model generation:', error);
      throw error;
    }
  }

  async findAll() {
    const db = this.firebaseService.getFirestore();
    const snapshot = await db.collection('products').get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
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