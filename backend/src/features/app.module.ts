import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SearchModule } from './search/search.module';
import { BudgetModule } from './budget/budget.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
        }),
        SearchModule,
        BudgetModule,
    ],
})
export class AppModule { }
