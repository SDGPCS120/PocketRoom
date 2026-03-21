import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';

@Injectable()
export class ReviewService {
  constructor(private readonly firebase: FirebaseService) {}

  private collection() {
    return this.firebase.firestore.collection('reviews');
  }

  // CRUD methods to be implemented
}
