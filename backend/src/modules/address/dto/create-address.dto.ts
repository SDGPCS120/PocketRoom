import {
  IsBoolean,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export enum AddressType {
  BILLING = 'BILLING',
  SHIPPING = 'SHIPPING',
}

export class CreateAddressDto {
  @IsString()
  @IsNotEmpty()
  customerId: string;

  @IsEnum(AddressType)
  addressType: AddressType;

  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  recipientName: string;

  @IsString()
  @IsNotEmpty()
  // If you want strict phone format by region, replace with IsPhoneNumber('LK') etc.
  phone: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  addressLine1: string;

  @IsString()
  @IsOptional()
  @MaxLength(200)
  addressLine2?: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  city: string;

  @IsString()
  @IsOptional()
  @MaxLength(80)
  state?: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  country: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  postalCode: string;

  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;
}
