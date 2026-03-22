import { Module } from '@nestjs/common';
import { FirebaseModule } from '../../firebase/firebase.module';
import { ReviewController } from './review.controller';
import { ReviewService } from './review.service';

@Module({
  imports: [FirebaseModule],
  controllers: [ReviewController],
  providers: [ReviewService],
})
export class ReviewModule {}
