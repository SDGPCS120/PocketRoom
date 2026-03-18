import { Injectable, Logger } from '@nestjs/common';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';
import { buildBundle } from './algo/buildBundle';
import { FirebaseService } from '../../firebase/firebase.service';
import { FurnitureItem } from '../../furniture/furniture.mock';

@Injectable()
export class BudgetService {
  private readonly logger = new Logger(BudgetService.name);

  constructor(private readonly firebase: FirebaseService) { }

  private async getFurnitureFromDB(): Promise<FurnitureItem[]> {
    const snapshot = await this.firebase.firestore
      .collection('products')
      .get();

    this.logger.log(`Fetched ${snapshot.docs.length} products from Firestore`);

    const items = snapshot.docs.map((doc) => {
      const data = doc.data();

      // Prioritize explicit category field, fallback to ID-based derivation
      const category = (data.category || doc.id.split('-')[0]).toUpperCase();

      const item = {
        id: doc.id,
        name: data.name ?? doc.id,
        category,
        price: data.price ?? 10000,
        rating: data.rating ?? 4,
        inStock: data.inStock ?? true,
        style: data.style,
        color: data.color,
      };

      this.logger.debug(`Loaded item: ${item.id} -> Category: ${item.category}`);
      return item;
    }) as FurnitureItem[];

    return items;
  }
  async generateBundle(
    dto: BudgetBundleRequestDto
  ): Promise<BudgetBundleResponseDto> {

    const furnitureItems = await this.getFurnitureFromDB();

    return buildBundle(dto, furnitureItems);
  }
}