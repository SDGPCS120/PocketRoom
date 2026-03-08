import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { OrderService } from './order.service';

@Controller('order')
@UseGuards(FirebaseAuthGuard)
export class OrderController {
  constructor(private readonly orderService: OrderService) { }

  @Post()
  createOrder(
    @Req() req: Request & { user?: { uid: string } },
    @Body() dto: CreateOrderDto,
  ) {
    const userId = req.user!.uid;
    return this.orderService.createOrder(userId, dto);
  @Get()
  ping() {
    return { message: 'Order endpoint is online' };
  }

  @Get('me')
  getUserOrders(@Req() req: Request & { user?: { uid: string } }) {
    const userId = req.user!.uid;
    return this.orderService.getUserOrders(userId);
  }

  @Get(':id')
  getOrderById(@Param('id') orderId: string) {
    return this.orderService.getOrderById(orderId);
  }

  @Patch(':id/status')
  updateOrderStatus(
    @Param('id') orderId: string,
    @Body() dto: UpdateOrderDto,
  ) {
    // Assuming UpdateOrderDto contains the orderStatus field.
    // In a real scenario, you might want a specific DTO for status updates
    // if 'orderStatus' isn't reliably present in PartialType(CreateOrderDto).
    if (!dto.orderStatus) {
      throw new Error('orderStatus is required for this endpoint');
    }
    return this.orderService.updateOrderStatus(orderId, dto.orderStatus);
  }
}
