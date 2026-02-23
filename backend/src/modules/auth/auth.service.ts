import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service.js';

export type FirestoreUser = {
  uid: string;
  email: string | null;
  roles: string[];
};

export type SyncResult =
  | { status: 'created'; user: FirestoreUser }
  | { status: 'exists'; user: FirestoreUser };

type UnknownDoc = Record<string, unknown>;

function isStringArray(v: unknown): v is string[] {
  return Array.isArray(v) && v.every((x) => typeof x === 'string');
}

function asUnknownDoc(v: unknown): UnknownDoc {
  return typeof v === 'object' && v !== null ? (v as UnknownDoc) : {};
}

function toFirestoreUser(
  uid: string,
  raw: unknown,
  fallbackEmail: string | null,
): FirestoreUser {
  const doc = asUnknownDoc(raw);

  const email = typeof doc.email === 'string' ? doc.email : fallbackEmail;

  const roles = isStringArray(doc.roles) ? doc.roles : ['user'];

  return { uid, email, roles };
}

@Injectable()
export class AuthService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async syncUser(uid: string, email: string | null): Promise<SyncResult> {
    const db = this.firebaseService.firestore;

    const ref = db.collection('users').doc(uid);
    const snap = await ref.get();

    if (!snap.exists) {
      const user: FirestoreUser = {
        uid,
        email,
        roles: ['user'],
      };

      await ref.set({
        ...user,
        createdAt: this.firebaseService.fieldValue.serverTimestamp(),
        lastLoginAt: this.firebaseService.fieldValue.serverTimestamp(),
      });

      return { status: 'created', user };
    }

    await ref.update({
      lastLoginAt: this.firebaseService.fieldValue.serverTimestamp(),
    });

    // snap.data() can be loosely typed; treat it as unknown and normalize
    const user = toFirestoreUser(uid, snap.data() as unknown, email);
    return { status: 'exists', user };
  }

  async getRoles(uid: string): Promise<string[]> {
    const db = this.firebaseService.firestore;

    const snap = await db.collection('users').doc(uid).get();
    const user = toFirestoreUser(uid, snap.data() as unknown, null);
    return user.roles;
  }
}
