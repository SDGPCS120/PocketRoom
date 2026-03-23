import { Injectable } from '@nestjs/common';
import { CartService } from '../cart/cart.service.js';

@Injectable()
export class CartDebugService {
  constructor(private readonly cartService: CartService) {}

  async getUnityCartPayload(user: { uid: string; email: string | null }) {
    const cart = await this.cartService.findAll(user.uid);
    return {
      uid: user.uid,
      email: user.email,
      cart,
    };
  }
}
