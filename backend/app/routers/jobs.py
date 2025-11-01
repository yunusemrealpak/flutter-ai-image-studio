from fastapi import APIRouter, HTTPException, UploadFile, File, Form, BackgroundTasks
from typing import List
from app.models import Job, JobCreate, JobResponse
from app.services.job_service import job_service
import base64

router = APIRouter(prefix="/api/jobs", tags=["jobs"])


@router.post("", response_model=JobResponse, status_code=201)
async def create_job(
    background_tasks: BackgroundTasks,
    image: UploadFile = File(...),
    prompt: str = Form(...)
):
    """
    Create a new image editing job (returns immediately, processing in background)

    Args:
        background_tasks: FastAPI background tasks
        image: Uploaded image file
        prompt: Text prompt for editing

    Returns:
        Created job with PROCESSING status (use GET /api/jobs/{job_id} to check progress)
    """
    try:
        # Read image file
        image_bytes = await image.read()

        # Convert to base64 data URI
        image_base64 = base64.b64encode(image_bytes).decode('utf-8')

        # Determine image format
        content_type = image.content_type or 'image/png'
        image_format = content_type.split('/')[-1]

        # Create data URI
        original_image_url = f"data:{content_type};base64,{image_base64}"

        # Create job (returns immediately with PROCESSING status)
        job_data = JobCreate(prompt=prompt)
        job = await job_service.create_job(original_image_url, job_data)

        # Add AI processing to background tasks
        background_tasks.add_task(job_service.process_job_with_ai, job.id)

        return job

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{job_id}", response_model=JobResponse)
async def get_job(job_id: str):
    """
    Get job by ID

    Args:
        job_id: Job ID

    Returns:
        Job details
    """
    job = job_service.get_job(job_id)
    if not job:
        raise HTTPException(status_code=404, detail=f"Job {job_id} not found")
    return job


@router.get("", response_model=List[JobResponse])
async def list_jobs():
    """
    List all jobs (version history)

    Returns:
        List of all jobs, newest first
    """
    jobs = job_service.get_all_jobs()
    return jobs


@router.delete("/{job_id}")
async def delete_job(job_id: str):
    """
    Delete a job

    Args:
        job_id: Job ID

    Returns:
        Success message
    """
    deleted = job_service.delete_job(job_id)
    if not deleted:
        raise HTTPException(status_code=404, detail=f"Job {job_id} not found")
    return {"message": f"Job {job_id} deleted successfully"}
