import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { GenerateModelDto } from './dto/generate-model.dto';
export declare class ProductsController {
    private readonly productsService;
    constructor(productsService: ProductsService);
    create(createProductDto: CreateProductDto): Promise<{
        id: string;
        message: string;
    }>;
    generateModel(id: string, file: Express.Multer.File, dimensions: GenerateModelDto): Promise<{
        message: string;
        jobId: string | undefined;
        productId: string;
        status: string;
    }>;
    findAll(): Promise<{
        id: string;
    }[]>;
    findOne(id: string): Promise<{
        id: string;
    }>;
    update(id: string, updateProductDto: UpdateProductDto): Promise<{
        id: string;
        message: string;
    }>;
    remove(id: string): Promise<{
        id: string;
        message: string;
    }>;
}
