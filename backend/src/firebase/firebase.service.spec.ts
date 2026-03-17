import { Test, TestingModule } from '@nestjs/testing';
import { FirebaseService } from './firebase.service';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

jest.mock('firebase-admin', () => {
  const mockApp = {
    firestore: jest.fn().mockReturnValue({
      settings: jest.fn(),
    }),
    auth: jest.fn().mockReturnValue({}),
    storage: jest.fn().mockReturnValue({}),
  };
  return {
    apps: [],
    initializeApp: jest.fn().mockReturnValue(mockApp),
    credential: {
      applicationDefault: jest.fn(),
      cert: jest.fn(),
    },
    firestore: {
      FieldValue: {
        serverTimestamp: jest.fn(),
      },
    },
  };
});

describe('FirebaseService', () => {
  let service: FirebaseService;
  let configService: jest.Mocked<ConfigService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FirebaseService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<FirebaseService>(FirebaseService);
    configService = module.get(ConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
    (admin.apps as any).length = 0; // Reset apps array
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should initialize firebase app if none exist', () => {
      configService.get.mockReturnValue(null);
      
      service.onModuleInit();

      expect(admin.initializeApp).toHaveBeenCalled();
    });

    it('should reuse existing firebase app if one already exists', () => {
      (admin.apps as any).push({}); // Simulate existing app
      
      service.onModuleInit();

      expect(admin.initializeApp).not.toHaveBeenCalled();
    });
  });

  describe('getters', () => {
    beforeEach(() => {
      configService.get.mockReturnValue(null);
      service.onModuleInit();
    });

    it('should return firestore instance', () => {
      expect(service.firestore).toBeDefined();
    });

    it('should return auth instance', () => {
      expect(service.auth).toBeDefined();
    });

    it('should return fieldValue', () => {
      expect(service.fieldValue).toBeDefined();
    });
  });
});
