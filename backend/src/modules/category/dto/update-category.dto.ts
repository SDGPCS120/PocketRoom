import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class UpdateCategoryDto {

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  slug?: string;

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