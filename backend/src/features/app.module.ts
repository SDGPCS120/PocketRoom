import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SearchModule } from './search/search.module';
import { BudgetModule } from './budget/budget.module';
import { FirebaseModule } from '../firebase/firebase.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
        }),
        FirebaseModule, // Now global and available to SearchModule
        SearchModule,
        BudgetModule,
    ],
})
export class AppModule { }
