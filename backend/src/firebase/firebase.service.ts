import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as serviceAccount from '../../config/pocketroom-80f62-firebase-adminsdk-fbsvc-f7c34c2e27.json';

@Injectable()
export class FirebaseService {
  public firestore: FirebaseFirestore.Firestore;

  constructor() {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
      });
    }

    this.firestore = admin.firestore();
  }
}