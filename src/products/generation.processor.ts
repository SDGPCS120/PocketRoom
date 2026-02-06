import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import axios from 'axios';
import { Logger } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { optimizeGLB } from './utils/optimization.util';

interface GenerationJobData {
  productId: string;
  imageUrl: string;
  dimensions?: any;
}

@Processor('generation-queue')
export class GenerationProcessor extends WorkerHost {
  private readonly logger = new Logger(GenerationProcessor.name);

  constructor(private readonly firebaseService: FirebaseService) {
    super();
  }

  async process(job: Job<GenerationJobData, any, string>): Promise<any> {
    const { productId, imageUrl } = job.data;
    const apiKey = process.env.TRIPO_API_KEY;

    this.logger.log(`[Tripo] Starting Job ${job.id} for Product ${productId}`);

    try {
      if (!apiKey) {
        throw new Error('TRIPO_API_KEY is not set in environment variables');
      }

      // ---------------------------------------------------------
      // 1. START GENERATION TASK
      // ---------------------------------------------------------
      this.logger.log(`[Tripo] Step 1: Sending Image: ${imageUrl}`);

      const extension =
        imageUrl.split(/[#?]/)[0].split('.').pop()?.toLowerCase() || 'jpg';
      const fileType = ['png', 'jpg', 'jpeg', 'bmp'].includes(extension)
        ? extension === 'jpeg'
          ? 'jpg'
          : extension
        : 'jpg';

      // Use Tripo v1.4 for cost efficiency (~25-30 credits vs ~250 for v2)
      const payload = {
        type: 'image_to_model',
        file: {
          type: fileType,
          url: imageUrl,
        },
        model_version: 'v1.4-20240625',
      };

      this.logger.log(`[Tripo] Image URL being sent: ${imageUrl}`);

      const startResponse = await axios.post(
        'https://api.tripo3d.ai/v2/openapi/task',
        payload,
        { headers: { Authorization: `Bearer ${apiKey}` } },
      );

      const taskId = startResponse.data.data.task_id;
      this.logger.log(`[Tripo] Task Started. ID: ${taskId}`);

      // ---------------------------------------------------------
      // 2. POLL FOR COMPLETION (Wait Loop)
      // ---------------------------------------------------------
      let modelUrl = '';
      let attempts = 0;
      const maxAttempts = 36; // Wait max 3 minutes (5s * 36)

      while (attempts < maxAttempts) {
        await new Promise((resolve) => setTimeout(resolve, 5000));

        const statusResponse = await axios.get(
          `https://api.tripo3d.ai/v2/openapi/task/${taskId}`,
          { headers: { Authorization: `Bearer ${apiKey}` } },
        );

        const status = statusResponse.data.data.status;

        if (status === 'success') {
          modelUrl = statusResponse.data.data.output.model;
          this.logger.log('[Tripo] Generation Successful!');
          break;
        } else if (status === 'failed') {
          throw new Error('Tripo Generation Failed');
        } else {
          process.stdout.write('.');
          attempts++;
        }
      }

      if (!modelUrl) throw new Error('Timeout waiting for Tripo');

      // ---------------------------------------------------------
      // 3. DOWNLOAD & OPTIMIZE
      // ---------------------------------------------------------
      this.logger.log('[Processor] Step 3: Downloading & Optimizing...');
      const modelBuffer = await axios.get(modelUrl, {
        responseType: 'arraybuffer',
      });
      const optimizedBuffer = await optimizeGLB(Buffer.from(modelBuffer.data));

      // ---------------------------------------------------------
      // 4. UPLOAD TO FIREBASE & UPDATE DB
      // ---------------------------------------------------------
      this.logger.log('[Processor] Step 4: Saving to Firebase...');
      const storage = this.firebaseService.getStorage();
      const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
      const filename = `3DModel/${productId}_${Date.now()}.glb`;
      const file = bucket.file(filename);

      await file.save(optimizedBuffer, {
        metadata: { contentType: 'model/gltf-binary' },
        public: true,
      });

      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

      const db = this.firebaseService.getFirestore();
      await db.collection('products').doc(productId).update({
        modelStatus: 'completed',
        modelURL: publicUrl,
        updatedAt: new Date(),
      });

      this.logger.log(`[Processor] Job Finished. URL: ${publicUrl}`);
      return { success: true, url: publicUrl };
    } catch (error: any) {
      const errorMessage = error.response?.data
        ? JSON.stringify(error.response.data)
        : error.message;
      this.logger.error(`[Processor] FAILED:`, errorMessage);

      const db = this.firebaseService.getFirestore();
      await db.collection('products').doc(productId).update({
        modelStatus: 'failed',
        modelError: errorMessage,
        updatedAt: new Date(),
      });
      throw error;
    }
  }
}
