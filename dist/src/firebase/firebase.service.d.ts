import { OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
export declare class FirebaseService implements OnModuleInit {
    onModuleInit(): void;
    getFirestore(): admin.firestore.Firestore;
    getStorage(): admin.storage.Storage;
}
