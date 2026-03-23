# AI Search Integration - Setup & Testing Guide

## Overview

This Flutter app now includes AI-powered search functionality that connects to a FastAPI backend. The backend uses semantic search (TF-IDF or embeddings) combined with ML ranking to return relevant furniture products.

---

## Backend Setup

### 1. Install Backend Dependencies

```bash
cd d:\Playground\Pocketroom\backend
pip install -r requirements.txt
```

**Required packages:**
- fastapi
- uvicorn[standard]
- pydantic
- numpy
- scikit-learn

### 2. Start the Backend Server

```bash
# From the backend directory
python -m uvicorn main:app --reload
```

The server will start at `http://localhost:8000`

### 3. Verify Backend is Running

Open your browser and navigate to:
- Health check: http://localhost:8000/health
- API docs: http://localhost:8000/docs

You should see:
```json
{
  "status": "ok",
  "items": <number_of_products>,
  "semantic_mode": "tfidf"
}
```

---

## Flutter Configuration

### Backend URL Configuration

The default backend URL is `http://localhost:8000`. You need to update this based on your testing environment:

**File:** `lib/src/core/services/api_client.dart`

```dart
static const String baseUrl = 'http://localhost:8000';
```

**Update based on your platform:**

| Platform | URL |
|----------|-----|
| **iOS Simulator** | `http://localhost:8000` |
| **Android Emulator** | `http://10.0.2.2:8000` |
| **Physical Device** | `http://<YOUR_COMPUTER_IP>:8000` |
| **Web** | `http://localhost:8000` |

**To find your computer's IP address:**
- Windows: `ipconfig` (look for IPv4 Address)
- Mac/Linux: `ifconfig` or `ip addr`

---

## API Reference

### Search Endpoint

**Endpoint:** `POST /search`

**Request:**
```json
{
  "query": "pink sofa for living room",
  "top_k": 10
}
```

**Response:**
```json
{
  "query": "pink sofa for living room",
  "semantic_mode": "tfidf",
  "count": 5,
  "results": [
    {
      "score": 0.8542,
      "matchedTags": ["color match", "category match", "semantic=0.756", "ml=0.892"],
      "product": {
        "id": 1,
        "name": "Comfort Max Sofa",
        "price": 125000,
        "category": "Sofa",
        "color": "Magenta",
        "material": "Fabric",
        "style": "Modern",
        "description": "Spacious 3-seater sofa...",
        "image": "https://example.com/image.jpg",
        "brand": "IKEA",
        "rating": 4.5,
        "dimensions_cm": {
          "l": 200,
          "w": 90,
          "h": 85
        }
      }
    }
  ]
}
```

---

## Testing the Integration

### 1. Start the Backend

```bash
cd d:\Playground\Pocketroom\backend
python -m uvicorn main:app --reload
```

### 2. Run the Flutter App

```bash
cd d:\Playground\Pocketroom\PocketRoom
flutter run
```

### 3. Test AI Search Flow

1. **Tap the AI Search button** (sparkle icon) in the search bar
2. **Enter a query** in the AI prompt panel:
   - "pink sofa"
   - "modern chair"
   - "wooden table"
3. **Press Send** (black button with send icon)
4. **Observe the results:**
   - Loading indicator appears
   - Results display with "AI-powered results" banner
   - Product cards show matched items

### 4. Test State Transitions

**Success State:**
- Query: "pink sofa"
- Expected: Shows matching products with AI banner

**Empty State:**
- Query: "xyzabc123nonsense"
- Expected: Shows "No results found" message

**Error State:**
- Stop the backend server
- Query: "any query"
- Expected: Shows error message with retry button

**Toggle Back to Normal Search:**
- Click the search icon button
- Expected: Returns to normal search bar, clears AI results

---

## Sample Test Queries

Try these queries to test the AI search:

| Query | Expected Results |
|-------|------------------|
| "pink sofa" | Magenta/pink colored sofas |
| "modern chair" | Modern style chairs |
| "wooden table" | Tables with wood material |
| "cheap furniture" | Lower-priced items |
| "luxury sofa" | Higher-priced sofas |
| "minimalist" | Minimalistic style items |

---

## Troubleshooting

### Issue: "Cannot connect to server"

**Cause:** Backend is not running or wrong URL

**Solution:**
1. Verify backend is running: `curl http://localhost:8000/health`
2. Check the `baseUrl` in `api_client.dart` matches your setup
3. For Android emulator, use `http://10.0.2.2:8000`
4. For physical device, use your computer's IP address

### Issue: "Connection timeout"

**Cause:** Network issues or firewall blocking

**Solution:**
1. Check firewall settings
2. Ensure backend and Flutter app are on same network (for physical devices)
3. Try increasing timeout in `api_client.dart` (currently 30s)

### Issue: Empty results for valid queries

**Cause:** Backend data doesn't match query

**Solution:**
1. Check backend logs for the search query
2. Verify products.json has relevant data
3. Try broader queries like "sofa" or "chair"

### Issue: App crashes on search

**Cause:** JSON parsing error or null safety issue

**Solution:**
1. Check backend response format matches expected schema
2. Look at Flutter console for error messages
3. Verify all required fields are present in backend response

---

## Architecture Overview

### File Structure

```
lib/src/
├── core/
│   └── services/
│       ├── api_client.dart          # HTTP client with error handling
│       └── ai_search_service.dart   # AI search API calls
├── features/
│   └── home/
│       ├── data/
│       │   ├── models/
│       │   │   ├── ai_search_request.dart   # Request model
│       │   │   └── ai_search_response.dart  # Response models
│       │   ├── ai_search_state.dart         # State definitions
│       │   └── ai_search_provider.dart      # Riverpod providers
│       └── presentation/
│           └── widgets/
│               └── product_list.dart        # Updated to show AI results
└── common_widgets/
    ├── ai_prompt_panel.dart         # AI search input UI
    └── search_bar_widget.dart       # Search bar with toggle
```

### Data Flow

1. User taps AI Search button → `search_bar_widget.dart` toggles to `ai_prompt_panel.dart`
2. User enters query and presses Send → `ai_prompt_panel.dart` calls `aiSearchStateProvider.notifier.searchAi()`
3. State changes to `AiSearchLoading` → `product_list.dart` shows loading indicator
4. `AiSearchService` calls backend `/search` endpoint via `ApiClient`
5. Response parsed into `AiSearchResponse` → converted to `List<Furniture>`
6. State changes to `AiSearchSuccess` → `product_list.dart` displays results
7. User taps search icon → toggles back, clears AI state, shows normal list

---

## Next Steps

### Optional Enhancements

1. **Add filters to AI search:**
   - Modify `ai_search_request.dart` to include price range, style, etc.
   - Update backend to support filters

2. **Implement voice search:**
   - Use `speech_to_text` package
   - Wire to `_onVoiceTap()` in `ai_prompt_panel.dart`

3. **Add search history:**
   - Store recent queries locally
   - Show suggestions when user opens AI search

4. **Improve error messages:**
   - Parse backend error responses
   - Show specific guidance based on error type

5. **Add analytics:**
   - Track search queries
   - Monitor success/failure rates
   - Analyze popular searches

---

## Production Checklist

Before deploying to production:

- [ ] Update `baseUrl` to production backend URL
- [ ] Add proper authentication if required
- [ ] Implement rate limiting on backend
- [ ] Add proper error tracking (e.g., Sentry)
- [ ] Test on multiple devices and network conditions
- [ ] Add loading timeouts and retry logic
- [ ] Implement caching for frequent queries
- [ ] Add proper logging for debugging
- [ ] Test with large result sets
- [ ] Optimize image loading in product cards
