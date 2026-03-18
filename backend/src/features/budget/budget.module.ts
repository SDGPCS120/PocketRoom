import { Module } from '@nestjs/common';
import { BudgetController } from './budget.controller';
import { BudgetService } from './budget.service';
import { FirebaseService } from '../../firebase/firebase.service';

@Module({
  controllers: [BudgetController],
  providers: [BudgetService, FirebaseService]
})
export class BudgetModule { }
