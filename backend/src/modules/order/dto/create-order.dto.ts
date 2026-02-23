import {
  ArrayMinSize,
  IsArray,
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsPositive,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { CreateOrderItemDto } from './create-order-item.dto';

export enum OrderStatus {
  PENDING = 'PENDING',
  PROCESSING = 'PROCESSING',
  SHIPPED = 'SHIPPED',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
}

export class CreateOrderDto {
  @IsString()
  @IsNotEmpty()
  customerId: string;

  @IsString()
  @IsNotEmpty()
  shippingAddressId: string;

  @IsString()
  @IsNotEmpty()
  billingAddressId: string;

  // Often generated server-side; keep optional if you want to create it on server.
  @IsString()
  @IsOptional()
  orderNumber?: string;

  @IsEnum(OrderStatus)
  @IsOptional()
  orderStatus?: OrderStatus; // default PENDING

  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items: CreateOrderItemDto[];

  // Totals usually computed on server, but optional if your flow needs them:
  @IsPositive()
  @IsOptional()
  subtotal?: number;

  @IsPositive()
  @IsOptional()
  taxAmount?: number;

  @IsPositive()
  @IsOptional()
  shippingCost?: number;

  @IsPositive()
  @IsOptional()
  discountAmount?: number;

  @IsPositive()
  @IsOptional()
  totalAmount?: number;

  @IsString()
  @IsOptional()
  currency?: string;

  @IsString()
  @IsOptional()
  paymentStatus?: string;

  @IsDateString()
  @IsOptional()
  estimatedDelivery?: string;
}