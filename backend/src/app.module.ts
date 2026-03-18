import { Module } from '@nestjs/common';
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
import { PaymentModule } from './modules/payment/payment.module.js';
import { BudgetModule } from './features/budget/budget.module.js';

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
    BudgetModule,
  ],

  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
