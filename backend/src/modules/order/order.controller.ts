import { Body, Controller, Delete, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import type { AuthenticatedRequest } from '../auth/types/authenticated-request';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderFulfillmentDto } from './dto/update-order-fulfillment.dto';
import { OrderService } from './order.service';

@UseGuards(FirebaseAuthGuard)
@Controller('orders')
export class OrderController {
  constructor(private readonly orderService: OrderService) {}

  @Post()
  createOrder(@Req() req: AuthenticatedRequest, @Body() dto: CreateOrderDto) {
    return this.orderService.createOrder(req.user, dto);
  }

  @Get('my-orders')
  getUserOrders(@Req() req: AuthenticatedRequest) {
    return this.orderService.getUserOrders(req.user);
  }

  @Get('store/:storeId')
  getOrdersByStore(@Req() req: AuthenticatedRequest, @Param('storeId') storeId: string) {
    return this.orderService.getOrdersByStore(req.user, storeId);
  }

  @Get()
  getAllOrders(@Req() req: AuthenticatedRequest) {
    return this.orderService.getAllOrders(req.user);
  }

  @Get(':orderId')
  getOrderById(@Req() req: AuthenticatedRequest, @Param('orderId') orderId: string) {
    return this.orderService.getOrderById(req.user, orderId);
  }

  @Patch(':orderId')
  updateOrder(@Req() req: AuthenticatedRequest, @Param('orderId') orderId: string, @Body() dto: UpdateOrderDto) {
    return this.orderService.updateOrder(req.user, orderId, dto);
  }

  @Patch(':orderId/fulfillment')
  updateOrderFulfillment(
    @Req() req: AuthenticatedRequest,
    @Param('orderId') fulfillmentId: string,
    @Body() dto: UpdateOrderFulfillmentDto,
  ) {
    return this.orderService.updateOrderFulfillment(req.user, fulfillmentId, dto);
  }

  @Delete(':orderId')
  deleteOrder(@Req() req: AuthenticatedRequest, @Param('orderId') orderId: string) {
    return this.orderService.cancelOrder(req.user, orderId);
  }
}
