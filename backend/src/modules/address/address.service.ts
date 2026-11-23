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

  async create(userId: string, dto: CreateAddressDto) {
    const customId = generateMeaningfulId('address');
    const ref = this.col().doc(customId);

    const data: any = {
      id: ref.id,
      userId,
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
      await this.firebaseService.firestore.runTransaction(async (transaction) => {
        await this.clearOtherDefaults(transaction, userId);
        transaction.create(ref, data);
      });
    } else {
      await ref.create(data);
    }

    const created = await ref.get();
    return created.data();
  }

  async findAll(userId: string, isDefault?: boolean) {
    // Filter isDeleted and isDefault in memory to avoid composite indexes.
    const snap = await this.col().where('userId', '==', userId).get();
    let results = snap.docs.map((d) => d.data() as any);

    // In-memory filters (avoids composite index requirement)
    results = results.filter((r: any) => !r.isDeleted);
    if (typeof isDefault === 'boolean') {
      results = results.filter((r: any) => r.isDefault === isDefault);
    }

    return results;
  }

  private requireOwnedAddress(snap: FirebaseFirestore.DocumentSnapshot, userId: string) {
    const data = snap.data() as AddressDoc | undefined;
    if (!data || data.isDeleted || data.userId !== userId) {
      throw new NotFoundException('Address not found');
    }
    return data;
  }

  private async clearOtherDefaults(
    transaction: FirebaseFirestore.Transaction,
    userId: string,
    exceptId?: string,
  ) {
    const addresses = await transaction.get(this.col().where('userId', '==', userId));
    for (const doc of addresses.docs) {
      const address = doc.data() as AddressDoc;
      if (doc.id !== exceptId && !address.isDeleted && address.isDefault === true) {
        transaction.update(doc.ref, {
          isDefault: false,
          updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
        });
      }
    }
  }

  async findOne(userId: string, id: string) {
    return this.requireOwnedAddress(await this.col().doc(id).get(), userId);
  }

  async update(userId: string, id: string, dto: UpdateAddressDto) {
    const ref = this.col().doc(id);

    const updateData: any = {
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

    if (dto.fullName !== undefined) updateData.fullName = dto.fullName;
    if (dto.phoneNumber !== undefined) updateData.phoneNumber = dto.phoneNumber;
    if (dto.addressLine1 !== undefined) updateData.addressLine1 = dto.addressLine1;
    if (dto.addressLine2 !== undefined) updateData.addressLine2 = dto.addressLine2;
    if (dto.city !== undefined) updateData.city = dto.city;
    if (dto.district !== undefined) updateData.district = dto.district;
    if (dto.postalCode !== undefined) updateData.postalCode = dto.postalCode;
    if (dto.country !== undefined) updateData.country = dto.country;
    if (dto.isDefault !== undefined) updateData.isDefault = dto.isDefault;

    await this.firebaseService.firestore.runTransaction(async (transaction) => {
      this.requireOwnedAddress(await transaction.get(ref), userId);
      if (dto.isDefault === true) {
        await this.clearOtherDefaults(transaction, userId, id);
      }
      transaction.update(ref, updateData);
    });

    return this.findOne(userId, id);
  }

  async remove(userId: string, id: string) {
    const ref = this.col().doc(id);
    await this.firebaseService.firestore.runTransaction(async (transaction) => {
      this.requireOwnedAddress(await transaction.get(ref), userId);
      transaction.update(ref, {
        isDeleted: true,
        isDefault: false,
        deletedAt: this.firebaseService.fieldValue.serverTimestamp(),
        updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
      });
    });

    return { deleted: true, id };
  }
}
