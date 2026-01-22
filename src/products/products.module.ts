import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { FirebaseModule } from '../firebase/firebase.module';
import { BullModule } from '@nestjs/bullmq';
import { GenerationProcessor } from './generation.processor';

@Module({
  imports: [
    FirebaseModule,
    BullModule.registerQueue({
      name: 'generation-queue',
    }),
  ],
  controllers: [ProductsController],
  providers: [ProductsService, GenerationProcessor],
})
export class ProductsModule { }
