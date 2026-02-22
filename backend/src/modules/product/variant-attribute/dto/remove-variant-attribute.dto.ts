import { IsNotEmpty, IsString } from 'class-validator';

export class RemoveVariantAttributeDto {
  @IsString()
  @IsNotEmpty()
  variantId: string;

  @IsString()
  @IsNotEmpty()
  valueId: string;
}