import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { OrderService } from './order.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderFulfillmentDto } from './dto/update-order-fulfillment.dto';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';

type AuthenticatedRequest = Request & {
  user: {
    uid: string;
  };
};

@UseGuards(FirebaseAuthGuard)
@Controller('orders')
export class OrderController {
  constructor(private readonly orderService: OrderService) {}

  @Post()
  createOrder(@Req() req: AuthenticatedRequest, @Body() dto: CreateOrderDto) {
    const userId = req.user.uid;
    return this.orderService.createOrder(userId, dto);
  }

  @Get('my-orders')
  getUserOrders(@Req() req: AuthenticatedRequest) {
    const userId = req.user.uid;
    return this.orderService.getUserOrders(userId);
  }

  @Get('store/:storeId')
  getOrdersByStore(@Param('storeId') storeId: string) {
    return this.orderService.getOrdersByStore(storeId);
  }

  @Get()
  getAllOrders() {
    return this.orderService.getAllOrders();
  }

  @Get(':orderId')
  getOrderById(@Param('orderId') orderId: string) {
    return this.orderService.getOrderById(orderId);
  }

  @Patch(':orderId')
  updateOrder(@Param('orderId') orderId: string, @Body() dto: UpdateOrderDto) {
    return this.orderService.updateOrder(orderId, dto);
  }

  @Patch(':orderId/fulfillment')
  updateOrderFulfillment(
    @Param('orderId') orderId: string,
    @Body() dto: UpdateOrderFulfillmentDto,
  ) {
    return this.orderService.updateOrderFulfillment(orderId, dto);
  }

  @Delete(':orderId')
  deleteOrder(@Param('orderId') orderId: string) {
    return this.orderService.deleteOrder(orderId);
  }
}
