import { Injectable, NotFoundException, ConflictException } from "@nestjs/common";
import { CreateUserDto, UserRole } from "./dto/create-user.dto";
import { UpdateUserDto } from "./dto/update-user.dto";
import { FirebaseService } from "../../firebase/firebase.service";

type UserDoc = {
  id: string;
  email: string;
  fullName: string;
  phoneNumber?: string;
  photoURL?: string;
  role: UserRole;
  isActive: boolean;
  isDeleted: boolean;
  createdAt: any;
  updatedAt: any;
  deletedAt?: any;
};

@Injectable()
export class UserService {
  private readonly colName = "users";

  constructor(private readonly firebaseService: FirebaseService) {}

  private col() {
    return this.firebaseService.firestore.collection(this.colName);
  }

 async create(dto: CreateUserDto) {
  const ref = this.col().doc();

  const data: any = {
    id: ref.id,
    email: dto.email,
    fullName: dto.fullName,
    role: dto.role ?? UserRole.CUSTOMER,
    isActive: dto.isActive ?? true,
    isDeleted: false,
    createdAt: this.firebaseService.fieldValue.serverTimestamp(),
    updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
  };

  if (dto.phoneNumber !== undefined) {
    data.phoneNumber = dto.phoneNumber;
  }

  if (dto.photoURL !== undefined) {
    data.photoURL = dto.photoURL;
  }

  await ref.set(data);
  const created = await ref.get();
  return created.data();
}

  async findAll(role?: UserRole, isActive?: boolean) {
    let q = this.col().where("isDeleted", "==", false);

    if (role) q = q.where("role", "==", role);
    if (typeof isActive === "boolean") q = q.where("isActive", "==", isActive);

    const snap = await q.get();
    return snap.docs.map((d) => d.data());
  }

  async findOne(id: string) {
    const ref = this.col().doc(id);
    const snap = await ref.get();

    if (!snap.exists) throw new NotFoundException("User not found");

    const data = snap.data() as any;
    if (data?.isDeleted) throw new NotFoundException("User not found");

    return data;
  }

  async update(id: string, dto: UpdateUserDto) {
  const ref = this.col().doc(id);
  const snap = await ref.get();

  if (!snap.exists) throw new NotFoundException("User not found");

  const current = snap.data() as any;
  if (current?.isDeleted) throw new NotFoundException("User not found");

  const updateData: any = {
    updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
  };

  if (dto.email !== undefined && dto.email !== current.email) {
    updateData.email = dto.email;
  }

  if (dto.fullName !== undefined) updateData.fullName = dto.fullName;
  if (dto.phoneNumber !== undefined) updateData.phoneNumber = dto.phoneNumber;
  if (dto.photoURL !== undefined) updateData.photoURL = dto.photoURL;
  if (dto.role !== undefined) updateData.role = dto.role;
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