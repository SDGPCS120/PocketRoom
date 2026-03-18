import { IsNumber, IsNotEmpty } from 'class-validator';
import { Transform } from 'class-transformer';

export class GenerateModelDto {
  @Transform(({ value }) => Number(value))
  @IsNumber()
  @IsNotEmpty()
  x: number;

  @Transform(({ value }) => Number(value))
  @IsNumber()
  @IsNotEmpty()
  y: number;

  @Transform(({ value }) => Number(value))
  @IsNumber()
  @IsNotEmpty()
  z: number;
}
