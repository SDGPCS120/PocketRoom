import { IsEnum, IsInt, IsOptional } from 'class-validator';

export enum ArSessionStatus {
  COMPLETED = 'COMPLETED',
  ABANDONED = 'ABANDONED',
}

export class EndArSessionDto {
  @IsEnum(ArSessionStatus)
  sessionStatus!: ArSessionStatus;

  @IsOptional()
  @IsInt()
  interactionsCount?: number;
}
