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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProductsService = void 0;
const common_1 = require("@nestjs/common");
const firebase_service_1 = require("../firebase/firebase.service");
const bullmq_1 = require("@nestjs/bullmq");
const bullmq_2 = require("bullmq");
let ProductsService = class ProductsService {
    firebaseService;
    generationQueue;
    constructor(firebaseService, generationQueue) {
        this.firebaseService = firebaseService;
        this.generationQueue = generationQueue;
    }
    async create(createProductDto) {
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
            }
            else {
                const docRef = await db.collection('products').add({
                    ...createProductDto,
                    createdAt: new Date(),
                    modelStatus: 'pending',
                });
                return { id: docRef.id, message: 'Product created' };
            }
        }
        catch (error) {
            console.error('Error creating product:', error);
            throw error;
        }
    }
    async uploadProductImage(productId, fileBuffer, mimeType) {
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
            const [signedUrl] = await imageFileRef.getSignedUrl({
                action: 'read',
                expires: Date.now() + 60 * 60 * 1000 * 24 * 365,
            });
            return {
                imageUrl: signedUrl,
                imagePath: imageFileName,
            };
        }
        catch (error) {
            console.error('Error uploading product image:', error);
            throw error;
        }
    }
    async generateModel(productId, imageFile, dimensions) {
        try {
            const db = this.firebaseService.getFirestore();
            const productDoc = await db.collection('products').doc(productId).get();
            if (!productDoc.exists) {
                throw new Error(`Product with ID ${productId} not found`);
            }
            const storage = this.firebaseService.getStorage();
            const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
            const imageFileName = `Images/${productId}_${Date.now()}.jpg`;
            const imageFileRef = bucket.file(imageFileName);
            await imageFileRef.save(imageFile.buffer, {
                metadata: {
                    contentType: imageFile.mimetype,
                },
            });
            const [signedUrl] = await imageFileRef.getSignedUrl({
                action: 'read',
                expires: Date.now() + 60 * 60 * 1000,
            });
            const imageUrl = signedUrl;
            await db.collection('products').doc(productId).update({
                modelStatus: 'processing',
                imageUrl: imageUrl,
                imagePath: imageFileName,
                updatedAt: new Date(),
            });
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
        }
        catch (error) {
            console.error('Error initiating model generation:', error);
            throw error;
        }
    }
    async regenerateModel(productId, dimensions) {
        try {
            const db = this.firebaseService.getFirestore();
            const productDoc = await db.collection('products').doc(productId).get();
            if (!productDoc.exists) {
                throw new Error(`Product with ID ${productId} not found`);
            }
            const productData = productDoc.data();
            let imageUrl;
            if (productData?.imagePath) {
                console.log(`[Regen] Using imagePath: ${productData.imagePath}`);
                const storage = this.firebaseService.getStorage();
                const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
                const imageFileRef = bucket.file(productData.imagePath);
                const [freshSignedUrl] = await imageFileRef.getSignedUrl({
                    action: 'read',
                    expires: Date.now() + 60 * 60 * 1000,
                });
                imageUrl = freshSignedUrl;
                console.log(`[Regen] Generated fresh signed URL for ${productId}`);
            }
            else if (productData?.imageUrl) {
                console.log(`[Regen] Using legacy imageUrl for ${productId}`);
                imageUrl = productData.imageUrl;
                const gcsMatch = productData.imageUrl.match(/storage\.googleapis\.com\/[^/]+\/(.+?)(\?|$)/);
                if (gcsMatch) {
                    const extractedPath = decodeURIComponent(gcsMatch[1]);
                    console.log(`[Regen] Backfilling imagePath: ${extractedPath}`);
                    await db.collection('products').doc(productId).update({
                        imagePath: extractedPath,
                    });
                }
            }
            else {
                throw new Error(`Logic Error: Product ${productId} is missing a source image. ` +
                    `Cannot generate 3D model from nothing. Check your upload logic.`);
            }
            const job = await this.generationQueue.add('generate-3d-model', {
                productId,
                imageUrl,
                dimensions,
            });
            console.log(`[Regen] Added job ${job.id} for product ${productId}`);
            await db.collection('products').doc(productId).update({
                modelStatus: 'processing',
                modelError: null,
                updatedAt: new Date(),
            });
            return {
                message: 'Regeneration started',
                jobId: job.id,
                status: 'processing',
            };
        }
        catch (error) {
            console.error('Error regenerating model:', error);
            throw error;
        }
    }
    async findAll() {
        const db = this.firebaseService.getFirestore();
        const snapshot = await db.collection('products').get();
        return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    }
    async findOne(id) {
        const db = this.firebaseService.getFirestore();
        const doc = await db.collection('products').doc(id).get();
        if (!doc.exists) {
            throw new Error(`Product with ID ${id} not found`);
        }
        return { id: doc.id, ...doc.data() };
    }
    async update(id, updateProductDto) {
        const db = this.firebaseService.getFirestore();
        const docRef = db.collection('products').doc(id);
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
    async remove(id) {
        const db = this.firebaseService.getFirestore();
        const docRef = db.collection('products').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            throw new Error(`Product with ID ${id} not found`);
        }
        await docRef.delete();
        return { id, message: 'Product deleted successfully' };
    }
};
exports.ProductsService = ProductsService;
exports.ProductsService = ProductsService = __decorate([
    (0, common_1.Injectable)(),
    __param(1, (0, bullmq_1.InjectQueue)('generation-queue')),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService,
        bullmq_2.Queue])
], ProductsService);
//# sourceMappingURL=products.service.js.map