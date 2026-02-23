import { IsEnum, IsNumber } from 'class-validator';

export enum PresenceStatus {
  ACTIVE = 'ACTIVE',
  IDLE = 'IDLE',
  LEFT = 'LEFT',
}

export class PresenceUpdateDto {

  @IsEnum(PresenceStatus)
  status: PresenceStatus;

  @IsNumber()
  cursorX: number;

  @IsNumber()
  cursorY: number;
}