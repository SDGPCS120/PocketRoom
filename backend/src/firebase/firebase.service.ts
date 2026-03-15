import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { resolve } from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private app!: admin.app.App;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    if (admin.apps.length > 0) {
      this.app = admin.apps[0]!;
      this.logger.log('Reusing existing Firebase Admin app');
      return;
    }

    const serviceAccountPath = this.configService.get<string>(
      'FIREBASE_SERVICE_ACCOUNT_PATH',
    );

    if (!serviceAccountPath) {
      this.logger.warn(
        'FIREBASE_SERVICE_ACCOUNT_PATH not set — using application default credentials',
      );
      this.app = admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
    } else {
      const absolutePath = resolve(serviceAccountPath);
      const serviceAccount = JSON.parse(
        readFileSync(absolutePath, 'utf-8'),
      ) as admin.ServiceAccount;

      this.app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }

    this.app.firestore().settings({ ignoreUndefinedProperties: true });
    this.logger.log('Firebase Admin initialized successfully');
  }

  get firestore(): admin.firestore.Firestore {
    return this.app.firestore();
  }

  get auth(): admin.auth.Auth {
    return this.app.auth();
  }

  get storage(): admin.storage.Storage {
    return this.app.storage();
  }

  get fieldValue(): typeof admin.firestore.FieldValue {
    return admin.firestore.FieldValue;
  }
}
