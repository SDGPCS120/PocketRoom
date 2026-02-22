import { IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { BaseUserDto } from './base-user.dto';

export class RegisterSellerDto extends BaseUserDto {
  @IsString()
  @IsNotEmpty()
  storeName: string;

  @IsString()
  @IsOptional()
  businessRegistrationNumber?: string;

  @IsString()
  @IsOptional()
  storeDescription?: string;
}