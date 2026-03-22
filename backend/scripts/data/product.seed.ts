export const products = [
    // ================= CHAIRS (6) =================
    {
        id: 'pink-fluffy-cloud-chair',
        name: 'Pink Fluffy Cloud Chair',
        description: 'A cozy fluffy accent chair with a playful cloud-inspired silhouette.',
        price: 24990,
        stock: 10,
        brand: 'PocketRoom',
        rating: 4.6,
        imageUrl: [],
        furnitureType: 'chair',
        dimensions: { height: 95, length: 75, width: 80 },
        modelURL: '',
        similarProducts: [
            'velvet-petal-chair', 'nordic-lounge-chair', 'ivory-nest-chair', 'amber-curve-chair', 'urban-recline-chair'
        ],
        customersAlsoBought: ['aurora-floor-lamp', 'oaknest-coffee-table', 'luna-wall-art-set'],
    },
    {
        id: 'nordic-lounge-chair',
        name: 'Nordic Lounge Chair',
        description: 'Minimalist Scandinavian-style lounge chair.',
        price: 28990,
        stock: 8,
        brand: 'PocketRoom',
        rating: 4.4,
        imageUrl: [],
        furnitureType: 'chair',
        dimensions: { height: 92, length: 78, width: 76 },
        modelURL: '',
        similarProducts: [
            'ivory-nest-chair', 'pink-fluffy-cloud-chair', 'amber-curve-chair', 'urban-recline-chair', 'velvet-petal-chair'
        ],
        customersAlsoBought: ['oaknest-coffee-table', 'urban-comfort-sofa', 'halo-floor-lamp'],
    },
    {
        id: 'ivory-nest-chair',
        name: 'Ivory Nest Chair',
        description: 'Soft upholstered chair perfect for compact spaces.',
        price: 26990,
        stock: 7,
        brand: 'PocketRoom',
        rating: 4.3,
        imageUrl: [],
        furnitureType: 'chair',
        dimensions: { height: 90, length: 74, width: 78 },
        modelURL: '',
        similarProducts: [
            'nordic-lounge-chair', 'pink-fluffy-cloud-chair', 'amber-curve-chair', 'velvet-petal-chair', 'urban-recline-chair'
        ],
        customersAlsoBought: ['marble-glow-side-table', 'aurora-floor-lamp', 'luna-wall-art-set'],
    },
    {
        id: 'urban-recline-chair',
        name: 'Urban Recline Chair',
        description: 'Modern reclined chair with premium comfort.',
        price: 31990,
        stock: 6,
        brand: 'PocketRoom',
        rating: 4.5,
        imageUrl: [],
        furnitureType: 'chair',
        dimensions: { height: 98, length: 82, width: 84 },
        modelURL: '',
        similarProducts: [
            'amber-curve-chair', 'velvet-petal-chair', 'nordic-lounge-chair', 'ivory-nest-chair', 'pink-fluffy-cloud-chair'
        ],
        customersAlsoBought: ['metro-3-seater-sofa', 'halo-floor-lamp', 'oaknest-coffee-table'],
    },
    {
        id: 'velvet-petal-chair',
        name: 'Velvet Petal Chair',
        description: 'Luxurious velvet chair with curved design.',
        price: 33990,
        stock: 5,
        brand: 'PocketRoom',
        rating: 4.7,
        imageUrl: [],
        furnitureType: 'chair',
        dimensions: { height: 96, length: 79, width: 81 },
        modelURL: '',
        similarProducts: [
            'pink-fluffy-cloud-chair', 'amber-curve-chair', 'urban-recline-chair', 'ivory-nest-chair', 'nordic-lounge-chair'
        ],
        customersAlsoBought: ['luna-wall-art-set', 'glassline-console-table', 'halo-floor-lamp'],
    },
    {
        id: 'amber-curve-chair',
        name: 'Amber Curve Chair',
        description: 'Warm-toned curved accent chair.',
        price: 29990,
        stock: 9,
        brand: 'PocketRoom',
        rating: 4.4,
        imageUrl: [],
        furnitureType: 'chair',
        dimensions: { height: 93, length: 77, width: 79 },
        modelURL: '',
        similarProducts: [
            'urban-recline-chair', 'velvet-petal-chair', 'nordic-lounge-chair', 'ivory-nest-chair', 'pink-fluffy-cloud-chair'
        ],
        customersAlsoBought: ['marble-glow-side-table', 'aurora-floor-lamp', 'urban-comfort-sofa'],
    },

    // ================= SOFAS (6) =================
    {
        id: 'urban-comfort-sofa',
        name: 'Urban Comfort Sofa',
        description: 'Spacious modern three-seater sofa.',
        price: 79990,
        stock: 5,
        brand: 'PocketRoom',
        rating: 4.7,
        imageUrl: [],
        furnitureType: 'sofa',
        dimensions: { height: 88, length: 90, width: 210 },
        modelURL: '',
        similarProducts: [
            'metro-3-seater-sofa', 'serene-linen-sofa', 'compact-city-sofa', 'cloud-rest-sofa', 'velour-luxe-sofa'
        ],
        customersAlsoBought: ['oaknest-coffee-table', 'aurora-floor-lamp', 'luna-wall-art-set'],
    },
    {
        id: 'metro-3-seater-sofa',
        name: 'Metro 3 Seater Sofa',
        description: 'Contemporary sofa with deep seating comfort.',
        price: 82990,
        stock: 4,
        brand: 'PocketRoom',
        rating: 4.6,
        imageUrl: [],
        furnitureType: 'sofa',
        dimensions: { height: 90, length: 95, width: 215 },
        modelURL: '',
        similarProducts: [
            'urban-comfort-sofa', 'serene-linen-sofa', 'velour-luxe-sofa', 'cloud-rest-sofa', 'compact-city-sofa'
        ],
        customersAlsoBought: ['oaknest-coffee-table', 'halo-floor-lamp', 'glassline-console-table'],
    },
    {
        id: 'serene-linen-sofa',
        name: 'Serene Linen Sofa',
        description: 'Lightweight linen sofa with airy design.',
        price: 75990,
        stock: 6,
        brand: 'PocketRoom',
        rating: 4.5,
        imageUrl: [],
        furnitureType: 'sofa',
        dimensions: { height: 87, length: 92, width: 205 },
        modelURL: '',
        similarProducts: [
            'urban-comfort-sofa', 'metro-3-seater-sofa', 'compact-city-sofa', 'cloud-rest-sofa', 'velour-luxe-sofa'
        ],
        customersAlsoBought: ['aurora-floor-lamp', 'luna-wall-art-set', 'oaknest-coffee-table'],
    },
    {
        id: 'cloud-rest-sofa',
        name: 'Cloud Rest Sofa',
        description: 'Ultra-soft sofa with plush cushioning.',
        price: 89990,
        stock: 3,
        brand: 'PocketRoom',
        rating: 4.8,
        imageUrl: [],
        furnitureType: 'sofa',
        dimensions: { height: 92, length: 100, width: 220 },
        modelURL: '',
        similarProducts: [
            'velour-luxe-sofa', 'metro-3-seater-sofa', 'urban-comfort-sofa', 'serene-linen-sofa', 'compact-city-sofa'
        ],
        customersAlsoBought: ['halo-floor-lamp', 'marble-glow-side-table', 'luna-wall-art-set'],
    },
    {
        id: 'compact-city-sofa',
        name: 'Compact City Sofa',
        description: 'Small sofa ideal for apartments.',
        price: 69990,
        stock: 7,
        brand: 'PocketRoom',
        rating: 4.3,
        imageUrl: [],
        furnitureType: 'sofa',
        dimensions: { height: 85, length: 85, width: 180 },
        modelURL: '',
        similarProducts: [
            'serene-linen-sofa', 'urban-comfort-sofa', 'metro-3-seater-sofa', 'cloud-rest-sofa', 'velour-luxe-sofa'
        ],
        customersAlsoBought: ['oaknest-coffee-table', 'aurora-floor-lamp', 'glassline-console-table'],
    },
    {
        id: 'velour-luxe-sofa',
        name: 'Velour Luxe Sofa',
        description: 'Premium velvet luxury sofa.',
        price: 94990,
        stock: 2,
        brand: 'PocketRoom',
        rating: 4.9,
        imageUrl: [],
        furnitureType: 'sofa',
        dimensions: { height: 95, length: 105, width: 225 },
        modelURL: '',
        similarProducts: [
            'cloud-rest-sofa', 'metro-3-seater-sofa', 'urban-comfort-sofa', 'serene-linen-sofa', 'compact-city-sofa'
        ],
        customersAlsoBought: ['halo-floor-lamp', 'luna-wall-art-set', 'marble-glow-side-table'],
    },

    // ================= TABLES (6) =================
    {
        id: 'oaknest-coffee-table',
        name: 'OakNest Coffee Table',
        description: 'Modern wooden coffee table.',
        price: 18990,
        stock: 9,
        brand: 'PocketRoom',
        rating: 4.3,
        imageUrl: [],
        furnitureType: 'table',
        dimensions: { height: 45, length: 55, width: 100 },
        modelURL: '',
        similarProducts: [
            'marble-glow-side-table',
            'minimalist-round-table',
            'compact-study-table',
            'glassline-console-table',
            'expandable-dining-table'
        ],
        customersAlsoBought: [
            'urban-comfort-sofa',
            'pink-fluffy-cloud-chair',
            'aurora-floor-lamp'
        ],
    },
    {
        id: 'marble-glow-side-table',
        name: 'Marble Glow Side Table',
        description: 'Elegant marble-top side table.',
        price: 15990,
        stock: 11,
        brand: 'PocketRoom',
        rating: 4.5,
        imageUrl: [],
        furnitureType: 'table',
        dimensions: { height: 50, length: 40, width: 40 },
        modelURL: '',
        similarProducts: [
            'minimalist-round-table',
            'oaknest-coffee-table',
            'compact-study-table',
            'glassline-console-table',
            'expandable-dining-table'
        ],
        customersAlsoBought: [
            'amber-curve-chair',
            'cloud-rest-sofa',
            'halo-floor-lamp'
        ],
    },
    {
        id: 'glassline-console-table',
        name: 'Glassline Console Table',
        description: 'Slim glass console table for entryways.',
        price: 22990,
        stock: 6,
        brand: 'PocketRoom',
        rating: 4.4,
        imageUrl: [],
        furnitureType: 'table',
        dimensions: { height: 80, length: 40, width: 120 },
        modelURL: '',
        similarProducts: [
            'compact-study-table',
            'oaknest-coffee-table',
            'expandable-dining-table',
            'marble-glow-side-table',
            'minimalist-round-table'
        ],
        customersAlsoBought: [
            'velvet-petal-chair',
            'metro-3-seater-sofa',
            'luna-wall-art-set'
        ],
    },
    {
        id: 'compact-study-table',
        name: 'Compact Study Table',
        description: 'Functional study desk for small spaces.',
        price: 19990,
        stock: 10,
        brand: 'PocketRoom',
        rating: 4.2,
        imageUrl: [],
        furnitureType: 'table',
        dimensions: { height: 75, length: 60, width: 100 },
        modelURL: '',
        similarProducts: [
            'glassline-console-table',
            'oaknest-coffee-table',
            'minimalist-round-table',
            'marble-glow-side-table',
            'expandable-dining-table'
        ],
        customersAlsoBought: [
            'ivory-nest-chair',
            'aurora-floor-lamp',
            'luna-wall-art-set'
        ],
    },
    {
        id: 'expandable-dining-table',
        name: 'Expandable Dining Table',
        description: 'Adjustable dining table for families.',
        price: 49990,
        stock: 4,
        brand: 'PocketRoom',
        rating: 4.6,
        imageUrl: [],
        furnitureType: 'table',
        dimensions: { height: 75, length: 90, width: 160 },
        modelURL: '',
        similarProducts: [
            'glassline-console-table',
            'compact-study-table',
            'oaknest-coffee-table',
            'minimalist-round-table',
            'marble-glow-side-table'
        ],
        customersAlsoBought: [
            'metro-3-seater-sofa',
            'halo-floor-lamp',
            'luna-wall-art-set'
        ],
    },
    {
        id: 'minimalist-round-table',
        name: 'Minimalist Round Table',
        description: 'Simple round table with modern design.',
        price: 17990,
        stock: 8,
        brand: 'PocketRoom',
        rating: 4.3,
        imageUrl: [],
        furnitureType: 'table',
        dimensions: { height: 50, length: 60, width: 60 },
        modelURL: '',
        similarProducts: [
            'marble-glow-side-table',
            'oaknest-coffee-table',
            'compact-study-table',
            'glassline-console-table',
            'expandable-dining-table'
        ],
        customersAlsoBought: [
            'amber-curve-chair',
            'aurora-floor-lamp',
            'luna-wall-art-set'
        ],
    },

    // ================= BEDS (6) =================
    {
        id: 'serenity-platform-bed',
        name: 'Serenity Platform Bed',
        description: 'Elegant platform bed with clean design.',
        price: 65990,
        stock: 4,
        brand: 'PocketRoom',
        rating: 4.5,
        imageUrl: [],
        furnitureType: 'bed',
        dimensions: { height: 110, length: 200, width: 160 },
        modelURL: '',
        similarProducts: [
            'soft-edge-bed',
            'storage-drawer-bed',
            'modern-loft-bed',
            'luxury-king-bed',
            'compact-single-bed'
        ],
        customersAlsoBought: [
            'aurora-floor-lamp',
            'luna-wall-art-set',
            'minimalist-round-table'
        ],
    },
    {
        id: 'luxury-king-bed',
        name: 'Luxury King Bed',
        description: 'Premium king-sized bed with headboard.',
        price: 99990,
        stock: 2,
        brand: 'PocketRoom',
        rating: 4.8,
        imageUrl: [],
        furnitureType: 'bed',
        dimensions: { height: 120, length: 210, width: 180 },
        modelURL: '',
        similarProducts: [
            'storage-drawer-bed',
            'serenity-platform-bed',
            'soft-edge-bed',
            'modern-loft-bed',
            'compact-single-bed'
        ],
        customersAlsoBought: [
            'halo-floor-lamp',
            'glassline-console-table',
            'luna-wall-art-set'
        ],
    },
    {
        id: 'compact-single-bed',
        name: 'Compact Single Bed',
        description: 'Space-saving single bed.',
        price: 39990,
        stock: 6,
        brand: 'PocketRoom',
        rating: 4.2,
        imageUrl: [],
        furnitureType: 'bed',
        dimensions: { height: 100, length: 190, width: 100 },
        modelURL: '',
        similarProducts: [
            'soft-edge-bed',
            'serenity-platform-bed',
            'modern-loft-bed',
            'storage-drawer-bed',
            'luxury-king-bed'
        ],
        customersAlsoBought: [
            'compact-study-table',
            'aurora-floor-lamp',
            'minimalist-round-table'
        ],
    },
    {
        id: 'storage-drawer-bed',
        name: 'Storage Drawer Bed',
        description: 'Bed with built-in storage drawers.',
        price: 74990,
        stock: 3,
        brand: 'PocketRoom',
        rating: 4.6,
        imageUrl: [],
        furnitureType: 'bed',
        dimensions: { height: 115, length: 200, width: 160 },
        modelURL: '',
        similarProducts: [
            'serenity-platform-bed',
            'luxury-king-bed',
            'soft-edge-bed',
            'modern-loft-bed',
            'compact-single-bed'
        ],
        customersAlsoBought: [
            'oaknest-coffee-table',
            'halo-floor-lamp',
            'luna-wall-art-set'
        ],
    },
    {
        id: 'modern-loft-bed',
        name: 'Modern Loft Bed',
        description: 'Elevated bed with workspace below.',
        price: 69990,
        stock: 2,
        brand: 'PocketRoom',
        rating: 4.5,
        imageUrl: [],
        furnitureType: 'bed',
        dimensions: { height: 180, length: 200, width: 140 },
        modelURL: '',
        similarProducts: [
            'storage-drawer-bed',
            'serenity-platform-bed',
            'soft-edge-bed',
            'compact-single-bed',
            'luxury-king-bed'
        ],
        customersAlsoBought: [
            'compact-study-table',
            'aurora-floor-lamp',
            'minimalist-round-table'
        ],
    },
    {
        id: 'soft-edge-bed',
        name: 'Soft Edge Bed',
        description: 'Bed with rounded soft edges.',
        price: 62990,
        stock: 5,
        brand: 'PocketRoom',
        rating: 4.4,
        imageUrl: [],
        furnitureType: 'bed',
        dimensions: { height: 105, length: 200, width: 150 },
        modelURL: '',
        similarProducts: [
            'serenity-platform-bed',
            'compact-single-bed',
            'storage-drawer-bed',
            'modern-loft-bed',
            'luxury-king-bed'
        ],
        customersAlsoBought: [
            'marble-glow-side-table',
            'halo-floor-lamp',
            'luna-wall-art-set'
        ],
    },

    // ================= DECOR (6) =================
    {
        id: 'aurora-floor-lamp',
        name: 'Aurora Floor Lamp',
        description: 'Elegant ambient floor lamp.',
        price: 12990,
        stock: 14,
        brand: 'PocketRoom',
        rating: 4.2,
        imageUrl: [],
        furnitureType: 'decor',
        dimensions: { height: 165, length: 35, width: 35 },
        modelURL: '',
        similarProducts: [
            'halo-floor-lamp',
            'minimalist-vase-set',
            'luna-wall-art-set',
            'geometric-rug',
            'ambient-led-strip'
        ],
        customersAlsoBought: [
            'pink-fluffy-cloud-chair',
            'oaknest-coffee-table',
            'urban-comfort-sofa'
        ],
    },
    {
        id: 'halo-floor-lamp',
        name: 'Halo Floor Lamp',
        description: 'Modern halo-style lighting piece.',
        price: 14990,
        stock: 10,
        brand: 'PocketRoom',
        rating: 4.5,
        imageUrl: [],
        furnitureType: 'decor',
        dimensions: { height: 170, length: 30, width: 30 },
        modelURL: '',
        similarProducts: [
            'aurora-floor-lamp',
            'ambient-led-strip',
            'minimalist-vase-set',
            'luna-wall-art-set',
            'geometric-rug'
        ],
        customersAlsoBought: [
            'velour-luxe-sofa',
            'marble-glow-side-table',
            'luxury-king-bed'
        ],
    },
    {
        id: 'luna-wall-art-set',
        name: 'Luna Wall Art Set',
        description: 'Modern abstract wall art set.',
        price: 9990,
        stock: 20,
        brand: 'PocketRoom',
        rating: 4.3,
        imageUrl: [],
        furnitureType: 'decor',
        dimensions: { height: 60, length: 5, width: 60 },
        modelURL: '',
        similarProducts: [
            'minimalist-vase-set',
            'geometric-rug',
            'ambient-led-strip',
            'aurora-floor-lamp',
            'halo-floor-lamp'
        ],
        customersAlsoBought: [
            'velvet-petal-chair',
            'urban-comfort-sofa',
            'glassline-console-table'
        ],
    },
    {
        id: 'minimalist-vase-set',
        name: 'Minimalist Vase Set',
        description: 'Decorative ceramic vases.',
        price: 7990,
        stock: 18,
        brand: 'PocketRoom',
        rating: 4.1,
        imageUrl: [],
        furnitureType: 'decor',
        dimensions: { height: 30, length: 20, width: 20 },
        modelURL: '',
        similarProducts: [
            'luna-wall-art-set',
            'ambient-led-strip',
            'geometric-rug',
            'aurora-floor-lamp',
            'halo-floor-lamp'
        ],
        customersAlsoBought: [
            'oaknest-coffee-table',
            'amber-curve-chair',
            'compact-study-table'
        ],
    },
    {
        id: 'geometric-rug',
        name: 'Geometric Rug',
        description: 'Stylish patterned rug.',
        price: 15990,
        stock: 12,
        brand: 'PocketRoom',
        rating: 4.4,
        imageUrl: [],
        furnitureType: 'decor',
        dimensions: { height: 1, length: 200, width: 150 },
        modelURL: '',
        similarProducts: [
            'luna-wall-art-set',
            'minimalist-vase-set',
            'ambient-led-strip',
            'halo-floor-lamp',
            'aurora-floor-lamp'
        ],
        customersAlsoBought: [
            'urban-comfort-sofa',
            'nordic-lounge-chair',
            'minimalist-round-table'
        ],
    },
    {
        id: 'ambient-led-strip',
        name: 'Ambient LED Strip',
        description: 'Smart LED strip for ambient lighting.',
        price: 5990,
        stock: 25,
        brand: 'PocketRoom',
        rating: 4.2,
        imageUrl: [],
        furnitureType: 'decor',
        dimensions: { height: 1, length: 500, width: 1 },
        modelURL: '',
        similarProducts: [
            'halo-floor-lamp',
            'minimalist-vase-set',
            'luna-wall-art-set',
            'aurora-floor-lamp',
            'geometric-rug'
        ],
        customersAlsoBought: [
            'metro-3-seater-sofa',
            'compact-study-table',
            'glassline-console-table'
        ],
    },
];