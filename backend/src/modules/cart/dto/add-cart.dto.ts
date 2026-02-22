import { IsInt, IsNotEmpty, IsPositive, IsString, Min } from 'class-validator';

export class AddCartItemDto {
  @IsString()
  @IsNotEmpty()
  cartId: string;

  @IsString()
  @IsNotEmpty()
  variantId: string;

  @IsInt()
  @Min(1)
  quantity: number;

  // UnitPrice normally comes from variant/product, not client.
  // Keep it out unless you *need* client-sent pricing.
}