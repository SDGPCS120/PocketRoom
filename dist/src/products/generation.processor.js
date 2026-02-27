"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var GenerationProcessor_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.GenerationProcessor = void 0;
const bullmq_1 = require("@nestjs/bullmq");
const axios_1 = __importDefault(require("axios"));
const common_1 = require("@nestjs/common");
const firebase_service_1 = require("../firebase/firebase.service");
const optimization_util_1 = require("./utils/optimization.util");
let GenerationProcessor = GenerationProcessor_1 = class GenerationProcessor extends bullmq_1.WorkerHost {
    firebaseService;
    logger = new common_1.Logger(GenerationProcessor_1.name);
    constructor(firebaseService) {
        super();
        this.firebaseService = firebaseService;
    }
    async process(job) {
        const { productId, imageUrl } = job.data;
        const apiKey = process.env.TRIPO_API_KEY;
        this.logger.log(`[Tripo] Starting Job ${job.id} for Product ${productId}`);
        try {
            if (!apiKey) {
                throw new Error('TRIPO_API_KEY is not set in environment variables');
            }
            this.logger.log(`[Tripo] Step 1: Sending Image: ${imageUrl}`);
            const extension = imageUrl.split(/[#?]/)[0].split('.').pop()?.toLowerCase() || 'jpg';
            const fileType = ['png', 'jpg', 'jpeg', 'bmp'].includes(extension)
                ? extension === 'jpeg'
                    ? 'jpg'
                    : extension
                : 'jpg';
            const payload = {
                type: 'image_to_model',
                file: {
                    type: fileType,
                    url: imageUrl,
                },
                model_version: 'v1.4-20240625',
            };
            this.logger.log(`[Tripo] Image URL being sent: ${imageUrl}`);
            const startResponse = await axios_1.default.post('https://api.tripo3d.ai/v2/openapi/task', payload, { headers: { Authorization: `Bearer ${apiKey}` } });
            const taskId = startResponse.data.data.task_id;
            this.logger.log(`[Tripo] Task Started. ID: ${taskId}`);
            let modelUrl = '';
            let attempts = 0;
            const maxAttempts = 36;
            while (attempts < maxAttempts) {
                await new Promise((resolve) => setTimeout(resolve, 5000));
                const statusResponse = await axios_1.default.get(`https://api.tripo3d.ai/v2/openapi/task/${taskId}`, { headers: { Authorization: `Bearer ${apiKey}` } });
                const status = statusResponse.data.data.status;
                if (status === 'success') {
                    modelUrl = statusResponse.data.data.output.model;
                    this.logger.log('[Tripo] Generation Successful!');
                    break;
                }
                else if (status === 'failed') {
                    throw new Error('Tripo Generation Failed');
                }
                else {
                    process.stdout.write('.');
                    attempts++;
                }
            }
            if (!modelUrl)
                throw new Error('Timeout waiting for Tripo');
            this.logger.log('[Processor] Step 3: Downloading & Optimizing...');
            const modelBuffer = await axios_1.default.get(modelUrl, {
                responseType: 'arraybuffer',
            });
            const optimizedBuffer = await (0, optimization_util_1.optimizeGLB)(Buffer.from(modelBuffer.data));
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
        }
        catch (error) {
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
};
exports.GenerationProcessor = GenerationProcessor;
exports.GenerationProcessor = GenerationProcessor = GenerationProcessor_1 = __decorate([
    (0, bullmq_1.Processor)('generation-queue'),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService])
], GenerationProcessor);
//# sourceMappingURL=generation.processor.js.map