import {
  IsArray,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { FurnitureItem } from '../algo/types';

export class PreferencesDto {
  @IsOptional()
  @IsString()
  style?: string;

  @IsOptional()
  @IsArray()
  colors?: string[];

  @IsOptional()
  @IsArray()
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
  @Max(10000)
  budgetStepLkr?: number = 1000;

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
  totalBudget!: number;

  @IsArray()
  requiredFurnitureTypes!: string[];

  @IsOptional()
  @IsArray()
  optionalFurnitureTypes?: string[] = [];

  @IsOptional()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto = {};

  @IsOptional()
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
