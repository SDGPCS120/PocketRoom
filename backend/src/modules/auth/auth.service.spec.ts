import { Test, TestingModule } from '@nestjs/testing';
import { AuthService, FirestoreUser } from './auth.service';
import { FirebaseService } from '../../firebase/firebase.service';

describe('AuthService', () => {
  let service: AuthService;
  let firebaseService: any;

  const mockFirestore = {
    collection: jest.fn().mockReturnThis(),
    doc: jest.fn().mockReturnThis(),
    get: jest.fn(),
    set: jest.fn(),
    where: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
  };

  const mockFieldValue = {
    serverTimestamp: jest.fn().mockReturnValue('mock-timestamp'),
  };

  beforeEach(async () => {
    firebaseService = {
      firestore: mockFirestore,
      fieldValue: mockFieldValue,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: FirebaseService,
          useValue: firebaseService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('syncUser', () => {
    const uid = 'test-uid';
    const email = 'test@example.com';

    it('should create a new user profile if it does not exist', async () => {
      mockFirestore.get
        .mockResolvedValueOnce({ empty: true, docs: [] })
        .mockResolvedValueOnce({ exists: false });

      const result = await service.syncUser(uid, email, false);

      expect(result.status).toBe('created');
      expect(result.user.role).toBe('customer');
      expect(mockFirestore.set).toHaveBeenCalledWith(
        expect.objectContaining({
          uid: expect.any(String),
          authUid: uid,
          email,
          role: 'customer',
          createdAt: 'mock-timestamp',
          lastLoginAt: 'mock-timestamp',
        }),
      );
    });

    it('should assign anonymous role for and anonymous sign-in', async () => {
      mockFirestore.get
        .mockResolvedValueOnce({ empty: true, docs: [] })
        .mockResolvedValueOnce({ exists: false });

      const result = await service.syncUser(uid, null, true);

      expect(result.status).toBe('created');
      expect(result.user.role).toBe('anonymous');
    });

    it('should preserve vendor role for existing users during sync', async () => {
      mockFirestore.get
        .mockResolvedValueOnce({ empty: true, docs: [] })
        .mockResolvedValueOnce({
          exists: true,
          id: uid,
          data: () => ({
            role: 'vendor',
            email: 'vendor@example.com',
          }),
        });

      const result = await service.syncUser(uid, 'vendor@example.com', false);

      expect(result.status).toBe('exists');
      expect(result.user.role).toBe('seller');
      expect(mockFirestore.set).toHaveBeenCalledWith(
        expect.objectContaining({
          role: 'seller',
          lastLoginAt: 'mock-timestamp',
        }),
        { merge: true },
      );
    });

    it('should update lastLoginAt for existing users', async () => {
      mockFirestore.get
        .mockResolvedValueOnce({ empty: true, docs: [] })
        .mockResolvedValueOnce({
          exists: true,
          id: uid,
          data: () => ({
            role: 'customer',
            email: email,
          }),
        });

      await service.syncUser(uid, email, false);

      expect(mockFirestore.set).toHaveBeenCalledWith(
        expect.objectContaining({
          lastLoginAt: 'mock-timestamp',
        }),
        { merge: true },
      );
    });
  });

  describe('getRole', () => {
    it('should return the correct user role from firestore', async () => {
      const uid = 'test-uid';
      mockFirestore.get.mockResolvedValue({
        exists: true,
        data: () => ({ role: 'vendor' }),
      });

      const role = await service.getRole(uid);

      expect(role).toBe('vendor');
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith(uid);
    });

    it('should default to customer if role is missing', async () => {
      const uid = 'missing-role-uid';
      mockFirestore.get.mockResolvedValue({
        exists: true,
        data: () => ({}), // Empty doc
      });

      const role = await service.getRole(uid);
      expect(role).toBe('customer');
    });
  });
});
