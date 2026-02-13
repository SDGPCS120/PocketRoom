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
};

export const MOCK_FURNITURE: FurnitureItem[] = [
  {
    id: 'P001',
    name: 'Velvet Accent Chair',
    category: 'Chair',
    price: 58900,
    style: 'Modern',
    color: 'Pink',
    material: 'Velvet',
    rating: 4.6,
    inStock: true,
  },
  {
    id: 'P002',
    name: 'Wooden Bed Frame',
    category: 'Bed',
    price: 120000,
    style: 'Modern',
    color: 'Oak',
    material: 'Wood',
    rating: 4.3,
    inStock: true,
  },
  {
    id: 'P003',
    name: 'Standing Lamp',
    category: 'Lamp',
    price: 18000,
    style: 'Modern',
    color: 'White',
    material: 'Metal',
    rating: 4.4,
    inStock: true,
  },
  {
    id: 'P004',
    name: 'Soft Area Rug',
    category: 'Rug',
    price: 35000,
    style: 'Modern',
    color: 'White',
    material: 'Fabric',
    rating: 4.1,
    inStock: true,
  },
  {
    id: 'P005',
    name: 'Wardrobe (2-door)',
    category: 'Wardrobe',
    price: 90000,
    style: 'Modern',
    color: 'Oak',
    material: 'Wood',
    rating: 4.0,
    inStock: true,
  },
];
