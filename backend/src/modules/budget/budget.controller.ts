import { Body, Controller, Post } from '@nestjs/common';
import { BudgetService } from './budget.service';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';

@Controller('budget')
export class BudgetController {
  constructor(private readonly budgetService: BudgetService) {}

  @Post('generate')
async generateBundle(
  @Body() dto: BudgetBundleRequestDto,
): Promise<BudgetBundleResponseDto> {
  return this.budgetService.generateBundle(dto);
}
}
