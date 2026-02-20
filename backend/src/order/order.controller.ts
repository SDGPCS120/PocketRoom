import { Body, Controller, Get, Post } from '@nestjs/common';
import { CreateOrderDto } from './dto/create-order.dto';

@Controller('order')
export class OrderController {

  @Get()
  ping() {
    return { message: 'Order endpoint is online' };
  }

  @Post()
  create(@Body() dto: CreateOrderDto) {
    return {
      message: 'Order received',
      order: dto,
    };
  }
}