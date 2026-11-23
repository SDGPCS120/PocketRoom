import { randomUUID } from 'node:crypto';
import { BadRequestException, ConflictException, ForbiddenException, HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { FirebaseService } from '../../../firebase/firebase.service.js';
import type { AuthUser } from '../../../modules/auth/types/auth-user.type';
import { GenerateModelDto } from './dto/generate-model.dto';
import { GenerationOwnershipService, type GenerationRequest } from './generation-ownership.service';

export type GenerationImage = {
  buffer: Buffer;
  mimetype: string;
};

@Injectable()
export class GenerationsService {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly ownership: GenerationOwnershipService,
    @InjectQueue('generation-queue') private readonly generationQueue: Queue,
  ) {}

  async generateModel(
    productId: string,
    user: AuthUser,
    imageFile: GenerationImage,
    dimensions: GenerateModelDto,
  ) {
    if (!user.authUid || user.isAnonymous) {
      throw new ForbiddenException('A seller account is required');
    }
    if (!productId || productId.includes('/') || productId === '.' || productId === '..') {
      throw new BadRequestException('Invalid product ID');
    }

    if (await this.generationQueue.getWaitingCount() >= 20) {
      throw new HttpException('Model generation queue is full; try again later', HttpStatus.TOO_MANY_REQUESTS);
    }

    const request: GenerationRequest = { productId, sellerId: user.uid, requestId: randomUUID() };
    await this.ownership.admit(request);

    try {
      const bucket = this.firebaseService.storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
      const extension = imageFile.mimetype === 'image/png' ? 'png' : 'jpg';
      const imagePath = `Images/${productId}_${request.requestId}.${extension}`;
      const imageRef = bucket.file(imagePath);
      await imageRef.save(imageFile.buffer, { metadata: { contentType: imageFile.mimetype } });
      const [imageUrl] = await imageRef.getSignedUrl({
        action: 'read',
        expires: Date.now() + 60 * 60 * 1000,
      });

      if (!await this.ownership.updateCurrent(request, { imagePath, updatedAt: new Date() })) {
        throw new ConflictException('This generation request is no longer current');
      }

      const job = await this.generationQueue.add('generate-3d-model', {
        ...request,
        imageUrl,
        dimensions,
      });

      return {
        message: 'Model generation started',
        jobId: job.id,
        productId,
        status: 'processing',
      };
    } catch (error) {
      await this.ownership.updateCurrent(request, {
        modelStatus: 'failed',
        modelError: 'Could not start model generation',
        updatedAt: new Date(),
      }).catch(() => undefined);
      throw error;
    }
  }
}
