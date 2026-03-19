import { Module } from '@nestjs/common';
import { GenerationsService } from './generations.service';
import { GenerationsController } from './generations.controller';
import { FirebaseModule } from '../../../firebase/firebase.module';
import { BullModule } from '@nestjs/bullmq';
import { GenerationProcessor } from './generation.processor';

@Module({
  imports: [
    FirebaseModule,
    BullModule.registerQueue({
      name: 'generation-queue',
    }),
  ],
  controllers: [GenerationsController],
  providers: [GenerationsService, GenerationProcessor],
})
export class ModelGenerationModule {}
