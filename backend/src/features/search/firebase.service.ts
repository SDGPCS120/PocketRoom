import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService implements OnModuleInit {
    private readonly logger = new Logger(FirebaseService.name);
    private _db!: admin.firestore.Firestore;
    private initialized = false;
    private initPromise: Promise<void> | null = null;

    constructor(private configService: ConfigService) { }

    onModuleInit() {
        return this.initialize();
    }

    async initialize(): Promise<void> {
        if (this.initPromise) return this.initPromise;

        this.initPromise = (async () => {
            const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
            const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
            const privateKey = this.configService
                .get<string>('FIREBASE_PRIVATE_KEY')
                ?.replace(/\\n/g, '\n');

            if (!projectId || !clientEmail || !privateKey) {
                this.logger.warn(
                    'Firebase credentials are missing. Firestore-backed product loading is disabled.',
                );
                return;
            }

            try {
                if (!admin.apps.length) {
                    admin.initializeApp({
                        credential: admin.credential.cert({
                            projectId,
                            clientEmail,
                            privateKey,
                        }),
                    });
                }
                this._db = admin.firestore();
                this.initialized = true;
                this.logger.log('Firebase initialized successfully.');
            } catch (error) {
                this.logger.error(`Failed to initialize Firebase: ${error}`);
            }
        })();

        return this.initPromise;
    }

    async waitForInitialization(): Promise<boolean> {
        if (!this.initPromise) {
            await this.initialize();
        }
        await this.initPromise;
        return this.initialized;
    }

    get db() {
        return this._db;
    }

    get isInitialized() {
        return this.initialized;
    }
}
