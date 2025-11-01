from typing import List, Optional
from sqlalchemy import select, delete as sql_delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import Job, JobDB, JobStatus
from app.database import AsyncSessionLocal
from uuid import uuid4
from datetime import datetime


class DatabaseJobStore:
    """SQLite database storage for jobs"""

    async def create_job(self, job: Job) -> Job:
        """Store a new job in database"""
        async with AsyncSessionLocal() as session:
            db_job = JobDB(
                id=job.id,
                original_image_url=job.original_image_url,
                edited_image_url=job.edited_image_url,
                prompt=job.prompt,
                status=job.status,
                progress=job.progress,
                error_message=job.error_message,
                created_at=job.created_at,
                updated_at=job.updated_at
            )
            session.add(db_job)
            await session.commit()
            await session.refresh(db_job)
            return self._db_to_pydantic(db_job)

    async def get_job(self, job_id: str) -> Optional[Job]:
        """Get job by ID from database"""
        async with AsyncSessionLocal() as session:
            result = await session.execute(
                select(JobDB).where(JobDB.id == job_id)
            )
            db_job = result.scalar_one_or_none()
            if db_job:
                return self._db_to_pydantic(db_job)
            return None

    async def get_all_jobs(self) -> List[Job]:
        """Get all jobs from database, sorted by creation date (newest first)"""
        async with AsyncSessionLocal() as session:
            result = await session.execute(
                select(JobDB).order_by(JobDB.created_at.desc())
            )
            db_jobs = result.scalars().all()
            return [self._db_to_pydantic(job) for job in db_jobs]

    async def update_job(self, job: Job) -> Job:
        """Update existing job in database"""
        async with AsyncSessionLocal() as session:
            result = await session.execute(
                select(JobDB).where(JobDB.id == job.id)
            )
            db_job = result.scalar_one_or_none()

            if db_job:
                db_job.original_image_url = job.original_image_url
                db_job.edited_image_url = job.edited_image_url
                db_job.prompt = job.prompt
                db_job.status = job.status
                db_job.progress = job.progress
                db_job.error_message = job.error_message
                db_job.updated_at = job.updated_at

                await session.commit()
                await session.refresh(db_job)
                return self._db_to_pydantic(db_job)

            return job

    async def delete_job(self, job_id: str) -> bool:
        """Delete a job from database"""
        async with AsyncSessionLocal() as session:
            result = await session.execute(
                sql_delete(JobDB).where(JobDB.id == job_id)
            )
            await session.commit()
            return result.rowcount > 0

    def _db_to_pydantic(self, db_job: JobDB) -> Job:
        """Convert SQLAlchemy model to Pydantic model"""
        return Job(
            id=db_job.id,
            original_image_url=db_job.original_image_url,
            edited_image_url=db_job.edited_image_url,
            prompt=db_job.prompt,
            status=db_job.status,
            progress=db_job.progress,
            error_message=db_job.error_message,
            created_at=db_job.created_at,
            updated_at=db_job.updated_at
        )


# Singleton instance
job_store = DatabaseJobStore()
