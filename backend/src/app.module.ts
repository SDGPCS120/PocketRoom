import { Module } from '@nestjs/common';
<<<<<<< HEAD
import { AppConfigModule } from './config/config.module.js';
import { FirebaseModule } from './firebase/firebase.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuthModule } from './modules/auth/auth.module.js';

@Module({
  imports: [AppConfigModule, FirebaseModule, AuthModule],
  controllers: [AppController],
  providers: [AppService],
=======
import { AuthModule } from './auth/auth.module';
import { OrderModule } from './order/order.module';

@Module({
  imports: [AuthModule, OrderModule],
>>>>>>> c83ae18 (chore: add remaining DTOs and validation updates)
})
export class AppModule {}
