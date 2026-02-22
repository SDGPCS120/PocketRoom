import { IsString, IsEnum } from 'class-validator';
import { RoomRole } from './room-role.enum';

export class UpdateRoomMemberRoleDto {

  @IsString()
  memberId: string;

  @IsEnum(RoomRole)
  role: RoomRole;
}