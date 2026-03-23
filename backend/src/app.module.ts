import { Module } from '@nestjs/common';
import * as dotenv from 'dotenv';
import { AppConfigModule } from './config/config.module.js';
import { FirebaseModule } from './firebase/firebase.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuthModule } from './modules/auth/auth.module.js';
import { ProductModule } from './modules/product/product.module.js';
import { OrderModule } from './modules/order/order.module.js';
import { UserModule } from './modules/user/user.module.js';
import { AddressModule } from './modules/address/address.module.js';
import { StoreModule } from './modules/store/store.module.js';
import { CartModule } from './modules/cart/cart.module.js';
import { CartDebugModule } from './modules/cart-debug/cart-debug.module.js';
import { CategoryModule } from './modules/category/category.module.js';
import { ReviewModule } from './modules/review/review.module.js';
import { PaymentModule } from './modules/payment/payment.module.js';
import { BullModule } from '@nestjs/bullmq';
import { ModelGenerationModule } from './features/modelGenerationPipeline/generation/generations.module.js';
import { BudgetModule } from './features/budget/budget.module.js';
import { SearchModule } from './features/search/search.module.js';

dotenv.config();

const redisEnabled =
  process.env.REDIS_ENABLED === 'true' || process.env.NODE_ENV === 'production';

@Module({
  imports: [
    AppConfigModule,
    FirebaseModule,
    AuthModule,
    OrderModule,
    PaymentModule,
    UserModule,
    AddressModule,
    ProductModule,
    StoreModule,
    CartModule,
    CartDebugModule,
    CategoryModule,
    ReviewModule,
    BudgetModule,
    SearchModule,
    ...(
      redisEnabled
        ? [
            BullModule.forRoot({
              connection: {
                host: process.env.REDIS_HOST || 'localhost',
                port: parseInt(process.env.REDIS_PORT || '6379', 10),
              },
            }),
            ModelGenerationModule,
          ]
        : []
    ),
  ],

  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
