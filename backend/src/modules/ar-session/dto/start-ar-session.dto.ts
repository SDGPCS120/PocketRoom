import { IsString, IsOptional } from 'class-validator';

export class StartArSessionDto {
  @IsString()
  variantId: string;

  @IsString()
  deviceModel: string;

  @IsString()
  osVersion: string;

  @IsOptional()
  @IsString()
  roomSnapshotUrl?: string;
}
