import { IsDateString, IsEnum, IsNotEmpty, IsOptional, IsPositive, IsString, Length } from 'class-validator';

export enum PaymentMethod {
  CREDIT_CARD = 'CREDIT_CARD',
  PAYPAL = 'PAYPAL',
  STRIPE = 'STRIPE',
}

export enum PaymentStatus {
  SUCCEEDED = 'SUCCEEDED',
  FAILED = 'FAILED',
  PENDING = 'PENDING',
  REFUNDED = 'REFUNDED',
}

export class CreatePaymentDto {
  @IsString()
  @IsNotEmpty()
  orderId: string;

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod;

  @IsString()
  @IsNotEmpty()
  transactionId: string;

  @IsPositive()
  amount: number;

  @IsString()
  @IsNotEmpty()
  currency: string;

  @IsDateString()
  @IsOptional()
  paymentDate?: string;

  @IsEnum(PaymentStatus)
  @IsOptional()
  paymentStatus?: PaymentStatus;

  @IsString()
  @IsOptional()
  @Length(4, 4)
  cardLast4?: string;

  @IsString()
  @IsOptional()
  cardBrand?: string;

  @IsDateString()
  @IsOptional()
  refundedAt?: string;

  @IsPositive()
  @IsOptional()
  refundAmount?: number;
}