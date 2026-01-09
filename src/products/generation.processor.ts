import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import axios from 'axios';
<<<<<<< HEAD
import FormData from 'form-data';
=======
>>>>>>> 9e3ad75 (using Tripo instead of Stable fast)
import { FirebaseService } from '../firebase/firebase.service';
import { optimizeGLB } from './utils/optimization.util';


@Processor('generation-queue')
export class GenerationProcessor extends WorkerHost {
    constructor(private readonly firebaseService: FirebaseService) {
        super();
    }

<<<<<<< HEAD
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

            // CALL API: BACKGROUND REMOVAL
            this.logger.log('[StabilityAI] Removing background...');
            const removeBgFormData = new FormData();
            removeBgFormData.append('image', imageBuffer, { filename: 'input.jpg' });
            removeBgFormData.append('output_format', 'webp'); // Stability recommends webp/png for transparency

            const removeBgResponse = await axios.post(
                'https://api.stability.ai/v2beta/stable-image/edit/remove-background',
                removeBgFormData,
                {
                    headers: {
                        ...removeBgFormData.getHeaders(),
                        Authorization: `Bearer ${apiKey}`,
                        Accept: 'image/*'
                    },
                    responseType: 'arraybuffer',
                },
            );

            if (removeBgResponse.status !== 200) {
                throw new Error(`Stability Background Removal Error: ${removeBgResponse.status}`);
            }

            const cleanImageBuffer = Buffer.from(removeBgResponse.data);
            this.logger.log(`[StabilityAI] Background removed. Clean image size: ${cleanImageBuffer.length} bytes`);

            // CALL API: STABLE FAST 3D
            this.logger.log('[StabilityAI] Sending to Stable Fast 3D...');

            const formData = new FormData();
            formData.append('image', cleanImageBuffer, { filename: 'input.webp' });

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
=======
    async process(job: Job<any, any, string>): Promise<any> {
        const { imageUrl, productId } = job.data;
        const apiKey = process.env.TRIPO_API_KEY;

        console.log(`[Tripo] Starting Job ${job.id} for Product ${productId}`);

        try {
            // ---------------------------------------------------------
            // 1. START GENERATION TASK
            // ---------------------------------------------------------
            console.log(`[Tripo] Step 1: Sending Image: ${imageUrl}`);
            console.log('API Key present:', !!apiKey);

            const extension = imageUrl.split(/[#?]/)[0].split('.').pop()?.toLowerCase() || 'jpg';
            const fileType = ['png', 'jpg', 'jpeg', 'bmp'].includes(extension) ? (extension === 'jpeg' ? 'jpg' : extension) : 'jpg';

            const payload = {
                type: 'image_to_model',
                file: {
                    type: fileType,
                    url: imageUrl
                }
            };
            require('fs').writeFileSync('C:\\Users\\abdur\\Documents\\GitHub\\3D_generation_Pipeline\\debug_payload.json', JSON.stringify(payload, null, 2));
            console.error('[Tripo] Payload written to debug_payload.json');

            const startResponse = await axios.post(
                'https://api.tripo3d.ai/v2/openapi/task', // V2 API Endpoint
                payload,
                { headers: { Authorization: `Bearer ${apiKey}` } }
            );

            const taskId = startResponse.data.data.task_id;
            console.log(`[Tripo] Task Started. ID: ${taskId}`);

            // ---------------------------------------------------------
            // 2. POLL FOR COMPLETION (Wait Loop)
            // ---------------------------------------------------------
            let modelUrl = '';
            let attempts = 0;
            const maxAttempts = 60; // Wait max 2 minutes (2s * 60)

            while (attempts < maxAttempts) {
                await new Promise(resolve => setTimeout(resolve, 2000)); // Wait 2 seconds

                const statusResponse = await axios.get(
                    `https://api.tripo3d.ai/v2/openapi/task/${taskId}`,
                    { headers: { Authorization: `Bearer ${apiKey}` } }
                );

                const status = statusResponse.data.data.status; // 'queuing', 'running', 'success', 'failed'

                if (status === 'success') {
                    // Tripo returns a .glb URL in the result
                    modelUrl = statusResponse.data.data.output.model;
                    console.log('[Tripo] Generation Successful!');
                    break;
                } else if (status === 'failed') {
                    throw new Error('Tripo Generation Failed');
                } else {
                    process.stdout.write('.'); // Show progress dot
                    attempts++;
                }
            }

            if (!modelUrl) throw new Error('Timeout waiting for Tripo');

            // ---------------------------------------------------------
            // 3. DOWNLOAD & OPTIMIZE
            // ---------------------------------------------------------
            console.log('\n[Processor] Step 3: Downloading & Optimizing...');
            const modelBuffer = await axios.get(modelUrl, { responseType: 'arraybuffer' });
            const optimizedBuffer = await optimizeGLB(Buffer.from(modelBuffer.data));

            // ---------------------------------------------------------
            // 4. UPLOAD TO FIREBASE & UPDATE DB
            // ---------------------------------------------------------
            console.log('[Processor] Step 4: Saving to Firebase...');
            const bucket = this.firebaseService.getStorage().bucket();
            const filename = `models/${productId}_${Date.now()}.glb`;
>>>>>>> 9e3ad75 (using Tripo instead of Stable fast)
            const file = bucket.file(filename);

            await file.save(optimizedBuffer, {
                metadata: { contentType: 'model/gltf-binary' },
<<<<<<< HEAD
            });

            // Make the file publicly accessible
            await file.makePublic();

            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

            // UPDATE FIRESTORE
            this.logger.log('[Processor] Updating Firestore with modelURL and status...');
=======
                public: true,
            });

            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

>>>>>>> 9e3ad75 (using Tripo instead of Stable fast)
            const db = this.firebaseService.getFirestore();
            await db.collection('products').doc(productId).update({
                modelStatus: 'completed',
                modelURL: publicUrl,
<<<<<<< HEAD
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

=======
                updatedAt: new Date()
            });

            console.log(`[Processor] Job Finished. URL: ${publicUrl}`);
            return { success: true, url: publicUrl };

        } catch (error) {
            console.error(`[Processor] FAILED:`, error.response?.data || error.message);

            const db = this.firebaseService.getFirestore();
            await db.collection('products').doc(productId).update({
                modelStatus: 'failed',
                modelError: error.response?.data ? JSON.stringify(error.response.data) : error.message
            });
>>>>>>> 9e3ad75 (using Tripo instead of Stable fast)
            throw error;
        }
    }
}
