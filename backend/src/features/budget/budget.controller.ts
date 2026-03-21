import { Body, Controller, Post } from '@nestjs/common';
import { BudgetService } from './budget.service';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';

@Controller('budget')
export class BudgetController {
  constructor(private readonly budgetService: BudgetService) { }

  @Post('generate')
  async generateBundle(
    @Body() dto: BudgetBundleRequestDto,
  ): Promise<BudgetBundleResponseDto> {
    console.log('[BudgetController] Received Request:', JSON.stringify(dto, null, 2));
    const res = await this.budgetService.generateBundle(dto);
    console.log('[BudgetController] Returning Full Response:', JSON.stringify(res, null, 2));
    return res;
  }
}
