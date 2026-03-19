import {
  IsString,
  IsNotEmpty,
  IsNumber,
  Min,
  IsOptional,
  IsInt,
  IsArray,
} from 'class-validator';

import { Type } from 'class-transformer';
import { ValidateNested } from 'class-validator';

class DimensionsDto {
  @IsOptional()
  @IsNumber()
  height?: number;

  @IsOptional()
  @IsNumber()
  length?: number;

  @IsOptional()
  @IsNumber()
  width?: number;
}

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNumber()
  @Min(0)
  price: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  stock?: number;

  @IsOptional()
  @IsString()
  brand?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  rating?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  imageUrl?: string[];

  @IsOptional()
  @IsString()
  furnitureType?: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => DimensionsDto)
  dimensions?: DimensionsDto;

  @IsOptional()
  @IsString()
  modelURL?: string;
}
