import { Body, Controller, Post } from '@nestjs/common';
import { BudgetService } from './budget.service';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';

@Controller('budget')
export class BudgetController {
  constructor(private readonly budgetService: BudgetService) {}

  @Post('bundle')
  generate(@Body() dto: BudgetBundleRequestDto): BudgetBundleResponseDto {
    return this.budgetService.generateBundle(dto);
  }
}
