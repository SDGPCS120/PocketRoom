import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';

export type UserRole = 'anonymous' | 'customer' | 'vendor';

export type FirestoreUser = {
  uid: string;
  email: string | null;
  role: UserRole;
};

export type SyncResult =
  | { status: 'created'; user: FirestoreUser }
  | { status: 'exists'; user: FirestoreUser };

type UnknownDoc = Record<string, unknown>;

function asUnknownDoc(v: unknown): UnknownDoc {
  return typeof v === 'object' && v !== null ? (v as UnknownDoc) : {};
}

function normalizeLegacyRole(rawRole: unknown): UserRole | null {
  if (rawRole === 'anonymous' || rawRole === 'customer' || rawRole === 'vendor') {
    return rawRole;
  }

  // Backward compatibility for previous role naming.
  if (rawRole === 'user') return 'customer';
  return null;
}

function toFirestoreUser(
  uid: string,
  raw: unknown,
  fallbackEmail: string | null,
  fallbackRole: UserRole,
): FirestoreUser {
  const doc = asUnknownDoc(raw);

  const email = typeof doc.email === 'string' ? doc.email : fallbackEmail;
  const directRole = normalizeLegacyRole(doc.role);

  // Backward compatibility for legacy roles[] shape.
  const legacyRoles =
    Array.isArray(doc.roles) && doc.roles.every((x) => typeof x === 'string')
      ? (doc.roles as string[])
      : null;
  const legacyRole = legacyRoles && legacyRoles.length > 0
    ? normalizeLegacyRole(legacyRoles[0])
    : null;

  const role = directRole ?? legacyRole ?? fallbackRole;
  return { uid, email, role };
}

@Injectable()
export class AuthService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async syncUser(
    uid: string,
    email: string | null,
    isAnonymous: boolean,
    requestedRole?: UserRole,
  ): Promise<SyncResult> {
    console.log(`[SyncUser] uid: ${uid}, reqRole: ${requestedRole}`);
    const db = this.firebaseService.firestore;
    let defaultRole: UserRole = isAnonymous ? 'anonymous' : 'customer';

    if (requestedRole === 'vendor' || requestedRole === 'customer') {
      defaultRole = requestedRole;
    }
    console.log(`[SyncUser] setting defaultRole to: ${defaultRole}`);

    const ref = db.collection('users').doc(uid);
    const snap = await ref.get();

    if (!snap.exists) {
      const user: FirestoreUser = {
        uid,
        email,
        role: defaultRole,
      };

      await ref.set({
        ...user,
        createdAt: this.firebaseService.fieldValue.serverTimestamp(),
        lastLoginAt: this.firebaseService.fieldValue.serverTimestamp(),
      });

      return { status: 'created', user };
    }

    const existingUser = toFirestoreUser(
      uid,
      snap.data() as unknown,
      email,
      defaultRole,
    );
    // If the vendor was already a vendor, keep it vendor, OR if the request specifically upgrades/requests a valid role.
    const preservedRole: UserRole =
      existingUser.role === 'vendor' ? 'vendor' : defaultRole;

    await ref.set({
      uid,
      email: existingUser.email ?? email,
      role: preservedRole,
      lastLoginAt: this.firebaseService.fieldValue.serverTimestamp(),
    }, { merge: true });

    const user: FirestoreUser = {
      uid,
      email: existingUser.email ?? email,
      role: preservedRole,
    };
    return { status: 'exists', user };
  }

  async getRole(uid: string): Promise<UserRole> {
    const db = this.firebaseService.firestore;

    const snap = await db.collection('users').doc(uid).get();
    const user = toFirestoreUser(uid, snap.data() as unknown, null, 'customer');
    return user.role;
  }
}
