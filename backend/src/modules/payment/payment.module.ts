import { Module } from '@nestjs/common';
import { FirebaseModule } from '../../firebase/firebase.module';
import { PaymentController } from './payment.controller';
import { PaymentService } from './payment.service';

@Module({
  imports: [FirebaseModule],
  controllers: [PaymentController],
  providers: [PaymentService],
})
export class PaymentModule {}