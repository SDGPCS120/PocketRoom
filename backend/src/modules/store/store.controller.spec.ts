import { Test } from '@nestjs/testing';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { StoreController } from './store.controller';
import { StoreService } from './store.service';

describe('StoreController', () => {
  it('createStore uses req.user.uid (not dto.sellerId)', async () => {
    const storeService = {
      createStore: jest.fn(async (sellerId: string, dto: any) => ({
        storeId: 'store-1',
        ...dto,
        sellerId,
      })),
    } as unknown as StoreService;

    const modRef = await Test.createTestingModule({
      controllers: [StoreController],
      providers: [{ provide: StoreService, useValue: storeService }],
    })
      .overrideGuard(FirebaseAuthGuard)
      .useValue({ canActivate: () => true })
      .compile();

    const controller = modRef.get(StoreController);

    const res = await controller.createStore(
      { user: { uid: 'uid-from-token' } } as any,
      {
        sellerId: 'sellerId-from-body',
        storeName: 'My Store',
        storeSlug: 'my-store',
        storeDescription: 'desc',
        isActive: true,
      } as any,
    );

    expect(storeService.createStore).toHaveBeenCalledWith('uid-from-token', expect.any(Object));
    expect(res).toMatchObject({ sellerId: 'uid-from-token', storeName: 'My Store' });
  });
});

