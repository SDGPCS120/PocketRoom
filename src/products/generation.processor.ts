import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import axios from 'axios';
import FormData from 'form-data';
import { FirebaseService } from '../firebase/firebase.service';
import { optimizeGLB } from './utils/optimization.util';

interface GenerationJobData {
    productId: string;
    imageUrl: string;
    dimensions: {
        x: number;
        y: number;
        z: number;
    };
}

@Processor('generation-queue')
@Injectable()
export class GenerationProcessor extends WorkerHost {
    private readonly logger = new Logger(GenerationProcessor.name);

    constructor(private readonly firebaseService: FirebaseService) {
        super();
    }

    async process(job: Job<GenerationJobData>): Promise<any> {
        const { productId, imageUrl } = job.data;
        const apiKey = process.env.STABILITY_API_KEY;

        this.logger.log(`[StabilityAI] Starting Job ${job.id} for Product ${productId}`);

        if (!apiKey) {
            throw new Error('STABILITY_API_KEY is not set in environment variables');
        }

        try {
            // DOWNLOAD SOURCE IMAGE
            this.logger.log('[Processor] Downloading source image...');
            const imageResponse = await axios.get(imageUrl, { responseType: 'arraybuffer' });
            const imageBuffer = Buffer.from(imageResponse.data);
            this.logger.log(`[Processor] Downloaded image: ${imageBuffer.length} bytes`);

            // CALL API
            this.logger.log('[StabilityAI] Sending to Stable Fast 3D...');

            const formData = new FormData();
            formData.append('image', imageBuffer, { filename: 'input.jpg' });

            const aiResponse = await axios.post(
                'https://api.stability.ai/v2beta/3d/stable-fast-3d',
                formData,
                {
                    headers: {
                        ...formData.getHeaders(),
                        Authorization: `Bearer ${apiKey}`,
                    },
                    responseType: 'arraybuffer',
                },
            );

            if (aiResponse.status !== 200) {
                throw new Error(`Stability API Error: ${aiResponse.status}`);
            }

            this.logger.log(`[StabilityAI] Success! Received raw GLB.`);
            const rawGlbBuffer = Buffer.from(aiResponse.data);
            this.logger.log(`[StabilityAI] Raw GLB size: ${rawGlbBuffer.length} bytes`);

            // OPTIMIZATION (Draco Compression)
            this.logger.log('[Processor] Optimizing with Draco compression...');
            const optimizedBuffer = await optimizeGLB(rawGlbBuffer);
            this.logger.log(`[Processor] Optimized GLB size: ${optimizedBuffer.length} bytes`);

            // UPLOAD TO FIREBASE
            this.logger.log('[Processor] Uploading result to Firebase Storage...');
            const storage = this.firebaseService.getStorage();
            const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
            const filename = `3DModel/${productId}_${Date.now()}.glb`;
            const file = bucket.file(filename);

            await file.save(optimizedBuffer, {
                metadata: { contentType: 'model/gltf-binary' },
            });

            // Make the file publicly accessible
            await file.makePublic();

            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

            // UPDATE FIRESTORE
            this.logger.log('[Processor] Updating Firestore with modelURL and status...');
            const db = this.firebaseService.getFirestore();
            await db.collection('products').doc(productId).update({
                modelStatus: 'completed',
                modelURL: publicUrl,
                updatedAt: new Date(),
            });

            this.logger.log(`[Processor] Job ${job.id} Finished. URL: ${publicUrl}`);
            return { success: true, url: publicUrl };

        } catch (error) {
            this.logger.error(`[Processor] Job ${job.id} FAILED:`, error.message);

            // Log detailed API error if available
            if (error.response) {
                const errorDetails = error.response.data instanceof Buffer
                    ? error.response.data.toString()
                    : JSON.stringify(error.response.data);
                this.logger.error('[StabilityAI Error Details]:', errorDetails);
            }

            // Update Firestore with failed status
            const db = this.firebaseService.getFirestore();
            await db.collection('products').doc(productId).update({
                modelStatus: 'failed',
                modelError: error.message,
                updatedAt: new Date(),
            });

            throw error;
        }
    }
}
