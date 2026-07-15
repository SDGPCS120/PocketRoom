export const CATEGORIES = ['Sofa', 'Chair', 'Table', 'Bed', 'Storage', 'Decor'] as const;

export type FurnitureCategory = (typeof CATEGORIES)[number];
