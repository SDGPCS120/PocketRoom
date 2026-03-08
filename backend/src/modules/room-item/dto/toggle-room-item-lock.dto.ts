import { IsString, IsBoolean } from 'class-validator';
export class ToggleRoomItemLockDto {
  @IsString()
  roomItemId: string;

  @IsBoolean()
  isLocked: boolean;
}
