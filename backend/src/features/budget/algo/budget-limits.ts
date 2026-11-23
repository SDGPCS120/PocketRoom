import { BadRequestException } from '@nestjs/common';

export const MAX_BUDGET_LKR = 5_000_000;
export const MAX_BUDGET_CATEGORIES = 12;
export const MAX_BUDGET_STEP_LKR = 10_000;
export const DEFAULT_BUDGET_STEP_LKR = 1_000;
const MAX_BUDGET_STATES = 5_001;

export function budgetStateCount(totalBudget: number, step: number): number {
  if (!Number.isSafeInteger(totalBudget) || totalBudget < 1 || totalBudget > MAX_BUDGET_LKR) {
    throw new BadRequestException(`totalBudget must be between 1 and ${MAX_BUDGET_LKR} LKR`);
  }
  if (!Number.isSafeInteger(step) || step < 1 || step > MAX_BUDGET_STEP_LKR) {
    throw new BadRequestException(`budgetStepLkr must be between 1 and ${MAX_BUDGET_STEP_LKR}`);
  }
  const states = Math.floor(totalBudget / step) + 1;
  if (states > MAX_BUDGET_STATES) {
    throw new BadRequestException('Increase budgetStepLkr for this budget');
  }
  return states;
}
