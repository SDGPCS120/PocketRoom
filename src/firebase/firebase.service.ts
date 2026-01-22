import { Injectable, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
    onModuleInit() {
        try {
            const serviceAccount = require(path.resolve('service-account.json'));

            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined
            });

            console.log('Firebase Admin Initialized Successfully');
        } catch (error) {
            console.error('Firebase Admin Initialization Failed:', error.message);
            throw error;
        }
    }

    getFirestore() {
        return admin.firestore();
    }

    getStorage() {
        return admin.storage();
    }
}