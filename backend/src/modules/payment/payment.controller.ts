import { randomBytes } from 'node:crypto';
import { Body, Controller, Get, Header, HttpCode, Param, Post, Req, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import type { AuthenticatedRequest } from '../auth/types/authenticated-request';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { checkoutLinkPage } from './payhere-checkout';
import { PaymentService } from './payment.service';

@Controller('payments')
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @UseGuards(FirebaseAuthGuard)
  @Post('create')
  createPayment(@Req() req: AuthenticatedRequest, @Body() dto: CreatePaymentDto) {
    return this.paymentService.createPayment(req.user, dto.orderId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Get('my-payments')
  getMyPayments(@Req() req: AuthenticatedRequest) {
    return this.paymentService.getPaymentsByUser(req.user);
  }

  @UseGuards(FirebaseAuthGuard)
  @Get()
  getAllPayments(@Req() req: AuthenticatedRequest) {
    return this.paymentService.getAllPayments(req.user);
  }

  @UseGuards(FirebaseAuthGuard)
  @Get('order/:orderId')
  getPaymentByOrderId(@Req() req: AuthenticatedRequest, @Param('orderId') orderId: string) {
    return this.paymentService.verifyPayment(req.user, orderId);
  }

  @UseGuards(FirebaseAuthGuard)
  @Post('verify')
  verifyPayment(@Req() req: AuthenticatedRequest, @Body() dto: CreatePaymentDto) {
    return this.paymentService.verifyPayment(req.user, dto.orderId);
  }

  @Get('checkout-result')
  @Header('Cache-Control', 'no-store')
  checkoutResult(@Res() response: Response) {
    response.type('html').send('<!doctype html><meta charset="utf-8"><title>Checkout</title><p>Return to PocketRoom to check your payment status.</p>');
  }

  @Get('checkout/:paymentId')
  checkoutLink(@Res() response: Response) {
    const nonce = randomBytes(16).toString('base64');
    response.set({
      'Cache-Control': 'no-store',
      'Referrer-Policy': 'no-referrer',
      'Content-Security-Policy': `default-src 'none'; script-src 'nonce-${nonce}'; form-action 'self'; frame-ancestors 'none'; base-uri 'none'`,
    }).type('html').send(checkoutLinkPage(nonce));
  }

  @Post('checkout/:paymentId')
  async openCheckout(
    @Param('paymentId') paymentId: string,
    @Body('token') token: unknown,
    @Res() response: Response,
  ) {
    const page = await this.paymentService.openCheckout(paymentId, token);
    response.set({
      'Cache-Control': 'no-store',
      'Referrer-Policy': 'strict-origin',
      'Content-Security-Policy': "default-src 'none'; form-action https://sandbox.payhere.lk; frame-ancestors 'none'; base-uri 'none'",
    }).type('html').send(page);
  }

  @UseGuards(FirebaseAuthGuard)
  @Get(':paymentId')
  getPaymentById(@Req() req: AuthenticatedRequest, @Param('paymentId') paymentId: string) {
    return this.paymentService.getPaymentById(req.user, paymentId);
  }

  @Post('notify')
  @HttpCode(200)
  handleNotify(@Body() body: unknown) {
    return this.paymentService.handleNotify(body);
  }
}
