import {
  ArrayMaxSize,
  IsArray,
  IsInt,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { FurnitureItem } from '../algo/types';
import {
  DEFAULT_BUDGET_STEP_LKR,
  MAX_BUDGET_CATEGORIES,
  MAX_BUDGET_LKR,
  MAX_BUDGET_STEP_LKR,
} from '../algo/budget-limits';

export class PreferencesDto {
  @IsOptional()
  @IsString()
  @MaxLength(80)
  style?: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  @MaxLength(80, { each: true })
  colors?: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  @MaxLength(80, { each: true })
  materials?: string[];
}

export class ConstraintsDto {
  @IsOptional()
  @IsInt()
  @Min(5)
  @Max(100)
  topKPerFurnitureType?: number = 30;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(MAX_BUDGET_STEP_LKR)
  budgetStepLkr?: number = DEFAULT_BUDGET_STEP_LKR;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(20)
  maxOptionalItems?: number = 3;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(5)
  minRating?: number = 0;
}

export class BudgetBundleRequestDto {
  @IsInt()
  @Min(1)
  @Max(MAX_BUDGET_LKR)
  totalBudget!: number;

  @IsArray()
  @ArrayMaxSize(MAX_BUDGET_CATEGORIES)
  @IsString({ each: true })
  @MaxLength(80, { each: true })
  requiredFurnitureTypes!: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_BUDGET_CATEGORIES)
  @IsString({ each: true })
  @MaxLength(80, { each: true })
  optionalFurnitureTypes?: string[] = [];

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto = {};

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => ConstraintsDto)
  constraints?: ConstraintsDto = {};
}

export type PickedItem = {
  furnitureType: string;
  id: string;
  name: string;
  price: number;
  score: number;
  reason: string;
  product: FurnitureItem;
};

export class BundleVariantDto {
  totalCost!: number;
  remaining!: number;
  requiredBundle!: PickedItem[];
  optionalBundle!: PickedItem[];
  explanations!: string[];
}

export class BudgetBundleResponseDto {
  ok!: boolean;
  totalBudget!: number;
  bundles!: BundleVariantDto[];
  reason?: string;
  minPossibleCost?: number;
}
