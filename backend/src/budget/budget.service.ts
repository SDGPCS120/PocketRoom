import { Injectable } from '@nestjs/common';
import { BudgetBundleRequestDto, BudgetBundleResponseDto } from './dto/budget-bundle.dto';
import { buildBundle } from './algo/buildBundle';
import { FirebaseService } from '../firebase/firebase.service';
import { FurnitureItem } from '../furniture/furniture.mock';

@Injectable()
export class BudgetService {

  constructor(private readonly firebase: FirebaseService) {}

private async getFurnitureFromDB(): Promise<FurnitureItem[]> {
  const snapshot = await this.firebase.firestore
    .collection('products')
    .get();

  return snapshot.docs.map((doc) => {
    const data = doc.data();
    const category = doc.id.split('-')[0].toUpperCase();

    return {
      id: doc.id,
      name: data.name ?? doc.id,
      category,
      price: data.price ?? 10000,
      rating: data.rating ?? 4,
      inStock: data.inStock ?? true,
    };
  }) as FurnitureItem[];
}
  async generateBundle(
    dto: BudgetBundleRequestDto
  ): Promise<BudgetBundleResponseDto> {

    const furnitureItems = await this.getFurnitureFromDB();

    return buildBundle(dto, furnitureItems);
  }
}