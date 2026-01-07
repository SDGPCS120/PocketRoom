import { IsNumber, IsNotEmpty } from 'class-validator';

export class GenerateModelDto {
    @IsNumber()
    @IsNotEmpty()
    x: number;

    @IsNumber()
    @IsNotEmpty()
    y: number;

    @IsNumber()
    @IsNotEmpty()
    z: number;
}
