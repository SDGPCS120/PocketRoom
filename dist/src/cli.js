"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = __importStar(require("firebase-admin"));
const axios_1 = __importDefault(require("axios"));
const fs = __importStar(require("fs"));
const dotenv = __importStar(require("dotenv"));
dotenv.config();
const service_account_json_1 = __importDefault(require("../service-account.json"));
admin.initializeApp({
    credential: admin.credential.cert(service_account_json_1.default),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined,
});
const db = admin.firestore();
const storage = admin.storage();
const readline = __importStar(require("readline"));
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
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
async function checkConnection() {
    console.log('Connecting to Firebase...');
    try {
        await db.collection('_test').doc('_ping').set({ timestamp: new Date() });
        await db.collection('_test').doc('_ping').delete();
        console.log('✓ Firebase connected successfully!\n');
        return true;
    }
    catch (err) {
        const error = err;
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
        const divider = '-'.repeat(120);
        console.log(divider);
        console.log(padRight('#', 4) +
            padRight('ID', 24) +
            padRight('Name', 28) +
            padRight('Status', 12) +
            padRight('Has Image', 10) +
            'Model URL');
        console.log(divider);
        snapshot.docs.forEach((doc, index) => {
            const data = doc.data();
            const hasImage = data.imageUrl ? 'Yes' : 'No';
            const modelUrl = data.modelURL
                ? truncate(data.modelURL, 40)
                : '-';
            console.log(padRight(String(index + 1), 4) +
                padRight(doc.id, 24) +
                padRight(truncate(data.name || 'N/A', 26), 28) +
                padRight(data.modelStatus || 'N/A', 12) +
                padRight(hasImage, 10) +
                modelUrl);
        });
        console.log(divider);
        console.log(`Total: ${snapshot.size} products\n`);
    }
    catch (error) {
        console.error('Error fetching products:', error.message);
    }
}
function padRight(str, length) {
    return str.substring(0, length).padEnd(length);
}
function truncate(str, maxLength) {
    if (str.length <= maxLength)
        return str;
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
    }
    catch (error) {
        console.error('Error:', error.message || error);
    }
}
async function generateModel() {
    console.log('\n⚠️  WARNING: This will use Tripo AI credits!\n');
    await listProducts();
    const productId = await askQuestion('Enter Product ID: ');
    const doc = await db.collection('products').doc(productId).get();
    if (!doc.exists) {
        console.log('\nProduct not found.\n');
        return;
    }
    const productData = doc.data();
    let imageUrl = productData?.imageUrl;
    let imagePath = null;
    if (imageUrl) {
        console.log(`\nExisting image found: ${imageUrl}`);
        const useExisting = await askQuestion('Use existing image? (yes/no): ');
        if (useExisting.toLowerCase() !== 'yes') {
            imagePath = await askQuestion('Enter new image file path: ');
        }
    }
    else {
        imagePath = await askQuestion('Enter image file path: ');
    }
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
        const [signedUrl] = await imageFile.getSignedUrl({
            action: 'read',
            expires: Date.now() + 60 * 60 * 1000,
        });
        imageUrl = signedUrl;
        console.log(`Uploaded and generated signed URL: ${imageUrl}`);
    }
    else {
        const confirm = await askQuestion('Proceed with generation? (yes/no): ');
        if (confirm.toLowerCase() !== 'yes') {
            console.log('Cancelled.\n');
            return;
        }
    }
    console.log('\nStarting 3D model generation with Tripo AI...\n');
    const apiKey = process.env.TRIPO_API_KEY;
    if (!apiKey) {
        console.error('Error: TRIPO_API_KEY not set');
        return;
    }
    try {
        await db.collection('products').doc(productId).update({
            modelStatus: 'processing',
            imageUrl: imageUrl,
            updatedAt: new Date(),
        });
        console.log('Step 1: Initiating Tripo task...');
        const extension = imageUrl.split(/[#?]/)[0].split('.').pop()?.toLowerCase() || 'jpg';
        const fileType = ['png', 'jpg', 'jpeg', 'bmp'].includes(extension)
            ? extension === 'jpeg'
                ? 'jpg'
                : extension
            : 'jpg';
        const payload = {
            type: 'image_to_model',
            file: { type: fileType, url: imageUrl },
            model_version: 'v1.4-20240625',
        };
        const startResponse = await axios_1.default.post('https://api.tripo3d.ai/v2/openapi/task', payload, { headers: { Authorization: `Bearer ${apiKey}` } });
        const taskId = startResponse.data.data.task_id;
        console.log(`Task Started. ID: ${taskId}`);
        console.log('Step 2: Polling for completion...');
        let modelUrl = '';
        let attempts = 0;
        while (attempts < 36) {
            await new Promise((resolve) => setTimeout(resolve, 5000));
            const statusResponse = await axios_1.default.get(`https://api.tripo3d.ai/v2/openapi/task/${taskId}`, { headers: { Authorization: `Bearer ${apiKey}` } });
            const status = statusResponse.data.data.status;
            if (status === 'success') {
                modelUrl = statusResponse.data.data.output.model;
                console.log('\n✓ Generation Successful!');
                break;
            }
            else if (status === 'failed') {
                throw new Error('Tripo Generation Failed');
            }
            else {
                process.stdout.write('.');
                attempts++;
            }
        }
        if (!modelUrl)
            throw new Error('Timeout');
        console.log('\nStep 3: Downloading model...');
        const modelResponse = await axios_1.default.get(modelUrl, {
            responseType: 'arraybuffer',
        });
        const glbBuffer = Buffer.from(modelResponse.data);
        console.log('Step 4: Uploading to Firebase...');
        const bucket = storage.bucket(process.env.FIREBASE_STORAGE_BUCKET);
        const filename = `3DModel/${productId}_${Date.now()}.glb`;
        const file = bucket.file(filename);
        await file.save(glbBuffer, {
            metadata: { contentType: 'model/gltf-binary' },
            public: true,
        });
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;
        await db.collection('products').doc(productId).update({
            modelStatus: 'completed',
            modelURL: publicUrl,
            updatedAt: new Date(),
        });
        console.log('\n✓ Success!');
        console.log(`Model URL: ${publicUrl}\n`);
    }
    catch (err) {
        const error = err;
        console.error('\nError:', error.message || error);
        await db.collection('products').doc(productId).update({
            modelStatus: 'failed',
            modelError: error.message || error,
            updatedAt: new Date(),
        });
    }
}
function askQuestion(question) {
    return new Promise((resolve) => {
        rl.question(question, (answer) => {
            resolve(answer.trim());
        });
    });
}
async function main() {
    printHeader();
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
//# sourceMappingURL=cli.js.map