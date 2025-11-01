from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import jobs

# Create FastAPI app
app = FastAPI(
    title="AI Image Editing API",
    description="Backend API for AI-powered image editing using fal.ai",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(jobs.router)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "AI Image Editing API",
        "version": "1.0.0",
        "endpoints": {
            "create_job": "POST /api/jobs",
            "get_job": "GET /api/jobs/{job_id}",
            "list_jobs": "GET /api/jobs",
            "docs": "/docs"
        }
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
