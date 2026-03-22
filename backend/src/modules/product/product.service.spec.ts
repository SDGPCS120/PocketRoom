import { Test, TestingModule } from '@nestjs/testing';
import { ProductService } from './product.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { StoreService } from '../store/store.service';
import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { CreateProductDto } from './dto/create-product.dto';

describe('ProductService', () => {
  let service: ProductService;
  let firebaseService: any;
  let storeService: jest.Mocked<StoreService>;
  let mockDoc: any;
  let mockFirestore: any;
  let mockBucket: any;
  let mockStorage: any;

  beforeEach(async () => {
    mockDoc = {
      id: 'mock-id',
      get: jest.fn(),
      set: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };

    mockBucket = {
      deleteFiles: jest.fn().mockResolvedValue(undefined),
    };

    mockStorage = {
      bucket: jest.fn().mockReturnValue(mockBucket),
    };

    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnValue(mockDoc),
      get: jest.fn(),
      where: jest.fn().mockReturnThis(),
    };

    firebaseService = {
      firestore: mockFirestore,
      storage: mockStorage,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductService,
        {
          provide: FirebaseService,
          useValue: firebaseService,
        },
        {
          provide: StoreService,
          useValue: {
            getStoreById: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<ProductService>(ProductService);
    storeService = module.get(StoreService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createProduct', () => {
    const storeId = 'store-1';
    const sellerId = 'seller-1';
    const dto: CreateProductDto = {
      name: 'Test Product',
      price: 100,
      description: 'A test product',
      images: [],
      furnitureType: 'Test',
      stock: 10,
    } as any;

    it('should create a product successfully', async () => {
      storeService.getStoreById.mockResolvedValue({ storeId, sellerId });
      mockDoc.id = 'new-prod-id';

      const result = await service.createProduct(storeId, sellerId, dto);

      expect(result.productId).toBe('new-prod-id');
      expect(mockDoc.set).toHaveBeenCalled();
    });

    it('should throw ForbiddenException if user does not own the store', async () => {
      storeService.getStoreById.mockResolvedValue({ storeId, sellerId: 'other-seller' });

      await expect(service.createProduct(storeId, sellerId, dto))
        .rejects.toThrow(ForbiddenException);
    });
  });

  describe('getProductById', () => {
    it('should return product data if it exists', async () => {
      const productId = 'prod-1';
      const productData = { productId, name: 'Prod 1' };
      mockDoc.get.mockResolvedValue({
        exists: true,
        data: () => productData,
      });

      const result = await service.getProductById(productId);

      expect(result).toEqual(productData);
    });

    it('should throw NotFoundException if product does not exist', async () => {
      mockDoc.get.mockResolvedValue({ exists: false });

      await expect(service.getProductById('invalid-id'))
        .rejects.toThrow(NotFoundException);
    });
  });

  describe('updateProduct', () => {
    const productId = 'prod-1';
    const sellerId = 'seller-1';

    it('should update product successfully', async () => {
      mockDoc.get.mockResolvedValue({
        exists: true,
        data: () => ({ storeId: 'store-1' }),
      });
      storeService.getStoreById.mockResolvedValue({ sellerId });

      const result = await service.updateProduct(productId, sellerId, { name: 'Updated' } as any);

      expect(result.message).toBe('Product updated successfully');
      expect(mockDoc.update).toHaveBeenCalled();
    });

    it('should throw ForbiddenException if user does not own the product via store', async () => {
      mockDoc.get.mockResolvedValue({
        exists: true,
        data: () => ({ storeId: 'store-1' }),
      });
      storeService.getStoreById.mockResolvedValue({ sellerId: 'wrong-seller' });

      await expect(service.updateProduct(productId, sellerId, {} as any))
        .rejects.toThrow(ForbiddenException);
    });
  });

  describe('deleteProduct', () => {
    const productId = 'prod-1';
    const sellerId = 'seller-1';

    it('should delete product successfully', async () => {
      mockDoc.get.mockResolvedValue({
        exists: true,
        data: () => ({ storeId: 'store-1' }),
      });
      storeService.getStoreById.mockResolvedValue({ sellerId });
      mockDoc.delete.mockResolvedValue(undefined);

      const result = await service.deleteProduct(productId, sellerId);

      expect(result.message).toBe('Product deleted successfully');
      expect(storeService.getStoreById).toHaveBeenCalledWith('store-1');
      expect(mockStorage.bucket).toHaveBeenCalled();
      expect(mockBucket.deleteFiles).toHaveBeenCalledTimes(2);
      expect(mockDoc.delete).toHaveBeenCalled();
    });
  });
});
