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

      if (createProductDto.productID) {
        await db
          .collection('products')
          .doc(createProductDto.productID)
          .set({
            ...createProductDto,
            createdAt: new Date(),
            modelStatus: 'pending',
          });
        return { id: createProductDto.productID, message: 'Product created' };
      } else {
        const docRef = await db.collection('products').add({
          ...createProductDto,
          createdAt: new Date(),
          modelStatus: 'pending',
        });
        return { id: docRef.id, message: 'Product created' };
      }
    } catch (error) {
      console.error('Error creating product:', error);
      throw error;
    }
  }

  async uploadProductImage(
    productId: string,
    fileBuffer: Buffer,
    mimeType: string,
  ) {
    try {
      const storage = this.firebaseService.getStorage();
      const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
      const extension = mimeType.split('/')[1] || 'jpg';
      const imageFileName = `Images/${productId}.${extension}`;
      const imageFileRef = bucket.file(imageFileName);

      await imageFileRef.save(fileBuffer, {
        metadata: {
          contentType: mimeType,
        },
      });

      // Generate signed URL
      const [signedUrl] = await imageFileRef.getSignedUrl({
        action: 'read',
        expires: Date.now() + 60 * 60 * 1000 * 24 * 365, // 1 year (long expiry for manual upload)
      });

      return {
        imageUrl: signedUrl,
        imagePath: imageFileName,
      };
    } catch (error) {
      console.error('Error uploading product image:', error);
      throw error;
    }
  }

  /**
   Generate 3D model for a product
   Uploads image to Firebase Storage and adds job to queue
   */
  async generateModel(
    productId: string,
    imageFile: Express.Multer.File,
    dimensions: GenerateModelDto,
  ) {
    try {
      // Step 1
      const db = this.firebaseService.getFirestore();
      const productDoc = await db.collection('products').doc(productId).get();

      if (!productDoc.exists) {
        throw new Error(`Product with ID ${productId} not found`);
      }

      // Step 2
      const storage = this.firebaseService.getStorage();
      const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
      const imageFileName = `Images/${productId}_${Date.now()}.jpg`;
      const imageFileRef = bucket.file(imageFileName);

      await imageFileRef.save(imageFile.buffer, {
        metadata: {
          contentType: imageFile.mimetype,
        },
      });

      // Use signed URL for reliable Tripo access (expires in 1 hour)
      // This works even if bucket rules block public access
      const [signedUrl] = await imageFileRef.getSignedUrl({
        action: 'read',
        expires: Date.now() + 60 * 60 * 1000, // 1 hour
      });
      const imageUrl = signedUrl;

      // Step 3
      await db.collection('products').doc(productId).update({
        modelStatus: 'processing',
        imageUrl: imageUrl,
        imagePath: imageFileName, // Store path for regeneration (signed URLs expire)
        updatedAt: new Date(),
      });

      // Step 4
      const job = await this.generationQueue.add('generate-3d-model', {
        productId,
        imageUrl,
        dimensions,
      });

      console.log(
        `Added job ${job.id} to generation queue for product ${productId}`,
      );

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

  /**
   * Regenerate 3D model using existing image
   * Handles both new products (with imagePath) and legacy products (with only imageUrl)
   */
  async regenerateModel(productId: string, dimensions: GenerateModelDto) {
    try {
      const db = this.firebaseService.getFirestore();
      const productDoc = await db.collection('products').doc(productId).get();

      if (!productDoc.exists) {
        throw new Error(`Product with ID ${productId} not found`);
      }

      const productData = productDoc.data();
      let imageUrl: string;

      if (productData?.imagePath) {
        console.log(`[Regen] Using imagePath: ${productData.imagePath}`);
        const storage = this.firebaseService.getStorage();
        const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
        const imageFileRef = bucket.file(productData.imagePath);

        const [freshSignedUrl] = await imageFileRef.getSignedUrl({
          action: 'read',
          expires: Date.now() + 60 * 60 * 1000, // 1 hour
        });
        imageUrl = freshSignedUrl;
        console.log(`[Regen] Generated fresh signed URL for ${productId}`);
      } else if (productData?.imageUrl) {
        // Legacy flow: Use existing imageUrl directly (may be public GCS URL)
        console.log(`[Regen] Using legacy imageUrl for ${productId}`);
        imageUrl = productData.imageUrl;

        // Try to extract path from GCS URL and backfill imagePath
        const gcsMatch = productData.imageUrl.match(
          /storage\.googleapis\.com\/[^/]+\/(.+?)(\?|$)/,
        );
        if (gcsMatch) {
          const extractedPath = decodeURIComponent(gcsMatch[1]);
          console.log(`[Regen] Backfilling imagePath: ${extractedPath}`);
          await db.collection('products').doc(productId).update({
            imagePath: extractedPath,
          });
        }
      } else {
        throw new Error(
          `Logic Error: Product ${productId} is missing a source image. ` +
          `Cannot generate 3D model from nothing. Check your upload logic.`,
        );
      }

      // Add job to generation queue
      const job = await this.generationQueue.add('generate-3d-model', {
        productId,
        imageUrl,
        dimensions,
      });

      console.log(`[Regen] Added job ${job.id} for product ${productId}`);

      // Update status
      await db.collection('products').doc(productId).update({
        modelStatus: 'processing',
        modelError: null, // Clear previous errors
        updatedAt: new Date(),
      });

      return {
        message: 'Regeneration started',
        jobId: job.id,
        status: 'processing',
      };
    } catch (error) {
      console.error('Error regenerating model:', error);
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
