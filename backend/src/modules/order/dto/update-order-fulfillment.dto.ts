import { IsDateString, IsEnum, IsOptional, IsString } from 'class-validator';
import { OrderStatus } from './create-order.dto';

export class UpdateOrderFulfillmentDto {
  @IsEnum(OrderStatus)
  orderStatus!: OrderStatus;

  @IsOptional()
  @IsString()
  trackingNumber?: string;

  @IsOptional()
  @IsString()
  courierName?: string;

  @IsOptional()
  @IsDateString()
  estimatedDelivery?: string;
}