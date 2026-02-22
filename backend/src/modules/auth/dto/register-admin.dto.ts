import { IsOptional, IsString } from 'class-validator';
import { BaseUserDto } from './base-user.dto';

export class RegisterAdminDto extends BaseUserDto {
  @IsString()
  @IsOptional()
  adminLevel?: string; // e.g., SUPER_ADMIN, SUPPORT_ADMIN
}