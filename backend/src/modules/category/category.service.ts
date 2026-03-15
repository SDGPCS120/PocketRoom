import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { FirebaseService } from '../../firebase/firebase.service';

type CategoryDoc = {
  id: string;
  name: string;
  slug: string;
  description?: string;
  parentCategoryId?: string;
  imageURL?: string;
  isActive: boolean;
  isDeleted: boolean;
  createdAt: any;
  updatedAt: any;
  deletedAt?: any;
};

@Injectable()
export class CategoryService {
  private readonly colName = 'categories';

  constructor(private readonly firebaseService: FirebaseService) {}

  private col() {
    return this.firebaseService.firestore.collection(this.colName);
  }

  async create(dto: CreateCategoryDto) {
    const slugExists = await this.col()
      .where('slug', '==', dto.slug)
      .where('isDeleted', '==', false)
      .limit(1)
      .get();

    if (!slugExists.empty) {
      throw new ConflictException('Category slug already exists');
    }

    const ref = this.col().doc();

    const data: any = {
      id: ref.id,
      name: dto.name,
      slug: dto.slug,
      isActive: dto.isActive ?? true,
      isDeleted: false,
      createdAt: this.firebaseService.fieldValue.serverTimestamp(),
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    if (dto.description !== undefined) data.description = dto.description;
    if (dto.parentCategoryId !== undefined) data.parentCategoryId = dto.parentCategoryId;
    if (dto.imageURL !== undefined) data.imageURL = dto.imageURL;

    await ref.set(data);

    const created = await ref.get();
    return created.data();
  }

  async findAll(parentCategoryId?: string, isActive?: boolean) {
    let q = this.col().where('isDeleted', '==', false);

    if (parentCategoryId) q = q.where('parentCategoryId', '==', parentCategoryId);
    if (typeof isActive === 'boolean') q = q.where('isActive', '==', isActive);

    const snap = await q.get();
    return snap.docs.map((d) => d.data());
  }

  async findOne(id: string) {
    const ref = this.col().doc(id);
    const snap = await ref.get();

    if (!snap.exists) throw new NotFoundException('Category not found');

    const data = snap.data() as any;
    if (data?.isDeleted) throw new NotFoundException('Category not found');

    return data;
  }

  async update(id: string, dto: UpdateCategoryDto) {
    const ref = this.col().doc(id);
    const snap = await ref.get();

    if (!snap.exists) throw new NotFoundException('Category not found');

    const current = snap.data() as any;
    if (current?.isDeleted) throw new NotFoundException('Category not found');

    if (dto.slug !== undefined && dto.slug !== current.slug) {
      const slugExists = await this.col()
        .where('slug', '==', dto.slug)
        .where('isDeleted', '==', false)
        .limit(1)
        .get();

      if (!slugExists.empty) {
        throw new ConflictException('Category slug already exists');
      }
    }

    const updateData: any = {
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.slug !== undefined) updateData.slug = dto.slug;
    if (dto.description !== undefined) updateData.description = dto.description;
    if (dto.parentCategoryId !== undefined) updateData.parentCategoryId = dto.parentCategoryId;
    if (dto.imageURL !== undefined) updateData.imageURL = dto.imageURL;
    if (dto.isActive !== undefined) updateData.isActive = dto.isActive;

    await ref.update(updateData);

    const updated = await ref.get();
    return updated.data();
  }

  async remove(id: string) {
    await this.findOne(id);

    const ref = this.col().doc(id);
    await ref.update({
      isDeleted: true,
      deletedAt: this.firebaseService.fieldValue.serverTimestamp(),
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    });

    return { deleted: true, id };
  }
}