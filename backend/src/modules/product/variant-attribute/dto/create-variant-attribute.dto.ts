import { IsNotEmpty, IsString } from 'class-validator';

export class CreateVariantAttributeDto {
  @IsString()
  @IsNotEmpty()
  variantId: string;

  @IsString()
  @IsNotEmpty()
  valueId: string; // FK -> ATTRIBUTE_VALUE
}
