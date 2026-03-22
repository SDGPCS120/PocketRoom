export type FurnitureItem = {
    id: string;
    name: string;
    category: string;
    price: number;
    style?: string;
    color?: string;
    material?: string;
    rating?: number;
    inStock?: boolean;
    images?: string[];
    brand?: string;
    imageUrl?: string | string[];
};
