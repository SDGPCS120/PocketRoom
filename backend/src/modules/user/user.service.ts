import { Injectable, NotFoundException, ConflictException } from "@nestjs/common";
import { Firestore } from "firebase-admin/firestore";
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
  private db: Firestore;
  private colName = "users";

  constructor(private readonly firebaseService: FirebaseService) {
    this.db = this.firebaseService.firestore; // ✅ getter from your FirebaseService
  }

  private col() {
    return this.db.collection(this.colName);
  }

  async create(dto: CreateUserDto) {
    const existing = await this.col()
      .where("email", "==", dto.email)
      .where("isDeleted", "==", false)
      .limit(1)
      .get();

    if (!existing.empty) {
      throw new ConflictException("User with this email already exists");
    }

    const ref = this.col().doc();

    const data: UserDoc = {
      id: ref.id,
      email: dto.email,
      fullName: dto.fullName,
      phoneNumber: dto.phoneNumber,
      photoURL: dto.photoURL,
      role: dto.role ?? UserRole.CUSTOMER,
      isActive: dto.isActive ?? true,
      isDeleted: false,
      createdAt: this.firebaseService.fieldValue.serverTimestamp(),
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    };

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

    if (dto.email && dto.email !== current.email) {
      const existing = await this.col()
        .where("email", "==", dto.email)
        .where("isDeleted", "==", false)
        .limit(1)
        .get();
      if (!existing.empty) throw new ConflictException("Email already in use");
    }

    await ref.update({
      ...dto,
      updatedAt: this.firebaseService.fieldValue.serverTimestamp(),
    });

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