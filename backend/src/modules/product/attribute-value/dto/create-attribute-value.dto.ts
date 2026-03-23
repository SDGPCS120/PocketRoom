import {
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  Min,
} from 'class-validator';

export class CreateAttributeValueDto {
  @IsString()
  @IsNotEmpty()
  attributeId!: string; // FK -> ATTRIBUTE

  @IsOptional()
  @IsString()
  valueText?: string;

  @IsOptional()
  @IsString()
  valueCode?: string;

  // hex like #FFFFFF
  @IsOptional()
  @IsString()
  @Matches(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
  colorHex?: string;

  @IsOptional()
  @IsNumber()
  numericValue?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  displayOrder?: number;
}
