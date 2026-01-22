import * as admin from 'firebase-admin';
import * as path from 'path';
import * as readline from 'readline';
import axios from 'axios';
import FormData from 'form-data';
import * as fs from 'fs';

// Load environment variables
require('dotenv').config();

// Initialize Firebase
const serviceAccount = require(path.resolve('service-account.json'));
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined
});

const db = admin.firestore();
const storage = admin.storage();

// CLI Interface
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

function printHeader() {
    console.log('\n========================================');
    console.log('   PocketRoom 3D Pipeline CLI');
    console.log('========================================\n');
}

function printMenu() {
    console.log('Commands:');
    console.log('  1. List Products');
    console.log('  2. Generate 3D Model (uses credits!)');
    console.log('  3. Check Product Status');
    console.log('  4. Exit\n');
}

async function checkConnection(): Promise<boolean> {
    console.log('Connecting to Firebase...');
    try {
        await db.collection('_test').doc('_ping').set({ timestamp: new Date() });
        await db.collection('_test').doc('_ping').delete();
        console.log('✓ Firebase connected successfully!\n');
        return true;
    } catch (error: any) {
        console.log(`✗ Firebase connection failed: ${error.message}\n`);
        return false;
    }
}

async function listProducts() {
    console.log('\nFetching products from Firestore...\n');
    try {
        const snapshot = await db.collection('products').get();
        if (snapshot.empty) {
            console.log('No products found in database.\n');
            return;
        }

        // Table header
        const divider = '-'.repeat(120);
        console.log(divider);
        console.log(
            padRight('#', 4) +
            padRight('ID', 24) +
            padRight('Name', 28) +
            padRight('Status', 12) +
            padRight('Has Image', 10) +
            'Model URL'
        );
        console.log(divider);

        // Table rows
        snapshot.docs.forEach((doc, index) => {
            const data = doc.data();
            const hasImage = data.imageUrl ? 'Yes' : 'No';
            const modelUrl = data.modelURL ? truncate(data.modelURL, 40) : '-';

            console.log(
                padRight(String(index + 1), 4) +
                padRight(doc.id, 24) +
                padRight(truncate(data.name || 'N/A', 26), 28) +
                padRight(data.modelStatus || 'N/A', 12) +
                padRight(hasImage, 10) +
                modelUrl
            );
        });

        console.log(divider);
        console.log(`Total: ${snapshot.size} products\n`);
    } catch (error: any) {
        console.error('Error fetching products:', error.message);
    }
}

function padRight(str: string, length: number): string {
    return str.substring(0, length).padEnd(length);
}

function truncate(str: string, maxLength: number): string {
    if (str.length <= maxLength) return str;
    return str.substring(0, maxLength - 3) + '...';
}

async function checkProductStatus() {
    const productId = await askQuestion('Enter Product ID: ');
    try {
        const doc = await db.collection('products').doc(productId).get();
        if (!doc.exists) {
            console.log('\nProduct not found.\n');
            return;
        }
        const data = doc.data();
        console.log('\n' + '-'.repeat(50));
        console.log('Product Details');
        console.log('-'.repeat(50));
        console.log(`  ID:           ${doc.id}`);
        console.log(`  Name:         ${data?.name || 'N/A'}`);
        console.log(`  Model Status: ${data?.modelStatus || 'N/A'}`);
        console.log(`  Image URL:    ${data?.imageUrl || 'No image'}`);
        console.log(`  Model URL:    ${data?.modelURL || 'Not generated'}`);
        if (data?.modelError) {
            console.log(`  Error:        ${data.modelError}`);
        }
        console.log('-'.repeat(50) + '\n');
    } catch (error: any) {
        console.error('Error:', error.message);
    }
}

async function generateModel() {
    console.log('\n⚠️  WARNING: This will use Stability AI credits!\n');

    // List products first
    await listProducts();

    const productId = await askQuestion('Enter Product ID: ');

    // Get product and check for existing image
    const doc = await db.collection('products').doc(productId).get();
    if (!doc.exists) {
        console.log('\nProduct not found.\n');
        return;
    }

    const productData = doc.data();
    let imageUrl = productData?.imageUrl;
    let imagePath: string | null = null;

    if (imageUrl) {
        console.log(`\nExisting image found: ${imageUrl}`);
        const useExisting = await askQuestion('Use existing image? (yes/no): ');
        if (useExisting.toLowerCase() !== 'yes') {
            imagePath = await askQuestion('Enter new image file path: ');
        }
    } else {
        imagePath = await askQuestion('Enter image file path: ');
    }

    // If using local file, validate and upload
    if (imagePath) {
        if (!fs.existsSync(imagePath)) {
            console.log('\nError: Image file not found.\n');
            return;
        }

        const confirm = await askQuestion('Proceed with generation? (yes/no): ');
        if (confirm.toLowerCase() !== 'yes') {
            console.log('Cancelled.\n');
            return;
        }

        console.log('\nUploading image...');
        const imageBuffer = fs.readFileSync(imagePath);

        const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
        const imageFileName = `Images/${productId}_${Date.now()}.jpg`;
        const imageFile = bucket.file(imageFileName);

        await imageFile.save(imageBuffer, {
            metadata: { contentType: 'image/jpeg' },
        });
        await imageFile.makePublic();
        imageUrl = `https://storage.googleapis.com/${bucket.name}/${imageFileName}`;
        console.log(`Uploaded to: ${imageUrl}`);
    } else {
        const confirm = await askQuestion('Proceed with generation? (yes/no): ');
        if (confirm.toLowerCase() !== 'yes') {
            console.log('Cancelled.\n');
            return;
        }
    }

    console.log('\nStarting 3D model generation...\n');

    try {
        // Update status
        await db.collection('products').doc(productId).update({
            modelStatus: 'processing',
            imageUrl: imageUrl,
            updatedAt: new Date(),
        });

        // Download image for API
        console.log('Downloading image for API...');
        const imageResponse = await axios.get(imageUrl, { responseType: 'arraybuffer' });
        const imageBuffer = Buffer.from(imageResponse.data);
        console.log(`Image size: ${imageBuffer.length} bytes`);

        // Call Stability AI
        console.log('Calling Stability AI API...');
        const formData = new FormData();
        formData.append('image', imageBuffer, { filename: 'input.jpg' });

        const response = await axios.post(
            'https://api.stability.ai/v2beta/3d/stable-fast-3d',
            formData,
            {
                headers: {
                    ...formData.getHeaders(),
                    Authorization: `Bearer ${process.env.STABILITY_API_KEY}`,
                },
                responseType: 'arraybuffer',
            },
        );

        console.log('Received GLB from Stability AI!');
        const glbBuffer = Buffer.from(response.data);
        console.log(`GLB size: ${glbBuffer.length} bytes`);

        // Upload GLB
        const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
        const glbFileName = `3DModel/${productId}_${Date.now()}.glb`;
        const glbFile = bucket.file(glbFileName);

        await glbFile.save(glbBuffer, {
            metadata: { contentType: 'model/gltf-binary' },
        });
        await glbFile.makePublic();
        const modelUrl = `https://storage.googleapis.com/${bucket.name}/${glbFileName}`;

        // Update Firestore
        await db.collection('products').doc(productId).update({
            modelStatus: 'completed',
            modelURL: modelUrl,
            updatedAt: new Date(),
        });

        console.log('\n✓ Success!');
        console.log(`Model URL: ${modelUrl}\n`);

    } catch (error: any) {
        console.error('\nError:', error.message);
        if (error.response) {
            console.error('API Response:', error.response.data.toString());
        }
        await db.collection('products').doc(productId).update({
            modelStatus: 'failed',
            modelError: error.message,
        });
    }
}

function askQuestion(question: string): Promise<string> {
    return new Promise((resolve) => {
        rl.question(question, (answer) => {
            resolve(answer.trim());
        });
    });
}

async function main() {
    printHeader();

    // Check connection at startup
    const connected = await checkConnection();
    if (!connected) {
        console.log('Cannot proceed without Firebase connection. Exiting.');
        rl.close();
        process.exit(1);
    }

    while (true) {
        printMenu();
        const choice = await askQuestion('Enter choice (1-4): ');

        switch (choice) {
            case '1':
                await listProducts();
                break;
            case '2':
                await generateModel();
                break;
            case '3':
                await checkProductStatus();
                break;
            case '4':
                console.log('\nGoodbye!\n');
                rl.close();
                process.exit(0);
            default:
                console.log('\nInvalid choice. Try again.\n');
        }
    }
}

main().catch(console.error);
