import { Module } from '@nestjs/common';
import { FirebaseModule } from '../../firebase/firebase.module.js';
import { CartController } from './cart.controller';
import { CartService } from './cart.service';

@Module({
  imports: [FirebaseModule],
  controllers: [CartController],
  providers: [CartService],
  exports: [CartService],
})
export class CartModule {}