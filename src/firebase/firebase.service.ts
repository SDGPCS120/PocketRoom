import { Injectable, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import serviceAccount from '../../service-account.json';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
  onModuleInit() {
    try {
<<<<<<< HEAD
      const serviceAccount = require(path.resolve('service-account.json'));

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined,
      });

      console.log('Firebase Admin Initialized Successfully');
    } catch (error) {
=======
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
>>>>>>> d736028ecd9905450b5fd998b5f70e76ff4eef59
      console.error('Firebase Admin Initialization Failed:', error.message);
      throw error;
    }
  }

<<<<<<< HEAD
  getFirestore() {
    return admin.firestore();
  }

  getStorage() {
=======
  getFirestore(): admin.firestore.Firestore {
    return admin.firestore();
  }

  getStorage(): admin.storage.Storage {
>>>>>>> d736028ecd9905450b5fd998b5f70e76ff4eef59
    return admin.storage();
  }
}
