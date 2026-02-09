# PocketRoom - 3D Model Generation Pipeline

A NestJS-based backend service that generates 3D models from product images using **Tripo AI** API. The pipeline automatically processes images, generates GLB models, optimizes them with Draco compression, and stores them in Firebase.

## 🚀 Features

- **Image-to-3D Generation**: Convert product images to 3D GLB models using Tripo AI
- **Draco Compression**: Automatic GLB optimization for mobile-ready models
- **Firebase Integration**: Store images and models in Firebase Storage, track status in Firestore
- **Job Queue**: BullMQ-powered async processing with Redis
- **REST API**: Full CRUD for products with 3D generation endpoint

## 📋 Prerequisites

- **Node.js** v18 or higher
- **Redis** server (for job queue)
- **Firebase** project with Firestore and Storage enabled
- **Tripo AI** API key ([Get one here](https://www.tripo3d.ai/))

## 🛠️ Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable **Firestore Database** and **Storage**
4. Go to Project Settings → Service Accounts → Generate New Private Key
5. Save the downloaded file as `service-account.json` in the project root

### 3. Configure Environment Variables

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

```env
PORT=3000
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
TRIPO_API_KEY=your-tripo-api-key
REDIS_HOST=localhost
REDIS_PORT=6379
```

### 4. Start Redis

**Windows (WSL or Docker):**
```bash
# WSL
redis-server

# Docker
docker run -d -p 6379:6379 redis
```

**macOS:**
```bash
brew services start redis
```

**Linux:**
```bash
sudo systemctl start redis
```

### 5. Run the Application

```bash
# Development (with hot reload)
npm run start:dev

# Production
npm run build
npm run start:prod
```

The server will start on `http://localhost:3000`

## 📡 API Endpoints

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/products` | Create a new product |
| `GET` | `/products` | Get all products |
| `GET` | `/products/:id` | Get a product by ID |
| `PATCH` | `/products/:id` | Update a product |
| `DELETE` | `/products/:id` | Delete a product |

### 3D Model Generation

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/products/:id/generate` | Generate 3D model for a product |

#### Generate 3D Model Request

**Endpoint:** `POST /products/:id/generate`

**Content-Type:** `multipart/form-data`

**Body:**
| Field | Type | Description |
|-------|------|-------------|
| `image` | File | Product image (JPG, PNG, GIF - max 10MB) |
| `x` | Number | Width dimension |
| `y` | Number | Height dimension |
| `z` | Number | Depth dimension |

**Example using cURL:**
```bash
curl -X POST http://localhost:3000/products/YOUR_PRODUCT_ID/generate \
  -F "image=@/path/to/your/image.jpg" \
  -F "x=1.0" \
  -F "y=1.5" \
  -F "z=0.8"
```

**Response (202 Accepted):**
```json
{
  "message": "Model generation started",
  "jobId": "123",
  "productId": "abc123",
  "status": "processing"
}
```

## 🔄 Pipeline Flow

```
1. Upload image → Firebase Storage (Images/)
2. Add job to Redis queue
3. Worker downloads image
4. Send to Tripo AI
5. Receive raw GLB
6. Optimize with Draco compression
7. Upload to Firebase Storage (3DModel/)
8. Update Firestore with modelURL & status
```

### Model Status Values

| Status | Description |
|--------|-------------|
| `pending` | Product created, no generation started |
| `processing` | 3D model generation in progress |
| `completed` | Model generated and available at `modelURL` |
| `failed` | Generation failed (see `modelError` field) |

## 📁 Project Structure

```
src/
├── app.module.ts           # Main application module
├── main.ts                 # Application entry point
├── firebase/
│   ├── firebase.module.ts  # Firebase module
│   └── firebase.service.ts # Firebase Admin SDK setup
└── products/
    ├── dto/
    │   ├── create-product.dto.ts    # Product creation validation
    │   ├── update-product.dto.ts    # Product update validation
    │   └── generate-model.dto.ts    # 3D generation validation
    ├── entities/
    │   └── product.entity.ts
    ├── utils/
    │   └── optimization.util.ts     # Draco GLB optimization
    ├── generation.processor.ts      # BullMQ job processor
    ├── products.controller.ts       # REST API endpoints
    ├── products.module.ts           # Products module
    └── products.service.ts          # Business logic
```

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 🔧 Troubleshooting

### Redis Connection Error
Make sure Redis is running:
```bash
redis-cli ping
# Should return: PONG
```

### Firebase Initialization Error
- Verify `service-account.json` exists in project root
- Check that the file contains valid credentials
- Ensure `FIREBASE_STORAGE_BUCKET` matches your Firebase project

### Tripo AI Error
- Verify your API key is valid
- Check you have sufficient credits
- Ensure image is valid (JPG/PNG, not corrupted)

## 📄 License

This project is [MIT licensed](LICENSE).
