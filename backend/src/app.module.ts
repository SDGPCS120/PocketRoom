import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { BudgetModule } from './budget/budget.module';

@Module({
  imports: [BudgetModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
