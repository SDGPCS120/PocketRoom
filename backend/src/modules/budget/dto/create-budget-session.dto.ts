import {
  IsNumber,
  IsString,
  IsEnum,
  IsOptional,
  IsObject,
  Min,
} from 'class-validator';
import { RoomType } from '../enums/room-type.enum';

export class CreateBudgetSessionDto {

  @IsNumber()
  @Min(0)
  budgetMin: number;

  @IsNumber()
  @Min(0)
  budgetMax: number;

  @IsString()
  currency: string;

  @IsEnum(RoomType)
  roomType: RoomType;

  @IsOptional()
  @IsString()
  styleTag?: string;

  @IsOptional()
  @IsObject()
  constraintsJSON?: Record<string, any>;
}