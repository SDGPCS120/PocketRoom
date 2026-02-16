import { Injectable } from '@nestjs/common';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';
import { buildBundle } from './algo/buildBundle';

@Injectable()
export class BudgetService {
  generateBundle(dto: BudgetBundleRequestDto): BudgetBundleResponseDto {
    return buildBundle(dto);
  }
}
