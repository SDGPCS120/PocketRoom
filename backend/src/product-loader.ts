import { db } from './firebase';

export async function loadProductsFromFirestore(): Promise<any[]> {
    const snapshot = await db.collection('products').get();

    return snapshot.docs.map((doc) => {
        const data = doc.data();

        return {
            id: data.productID || doc.id,
            name: data.name || '',
            category: data.category || '',
            color: data.primaryColor || '',
            material: data.material || '',
            style: Array.isArray(data.styleTags) ? data.styleTags.join(' ') : '',
            description: data.description || '',
            price: data.price || 0,
            imageUrl: data.imageUrl || '',
            brand: data.brand || '',
            rating: data.rating || 0,
            dimensions_cm: {
                l: data.dimensions?.length || 0,
                w: data.dimensions?.width || 0,
                h: data.dimensions?.height || 0,
            },
            rawFirestoreData: data,
        };
    });
}