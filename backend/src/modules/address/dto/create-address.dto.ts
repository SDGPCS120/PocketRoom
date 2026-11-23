import { IsBoolean, IsNotEmpty, IsOptional, IsString, IsPhoneNumber, IsEnum,  MaxLength } from 'class-validator';
export enum AddressType {
  BILLING = 'BILLING',
  SHIPPING = 'SHIPPING',
}


export class CreateAddressDto {
  // Retained for existing clients. Ownership is derived from the verified token.
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  userId?: string;

  @IsString()
  @IsNotEmpty()
  fullName!: string;

  @IsString()
  @IsNotEmpty()
  phoneNumber!: string;

  @IsString()
  @IsNotEmpty()
  addressLine1!: string;

  @IsOptional()
  @IsString()
  addressLine2?: string;

  @IsString()
  @IsNotEmpty()
  city!: string;

  @IsString()
  @IsNotEmpty()
  district!: string;

  @IsString()
  @IsNotEmpty()
  postalCode!: string;

  @IsString()
  @IsNotEmpty()
  country!: string;

  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;
}
