import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewService {
  constructor(private readonly firebase: FirebaseService) {}

  private collection() {
    return this.firebase.firestore.collection('reviews');
  }

  async createReview(userId: string, dto: CreateReviewDto) {
    const docRef = this.collection().doc();

    const data = {
      reviewId: docRef.id,
      userId,
      ...dto,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    await docRef.set(data);
    return data;
  }

  async getReviewsByProductId(productId: string) {
    const snapshot = await this.collection()
      .where('productId', '==', productId)
      .get();

    return snapshot.docs.map((doc: any) => doc.data());
  }

  async updateReview(reviewId: string, userId: string, dto: Partial<CreateReviewDto>) {
    const docRef = this.collection().doc(reviewId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException('Review not found');
    }

    const review = doc.data();

    if (review?.userId !== userId) {
      throw new ForbiddenException('You do not own this review');
    }

    const updateData: any = {};
    if (dto.rating !== undefined) updateData.rating = dto.rating;
    if (dto.comment !== undefined) updateData.comment = dto.comment;
    updateData.updatedAt = new Date();

    await docRef.update(updateData);

    return { message: 'Review updated successfully' };
  }

  async deleteReview(reviewId: string, userId: string) {
    const docRef = this.collection().doc(reviewId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new NotFoundException('Review not found');
    }

    const review = doc.data();

    if (review?.userId !== userId) {
      throw new ForbiddenException('You do not own this review');
    }

    await docRef.delete();

    return { message: 'Review deleted successfully' };
  }
}

