import { Test } from '@nestjs/testing';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { ProductController } from './product.controller';
import { ProductService } from './product.service';

describe('ProductController', () => {
  it('createProduct uses req.user.uid from the auth guard', async () => {
    const productService = {
      createProduct: jest.fn(async (storeId: string, sellerId: string, dto: any) => ({
        productId: 'product-1',
        storeId,
        sellerId,
        ...dto,
      })),
    } as unknown as ProductService;

    const modRef = await Test.createTestingModule({
      controllers: [ProductController],
      providers: [{ provide: ProductService, useValue: productService }],
    })
      .overrideGuard(FirebaseAuthGuard)
      .useValue({ canActivate: () => true })
      .compile();

    const controller = modRef.get(ProductController);

    const res = await controller.createProduct(
      'store-1',
      { user: { uid: 'uid-from-token' } } as any,
      {
        name: 'Chair',
        description: 'desc',
        price: 100,
        furnitureType: 'Chair',
      } as any,
    );

    expect(productService.createProduct).toHaveBeenCalledWith(
      'store-1',
      'uid-from-token',
      expect.any(Object),
    );
    expect(res).toMatchObject({ sellerId: 'uid-from-token', productId: 'product-1' });
  });
});
