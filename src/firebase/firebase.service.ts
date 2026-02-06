import { Injectable, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import serviceAccount from '../../service-account.json';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
  onModuleInit() {
    try {
      if (admin.apps.length === 0) {
        admin.initializeApp({
          credential: admin.credential.cert(
            serviceAccount as admin.ServiceAccount,
          ),
          storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined,
        });
        console.log('Firebase Admin Initialized Successfully');
      }
    } catch (error: any) {
      console.error('Firebase Admin Initialization Failed:', error.message);
      throw error;
    }
  }

  getFirestore(): admin.firestore.Firestore {
    return admin.firestore();
  }

  getStorage(): admin.storage.Storage {
    return admin.storage();
  }
}
