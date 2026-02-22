import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module.js';
import { FirebaseModule } from './firebase/firebase.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuthModule } from './modules/auth/auth.module.js';

@Module({
  imports: [AppConfigModule, FirebaseModule, AuthModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
