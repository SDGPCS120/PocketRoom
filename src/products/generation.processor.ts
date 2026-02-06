import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import axios from 'axios';

import { FirebaseService } from '../firebase/firebase.service';
import { optimizeGLB } from './utils/optimization.util';


@Processor('generation-queue')
export class GenerationProcessor extends WorkerHost {
    constructor(private readonly firebaseService: FirebaseService) {
        super();
    }

    async process(job: Job<any, any, string>): Promise<any> {
        const { imageUrl, productId } = job.data;
        const apiKey = process.env.TRIPO_API_KEY;

        console.log(`[Tripo] Starting Job ${job.id} for Product ${productId}`);

        try {
            // 1. START GENERATION TASK
            console.log(`[Tripo] Step 1: Sending Image: ${imageUrl}`);
            console.log('API Key present:', !!apiKey);

            const extension = imageUrl.split(/[#?]/)[0].split('.').pop()?.toLowerCase() || 'jpg';
            const fileType = ['png', 'jpg', 'jpeg', 'bmp'].includes(extension) ? (extension === 'jpeg' ? 'jpg' : extension) : 'jpg';

            // Use Tripo v1.4 for cost efficiency (30 credits)
            const payload = {
                type: 'image_to_model',
                file: {
                    type: fileType,
                    url: imageUrl
                },
                model_version: 'v1.4-20240625'
            };

            console.log(`[Tripo] Image URL being sent: ${imageUrl}`);
            console.log('[Tripo] ⚠️  If you get a 400 error, test this URL in Incognito mode first!');

            const startResponse = await axios.post(
                'https://api.tripo3d.ai/v2/openapi/task',
                payload,
                { headers: { Authorization: `Bearer ${apiKey}` } }
            );

            const taskId = startResponse.data.data.task_id;
            console.log(`[Tripo] Task Started. ID: ${taskId}`);

            // 2. POLL FOR COMPLETION (Wait Loop)
            let modelUrl = '';
            let attempts = 0;
            const maxAttempts = 36; // Wait max 3 minutes (5s * 36)

            while (attempts < maxAttempts) {
                await new Promise(resolve => setTimeout(resolve, 5000)); // Wait 5 seconds (avoid API throttling)

                const statusResponse = await axios.get(
                    `https://api.tripo3d.ai/v2/openapi/task/${taskId}`,
                    { headers: { Authorization: `Bearer ${apiKey}` } }
                );

                const status = statusResponse.data.data.status; // queuing, running, success, failed

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

            // 3. DOWNLOAD & OPTIMIZE
            console.log('\n[Processor] Step 3: Downloading & Optimizing...');
            const modelBuffer = await axios.get(modelUrl, { responseType: 'arraybuffer' });
            const optimizedBuffer = await optimizeGLB(Buffer.from(modelBuffer.data));

            // 4. UPLOAD TO FIREBASE & UPDATE DB
            console.log('[Processor] Step 4: Saving to Firebase...');
            const bucket = this.firebaseService.getStorage().bucket();
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
                updatedAt: new Date()
            });

            console.log(`[Processor] Job Finished. URL: ${publicUrl}`);
            return { success: true, url: publicUrl };

        } catch (error) {
            console.error(`[Processor] FAILED:`, error.response?.data || error.message);

            const db = this.firebaseService.getFirestore();
            await db.collection('products').doc(productId).update({
                modelStatus: 'failed',
                modelError: error.response?.data ? JSON.stringify(error.response.data) : error.message,
                updatedAt: new Date()
            });
            throw error;
        }
    }
}

