import { PartialType } from '@nestjs/mapped-types';
import { CreateBudgetSessionDto } from './create-budget-session.dto';

export class UpdateBudgetSessionDto extends PartialType(CreateBudgetSessionDto) {}