# AI Image Editing Backend

FastAPI backend service for AI-powered image editing using fal.ai's Seedream v4 model.

## Features

- ✅ Image upload and editing with text prompts
- ✅ Job status tracking
- ✅ Version history (list all jobs)
- ✅ CORS enabled for frontend integration
- ✅ Async processing with fal.ai API
- ✅ In-memory job storage

## Tech Stack

- **Framework:** FastAPI 0.104.1
- **AI Service:** fal.ai (Seedream v4 Edit model)
- **Python:** 3.11+
- **Deployment:** Render.com

## API Endpoints

### POST /api/jobs
Create a new image editing job.

**Request:**
- `image` (file): Image file to edit
- `prompt` (form field): Text description of desired edits

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
Get job status and result by ID.

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

## Local Development

### Prerequisites
- Python 3.11+
- pip

### Setup

1. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env and add your FAL_AI_API_KEY
```

4. Run the server:
```bash
python -m app.main
```

The API will be available at `http://localhost:8000`

### API Documentation

Once running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Deployment on Render.com

### Option 1: Using render.yaml (Recommended)

1. Push code to GitHub
2. Connect repository to Render.com
3. Render will automatically detect `render.yaml`
4. Add environment variable in Render dashboard:
   - `FAL_AI_API_KEY`: Your fal.ai API key

### Option 2: Manual Setup

1. Create new Web Service on Render.com
2. Connect your GitHub repository
3. Configure:
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Environment Variables:**
     - `FAL_AI_API_KEY`: Your fal.ai API key
     - `ENVIRONMENT`: production

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| FAL_AI_API_KEY | fal.ai API key for image editing | Yes |
| PORT | Server port (auto-set by Render) | No |
| HOST | Server host address | No |
| ENVIRONMENT | Environment (development/production) | No |

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app and CORS config
│   ├── config.py            # Settings and environment vars
│   ├── models.py            # Pydantic models
│   ├── routers/
│   │   ├── __init__.py
│   │   └── jobs.py          # Job endpoints
│   └── services/
│       ├── __init__.py
│       └── fal_ai.py        # fal.ai integration
├── requirements.txt         # Python dependencies
├── .env.example            # Environment variables template
├── .env                    # Local environment variables
├── .gitignore
├── Procfile                # Render deployment config
├── runtime.txt             # Python version
├── start.sh                # Start script
└── render.yaml             # Render configuration
```

## AI Model Used

**Model:** fal-ai/bytedance/seedream/v4/edit

This model provides high-quality image editing based on text prompts. It supports:
- Image-to-image editing
- Natural language prompts
- Multiple output images
- Safety checking

## Known Limitations

- **Storage:** Jobs are stored in-memory and will be lost on server restart
- **File Size:** Large images may take longer to process
- **Rate Limits:** Subject to fal.ai API rate limits

## Future Improvements

- [ ] Add SQL database for persistent storage
- [ ] Implement job queuing system
- [ ] Add image size optimization
- [ ] Implement rate limiting
- [ ] Add request caching
- [ ] Support multiple AI models
