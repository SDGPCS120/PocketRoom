import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { generateMeaningfulId } from '../../common/utils/generate-id.util';
import { FirebaseService } from '../../firebase/firebase.service';
import type { AuthUser } from '../auth/types/auth-user.type';
import { isAdministrator, requireAdministrator } from '../auth/types/authenticated-request';
import { CreateUserDto, UserRole } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UserService {
  constructor(private readonly firebaseService: FirebaseService) {}

  private col() {
    return this.firebaseService.firestore.collection('users');
  }

  private profile(snapshot: FirebaseFirestore.DocumentSnapshot) {
    const data = snapshot.data()!;
    const { uid, email, fullName, phoneNumber, photoURL, role, isActive, isDeleted, createdAt, updatedAt } = data;
    return { id: snapshot.id, uid, email, fullName, phoneNumber, photoURL, role, isActive, isDeleted, createdAt, updatedAt };
  }

  private checkAccess(actor: AuthUser, snapshot: FirebaseFirestore.DocumentSnapshot) {
    const data = snapshot.data();
    if (!data || data.isDeleted) throw new NotFoundException('User not found');
    if (isAdministrator(actor)) return;
    // Auth sync stores authUid on mapped profiles. Legacy profiles used it as their ID.
    const owner = data.authUid === undefined ? snapshot.id : data.authUid;
    if (!actor.authUid || actor.authUid !== owner) throw new NotFoundException('User not found');
  }

  async create(actor: AuthUser, dto: CreateUserDto) {
    requireAdministrator(actor);
    const ref = this.col().doc(generateMeaningfulId(dto.fullName ?? dto.email));
    const timestamp = this.firebaseService.fieldValue.serverTimestamp();
    await ref.create({
      id: ref.id,
      email: dto.email,
      fullName: dto.fullName,
      role: dto.role ?? UserRole.CUSTOMER,
      isActive: dto.isActive ?? true,
      isDeleted: false,
      createdAt: timestamp,
      updatedAt: timestamp,
      ...(dto.phoneNumber !== undefined && { phoneNumber: dto.phoneNumber }),
      ...(dto.photoURL !== undefined && { photoURL: dto.photoURL }),
    });
    return this.profile(await ref.get());
  }

  async findAll(actor: AuthUser, role?: UserRole, isActive?: boolean) {
    requireAdministrator(actor);
    let query = this.col().where('isDeleted', '==', false);
    if (role) query = query.where('role', '==', role);
    if (typeof isActive === 'boolean') query = query.where('isActive', '==', isActive);
    return (await query.get()).docs.map((doc) => this.profile(doc));
  }

  async findOne(actor: AuthUser, id: string) {
    const snapshot = await this.col().doc(id).get();
    this.checkAccess(actor, snapshot);
    return this.profile(snapshot);
  }

  async update(actor: AuthUser, id: string, dto: UpdateUserDto) {
    const ref = this.col().doc(id);
    const { email, role, isActive, fullName, phoneNumber, photoURL } = dto;
    await this.firebaseService.firestore.runTransaction(async (transaction) => {
      this.checkAccess(actor, await transaction.get(ref));
      if (!isAdministrator(actor) && (email !== undefined || role !== undefined || isActive !== undefined)) {
        throw new ForbiddenException('Only administrators may change email, role, or account status');
      }
      transaction.update(ref, {
        updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
        ...(email !== undefined && { email }),
        ...(role !== undefined && { role }),
        ...(isActive !== undefined && { isActive }),
        ...(fullName !== undefined && { fullName }),
        ...(phoneNumber !== undefined && { phoneNumber }),
        ...(photoURL !== undefined && { photoURL }),
      });
    });
    return this.findOne(actor, id);
  }

  async remove(actor: AuthUser, id: string) {
    requireAdministrator(actor);
    const ref = this.col().doc(id);
    await this.firebaseService.firestore.runTransaction(async (transaction) => {
      this.checkAccess(actor, await transaction.get(ref));
      const timestamp = this.firebaseService.fieldValue.serverTimestamp();
      transaction.update(ref, { isDeleted: true, deletedAt: timestamp, updatedAt: timestamp });
    });
    return { deleted: true, id };
  }
}
