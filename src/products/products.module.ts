import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { FirebaseModule } from '../firebase/firebase.module';

@Module({
  imports: [FirebaseModule], // Import FirebaseModule to use FirebaseService
  controllers: [ProductsController],
  providers: [ProductsService],
})
export class ProductsModule { }
