import { IsOptional, IsString } from 'class-validator';
import { BaseUserDto } from './base-user.dto';

export class RegisterCustomerDto extends BaseUserDto {
  @IsString()
  @IsOptional()
  profileImageUrl?: string;

  @IsString()
  @IsOptional()
  preferredCurrency?: string;
}
