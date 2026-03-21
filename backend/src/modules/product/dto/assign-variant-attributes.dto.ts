import { IsArray, IsNotEmpty, IsString } from 'class-validator';

export class AssignVariantAttributesDto {
  @IsString()
  @IsNotEmpty()
  variantId!: string;

  @IsArray()
  @IsString({ each: true })
  valueIds!: string[]; // list of ATTRIBUTE_VALUE IDs
}
