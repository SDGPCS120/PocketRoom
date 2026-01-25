import axios from 'axios';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load env from project root
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const API_KEY = process.env.TRIPO_API_KEY;
const IMAGE_URL = 'https://storage.googleapis.com/pocketroom-80f62.firebasestorage.app/Images/chair-103.jpg'; // Using the known working image URL from earlier logs

async function testTripo() {
    console.log('🧪 Testing Tripo API Credentials & Credits');
    console.log('----------------------------------------');
    console.log(`API Key length: ${API_KEY?.length || 0}`);

    if (!API_KEY) {
        console.error('❌ Missing TRIPO_API_KEY in .env');
        process.exit(1);
    }

    // Check Balance First
    try {
        console.log('Checking Balance...');
        const balanceRes = await axios.get('https://api.tripo3d.ai/v2/openapi/user/balance', {
            headers: { Authorization: `Bearer ${API_KEY}` }
        });
        console.log('💰 Current Balance:', JSON.stringify(balanceRes.data, null, 2));
    } catch (err) {
        console.error('⚠️ Could not fetch balance:', err.message);
    }

    // Try v1.4 explicitly
    const payload = {
        type: 'image_to_model',
        file: {
            type: 'jpg',
            url: IMAGE_URL
        },
        model_version: 'v1.4-20240625'
    };

    console.log('Sending payload:', JSON.stringify(payload, null, 2));

    try {
        const response = await axios.post(
            'https://api.tripo3d.ai/v2/openapi/task',
            payload,
            { headers: { Authorization: `Bearer ${API_KEY}` } }
        );

        console.log('\n✅ SUCCESS! Task created.');
        console.log('Task ID:', response.data.data.task_id);
        console.log('Credits check: Passed (at least for v1.4)');
    } catch (error: any) {
        console.error('\n❌ FAILED');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', JSON.stringify(error.response.data, null, 2));
        } else {
            console.error('Error:', error.message);
        }
    }
}

testTripo();
