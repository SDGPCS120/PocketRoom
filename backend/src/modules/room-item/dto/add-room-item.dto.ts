import { IsString, IsNumber, IsOptional, IsBoolean } from 'class-validator';

export class AddRoomItemDto {

  @IsString()
  roomId: string;

  @IsString()
  variantId: string;

  @IsNumber()
  posX: number;

  @IsNumber()
  posY: number;

  @IsNumber()
  posZ: number;

  @IsNumber()
  rotX: number;

  @IsNumber()
  rotY: number;

  @IsNumber()
  rotZ: number;

  @IsNumber()
  scale: number;

  @IsOptional()
  @IsString()
  materialOverride?: string;

  @IsOptional()
  @IsString()
  colorOverride?: string;
}