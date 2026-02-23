import { IsString, IsNumber } from 'class-validator';
export class UpdateRoomItemTransformDto {

  @IsString()
  roomItemId: string;

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
}