import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';
import { generateMeaningfulId } from '../../common/utils/generate-id.util';
import { AuthUser } from './types/auth-user.type.js';

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
    uid: string,
    email: string | null,
    isAnonymous: boolean,
    requestedRole?: UserRole,
  ): Promise<SyncResult> {
    console.log(`[SyncUser] uid: ${uid}, reqRole: ${requestedRole}`);
    const db = this.firebaseService.firestore;
    let defaultRole: UserRole = isAnonymous ? 'anonymous' : 'customer';

    if (requestedRole === 'vendor' || requestedRole === 'seller' || requestedRole === 'customer') {
      defaultRole = requestedRole === 'vendor' ? 'seller' : requestedRole;
    }
    console.log(`[SyncUser] setting defaultRole to: ${defaultRole}`);

    const existingByAuthUidSnap = await db.collection('users').where('authUid', '==', uid).limit(1).get();
    const legacyRef = db.collection('users').doc(uid);
    const legacySnap = await legacyRef.get();

    if (!legacySnap.exists && existingByAuthUidSnap.empty) {
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

    const isLegacy = legacySnap.exists;
    const docSnap = isLegacy ? legacySnap : existingByAuthUidSnap.docs[0];
    const docRef = isLegacy ? legacyRef : docSnap.ref;

    const existingUser = toFirestoreUser(
      docSnap.id,
      docSnap.data() as unknown,
      email,
      defaultRole,
    );

    const currentRole = existingUser.role === 'vendor' ? 'seller' : existingUser.role;
    const preservedRole: UserRole = currentRole === 'seller' ? 'seller' : defaultRole;

    await docRef.set({
      uid: docSnap.id,
      authUid: existingUser.authUid ?? uid,
      email: existingUser.email ?? email,
      role: preservedRole,
      lastLoginAt: this.firebaseService.fieldValue.serverTimestamp(),
    }, { merge: true });

    const user: FirestoreUser = {
      uid: docSnap.id,
      authUid: existingUser.authUid ?? uid,
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

  async deleteCurrentUser(authUser: AuthUser): Promise<{
    status: 'deleted';
    deletedUserDocs: number;
    deletedUsernameDocs: number;
    deletedAuthUser: boolean;
  }> {
    const db = this.firebaseService.firestore;
    const authUid = authUser.authUid ?? authUser.uid;
    const userSnapshots = new Map<string, FirebaseFirestore.DocumentSnapshot>();
    const usernameRefs = new Map<string, FirebaseFirestore.DocumentReference>();

    const addUserSnapshot = (snap: FirebaseFirestore.DocumentSnapshot) => {
      if (snap.exists) {
        userSnapshots.set(snap.ref.path, snap);
      }
    };

    for (const userDocId of new Set([authUser.uid, authUid])) {
      const userSnap = await db.collection('users').doc(userDocId).get();
      addUserSnapshot(userSnap);
    }

    const relatedUsersSnap = await db
      .collection('users')
      .where('authUid', '==', authUid)
      .get();
    for (const userSnap of relatedUsersSnap.docs) {
      addUserSnapshot(userSnap);
    }

    for (const userSnap of userSnapshots.values()) {
      const data = userSnap.data() as UnknownDoc | undefined;
      const usernameNormalized =
        typeof data?.usernameNormalized === 'string'
          ? data.usernameNormalized
          : null;

      if (usernameNormalized) {
        const usernameRef = db.collection('usernames').doc(usernameNormalized);
        usernameRefs.set(usernameRef.path, usernameRef);
      }
    }

    for (const uidToMatch of new Set([authUid, authUser.uid])) {
      const usernameSnap = await db
        .collection('usernames')
        .where('uid', '==', uidToMatch)
        .get();

      for (const doc of usernameSnap.docs) {
        usernameRefs.set(doc.ref.path, doc.ref);
      }
    }

    const batch = db.batch();
    for (const userSnap of userSnapshots.values()) {
      batch.delete(userSnap.ref);
    }
    for (const usernameRef of usernameRefs.values()) {
      batch.delete(usernameRef);
    }
    await batch.commit();

    let deletedAuthUser = true;
    try {
      await this.firebaseService.auth.deleteUser(authUid);
    } catch (error) {
      const code =
        typeof error === 'object' &&
        error !== null &&
        'code' in error &&
        typeof (error as { code?: unknown }).code === 'string'
          ? (error as { code: string }).code
          : null;

      if (code !== 'auth/user-not-found') {
        throw error;
      }

      deletedAuthUser = false;
    }

    return {
      status: 'deleted',
      deletedUserDocs: userSnapshots.size,
      deletedUsernameDocs: usernameRefs.size,
      deletedAuthUser,
    };
  }
}
