import { IsInt, IsNotEmpty, IsOptional, IsPositive, IsString, Min } from 'class-validator';

export class CreateOrderItemDto {
  @IsString()
  @IsNotEmpty()
  productId: string;

  @IsString()
  @IsOptional()
  variantId?: string;

  @IsString()
  @IsNotEmpty()
  productName: string;

  @IsPositive()
  unitPrice: number;

  @IsInt()
  @Min(1)
  quantity: number;

  @IsPositive()
  @IsOptional()
  itemTotal?: number;
}