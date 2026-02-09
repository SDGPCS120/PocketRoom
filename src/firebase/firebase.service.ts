import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);

  onModuleInit() {
    try {
      if (admin.apps.length === 0) {
        // Resolve absolute path to service-account.json in project root
        const serviceAccountPath = path.resolve(process.cwd(), 'service-account.json');

        // Dynamic require to handle local file
        const serviceAccount = require(serviceAccountPath);

        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined,
        });

        this.logger.log('Firebase Admin Initialized Successfully');
      }
    } catch (error: any) {
      if (error.code === 'MODULE_NOT_FOUND') {
        this.logger.error(
          'Firebase initialization failed: service-account.json not found in project root.',
        );
      } else {
        this.logger.error('Firebase Admin Initialization Failed:', error.message);
      }
      // We don't throw here to allow the app to start, but features using Firebase will fail
    }
  }

  getFirestore(): admin.firestore.Firestore {
    return admin.firestore();
  }

  getStorage(): admin.storage.Storage {
    return admin.storage();
  }
}
