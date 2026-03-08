import { IsBoolean, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateCategoryDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  slug: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  parentCategoryId?: string;

  @IsOptional()
  @IsString()
  imageURL?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}