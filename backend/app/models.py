from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field
from uuid import uuid4
from sqlalchemy import Column, String, Integer, DateTime, Enum as SQLEnum
from .database import Base


class JobStatus(str, Enum):
    """Job processing status"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


# SQLAlchemy Database Model
class JobDB(Base):
    """SQLAlchemy model for Job table"""
    __tablename__ = "jobs"

    id = Column(String, primary_key=True, index=True)
    original_image_url = Column(String, nullable=False)
    edited_image_url = Column(String, nullable=True)
    prompt = Column(String(1000), nullable=False)
    status = Column(SQLEnum(JobStatus), default=JobStatus.PENDING, nullable=False)
    progress = Column(Integer, default=0, nullable=False)
    error_message = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)


class Job(BaseModel):
    """Image editing job"""
    id: str = Field(default_factory=lambda: str(uuid4()))
    original_image_url: str
    edited_image_url: Optional[str] = None
    prompt: str
    status: JobStatus = JobStatus.PENDING
    progress: int = Field(default=0, ge=0, le=100)  # Progress percentage (0-100)
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
    progress: int = 0
    error_message: Optional[str] = None
    created_at: datetime
    updated_at: datetime
