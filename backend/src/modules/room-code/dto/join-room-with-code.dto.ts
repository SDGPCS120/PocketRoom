import { IsString } from 'class-validator';

export class JoinRoomWithCodeDto {
  @IsString()
  code!: string;
}
