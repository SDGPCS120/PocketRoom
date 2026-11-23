import { Body, Controller, Post, Req, ValidationPipe } from '@nestjs/common';
import type { Request } from 'express';
import { BudgetService } from './budget.service';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';

@Controller('budget')
export class BudgetController {
  constructor(private readonly budgetService: BudgetService) { }

  @Post('generate')
  async generateBundle(
    @Req() request: Request,
    @Body(new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    })) dto: BudgetBundleRequestDto,
  ): Promise<BudgetBundleResponseDto> {
    return this.budgetService.generateBundle(dto, request.ip);
  }
}
