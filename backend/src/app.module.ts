import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [AuthModule],
})
export class AppModule {
  constructor() {
    console.log('AppModule loaded (with AuthModule import)');
  }
}
