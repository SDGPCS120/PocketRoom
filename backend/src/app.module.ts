import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module.js';
import { FirebaseModule } from './firebase/firebase.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuthModule } from './modules/auth/auth.module.js';
import { OrderModule } from './modules/order/order.module.js';
import { UserModule } from './modules/user/user.module.js';
import { AddressModule } from './modules/address/address.module';
import { CategoryModule } from './modules/category/category.module';

@Module({
  imports: [
    AppConfigModule,
    FirebaseModule,
    AuthModule,
    OrderModule,
    UserModule,
    AddressModule,
    CategoryModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}