import {
  IsBoolean,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
} from 'class-validator';

export class CreateStoreDto {
  @IsString()
  @IsNotEmpty()
  sellerId!: string; // FK to SELLER

  @IsString()
  @IsNotEmpty()
  storeName!: string;

  // slug should be URL-friendly (lowercase + hyphens)
  @IsString()
  @IsNotEmpty()
  @Matches(/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
  storeSlug!: string;

  @IsOptional()
  @IsString()
  storeDescription?: string;

  @IsOptional()
  @IsString()
  storeLogo?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
