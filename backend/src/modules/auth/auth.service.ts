import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';
import { generateMeaningfulId } from '../../common/utils/generate-id.util';

export type UserRole = 'anonymous' | 'customer' | 'vendor' | 'seller';

export type FirestoreUser = {
  uid: string;
  email: string | null;
  role: UserRole;
  authUid?: string;
};

export type SyncResult =
  | { status: 'created'; user: FirestoreUser }
  | { status: 'exists'; user: FirestoreUser };

type UnknownDoc = Record<string, unknown>;

function asUnknownDoc(v: unknown): UnknownDoc {
  return typeof v === 'object' && v !== null ? (v as UnknownDoc) : {};
}

function normalizeLegacyRole(rawRole: unknown): UserRole | null {
  if (rawRole === 'anonymous' || rawRole === 'customer' || rawRole === 'vendor' || rawRole === 'seller') {
    return rawRole as UserRole;
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
  const authUid = typeof doc.authUid === 'string' ? doc.authUid : undefined;
  return { uid, email, role, authUid };
}

@Injectable()
export class AuthService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async syncUser(
    uid: string, // this is the Firebase Auth UID
    email: string | null,
    isAnonymous: boolean,
    requestedRole?: UserRole,
  ): Promise<SyncResult> {
    console.log(`[SyncUser] uid: ${uid}, reqRole: ${requestedRole}`);
    const db = this.firebaseService.firestore;
    let defaultRole: UserRole = isAnonymous ? 'anonymous' : 'customer';

    if (requestedRole === 'vendor' || requestedRole === 'seller' || requestedRole === 'customer') {
      defaultRole = requestedRole === 'vendor' ? 'seller' : requestedRole; // Auto-consolidate new vendor requests to seller
    }
    console.log(`[SyncUser] setting defaultRole to: ${defaultRole}`);

    // Check if user already exists as a meaningful ID
    const existingByAuthUidSnap = await db.collection('users').where('authUid', '==', uid).limit(1).get();
    
    // Check if user exists as a legacy ID
    const legacyRef = db.collection('users').doc(uid);
    const legacySnap = await legacyRef.get();

    if (!legacySnap.exists && existingByAuthUidSnap.empty) {
      // ── BRAND NEW USER: Generate Meaningful ID ──
      const prefix = email ? email.split('@')[0] : 'user';
      const meaningfulId = generateMeaningfulId(prefix);
      const newRef = db.collection('users').doc(meaningfulId);

      const user: FirestoreUser = {
        uid: meaningfulId,
        authUid: uid,
        email,
        role: defaultRole,
      };

      await newRef.set({
        ...user,
        createdAt: this.firebaseService.fieldValue.serverTimestamp(),
        lastLoginAt: this.firebaseService.fieldValue.serverTimestamp(),
      });

      return { status: 'created', user };
    }

    // ── EXISTING USER: Update login time and role if needed ──
    const isLegacy = legacySnap.exists;
    const docSnap = isLegacy ? legacySnap : existingByAuthUidSnap.docs[0];
    const docRef = isLegacy ? legacyRef : docSnap.ref;
    
    const existingUser = toFirestoreUser(
      docSnap.id,
      docSnap.data() as unknown,
      email,
      defaultRole,
    );
    
    // If the user was already a vendor/seller, keep it seller, OR if the request specifically upgrades/requests a valid role.
    const currentRole = existingUser.role === 'vendor' ? 'seller' : existingUser.role;
    const preservedRole: UserRole = currentRole === 'seller' ? 'seller' : defaultRole;

    await docRef.set({
      uid: docSnap.id,
      email: existingUser.email ?? email,
      role: preservedRole,
      lastLoginAt: this.firebaseService.fieldValue.serverTimestamp(),
    }, { merge: true });

    const user: FirestoreUser = {
      uid: docSnap.id,
      authUid: existingUser.authUid,
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
