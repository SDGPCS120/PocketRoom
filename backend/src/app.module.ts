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

@Module({
  imports: [
    AppConfigModule,
    FirebaseModule,
    AuthModule,
    OrderModule,
    UserModule,
    AddressModule,
    ProductModule,
    StoreModule,
    CartModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
