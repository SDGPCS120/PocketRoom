import { Module } from '@nestjs/common';
import { GenerationsService } from './generations.service';
import { GenerationsController } from './generations.controller';
import { FirebaseModule } from '../../../firebase/firebase.module';
import { BullModule } from '@nestjs/bullmq';
import { GenerationProcessor } from './generation.processor';
import { GenerationOwnershipService } from './generation-ownership.service';

@Module({
  imports: [
    FirebaseModule,
    BullModule.registerQueue({
      name: 'generation-queue',
    }),
  ],
  controllers: [GenerationsController],
  providers: [GenerationsService, GenerationProcessor, GenerationOwnershipService],
})
export class ModelGenerationModule {}
