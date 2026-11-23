import * as admin from 'firebase-admin';
import { products } from '../scripts/data/products.seed';

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.applicationDefault(),
    });
}

const db = admin.firestore();

async function seedProducts() {
    try {
        for (const product of products) {
            const { id, ...data } = product;

            await db.collection('products').doc(id).set(
                {
                    ...data,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                },
                { merge: true }
            );

            console.log(`✅ Seeded: ${id}`);
        }

        console.log('🎉 All products seeded successfully');
        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err);
        process.exit(1);
    }
}

seedProducts();
