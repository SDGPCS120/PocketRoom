import { IsEnum, IsString } from 'class-validator';

export enum Platform {
  IOS = 'IOS',
  ANDROID = 'ANDROID',
  WEB = 'WEB',
}

export class ConnectRealtimeDto {
  @IsString()
  roomId: string;

  @IsString()
  deviceType: string;

  @IsEnum(Platform)
  platform: Platform;
}
