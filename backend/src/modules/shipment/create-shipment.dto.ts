import {
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';
import { ShipmentStatus } from './shipment-status.enum';

export class CreateShipmentDto {
  @IsString()
  @IsNotEmpty()
  orderId: string;

  @IsString()
  @IsOptional()
  trackingNumber?: string;

  @IsDateString()
  @IsOptional()
  shipDate?: string;

  @IsDateString()
  @IsOptional()
  estimatedDelivery?: string;

  @IsDateString()
  @IsOptional()
  actualDelivery?: string;

  @IsEnum(ShipmentStatus)
  @IsOptional()
  shipmentStatus?: ShipmentStatus;

  @IsPositive()
  @IsOptional()
  shippingCost?: number;
}
