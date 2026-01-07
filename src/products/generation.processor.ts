import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { FirebaseService } from '../firebase/firebase.service';
import { optimizeGLB } from './utils/optimization.util';
import * as fs from 'fs';
import * as path from 'path';

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

    async process(job: Job<GenerationJobData>): Promise<void> {
        this.logger.log(`Processing job ${job.id} for product ${job.data.productId}`);
        const { productId, imageUrl, dimensions } = job.data;

        try {
            // Step A: Mock AI Response (Simulating Hugging Face Inference)
            this.logger.log('Step A: Generating 3D model (MOCKED)...');
            const rawGLBBuffer = await this.mockAIGeneration(imageUrl, dimensions);

            // Step B: Optimization with Draco Compression
            this.logger.log('Step B: Optimizing GLB with Draco compression...');
            const optimizedGLBBuffer = await optimizeGLB(rawGLBBuffer);

            // Step C: Upload to Firebase Storage
            this.logger.log('Step C: Uploading optimized GLB to Firebase Storage...');
            const modelURL = await this.uploadToStorage(productId, optimizedGLBBuffer);

            // Step D: Update Firestore
            this.logger.log('Step D: Updating Firestore with modelURL and status...');
            await this.updateProductStatus(productId, modelURL, 'completed');

            this.logger.log(`Job ${job.id} completed successfully!`);
        } catch (error) {
            this.logger.error(`Job ${job.id} failed:`, error);

            // Update status to failed
            await this.updateProductStatus(productId, null, 'failed');

            throw error; // Rethrow to mark job as failed in BullMQ
        }
    }

    /**
     * Mock AI generation - simulates Hugging Face returning a GLB buffer
     * In production, this would call the actual Hugging Face Inference Endpoint
     */
    private async mockAIGeneration(
        imageUrl: string,
        dimensions: { x: number; y: number; z: number },
    ): Promise<Buffer> {
        this.logger.log(`Mock AI: Processing image ${imageUrl} with dimensions ${JSON.stringify(dimensions)}`);

        // Simulate API delay
        await new Promise((resolve) => setTimeout(resolve, 2000));

        // Create a simple mock GLB file (minimal valid GLB structure)
        // In production, this would be: const response = await axios.post(HUGGING_FACE_URL, {...})
        const mockGLB = this.createMockGLB();

        this.logger.log('Mock AI: Generated dummy GLB buffer');
        return mockGLB;
    }

    /**
     * Creates a minimal valid GLB buffer for testing
     */
    private createMockGLB(): Buffer {
        // This is a minimal GLB header + JSON chunk
        // Real GLB would come from the AI service
        const json = {
            asset: { version: '2.0', generator: 'Mock Generator' },
            scene: 0,
            scenes: [{ nodes: [0] }],
            nodes: [{ mesh: 0 }],
            meshes: [
                {
                    primitives: [
                        {
                            attributes: { POSITION: 0 },
                            mode: 4,
                        },
                    ],
                },
            ],
            accessors: [
                {
                    bufferView: 0,
                    componentType: 5126,
                    count: 3,
                    type: 'VEC3',
                    max: [1, 1, 0],
                    min: [-1, -1, 0],
                },
            ],
            bufferViews: [{ buffer: 0, byteOffset: 0, byteLength: 36 }],
            buffers: [{ byteLength: 36 }],
        };

        const jsonString = JSON.stringify(json);
        const jsonBuffer = Buffer.from(jsonString);
        const jsonPadding = (4 - (jsonBuffer.length % 4)) % 4;
        const jsonChunkLength = jsonBuffer.length + jsonPadding;

        // Binary data (simple triangle vertices)
        const binaryData = new Float32Array([
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0,
            0.0, 1.0, 0.0,
        ]);
        const binaryBuffer = Buffer.from(binaryData.buffer);

        // GLB header
        const header = Buffer.alloc(12);
        header.writeUInt32LE(0x46546c67, 0); // magic: "glTF"
        header.writeUInt32LE(2, 4); // version: 2
        header.writeUInt32LE(12 + 8 + jsonChunkLength + 8 + binaryBuffer.length, 8); // total length

        // JSON chunk header
        const jsonChunkHeader = Buffer.alloc(8);
        jsonChunkHeader.writeUInt32LE(jsonChunkLength, 0);
        jsonChunkHeader.writeUInt32LE(0x4e4f534a, 4); // "JSON"

        // Binary chunk header
        const binaryChunkHeader = Buffer.alloc(8);
        binaryChunkHeader.writeUInt32LE(binaryBuffer.length, 0);
        binaryChunkHeader.writeUInt32LE(0x004e4942, 4); // "BIN\0"

        // Padding
        const padding = Buffer.alloc(jsonPadding, 0x20);

        return Buffer.concat([
            header,
            jsonChunkHeader,
            jsonBuffer,
            padding,
            binaryChunkHeader,
            binaryBuffer,
        ]);
    }

    /**
     * Upload optimized GLB to Firebase Storage
     */
    private async uploadToStorage(productId: string, buffer: Buffer): Promise<string> {
        const storage = this.firebaseService.getStorage();
        const bucket = storage.bucket();
        const fileName = `models/${productId}.glb`;
        const file = bucket.file(fileName);

        await file.save(buffer, {
            metadata: {
                contentType: 'model/gltf-binary',
            },
        });

        // Make the file publicly accessible (optional - adjust based on security needs)
        await file.makePublic();

        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
        this.logger.log(`Uploaded GLB to: ${publicUrl}`);

        return publicUrl;
    }

    /**
     * Update product status in Firestore
     */
    private async updateProductStatus(
        productId: string,
        modelURL: string | null,
        status: 'processing' | 'completed' | 'failed',
    ): Promise<void> {
        const db = this.firebaseService.getFirestore();
        const updateData: any = {
            modelStatus: status,
            updatedAt: new Date(),
        };

        if (modelURL) {
            updateData.modelURL = modelURL;
        }

        await db.collection('products').doc(productId).update(updateData);
        this.logger.log(`Updated product ${productId} status to: ${status}`);
    }
}
