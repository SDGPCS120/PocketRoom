import { FirebaseService } from '../firebase/firebase.service';
import { CreateProductDto } from './dto/create-product.dto';
import { Queue } from 'bullmq';
import { GenerateModelDto } from './dto/generate-model.dto';
export declare class ProductsService {
    private readonly firebaseService;
    private readonly generationQueue;
    constructor(firebaseService: FirebaseService, generationQueue: Queue);
    create(createProductDto: CreateProductDto): Promise<{
        id: string;
        message: string;
    }>;
    uploadProductImage(productId: string, fileBuffer: Buffer, mimeType: string): Promise<{
        imageUrl: string;
        imagePath: string;
    }>;
    generateModel(productId: string, imageFile: Express.Multer.File, dimensions: GenerateModelDto): Promise<{
        message: string;
        jobId: string | undefined;
        productId: string;
        status: string;
    }>;
    regenerateModel(productId: string, dimensions: GenerateModelDto): Promise<{
        message: string;
        jobId: string | undefined;
        status: string;
    }>;
    findAll(): Promise<{
        id: string;
    }[]>;
    findOne(id: string): Promise<{
        id: string;
    }>;
    update(id: string, updateProductDto: Partial<CreateProductDto>): Promise<{
        id: string;
        message: string;
    }>;
    remove(id: string): Promise<{
        id: string;
        message: string;
    }>;
}
