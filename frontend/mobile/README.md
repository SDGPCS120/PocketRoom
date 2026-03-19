# PocketRoom - Flutter Frontend

Modern, responsive Flutter web application for the Pocketroom furniture e-commerce platform with AI-powered search.

## 🎯 Overview

A beautiful Flutter web application featuring:
- AI-powered natural language search
- Responsive product catalog
- Real-time search results
- Clean, modern UI design
- Shopping cart functionality
- Product detail views

## 📁 Project Structure

```
PocketRoom/
├── lib/
│   ├── src/
│   │   ├── core/
│   │   │   ├── services/
│   │   │   │   ├── api_client.dart        # HTTP client
│   │   │   │   └── ai_search_service.dart # AI search service
│   │   │   └── constants/
│   │   │
│   │   ├── features/
│   │   │   └── home/
│   │   │       ├── data/
│   │   │       │   ├── models/            # Data models
│   │   │       │   ├── ai_search_provider.dart
│   │   │       │   └── ai_search_state.dart
│   │   │       └── presentation/
│   │   │           ├── pages/             # Screen pages
│   │   │           └── widgets/           # UI widgets
│   │   │
│   │   └── common_widgets/
│   │       ├── search_bar_widget.dart
│   │       └── ai_prompt_panel.dart
│   │
│   └── main.dart                          # App entry point
│
├── pubspec.yaml                           # Dependencies
├── web/                                   # Web assets
└── README.md                              # This file
```

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK 3.0+**
- **Dart SDK 2.17+**
- **Chrome** (for web development)

### Installation

1. **Install dependencies:**
```bash
flutter pub get
```

2. **Run the app:**
```bash
flutter run -d chrome
```

The app will open in Chrome at `http://localhost:PORT`

### Hot Reload
- Press `r` for hot reload (preserves state)
- Press `R` for hot restart (resets state)
- Press `q` to quit

## 🔧 Configuration

### API Configuration

Update the API base URL in `lib/src/core/services/api_client.dart`:

```dart
class ApiClient {
  static const String baseUrl = 'http://localhost:8000';
  // For production: 'https://your-api-domain.com'
}
```

### Environment Setup

Create `.env` file (optional):
```
API_BASE_URL=http://localhost:8000
```

## 🎨 Features

### 1. AI Search
- Natural language query input
- Real-time search results
- Smart filtering by color, material, style, price
- Empty state handling

**Example Queries:**
- "pink chair"
- "green chair under 30000"
- "wooden dining table"
- "modern grey sofa"

### 2. Product Catalog
- Grid/List view toggle
- Product cards with images
- Price display in LKR
- Category badges
- Color indicators

### 3. Product Details
- Full product information
- Dimensions display
- Material and style tags
- Add to cart functionality
- Related products

### 4. Shopping Cart
- Add/remove items
- Quantity adjustment
- Price calculation
- Checkout flow

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.3.0
  
  # HTTP Client
  dio: ^5.0.0
  
  # UI Components
  google_fonts: ^5.0.0
  
  # Utilities
  intl: ^0.18.0
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## 🏗️ Architecture

### State Management
Using **Riverpod** for reactive state management:

```dart
// Provider example
final aiSearchProvider = StateNotifierProvider<AiSearchNotifier, AiSearchState>(
  (ref) => AiSearchNotifier(ref.read(aiSearchServiceProvider)),
);
```

### Service Layer
```dart
// AI Search Service
class AiSearchService {
  Future<AiSearchResponse> search(String query, {int topK = 10}) async {
    final response = await _apiClient.post('/search', {
      'query': query,
      'top_k': topK,
    });
    return AiSearchResponse.fromJson(response.data);
  }
}
```

### Data Models
```dart
class Product {
  final String id;
  final String name;
  final String category;
  final String color;
  final int price;
  final String imageUrl;
  // ...
}
```

## 🎨 UI Components

### Search Bar
```dart
SearchBarWidget(
  onSearch: (query) {
    ref.read(aiSearchProvider.notifier).search(query);
  },
)
```

### Product Card
```dart
ProductCard(
  product: product,
  onTap: () => Navigator.push(...),
)
```

### Product Grid
```dart
ProductGrid(
  products: products,
  crossAxisCount: 3,
)
```

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Tests
```dart
testWidgets('Search bar displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.byType(SearchBarWidget), findsOneWidget);
});
```

## 🚀 Build & Deploy

### Build for Web
```bash
# Development build
flutter build web

# Production build with optimization
flutter build web --release --web-renderer html
```

Output will be in `build/web/`

### Deploy to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Deploy
firebase deploy
```

### Deploy to Netlify
```bash
# Build
flutter build web --release

# Deploy (drag & drop build/web folder to Netlify)
# Or use Netlify CLI:
netlify deploy --prod --dir=build/web
```

### Deploy to Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

## 🎨 Theming

### Custom Theme
```dart
ThemeData(
  primarySwatch: Colors.blue,
  fontFamily: GoogleFonts.inter().fontFamily,
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
  ),
)
```

### Dark Mode Support
```dart
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system,
)
```

## 📱 Responsive Design

### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
```

### Responsive Layout
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < Breakpoints.mobile) {
      return MobileLayout();
    } else if (constraints.maxWidth < Breakpoints.tablet) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

## 🐛 Debugging

### Enable Debug Mode
```bash
flutter run -d chrome --debug
```

### Flutter DevTools
```bash
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Common Issues

**Issue: Images not loading**
- Check CORS settings in backend
- Verify image URLs are accessible
- Clear browser cache (`Ctrl+Shift+R`)

**Issue: API connection failed**
- Ensure backend is running on `http://localhost:8000`
- Check network tab in browser DevTools
- Verify API base URL in `api_client.dart`

**Issue: Hot reload not working**
- Press `R` for full restart
- Check for syntax errors
- Restart Flutter app

## 📊 Performance

### Optimization Tips
- Use `const` constructors where possible
- Implement lazy loading for images
- Use `ListView.builder` for long lists
- Cache network responses
- Minimize widget rebuilds

### Performance Monitoring
```dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    debugPrintBeginFrameBanner = true;
    debugPrintEndFrameBanner = true;
  }
  runApp(MyApp());
}
```

## 🔒 Security

- Validate all user inputs
- Sanitize search queries
- Use HTTPS in production
- Implement rate limiting
- Add authentication (if needed)

## 📝 Code Style

Following Flutter/Dart style guide:
- Use `lowerCamelCase` for variables
- Use `UpperCamelCase` for classes
- Use `snake_case` for file names
- Add documentation comments

```dart
/// Searches for products using AI-powered natural language processing.
///
/// Returns a list of [Product] objects matching the [query].
Future<List<Product>> searchProducts(String query) async {
  // Implementation
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Format code: `flutter format .`
6. Analyze code: `flutter analyze`
7. Submit a pull request

## 📄 License

MIT License

---

**Built with 💙 using Flutter**
