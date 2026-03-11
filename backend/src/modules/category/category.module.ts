import { Module } from '@nestjs/common';
import { FirebaseModule } from '../../firebase/firebase.module.js';
import { CategoryController } from './category.controller';
import { CategoryService } from './category.service';

@Module({
  imports: [FirebaseModule],
  controllers: [CategoryController],
  providers: [CategoryService],
  exports: [CategoryService],
})
export class CategoryModule {}