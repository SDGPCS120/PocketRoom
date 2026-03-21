import { Injectable } from '@nestjs/common';
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
}

