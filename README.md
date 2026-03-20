# Pocketroom - AI-Powered Furniture E-Commerce Platform

A modern furniture e-commerce application with intelligent AI search capabilities, built with Flutter for the frontend and FastAPI for the backend.

![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Mobile-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Python](https://img.shields.io/badge/Python-3.8+-3776AB?logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?logo=fastapi)

## 🌟 Features

### AI-Powered Search
- **Natural Language Processing**: Search using conversational queries like "I want a pink chair under 50000"
- **Smart Entity Extraction**: Automatically detects product type, color, material, style, and price constraints
- **Color Family Matching**: Understands color variations (pink → magenta, fuchsia, rose, blush)
- **Strict Filtering**: Returns only products matching all specified constraints
- **Relevance Ranking**: Intelligent scoring based on semantic similarity and ML predictions

### Product Catalog
- 34 curated furniture products across multiple categories
- Categories: Chairs, Tables, Sofas, Beds, Desks, Storage, Decor
- Detailed product information including dimensions, materials, styles, and prices
- High-quality product images

### User Experience
- Clean, modern UI with responsive design
- Real-time search results
- Product filtering and sorting
- Detailed product views
- Shopping cart functionality

## 📁 Project Structure

```
Pocketroom/
├── backend/              # FastAPI backend server
│   ├── data/            # Product database (JSON)
│   ├── main.py          # Main API application
│   ├── query_parser.py  # NLP query parsing
│   ├── color_matcher.py # Color similarity matching
│   └── relevance_scorer.py # Relevance scoring algorithm
│
├── PocketRoom/          # Flutter frontend application
│   ├── lib/
│   │   ├── src/
│   │   │   ├── core/    # Core services (API, search)
│   │   │   ├── features/# Feature modules (home, search)
│   │   │   └── common_widgets/ # Reusable widgets
│   │   └── main.dart
│   └── pubspec.yaml
│
└── README.md            # This file
```

## 🚀 Quick Start

### Prerequisites
- **Python 3.8+** for backend
- **Flutter 3.0+** for frontend
- **Chrome** (for web development)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd Pocketroom
```

### 2. Start the Backend
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # On Windows
# source venv/bin/activate  # On macOS/Linux
pip install -r requirements.txt
uvicorn main:app --reload
```

Backend will run on `http://localhost:8000`

### 3. Start the Frontend
```bash
cd PocketRoom
flutter pub get
flutter run -d chrome
```

Frontend will open in Chrome browser.

## 🔍 AI Search Examples

The AI search understands natural language queries:

| Query | What It Does |
|-------|-------------|
| `pink chair` | Finds all chairs in pink color family (pink, magenta, fuchsia) |
| `green chair under 30000` | Finds green chairs priced below LKR 30,000 |
| `wooden dining table` | Finds dining tables made of wood |
| `modern grey sofa` | Finds modern-style grey sofas |
| `velvet chair` | Finds chairs with velvet material |

### How It Works
1. **Query Parsing**: Extracts entities (type, color, material, price)
2. **Color Expansion**: Matches similar shades (pink → magenta, fuchsia, rose)
3. **Hard Filtering**: Applies strict constraints (category + color + price)
4. **Semantic Ranking**: Scores results by relevance
5. **ML Prediction**: Uses trained model for final ranking

## 🛠️ Technology Stack

### Backend
- **FastAPI**: Modern Python web framework
- **scikit-learn**: Machine learning for ranking
- **TF-IDF**: Semantic similarity (fallback)
- **Pydantic**: Data validation

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **Dio**: HTTP client

## 📊 API Documentation

### Search Endpoint
```http
POST /search
Content-Type: application/json

{
  "query": "pink chair under 50000",
  "top_k": 10,
  "debug": false
}
```

**Response:**
```json
{
  "query": "pink chair under 50000",
  "semantic_mode": "tfidf",
  "count": 3,
  "results": [
    {
      "score": 94.0033,
      "matchedTags": ["category_match", "color_exact", "price_match"],
      "product": {
        "id": "P001",
        "name": "Velvet Accent Chair",
        "color": "Pink",
        "price": 58900,
        ...
      }
    }
  ]
}
```

### Health Check
```http
GET /health
```

## 🎨 Color Families

The AI search understands these color families:

- **Pink**: pink, magenta, fuchsia, rose, blush, salmon, coral
- **Purple**: purple, violet, lavender, plum
- **Grey**: grey, gray, silver, charcoal
- **Brown**: brown, walnut, oak, teak, tan
- **Green**: green, olive, emerald, sage
- **Blue**: blue, navy, cyan, sky

## 📝 Development

### Backend Development
```bash
cd backend
# Install dependencies
pip install -r requirements.txt

# Run with auto-reload
uvicorn main:app --reload

# Run tests
python -m pytest
```

### Frontend Development
```bash
cd PocketRoom
# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Hot reload: press 'r'
# Hot restart: press 'R'
```

## 🔧 Configuration

### Backend Configuration
- **Port**: 8000 (default)
- **CORS**: Enabled for all origins (development only)
- **Data**: `backend/data/products.json`

### Frontend Configuration
- **API Base URL**: `http://localhost:8000`
- **Platform**: Web (Chrome)

## 📦 Deployment

### Backend Deployment
```bash
# Production server
uvicorn main:app --host 0.0.0.0 --port 8000

# Or use Gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker
```

### Frontend Deployment
```bash
# Build for web
flutter build web

# Deploy to hosting (Firebase, Netlify, Vercel, etc.)
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- FastAPI for the excellent web framework
- Flutter team for the amazing UI toolkit
- Unsplash for placeholder images

---

**Happy Shopping! 🛋️🪑🛏️**
