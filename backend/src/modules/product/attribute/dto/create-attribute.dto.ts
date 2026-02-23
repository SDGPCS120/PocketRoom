import {
  IsBoolean,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateAttributeDto {
  @IsString()
  @IsNotEmpty()
  attributeName: string;

  @IsString()
  @IsNotEmpty()
  attributeCode: string; // UK

  @IsIn(['TEXT', 'NUMBER', 'COLOR', 'DROPDOWN'])
  attributeType: 'TEXT' | 'NUMBER' | 'COLOR' | 'DROPDOWN';

  @IsOptional()
  @IsString()
  measurementUnit?: string; // e.g., cm, kg

  @IsOptional()
  @IsBoolean()
  isFilterable?: boolean;

  @IsOptional()
  @IsInt()
  @Min(0)
  displayOrder?: number;
}
