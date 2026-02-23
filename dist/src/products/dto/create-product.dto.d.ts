declare class DimensionsDto {
    height: number;
    length: number;
    width: number;
}
export declare class CreateProductDto {
    name: string;
    price: number;
    dimensions: DimensionsDto;
    material: string;
    modelURL?: string;
    primaryColor: string;
    productID?: string;
    stockStatus?: boolean;
    styleTags?: string[];
    imageUrl?: string;
    imagePath?: string;
    modelStatus?: string;
    modelError?: string;
    updatedAt?: Date;
}
export {};
