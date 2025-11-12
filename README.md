# AI Image Editing Web App

Production-ready AI image editing platform built with Flutter Web and FastAPI, powered by fal.ai's Seedream v4 model.

## ✨ Features

### Core Features
- ✅ **Image Upload** - Drag & drop or file picker
- ✅ **AI-Powered Editing** - Natural language prompts for image editing
- ✅ **Real-time Progress** - Live progress tracking with visual feedback
- ✅ **Job Management** - Complete history of all editing jobs
- ✅ **Download** - Save edited images locally
- ✅ **Responsive Design** - Works on desktop, tablet, and mobile

### Bonus Features Implemented
- ✅ **SQL Database** - SQLite for persistent job storage (survives server restarts)
- ✅ **Version History** - View and revisit all previous edits
- ✅ **Before/After Comparison** - Interactive slider to compare original vs edited
- ✅ **URL Routing** - Deep linking support with job IDs in URL
- ✅ **Processing Overlay** - Blur effect with AI animation during generation
- ✅ **Prompt Display** - See which prompt created each image

## 🏗️ Architecture

```
┌─────────────────────┐         ┌──────────────────┐         ┌─────────────┐
│   Flutter Web       │  HTTP   │   FastAPI        │   API   │  fal.ai     │
│   (Frontend)        │ ◄─────► │   (Backend)      │ ◄─────► │  Seedream   │
│  - UI/UX            │         │  - Job Queue     │         │  v4 Edit    │
│  - State Mgmt       │         │  - SQLite DB     │         └─────────────┘
│  - URL Routing      │         │  - Progress API  │
└─────────────────────┘         └──────────────────┘
       │                                │
       ▼                                ▼
  Firebase Hosting              Render.com
```

### Request Flow
1. User uploads image + prompt → Frontend
2. Frontend → `POST /api/jobs` → Backend creates job (PROCESSING status)
3. Backend → fal.ai API (async background task)
4. Frontend polls `GET /api/jobs/{id}` every 2s for progress updates
5. Backend updates job progress (0% → 100%) in SQLite
6. When complete → Frontend displays result with before/after comparison

## 🛠️ Tech Stack

| Layer | Technologies |
|-------|-------------|
| **Frontend** | Flutter Web 3.9+, Provider (state), go_router (routing), http client |
| **Backend** | Python 3.11, FastAPI 0.104, SQLAlchemy 2.0 (async), SQLite, Uvicorn |
| **AI Service** | fal.ai Seedream v4 Edit Model |
| **Deployment** | Frontend: Firebase Hosting, Backend: Render.com |

## 🚀 Local Setup

### Prerequisites
- Python 3.11+
- Flutter SDK 3.9+
- fal.ai API key (provided in assignment)

### Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file from example
cp .env.example .env
# Then edit .env and add your fal.ai API key
# Note: Only FAL_KEY is required. PORT, HOST, ENVIRONMENT have defaults.

# Run server (creates jobs.db automatically)
python -m app.main
```

Backend runs at `http://localhost:8000`
API docs at `http://localhost:8000/docs`

### Frontend Setup

```bash
# Navigate to frontend
cd frontend

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome
```

Frontend opens in Chrome at `http://localhost:xxxxx`

**Note:** Frontend is configured to use production backend URL. For local development, update `lib/services/job_api_service.dart`:

```dart
JobApiService({this.baseUrl = 'http://localhost:8000'});
```

## 📡 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/jobs` | POST | Create new editing job (returns immediately, processes in background) |
| `/api/jobs/{job_id}` | GET | Get job status and result |
| `/api/jobs` | GET | List all jobs (newest first) |
| `/api/jobs/{job_id}` | DELETE | Delete a job |
| `/health` | GET | Health check |

### Example: Create Job

```bash
curl -X POST http://localhost:8000/api/jobs \
  -F "image=@photo.jpg" \
  -F "prompt=Add sunglasses and make background tropical beach"
```

Response:
```json
{
  "id": "uuid-here",
  "status": "processing",
  "progress": 0,
  "prompt": "Add sunglasses...",
  "original_image_url": "data:image/...",
  "edited_image_url": null
}
```

### Poll for Progress

```bash
curl http://localhost:8000/api/jobs/{job_id}
```

Response (completed):
```json
{
  "id": "uuid-here",
  "status": "completed",
  "progress": 100,
  "edited_image_url": "https://fal.media/files/...",
  "created_at": "2025-11-01T12:00:00",
  "updated_at": "2025-11-01T12:02:00"
}
```

## 🤖 fal.ai Integration

**Model:** `fal-ai/bytedance/seedream/v4/edit`

**Why Seedream v4?**
- High-quality image-to-image editing
- Strong natural language understanding
- Fast processing (typically 30-60 seconds)
- Commercial use allowed
- Safety checker enabled

**How it works:**
1. Image + prompt sent to fal.ai via `fal_client.run_async()`
2. Backend simulates progress (10% increments every 2s) since fal.ai doesn't provide real-time progress
3. Final result returned when API completes
4. Job updated in database with edited image URL

**Example Prompts:**
- "Change background to mountain sunset"
- "Add colorful flowers in the foreground"
- "Make it look like a watercolor painting"
- "Convert to black and white with high contrast"

## 📂 Project Structure

```
voltran_study_case/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI app, CORS, lifespan
│   │   ├── database.py          # SQLAlchemy async config
│   │   ├── models.py            # Pydantic + SQLAlchemy models
│   │   ├── routers/
│   │   │   └── jobs.py          # Job API endpoints
│   │   ├── services/
│   │   │   ├── fal_ai.py        # fal.ai integration
│   │   │   └── job_service.py   # Job business logic
│   │   └── storage/
│   │       └── __init__.py      # Database operations
│   ├── requirements.txt
│   └── jobs.db                  # SQLite database (auto-created)
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart            # App entry, routing
│   │   ├── models/job.dart      # Job model
│   │   ├── providers/
│   │   │   └── job_provider.dart # State management
│   │   ├── services/
│   │   │   └── job_api_service.dart # Backend API client
│   │   ├── screens/
│   │   │   └── editor_screen.dart # Main editor UI
│   │   ├── widgets/
│   │   │   ├── editor_canvas.dart     # Image display
│   │   │   ├── prompt_input_bar.dart  # Prompt input
│   │   │   ├── app_drawer.dart        # Job history
│   │   │   └── recent_edits_bar.dart  # Bottom bar
│   │   └── theme/app_theme.dart
│   └── pubspec.yaml
│
└── README.md
```

## 🎯 Optional Features Implemented

### 1. **SQLite Database** ✅
- Persistent job storage using SQLAlchemy async
- Survives server restarts (unlike in-memory storage)
- Automatic table creation on startup
- All CRUD operations async

### 2. **Version History** ✅
- View all previous editing jobs
- Sidebar with thumbnails and timestamps
- Click to revisit any previous edit
- Delete functionality

### 3. **Before/After Slider** ✅
- Interactive slider to compare original vs edited
- Toggle button appears after edit completes
- Smooth transition animation

### 4. **URL Routing & Deep Linking** ✅
- Each job has unique URL: `/job/{job_id}`
- Share links to specific edits
- Browser back/forward navigation
- Clean URLs (no hash fragments)

### 5. **Enhanced UX**
- Blur overlay with AI animation during processing
- Progress percentage in Generate button
- Prompt display under each image
- "New Edit" button in app bar
- Remove uploaded image button

## ⚠️ Known Issues & Trade-offs

### Limitations
1. **Progress Simulation:** fal.ai doesn't provide real-time progress, so we simulate it (10% increments every 2s). Actual processing time varies.

2. **Image Storage:** Original images stored as base64 data URIs in database. For production at scale, would use cloud storage (S3, Cloudinary) with URLs.

3. **Cold Starts:** Render.com free tier has ~30-60s cold start on first request after inactivity.

4. **Database Persistence:** SQLite file on Render.com's ephemeral filesystem. For true persistence, would use PostgreSQL or external storage.

5. **Error Recovery:** If fal.ai request fails mid-processing, job marked as FAILED but partial progress not resumed.

### Trade-offs Made
- **Simplicity over Scale:** Chose SQLite for quick setup vs PostgreSQL for better production scalability
- **Simulated Progress:** Provides better UX than no feedback, even if not 100% accurate
- **In-database Images:** Faster development, but wouldn't scale to millions of jobs

### Future Improvements
- [ ] External image storage (S3/Cloudinary)
- [ ] PostgreSQL for production database
- [ ] Batch processing multiple images
- [ ] User authentication & private galleries
- [ ] Advanced editing parameters (strength, steps, etc.)
- [ ] Image caching & CDN

## 🤖 AI Tools Usage

This project was developed with assistance from **Claude Code** (Anthropic's AI development assistant). Here's how AI tools were leveraged:

### Development Strategy

**1. Architecture Design**
- Claude helped design the async job processing system
- Discussed trade-offs between polling vs webhooks
- Planned SQLite → PostgreSQL migration path

**2. Code Implementation**
- **Backend:** FastAPI app structure, SQLAlchemy models, async database operations
- **Frontend:** Flutter widget hierarchy, state management with Provider, URL routing with go_router
- **Integration:** fal.ai API calls, error handling, progress tracking

**3. Debugging & Problem-Solving**
- Python 3.13 compatibility issues with SQLAlchemy → upgraded to 2.0.36
- Missing greenlet dependency → identified and added to requirements
- CORS configuration for production deployment
- Deep linking issues → implemented didUpdateWidget for job switching

**4. Documentation**
- Generated comprehensive README
- Code comments and docstrings
- API documentation

### Prompting Approach

**Effective Prompts Used:**
- "Implement async job processing with FastAPI BackgroundTasks"
- "Add SQLite database with SQLAlchemy async for job persistence"
- "Fix: Job image disappears after upload, keep visible during processing"
- "Add URL routing so each job has unique shareable link"

**Iterative Development:**
- Started with basic features, incrementally added complexity
- Tested each feature before moving to next
- Refactored when issues found (e.g., state transition tracking)

**Result:** Claude Code enabled rapid development while maintaining code quality, proper architecture, and comprehensive documentation. The AI assistant was particularly valuable for:
- Boilerplate reduction
- Best practices guidance
- Quick debugging
- Documentation generation

## 📦 Deployment

### Backend (Render.com)

1. **Connect GitHub Repository**
2. **Render auto-detects:** `requirements.txt` and sets up Python environment
3. **Add Environment Variable:** `FAL_KEY=your_api_key`
4. **Build Command:** `pip install -r requirements.txt`
5. **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

Backend automatically creates `jobs.db` on first run.

### Frontend (Firebase Hosting)

**First Time Setup:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# (Optional) If deploying to your own Firebase project:
# Create a new Firebase project and update .firebaserc with your project ID
```

**Deploy:**
```bash
# Navigate to frontend directory
cd frontend

# Build production app
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

**Notes:**
- Update `baseUrl` in `lib/services/job_api_service.dart` to production backend URL before building
- Current `.firebaserc` points to `flutter-ai-image-studio` - update if using your own project

## 📄 License

This project is part of a technical assignment for Voltran.

## 👤 Author

**Yunus Emre Alpak**
Email: yunusemrealpak@gmail.com
GitHub: [yunusemrealpak](https://github.com/yunusemrealpak)

---

Built with ❤️ using Flutter, FastAPI, and fal.ai
