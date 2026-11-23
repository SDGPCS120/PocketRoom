import { HttpException, HttpStatus, Injectable, Logger } from '@nestjs/common';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';
import { buildBundle } from './algo/buildBundle';
import { FirebaseService } from '../../firebase/firebase.service';
import { FurnitureItem } from './algo/types';
import { budgetStateCount, DEFAULT_BUDGET_STEP_LKR } from './algo/budget-limits';

@Injectable()
export class BudgetService {
  private readonly logger = new Logger(BudgetService.name);
  private catalog?: { items: FurnitureItem[]; expiresAt: number };
  private catalogLoad?: Promise<FurnitureItem[]>;
  private readonly requestCounts = new Map<string, { count: number; expiresAt: number }>();
  private globalRequests = { count: 0, expiresAt: 0 };

  constructor(private readonly firebase: FirebaseService) { }

  private async getFurnitureFromDB(): Promise<FurnitureItem[]> {
    const snapshot = await this.firebase.firestore
      .collection('products')
      .limit(1000)
      .get();

    this.logger.log(`Fetched ${snapshot.docs.length} products from Firestore`);

    const items = snapshot.docs.map((doc) => {
      const data = doc.data();
      const name = (data.name || doc.id).toLowerCase();
      const id = doc.id.toLowerCase();

      let category = (data.category || data.furnitureType || '').toUpperCase();

      if (!category || category === 'N/A') {
        if (name.includes('chair') || id.includes('chair')) category = 'CHAIR';
        else if (name.includes('sofa') || id.includes('sofa') || name.includes('couch')) category = 'SOFA';
        else if (name.includes('table') || id.includes('table')) category = 'TABLE';
        else if (name.includes('bed') || id.includes('bed')) category = 'BED';
        else if (name.includes('wardrobe') || id.includes('wardrobe')) category = 'WARDROBE';
        else if (name.includes('lamp')) category = 'LAMP';
        else if (name.includes('rug')) category = 'RUG';
        else category = 'OTHER';
      }

      const item = {
        ...data,
        id: doc.id,
        name: data.name ?? doc.id,
        category,
        price: data.price ?? 10000,
        rating: data.rating ?? 4,
        inStock: data.inStock ?? true,
        images: data.images ?? (Array.isArray(data.imageUrl) ? data.imageUrl : (data.imageUrl ? [data.imageUrl] : [])),
      };

      this.logger.debug(`Loaded item: ${item.id} -> Category: ${item.category}`);
      return item;
    }) as FurnitureItem[];

    const categoriesFound = Array.from(new Set(items.map(it => it.category)));
    this.logger.log(`Distinct categories found: ${categoriesFound.join(', ')}`);

    return items;
  }

  private furniture(): Promise<FurnitureItem[]> {
    if (this.catalog && Date.now() < this.catalog.expiresAt) return Promise.resolve(this.catalog.items);
    if (this.catalogLoad) return this.catalogLoad;
    this.catalogLoad = this.getFurnitureFromDB().then((items) => {
      this.catalog = { items, expiresAt: Date.now() + 60_000 };
      return items;
    }).finally(() => { this.catalogLoad = undefined; });
    return this.catalogLoad;
  }

  private admitRequest(clientIp: string): void {
    const now = Date.now();
    if (now >= this.globalRequests.expiresAt) {
      this.globalRequests = { count: 0, expiresAt: now + 60_000 };
      this.requestCounts.clear();
    }
    const key = clientIp || 'unknown';
    const client = this.requestCounts.get(key) ?? { count: 0, expiresAt: now + 60_000 };
    if (now >= client.expiresAt) { client.count = 0; client.expiresAt = now + 60_000; }
    if (client.count >= 20 || this.globalRequests.count >= 120) {
      throw new HttpException('Budget request limit reached; try again shortly', HttpStatus.TOO_MANY_REQUESTS);
    }
    client.count++;
    this.globalRequests.count++;
    this.requestCounts.set(key, client);
  }

  async generateBundle(
    dto: BudgetBundleRequestDto,
    clientIp = 'unknown',
  ): Promise<BudgetBundleResponseDto> {
    budgetStateCount(dto.totalBudget, dto.constraints?.budgetStepLkr ?? DEFAULT_BUDGET_STEP_LKR);
    this.admitRequest(clientIp);
    const furnitureItems = await this.furniture();
    this.logger.log(`Generating bundle for ${dto.requiredFurnitureTypes.join(', ')} with ${furnitureItems.length} items`);
    const result = buildBundle(dto, furnitureItems);

    if (!result.ok && result.reason?.includes('Missing categories')) {
      const categoriesFound = Array.from(new Set(furnitureItems.map(it => it.category)));
      this.logger.warn(`Budget generation failed. Missing categories. Categories found in Firestore: ${categoriesFound.join(', ')}`);
    }

    return result;
  }
}
