import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getQueueToken } from '@nestjs/bullmq';
import request from 'supertest';
import { FirebaseService } from './firebase/firebase.service';
import { BudgetController } from './features/budget/budget.controller';
import { BudgetService } from './features/budget/budget.service';
import { mckp } from './features/budget/algo/mckp';
import { MAX_BUDGET_CATEGORIES, MAX_BUDGET_LKR } from './features/budget/algo/budget-limits';
import { GenerationOwnershipService } from './features/modelGenerationPipeline/generation/generation-ownership.service';
import { GenerationProcessor } from './features/modelGenerationPipeline/generation/generation.processor';
import { GenerationsController } from './features/modelGenerationPipeline/generation/generations.controller';
import { GenerationsService } from './features/modelGenerationPipeline/generation/generations.service';
import { SearchController } from './features/search/search.controller';
import { SearchService } from './features/search/search.service';
import type { ProductLoaderService } from './features/search/product-loader.service';
import { QueryParserService } from './features/search/query-parser.service';
import { ColorMatcherService } from './features/search/color-matcher.service';
import { RelevanceScorerService } from './features/search/relevance-scorer.service';
import { CategoryController } from './modules/category/category.controller';
import { CategoryService } from './modules/category/category.service';
import { StoreService } from './modules/store/store.service';
import { ProductService } from './modules/product/product.service';
import { createHash } from 'node:crypto';

describe('PocketRoom security boundaries', () => {
  let app: INestApplication;
  let ownership: GenerationOwnershipService;
  const category = {
    create: jest.fn().mockReturnValue({ id: 'chair' }),
    update: jest.fn(),
    remove: jest.fn(),
    findAll: jest.fn().mockReturnValue([]),
  };
  const search = { rebuildSearchIndex: jest.fn(), getProducts: jest.fn().mockReturnValue([]) };
  const product = { storeId: 'store', imageUrl: ['catalog-photo'] };
  const records: Record<string, Record<string, unknown>> = { 'products/item': product };
  const update = jest.fn((ref: string, values: Record<string, unknown>) => {
    Object.assign(records[ref], values);
  });
  const catalog = jest.fn().mockResolvedValue({ docs: [
    { id: 'item', data: () => ({ name: 'Chair', category: 'CHAIR', price: 25000 }) },
  ] });
  const quotaWrites: Record<string, Record<string, unknown>> = {};
  const storageSave = jest.fn().mockResolvedValue(undefined);
  const bucket = jest.fn().mockReturnValue({ file: jest.fn().mockReturnValue({
    save: storageSave,
    getSignedUrl: jest.fn().mockResolvedValue(['https://example.test/source']),
  }) });
  const queue = { add: jest.fn().mockResolvedValue({ id: 'job' }), getWaitingCount: jest.fn().mockResolvedValue(0) };
  const firebase = {
    auth: { verifyIdToken: jest.fn(async (token: string) => ({
      uid: token,
      firebase: { sign_in_provider: token === 'guest' ? 'anonymous' : 'password' },
      admin: token === 'admin' || token === 'guest',
    })) },
    storage: { bucket },
    firestore: {
      collection: (collection: string) => ({
        doc: (id: string) => `${collection}/${id}`,
        limit: () => ({ get: catalog }),
        get: catalog,
        where: () => ({ limit: () => ({ get: async () => ({ empty: true }) }) }),
      }),
      runTransaction: async (action: (transaction: unknown) => unknown) => action({
        get: async (ref: string) => ({
          ref,
          exists: ref in records || ref in quotaWrites,
          get: (field: string) => (records[ref] ?? quotaWrites[ref])?.[field],
        }),
        update,
        set: (ref: string, values: Record<string, unknown>) => { quotaWrites[ref] = values; },
      }),
    },
  };

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      controllers: [CategoryController, SearchController, GenerationsController, BudgetController],
      providers: [
        GenerationsService, GenerationOwnershipService, BudgetService,
        { provide: FirebaseService, useValue: firebase },
        { provide: CategoryService, useValue: category },
        { provide: SearchService, useValue: search },
        { provide: getQueueToken('generation-queue'), useValue: queue },
      ],
    }).compile();
    ownership = module.get(GenerationOwnershipService);
    app = module.createNestApplication();
    await app.init();
  });

  afterAll(async () => app?.close());

  beforeEach(() => {
    jest.clearAllMocks();
    records['products/item'] = { ...product };
    records['stores/store'] = { sellerId: 'seller' };
    for (const key of Object.keys(quotaWrites)) delete quotaWrites[key];
  });

  it('keeps public reads and restricts category mutations and search reloads', async () => {
    const http = request(app.getHttpServer());
    await http.get('/categories').expect(200);
    await http.get('/search/products').expect(200);
    await http.post('/categories').expect(401);
    await http.patch('/categories/chair').set('Authorization', 'Bearer seller').expect(403);
    await http.delete('/categories/chair').set('Authorization', 'Bearer guest').expect(403);
    await http.post('/search/reload').expect(401);
    await http.post('/search/reload').set('Authorization', 'Bearer seller').expect(403);
    expect(category.create).not.toHaveBeenCalled();
    expect(category.update).not.toHaveBeenCalled();
    expect(category.remove).not.toHaveBeenCalled();
    expect(search.rebuildSearchIndex).not.toHaveBeenCalled();
    await http.delete('/categories/chair').set('Authorization', 'Bearer admin').expect(200);
    await http.post('/search/reload').set('Authorization', 'Bearer admin').expect(201);
    expect(category.remove).toHaveBeenCalledWith('chair');
    expect(search.rebuildSearchIndex).toHaveBeenCalledTimes(1);
  });

  it('coalesces search rebuilds and releases the shared promise after failure', async () => {
    const loader = { loadProductsFromFirestore: jest.fn().mockRejectedValueOnce(new Error('catalog unavailable')).mockResolvedValue([]) };
    const colors = new ColorMatcherService();
    const service = new SearchService(loader as unknown as ProductLoaderService, new QueryParserService(), colors, new RelevanceScorerService(colors));
    const first = service.rebuildSearchIndex();
    expect(service.rebuildSearchIndex()).toBe(first);
    await expect(first).rejects.toThrow('catalog unavailable');
    await expect(service.rebuildSearchIndex()).resolves.toBeUndefined();
    expect(loader.loadProductsFromFirestore).toHaveBeenCalledTimes(2);
  });

  it('bounds budget allocation before loading the catalog and still returns normal bundles', async () => {
    const http = request(app.getHttpServer());
    const requiredFurnitureTypes = ['chair'];
    await http.post('/budget/generate').send({ totalBudget: MAX_BUDGET_LKR + 1, requiredFurnitureTypes }).expect(400);
    await http.post('/budget/generate').send({
      totalBudget: 500000, requiredFurnitureTypes, constraints: { budgetStepLkr: 1 },
    }).expect(400);
    await http.post('/budget/generate').send({
      totalBudget: 500000, requiredFurnitureTypes: Array(MAX_BUDGET_CATEGORIES + 1).fill('chair'),
    }).expect(400);
    expect(catalog).not.toHaveBeenCalled();
    expect(() => mckp([], {}, 500000, 1)).toThrow('Increase budgetStepLkr');
    const result = await http.post('/budget/generate').send({ totalBudget: 500000, requiredFurnitureTypes }).expect(201);
    expect(result.body.bundles[0].requiredBundle[0]).toMatchObject({ id: 'item', price: 25000 });
    await http.post('/budget/generate').send({ totalBudget: 500000, requiredFurnitureTypes }).expect(201);
    expect(catalog).toHaveBeenCalledTimes(1);
  });

  it('allows only the product owner to upload and enqueue then rejects duplicate requests', async () => {
    const http = request(app.getHttpServer());
    const upload = (id: string, token: string) => http.post(`/model-generation/${id}/generate`)
      .set('Authorization', `Bearer ${token}`).field('x', '10').field('y', '10').field('z', '10')
      .attach('image', Buffer.from('test image'), { filename: 'image.png', contentType: 'image/png' });
    await http.post('/model-generation/item/generate').expect(401);
    await upload('item', 'other-seller').expect(403);
    await upload('missing', 'seller').expect(404);
    expect(storageSave).not.toHaveBeenCalled();
    expect(queue.add).not.toHaveBeenCalled();
    expect(update).not.toHaveBeenCalled();

    await upload('item', 'seller').expect(202);
    await upload('item', 'seller').expect(409);
    expect(storageSave).toHaveBeenCalledTimes(1);
    expect(queue.add).toHaveBeenCalledTimes(1);
    expect(Object.values(quotaWrites)).toEqual([{ count: 1 }, { count: 1 }]);
    expect(records['products/item'].imageUrl).toEqual(['catalog-photo']);

    const jobData = queue.add.mock.calls[0][1];
    expect(await ownership.updateCurrent(jobData)).toBe(true);
    expect(await ownership.updateCurrent({ ...jobData, requestId: 'superseded' })).toBe(false);
    expect(await ownership.updateCurrent(jobData, { modelError: null })).toBe(true);
    records['stores/store'].sellerId = 'other-seller';
    expect(await ownership.updateCurrent(jobData, { modelStatus: 'completed' })).toBe(false);
    const processor = new GenerationProcessor(firebase as unknown as FirebaseService, ownership);
    const process = (data: typeof jobData) => processor.process({ id: 'job', data } as Parameters<typeof processor.process>[0]);
    await expect(process(jobData)).resolves.toMatchObject({ skipped: true });
    await expect(process({ productId: 'item' })).resolves.toMatchObject({ skipped: true });
    expect(bucket).toHaveBeenCalledTimes(1);
  });

  it('rejects seller and global generation quotas before upload or enqueue', async () => {
    const http = request(app.getHttpServer());
    const upload = () => http.post('/model-generation/item/generate')
      .set('Authorization', 'Bearer seller').field('x', '10').field('y', '10').field('z', '10')
      .attach('image', Buffer.from('test image'), { filename: 'image.png', contentType: 'image/png' });
    const day = new Date().toISOString().slice(0, 10);
    const sellerKey = createHash('sha256').update('seller').digest('hex');
    queue.getWaitingCount.mockResolvedValueOnce(20);
    await upload().expect(429);
    quotaWrites[`generation-quotas/seller_${day}_${sellerKey}`] = { count: 5 };
    await upload().expect(429);
    delete quotaWrites[`generation-quotas/seller_${day}_${sellerKey}`];
    quotaWrites[`generation-quotas/global_${day}`] = { count: 100 };
    await upload().expect(429);
    expect(storageSave).not.toHaveBeenCalled();
    expect(queue.add).not.toHaveBeenCalled();
  });

  it('uses create-only writes for new stores and products', async () => {
    const create = jest.fn().mockRejectedValue(new Error('ALREADY_EXISTS'));
    const db = { collection: () => ({ doc: () => ({ id: 'collision', create, set: jest.fn() }) }) };
    const firebaseMock = { firestore: db } as unknown as FirebaseService;
    const storeService = new StoreService(firebaseMock);
    await expect(storeService.createStore('seller', { storeName: 'Store' } as never)).rejects.toThrow('ALREADY_EXISTS');
    const productService = new ProductService(firebaseMock, {
      getStoreById: async () => ({ sellerId: 'seller', storeName: 'Store' }),
    } as unknown as StoreService);
    await expect(productService.createProduct('store', 'seller', { name: 'Chair' } as never)).rejects.toThrow('ALREADY_EXISTS');
    expect(create).toHaveBeenCalledTimes(2);
  });
});
