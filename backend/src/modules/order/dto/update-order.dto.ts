import { PartialType, PickType } from '@nestjs/mapped-types';
import { CreateOrderDto } from './create-order.dto';

export class UpdateOrderDto extends PartialType(
  PickType(CreateOrderDto, ['shippingAddressId', 'billingAddressId'] as const),
) {}
