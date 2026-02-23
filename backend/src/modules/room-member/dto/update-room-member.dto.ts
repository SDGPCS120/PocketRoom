import { IsString, IsEnum } from 'class-validator';
import { RoomRole } from '../enums/room-role.enum';

export class UpdateRoomMemberRoleDto {
  @IsString()
  memberId: string;

  @IsEnum(RoomRole)
  role: RoomRole;
}
