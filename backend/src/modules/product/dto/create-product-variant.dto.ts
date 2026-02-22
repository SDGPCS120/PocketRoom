import { IsBoolean, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CreateProductVariantDto {
  @IsString()
  @IsNotEmpty()
  productId: string; // FK to PRODUCT

  @IsString()
  @IsNotEmpty()
  sku: string; // should be unique

  @IsNumber()
  @Min(0)
  price: number;

  @IsInt()
  @Min(0)
  stock: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}