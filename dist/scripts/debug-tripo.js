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
const axios_1 = __importDefault(require("axios"));
const dotenv = __importStar(require("dotenv"));
const path = __importStar(require("path"));
dotenv.config({ path: path.resolve(__dirname, '../.env') });
const API_KEY = process.env.TRIPO_API_KEY;
const IMAGE_URL = 'https://storage.googleapis.com/pocketroom-80f62.firebasestorage.app/Images/chair-103.jpg';
async function testTripo() {
    console.log('🧪 Testing Tripo API Credentials & Credits');
    console.log('----------------------------------------');
    console.log(`API Key length: ${API_KEY?.length || 0}`);
    if (!API_KEY) {
        console.error('❌ Missing TRIPO_API_KEY in .env');
        process.exit(1);
    }
    try {
        console.log('Checking Balance...');
        const balanceRes = await axios_1.default.get('https://api.tripo3d.ai/v2/openapi/user/balance', {
            headers: { Authorization: `Bearer ${API_KEY}` }
        });
        console.log('💰 Current Balance:', JSON.stringify(balanceRes.data, null, 2));
    }
    catch (err) {
        console.error('⚠️ Could not fetch balance:', err.message);
    }
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
        const response = await axios_1.default.post('https://api.tripo3d.ai/v2/openapi/task', payload, { headers: { Authorization: `Bearer ${API_KEY}` } });
        console.log('\n✅ SUCCESS! Task created.');
        console.log('Task ID:', response.data.data.task_id);
        console.log('Credits check: Passed (at least for v1.4)');
    }
    catch (error) {
        console.error('\n❌ FAILED');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', JSON.stringify(error.response.data, null, 2));
        }
        else {
            console.error('Error:', error.message);
        }
    }
}
testTripo();
//# sourceMappingURL=debug-tripo.js.map