import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsString,
  Min,
} from 'class-validator';

export class CreateOrderItemDto {
  @IsString()
  @IsNotEmpty()
  variantId: string;

  @IsString()
  @IsNotEmpty()
  storeId: string;

  @IsInt()
  @Min(1)
  quantity: number;

  // Usually computed server-side, but included if needed:
  @IsPositive()
  @IsOptional()
  unitPrice?: number;

  @IsPositive()
  @IsOptional()
  taxAmount?: number;

  @IsPositive()
  @IsOptional()
  itemTotal?: number;
}
