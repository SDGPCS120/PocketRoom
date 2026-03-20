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
      const name = (data.name || doc.id).toLowerCase();
      const id = doc.id.toLowerCase();

      let category = (data.category || '').toUpperCase();

      if (!category) {
        if (name.includes('chair') || id.includes('chair')) category = 'CHAIR';
        else if (name.includes('sofa') || id.includes('sofa') || name.includes('couch')) category = 'SOFA';
        else if (name.includes('table') || id.includes('table')) category = 'TABLE';
        else if (name.includes('bed') || id.includes('bed')) category = 'BED';
        else if (name.includes('wardrobe') || id.includes('wardrobe')) category = 'WARDROBE';
        else category = id.split('-')[0].toUpperCase();
      }

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

    const categoriesFound = Array.from(new Set(items.map(it => it.category)));
    this.logger.log(`Distinct categories found: ${categoriesFound.join(', ')}`);

    return items;
  }

  async generateBundle(
    dto: BudgetBundleRequestDto
  ): Promise<BudgetBundleResponseDto> {
    const furnitureItems = await this.getFurnitureFromDB();
    this.logger.log(`Generating bundle for ${dto.requiredCategories.join(', ')} with ${furnitureItems.length} items`);
    const result = buildBundle(dto, furnitureItems);

    if (!result.ok && result.reason?.includes('Missing categories')) {
      const categoriesFound = Array.from(new Set(furnitureItems.map(it => it.category)));
      this.logger.warn(`Budget generation failed. Missing categories. Categories found in Firestore: ${categoriesFound.join(', ')}`);
    }

    return result;
  }
}