import { WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { FirebaseService } from '../firebase/firebase.service';
interface GenerationJobData {
    productId: string;
    imageUrl: string;
    dimensions?: any;
}
export declare class GenerationProcessor extends WorkerHost {
    private readonly firebaseService;
    private readonly logger;
    constructor(firebaseService: FirebaseService);
    process(job: Job<GenerationJobData, any, string>): Promise<any>;
}
export {};
