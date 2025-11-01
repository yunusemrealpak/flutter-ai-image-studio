from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field
from uuid import uuid4


class JobStatus(str, Enum):
    """Job processing status"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class Job(BaseModel):
    """Image editing job"""
    id: str = Field(default_factory=lambda: str(uuid4()))
    original_image_url: str
    edited_image_url: Optional[str] = None
    prompt: str
    status: JobStatus = JobStatus.PENDING
    error_message: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class JobCreate(BaseModel):
    """Request model for creating a new job"""
    prompt: str = Field(..., min_length=1, max_length=1000)


class JobResponse(BaseModel):
    """Response model for job data"""
    id: str
    original_image_url: str
    edited_image_url: Optional[str]
    prompt: str
    status: JobStatus
    error_message: Optional[str] = None
    created_at: datetime
    updated_at: datetime
