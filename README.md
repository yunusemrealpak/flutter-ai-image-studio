# AI Image Editing Web Application

Full-stack web application for AI-powered image editing using fal.ai's Seedream v4 model.

## 📋 Overview

This project is a production-ready AI image editing platform that allows users to upload images, provide text prompts describing desired edits, and receive AI-generated edited images. The application features a responsive Flutter Web frontend and a FastAPI Python backend.

## ✨ Features

### Core Features (Required)
- ✅ **Image Upload:** Drag & drop or file picker interface
- ✅ **Prompt Input:** Text field for editing instructions (max 1000 characters)
- ✅ **AI Processing:** Integration with fal.ai Seedream v4 Edit model
- ✅ **Result Display:** Preview of edited images
- ✅ **Download:** Save edited images locally
- ✅ **Job Tracking:** Status monitoring (pending, processing, completed, failed)
- ✅ **Job History:** List all previous editing jobs

### Additional Features
- ✅ **Responsive Design:** Works on desktop, tablet, and mobile
- ✅ **Error Handling:** User-friendly error messages
- ✅ **Loading States:** Visual feedback during processing
- ✅ **CORS Enabled:** Frontend-backend communication configured
- ✅ **Clean Architecture:** Modular, maintainable code structure

## 🏗️ Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────┐
│  Flutter Web    │  HTTP   │   FastAPI        │   API   │  fal.ai     │
│   Frontend      │ ◄─────► │   Backend        │ ◄─────► │  Seedream   │
│                 │         │                  │         │  v4 Edit    │
└─────────────────┘         └──────────────────┘         └─────────────┘
       │                            │
       │                            │
       ▼                            ▼
  Firebase/Vercel            Render.com
   (Hosting)                (Deployment)
```

### Tech Stack

**Frontend:**
- Flutter Web 3.9+
- Provider (State Management)
- HTTP Client
- File Picker

**Backend:**
- Python 3.11
- FastAPI 0.104
- fal-client (AI API)
- Uvicorn (ASGI Server)

**AI Service:**
- fal.ai Seedream v4 Edit Model

**Deployment:**
- Frontend: Firebase Hosting / Vercel
- Backend: Render.com

## 📁 Project Structure

```
voltran_study_case/
├── backend/                    # FastAPI backend
│   ├── app/
│   │   ├── main.py            # FastAPI app & CORS
│   │   ├── config.py          # Environment configuration
│   │   ├── models.py          # Data models
│   │   ├── routers/
│   │   │   └── jobs.py        # API endpoints
│   │   └── services/
│   │       └── fal_ai.py      # fal.ai integration
│   ├── requirements.txt
│   ├── .env                   # Environment variables
│   ├── Procfile              # Render deployment
│   ├── render.yaml           # Render configuration
│   └── README.md
│
├── frontend/                  # Flutter Web frontend
│   ├── lib/
│   │   ├── main.dart         # App entry point
│   │   ├── models/
│   │   │   └── job.dart      # Job model
│   │   ├── services/
│   │   │   └── api_service.dart  # Backend API client
│   │   ├── providers/
│   │   │   └── image_editor_provider.dart  # State management
│   │   ├── screens/
│   │   │   └── home_screen.dart  # Main screen
│   │   └── widgets/
│   │       ├── image_upload_area.dart
│   │       ├── prompt_input.dart
│   │       └── result_display.dart
│   ├── web/
│   ├── pubspec.yaml
│   ├── firebase.json         # Firebase config
│   ├── vercel.json          # Vercel config
│   └── README.md
│
└── README.md                 # This file
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Flutter SDK 3.9+
- Node.js (for deployment tools)
- Git

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Create .env file (copy from .env.example)
cp .env.example .env

# Edit .env and add your fal.ai API key
# FAL_AI_API_KEY=your_key_here

# Run the server
python -m app.main
```

Backend will run at `http://localhost:8000`

API Documentation: `http://localhost:8000/docs`

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Update backend URL in lib/services/api_service.dart
# Set baseUrl to your backend URL

# Run the app
flutter run -d chrome
```

Frontend will open in Chrome.

## 📡 API Endpoints

### POST /api/jobs
Create a new image editing job.

**Request:**
- `image` (multipart/form-data): Image file
- `prompt` (form field): Text prompt for editing

**Response:**
```json
{
  "id": "uuid",
  "prompt": "text prompt",
  "status": "completed",
  "result_image_url": "https://...",
  "created_at": "2025-10-31T...",
  "updated_at": "2025-10-31T..."
}
```

### GET /api/jobs/{job_id}
Get job status and result.

**Response:**
```json
{
  "id": "uuid",
  "prompt": "text prompt",
  "status": "completed",
  "result_image_url": "https://...",
  "created_at": "2025-10-31T...",
  "updated_at": "2025-10-31T..."
}
```

### GET /api/jobs
List all jobs (newest first).

**Response:**
```json
[
  {
    "id": "uuid",
    "prompt": "text prompt",
    "status": "completed",
    "result_image_url": "https://...",
    "created_at": "2025-10-31T...",
    "updated_at": "2025-10-31T..."
  }
]
```

## 🌐 Deployment

### Backend Deployment (Render.com)

1. Push code to GitHub
2. Create new Web Service on Render.com
3. Connect your repository
4. Render will detect `render.yaml` automatically
5. Add environment variable: `FAL_AI_API_KEY`
6. Deploy!

Your backend will be live at: `https://your-app.onrender.com`

### Frontend Deployment (Firebase Hosting)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (first time only)
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy
```

Your frontend will be live at: `https://your-project.web.app`

**Important:** Update `baseUrl` in `frontend/lib/services/api_service.dart` to your deployed backend URL.

## 🧪 Testing

### Backend Testing
```bash
# Using curl
curl -X POST http://localhost:8000/api/jobs \
  -F "image=@test_image.png" \
  -F "prompt=Change background to beach"

# Get job
curl http://localhost:8000/api/jobs/{job_id}

# List all jobs
curl http://localhost:8000/api/jobs
```

### Frontend Testing
1. Start both backend and frontend locally
2. Upload a test image
3. Enter a prompt (e.g., "Add sunglasses to the person")
4. Click Generate
5. Wait for processing
6. Download the result

## 🎨 AI Model Details

**Model:** fal-ai/bytedance/seedream/v4/edit

**Capabilities:**
- High-quality image-to-image editing
- Natural language prompt understanding
- Multiple editing operations in one prompt
- Safety checker enabled
- Commercial use permitted

**Example Prompts:**
- "Change background to a beach sunset"
- "Add sunglasses and a hat"
- "Make it look like a painting"
- "Convert to black and white"

## ⚙️ Environment Variables

### Backend (.env)
```
FAL_AI_API_KEY=your_fal_ai_api_key
PORT=8000
HOST=0.0.0.0
ENVIRONMENT=development
```

### Frontend
Update `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8000';  // Development
// static const String baseUrl = 'https://your-backend.onrender.com';  // Production
```

## 🔧 Known Issues & Limitations

### Current Limitations
- **Storage:** Jobs stored in-memory (lost on server restart)
- **Rate Limits:** Subject to fal.ai API rate limits
- **File Size:** Large images may take longer to process
- **Browser Support:** Limited file picker on some mobile browsers

### Future Improvements
- [ ] SQL database for persistent storage (bonus feature)
- [ ] Before/After image slider (bonus feature)
- [ ] Batch image processing
- [ ] Custom model parameters
- [ ] Image history with thumbnails
- [ ] User authentication
- [ ] Rate limiting implementation

## 🤖 AI Tools Usage

This project was developed with assistance from **Claude Code**, Anthropic's AI-powered development assistant. Here's how AI tools were utilized:

### Development Process
1. **Architecture Planning:** Designed system architecture and component structure
2. **Code Generation:** Created boilerplate code for models, services, and UI components
3. **Documentation:** Generated comprehensive README files and code comments
4. **Debugging:** Identified and fixed issues during development
5. **Best Practices:** Applied clean code principles and design patterns

### Implementation Strategy
- **Iterative Development:** Built features incrementally (backend-first approach)
- **Code Review:** AI-assisted code quality checks
- **Documentation:** Auto-generated inline comments and documentation
- **Testing Guidance:** Suggested testing strategies and edge cases

### Prompting Approach
- Clear, specific requirements with examples
- Incremental feature requests
- Architecture-first planning
- Error-driven debugging

**Result:** Efficient development with clean, maintainable code and comprehensive documentation.

## 📝 License

This project is part of a technical assignment for Voltran.

## 👤 Author

**Yunus Emre Alpak**
- Email: yunusemrealpak@gmail.com

## 🙏 Acknowledgments

- fal.ai for the AI image editing API
- Flutter team for the excellent web framework
- FastAPI team for the modern Python web framework
- Anthropic for Claude Code development assistance
