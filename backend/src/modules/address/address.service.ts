import { Injectable, NotFoundException } from '@nestjs/common';
import { generateMeaningfulId } from '../../common/utils/generate-id.util';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';
import { FirebaseService } from '../../firebase/firebase.service';

type AddressDoc = {
  id: string;
  userId: string;
  fullName: string;
  phoneNumber: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  district: string;
  postalCode: string;
  country: string;
  isDefault: boolean;
  isDeleted: boolean;
  createdAt: any;
  updatedAt: any;
  deletedAt?: any;
};

@Injectable()
export class AddressService {
  private readonly colName = 'addresses';

  constructor(private readonly firebaseService: FirebaseService) {}

  private col() {
    return this.firebaseService.firestore.collection(this.colName);
  }

  async create(dto: CreateAddressDto) {
    const customId = generateMeaningfulId('address');
    const ref = this.col().doc(customId);

    const data: any = {
      id: ref.id,
      userId: dto.userId,
      fullName: dto.fullName,
      phoneNumber: dto.phoneNumber,
      addressLine1: dto.addressLine1,
      city: dto.city,
      district: dto.district,
      postalCode: dto.postalCode,
      country: dto.country,
      isDefault: dto.isDefault ?? false,
      isDeleted: false,
      createdAt: this.firebaseService.fieldValue.serverTimestamp(),
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    if (dto.addressLine2 !== undefined) {
      data.addressLine2 = dto.addressLine2;
    }

    // if this address is set as default, unset other default addresses of same user
    if (data.isDefault === true) {
      const existingDefaults = await this.col()
        .where('userId', '==', dto.userId)
        .where('isDeleted', '==', false)
        .where('isDefault', '==', true)
        .get();

      const batch = this.firebaseService.firestore.batch();

      existingDefaults.docs.forEach((doc) => {
        batch.update(doc.ref, {
          isDefault: false,
          updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
        });
      });

      batch.set(ref, data);
      await batch.commit();
    } else {
      await ref.set(data);
    }

    const created = await ref.get();
    return created.data();
  }

  async findAll(userId?: string, isDefault?: boolean) {
    let q = this.col().where('isDeleted', '==', false);

    if (userId) q = q.where('userId', '==', userId);
    if (typeof isDefault === 'boolean') q = q.where('isDefault', '==', isDefault);

    const snap = await q.get();
    return snap.docs.map((d) => d.data());
  }

  async findOne(id: string) {
    const ref = this.col().doc(id);
    const snap = await ref.get();

    if (!snap.exists) throw new NotFoundException('Address not found');

    const data = snap.data() as any;
    if (data?.isDeleted) throw new NotFoundException('Address not found');

    return data;
  }

  async update(id: string, dto: UpdateAddressDto) {
    const ref = this.col().doc(id);
    const snap = await ref.get();

    if (!snap.exists) throw new NotFoundException('Address not found');

    const current = snap.data() as any;
    if (current?.isDeleted) throw new NotFoundException('Address not found');

    const updateData: any = {
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    if (dto.userId !== undefined) updateData.userId = dto.userId;
    if (dto.fullName !== undefined) updateData.fullName = dto.fullName;
    if (dto.phoneNumber !== undefined) updateData.phoneNumber = dto.phoneNumber;
    if (dto.addressLine1 !== undefined) updateData.addressLine1 = dto.addressLine1;
    if (dto.addressLine2 !== undefined) updateData.addressLine2 = dto.addressLine2;
    if (dto.city !== undefined) updateData.city = dto.city;
    if (dto.district !== undefined) updateData.district = dto.district;
    if (dto.postalCode !== undefined) updateData.postalCode = dto.postalCode;
    if (dto.country !== undefined) updateData.country = dto.country;
    if (dto.isDefault !== undefined) updateData.isDefault = dto.isDefault;

    // if making this address default, unset others for same user
    if (dto.isDefault === true) {
      const targetUserId = dto.userId ?? current.userId;

      const existingDefaults = await this.col()
        .where('userId', '==', targetUserId)
        .where('isDeleted', '==', false)
        .where('isDefault', '==', true)
        .get();

      const batch = this.firebaseService.firestore.batch();

      existingDefaults.docs.forEach((doc) => {
        if (doc.id !== id) {
          batch.update(doc.ref, {
            isDefault: false,
            updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
          });
        }
      });

      batch.update(ref, updateData);
      await batch.commit();
    } else {
      await ref.update(updateData);
    }

    const updated = await ref.get();
    return updated.data();
  }

  async remove(id: string) {
    await this.findOne(id);

    const ref = this.col().doc(id);
    await ref.update({
      isDeleted: true,
      isDefault: false,
      deletedAt: this.firebaseService.fieldValue.serverTimestamp(),
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    });

    return { deleted: true, id };
  }
}