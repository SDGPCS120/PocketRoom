import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, IsBoolean } from "class-validator";
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

export enum UserRole {
  CUSTOMER = "CUSTOMER",
  SELLER = "SELLER",
  ADMIN = "ADMIN",
}

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @IsNotEmpty()
  fullName: string;

  @IsOptional()
  @IsString()
  phoneNumber?: string;

  @IsOptional()
  @IsString()
  photoURL?: string;

  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole; // default CUSTOMER in service

  @IsOptional()
  @IsBoolean()
  isActive?: boolean; // default true in service
}
  role?: 'CUSTOMER' | 'SELLER' | 'ADMIN';
}
