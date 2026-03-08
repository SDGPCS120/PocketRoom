import { IsEnum, IsInt, IsOptional, IsDateString } from 'class-validator';

export enum AccessMode {
  VIEW = 'VIEW',
  EDIT = 'EDIT',
}

export class GenerateRoomCodeDto {
  @IsEnum(AccessMode)
  accessMode: AccessMode;

  @IsOptional()
  @IsInt()
  maxUses?: number;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}
