import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
} from '@nestjs/common';
import { Request } from 'express';
import { PaymentService } from './payment.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { UpdatePaymentStatusDto } from './dto/update-payment-status.dto';

type AuthenticatedRequest = Request & {
  user: {
    uid: string;
  };
};

@Controller('payments')
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @Post('create')
  createPayment(@Req() req: AuthenticatedRequest, @Body() dto: CreatePaymentDto) {
    const userId = req.user.uid;
    return this.paymentService.createPayment(userId, dto);
  }

  @Get('my-payments')
  getMyPayments(@Req() req: AuthenticatedRequest) {
    const userId = req.user.uid;
    return this.paymentService.getPaymentsByUser(userId);
  }

  @Get()
  getAllPayments() {
    return this.paymentService.getAllPayments();
  }

  @Get('order/:orderId')
  getPaymentByOrderId(@Param('orderId') orderId: string) {
    return this.paymentService.getPaymentByOrderId(orderId);
  }

  @Get(':paymentId')
  getPaymentById(@Param('paymentId') paymentId: string) {
    return this.paymentService.getPaymentById(paymentId);
  }

  @Patch(':paymentId/status')
  updatePaymentStatus(
    @Param('paymentId') paymentId: string,
    @Body() dto: UpdatePaymentStatusDto,
  ) {
    return this.paymentService.updatePaymentStatus(paymentId, dto);
  }

  @Delete(':paymentId')
  deletePayment(@Param('paymentId') paymentId: string) {
    return this.paymentService.deletePayment(paymentId);
  }

  @Post('verify')
  verifyPayment(@Body() body: { orderId: string }) {
    return this.paymentService.verifyPayment(body.orderId);
  }

  @Post('notify')
  handleNotify(@Body() body: any) {
    return this.paymentService.handleNotify(body);
  }
}
