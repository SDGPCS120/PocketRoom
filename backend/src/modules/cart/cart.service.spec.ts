import { Test, TestingModule } from '@nestjs/testing';
import { CartService } from './cart.service';
import { FirebaseService } from '../../firebase/firebase.service';

describe('CartService', () => {
  let service: CartService;
  let firebaseService: any;
  let mockDoc: any;
  let mockFirestore: any;

  beforeEach(async () => {
    mockDoc = {
      id: 'item-1',
      get: jest.fn(),
      set: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };

    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      get: jest.fn(),
    };

    // Override collection/doc for nested behavior
    mockFirestore.doc.mockReturnValue({
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnValue(mockDoc),
    });
    
    // For top-level collection().get()
    mockFirestore.get.mockResolvedValue({ docs: [] });

    firebaseService = {
      firestore: mockFirestore,
      fieldValue: {
        serverTimestamp: jest.fn().mockReturnValue('mock-timestamp'),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CartService,
        {
          provide: FirebaseService,
          useValue: firebaseService,
        },
      ],
    }).compile();

    service = module.get<CartService>(CartService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    const userId = 'user-1';
    const dto = { id: 'prod-1', quantity: 2, furniture: { name: 'Chair' } };

    it('should create or update a cart item successfully', async () => {
      mockDoc.id = 'prod-1';
      mockDoc.get.mockResolvedValue({
        id: 'prod-1',
        data: () => ({ ...dto, updatedAt: 'mock-timestamp' }),
      });

      const result = await service.create(userId, dto);

      expect(result.id).toBe('prod-1');
      expect(result.quantity).toBe(2);
      expect(mockDoc.set).toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return all cart items for a user', async () => {
      const userId = 'user-1';
      const nestedCollection = {
        get: jest.fn().mockResolvedValue({
          docs: [
            { id: 'item-1', data: () => ({ quantity: 2, furniture: {} }) },
            { id: 'item-2', data: () => ({ quantity: 1, furniture: {} }) },
          ],
        }),
      };
      
      mockFirestore.doc.mockReturnValue({
        collection: jest.fn().mockReturnValue(nestedCollection),
      });

      const result = await service.findAll(userId);

      expect(result).toHaveLength(2);
      expect(result[0].id).toBe('item-1');
    });
  });

  describe('update', () => {
    it('should update a cart item and return the new state', async () => {
      const userId = 'user-1';
      const id = 'item-1';
      const dto = { quantity: 5 };

      mockDoc.get.mockResolvedValue({
        id,
        data: () => ({ quantity: 5, furniture: {}, updatedAt: 'now' }),
      });

      const result = await service.update(userId, id, dto);

      expect(result.quantity).toBe(5);
      expect(mockDoc.set).toHaveBeenCalledWith(
        expect.objectContaining({ quantity: 5 }),
        { merge: true },
      );
    });
  });

  describe('remove', () => {
    it('should delete a cart item', async () => {
      const userId = 'user-1';
      const id = 'item-1';

      const result = await service.remove(userId, id);

      expect(result).toEqual({ id, deleted: true });
      expect(mockDoc.delete).toHaveBeenCalled();
    });
  });
});
