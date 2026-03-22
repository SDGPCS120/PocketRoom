import {
  IsString,
  IsNotEmpty,
  IsNumber,
  Min,
  IsOptional,
  IsInt,
  IsArray,
  IsObject,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

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
  name!: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNumber()
  @Min(0)
  price!: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  stock?: number;

  @IsOptional()
  @IsString()
  brand?: string;

  @IsOptional()
  @IsString()
  brandLogoUrl?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  rating?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  imageUrl?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  colors?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  materials?: string[];

  @IsOptional()
  @IsObject()
  imagesByColor?: Record<string, string[]>;

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

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  similarProducts?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  customersAlsoBought?: string[];
}