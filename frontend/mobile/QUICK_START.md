# 🚀 Quick Start Guide - AI Search Integration

## ⚡ Start Backend (Required First!)

```bash
cd d:\Playground\Pocketroom\backend
python -m uvicorn main:app --reload
```

✅ Verify: http://localhost:8000/health

---

## 📱 Configure Flutter App

**IMPORTANT:** Update backend URL based on your platform:

**File:** `lib/src/core/services/api_client.dart` (line 10)

```dart
// Choose ONE based on your testing platform:

// iOS Simulator (default)
static const String baseUrl = 'http://localhost:8000';

// Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000';

// Physical Device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.100:8000';
```

**Find your IP:**
- Windows: `ipconfig` → IPv4 Address
- Mac/Linux: `ifconfig` → inet

---

## 🏃 Run Flutter App

```bash
cd d:\Playground\Pocketroom\PocketRoom
flutter run
```

---

## 🧪 Test AI Search

### 1️⃣ Basic Flow
1. Tap **AI Search** button (✨ sparkle icon)
2. Type: `pink sofa`
3. Press **Send** (black button)
4. ✅ See results with AI banner

### 2️⃣ Empty Results
- Query: `xyzabc123nonsense`
- ✅ Should show "No results found"

### 3️⃣ Error Handling
1. **Stop backend** (Ctrl+C in terminal)
2. Try any query
3. ✅ Should show error with retry button
4. **Restart backend**
5. Click **Retry**
6. ✅ Should work now

### 4️⃣ Toggle Back
- Click **Search** icon button
- ✅ Returns to normal search

---

## 🔍 Sample Queries

| Query | Expected |
|-------|----------|
| `pink sofa` | Pink/magenta sofas |
| `modern chair` | Modern style chairs |
| `wooden table` | Wood material tables |
| `cheap furniture` | Lower-priced items |
| `luxury sofa` | Higher-priced sofas |

---

## ❌ Troubleshooting

### "Cannot connect to server"
- ✅ Backend running? Check terminal
- ✅ Correct URL? Check `api_client.dart`
- ✅ Android emulator? Use `10.0.2.2:8000`
- ✅ Physical device? Use your computer's IP

### "Connection timeout"
- ✅ Same network? (for physical devices)
- ✅ Firewall blocking? Check settings

### App crashes
- ✅ Check Flutter console for errors
- ✅ Verify backend is returning valid JSON

---

## 📚 Full Documentation

- **Setup Guide:** [AI_SEARCH_SETUP.md](file:///d:/Playground/Pocketroom/PocketRoom/AI_SEARCH_SETUP.md)
- **Walkthrough:** [walkthrough.md](file:///C:/Users/DELL/.gemini/antigravity/brain/89e9f7d5-81e6-42f9-9c35-d09b7d84a602/walkthrough.md)

---

## ✅ Checklist

- [ ] Backend running at http://localhost:8000
- [ ] Updated `baseUrl` in `api_client.dart`
- [ ] Flutter app running
- [ ] Tested success flow
- [ ] Tested error handling
- [ ] Tested toggle back to normal search

---

**Ready to test!** 🎉
