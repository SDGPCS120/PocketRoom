import { Module } from '@nestjs/common';
import { FirebaseModule } from '../../firebase/firebase.module.js';
import { CartController } from './cart.controller.js';
import { CartService } from './cart.service.js';

@Module({
  imports: [FirebaseModule],
  controllers: [CartController],
  providers: [CartService],
  exports: [CartService],
})
export class CartModule {}
