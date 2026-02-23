import { IsEnum, IsString } from 'class-validator';

export enum RoomRole {
  EDITOR = 'EDITOR',
  VIEWER = 'VIEWER',
}

export class InviteRoomMemberDto {
  @IsString()
  roomId: string;

  @IsString()
  customerId: string;

  @IsEnum(RoomRole)
  role: RoomRole;
}
