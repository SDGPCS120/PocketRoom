import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsArray,
  ValidateNested,
  IsObject,
} from 'class-validator';
import { Type } from 'class-transformer';

// Nested class for dimensions map
class DimensionsDto {
  @IsNumber()
  height: number;

  @IsNumber()
  length: number;

  @IsNumber()
  width: number;
}

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsNumber()
  @IsNotEmpty()
  price: number;

  @ValidateNested()
  @Type(() => DimensionsDto)
  @IsNotEmpty()
  dimensions: DimensionsDto;

  @IsString()
  @IsNotEmpty()
  material: string;

  @IsString()
  @IsOptional()
  modelURL?: string;

  @IsString()
  @IsNotEmpty()
  primaryColor: string;

  @IsString()
  @IsOptional()
  productID?: string;

  @IsBoolean()
  @IsOptional()
  stockStatus?: boolean;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  styleTags?: string[];

  @IsString()
  @IsOptional()
  imageUrl?: string;

  @IsString()
  @IsOptional()
  imagePath?: string;
<<<<<<< HEAD
=======

  @IsString()
  @IsOptional()
  modelStatus?: string;

  @IsString()
  @IsOptional()
  modelError?: string;

  @IsOptional()
  updatedAt?: Date;
>>>>>>> d736028ecd9905450b5fd998b5f70e76ff4eef59
}
