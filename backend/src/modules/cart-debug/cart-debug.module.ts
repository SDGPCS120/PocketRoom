import { Module } from '@nestjs/common';
import { CartModule } from '../cart/cart.module.js';
import { CartDebugController } from './cart-debug.controller.js';
import { CartDebugService } from './cart-debug.service.js';

@Module({
  imports: [CartModule],
  controllers: [CartDebugController],
  providers: [CartDebugService],
})
export class CartDebugModule {}
