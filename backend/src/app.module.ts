import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module.js';
import { FirebaseModule } from './firebase/firebase.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuthModule } from './modules/auth/auth.module.js';
import { ProductModule } from './modules/product/product.module.js';
import { OrderModule } from './modules/order/order.module.js';
import { StoreModule } from './modules/store/store.module';

@Module({
  imports: [AppConfigModule, FirebaseModule, AuthModule, ProductModule, OrderModule, StoreModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
