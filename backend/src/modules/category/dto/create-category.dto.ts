<<<<<<< HEAD
import { IsBoolean, IsNotEmpty, IsOptional, IsString } from 'class-validator';
=======
import { IsInt, IsNotEmpty, IsOptional, IsString, Min } from 'class-validator';
>>>>>>> bf9be906f4f4cfb86db39e920f6ebce8aee49a77

export class CreateCategoryDto {
  @IsString()
  @IsNotEmpty()
<<<<<<< HEAD
  name: string;

  @IsString()
  @IsNotEmpty()
  slug: string;

  @IsOptional()
  @IsString()
  description?: string;
=======
  categoryName: string;
>>>>>>> bf9be906f4f4cfb86db39e920f6ebce8aee49a77

  @IsOptional()
  @IsString()
  parentCategoryId?: string;

  @IsOptional()
  @IsString()
<<<<<<< HEAD
  imageURL?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
=======
  categoryDescription?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  displayOrder?: number;
}
>>>>>>> bf9be906f4f4cfb86db39e920f6ebce8aee49a77
