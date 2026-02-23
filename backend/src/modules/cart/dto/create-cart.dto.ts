import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export enum CartStatus {
  ACTIVE = 'ACTIVE',
  ABANDONED = 'ABANDONED',
  CONVERTED = 'CONVERTED',
}

export class CreateCartDto {
  @IsString()
  @IsNotEmpty()
  customerId: string;

  @IsEnum(CartStatus)
  @IsOptional()
  cartStatus?: CartStatus; // default ACTIVE in service
}