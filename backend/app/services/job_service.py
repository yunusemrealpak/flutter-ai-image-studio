import base64
import httpx
from datetime import datetime
from typing import List, Optional
from app.models import Job, JobCreate, JobStatus
from app.storage import job_store
from app.services.fal_ai import fal_ai_service


class JobService:
    """Service for managing image editing jobs"""

    async def _get_image_bytes_from_data_uri(self, data_uri: str) -> tuple[bytes, str]:
        """
        Extract image bytes from data URI

        Args:
            data_uri: Data URI (data:image/png;base64,xxxxx)

        Returns:
            Tuple of (image_bytes, image_format)
        """
        if not data_uri.startswith('data:image/'):
            raise Exception("Invalid data URI format")

        # Parse data URI: data:image/png;base64,xxxxx
        parts = data_uri.split(',', 1)
        if len(parts) != 2:
            raise Exception("Invalid data URI format")

        image_base64 = parts[1]
        image_bytes = base64.b64decode(image_base64)

        # Determine format from data URI
        format_part = parts[0]  # data:image/png;base64
        image_format = format_part.split('/')[1].split(';')[0]

        return image_bytes, image_format

    async def create_job(
        self,
        original_image_url: str,
        job_data: JobCreate
    ) -> Job:
        """
        Create a new image editing job (returns immediately with PROCESSING status)

        Args:
            original_image_url: Original image data URI
            job_data: Job creation data (prompt)

        Returns:
            Created job in PROCESSING state (processing will continue in background)
        """
        # Create job record with PROCESSING status
        job = Job(
            original_image_url=original_image_url,
            prompt=job_data.prompt,
            status=JobStatus.PROCESSING,
            progress=0
        )

        # Store job
        job_store.create_job(job)

        # Return job immediately - processing will happen in background
        return job

    async def process_job_with_ai(self, job_id: str):
        """
        Process job with AI in background (called by BackgroundTasks)

        Args:
            job_id: Job ID to process
        """
        job = job_store.get_job(job_id)
        if not job:
            return

        try:
            # Extract image bytes from data URI
            image_bytes, image_format = await self._get_image_bytes_from_data_uri(
                job.original_image_url
            )

            # Progress callback to update job progress
            def update_progress(progress: int):
                job.progress = progress
                job.updated_at = datetime.utcnow()
                job_store.update_job(job)

            # Call fal.ai to edit image with progress tracking
            result = await fal_ai_service.edit_image(
                image_data=image_bytes,
                prompt=job.prompt,
                image_format=image_format,
                on_progress=update_progress
            )

            # Update job with result
            job.status = JobStatus.COMPLETED
            job.progress = 100
            job.edited_image_url = result["images"][0]["url"]
            job.updated_at = datetime.utcnow()

            job_store.update_job(job)

        except Exception as e:
            # Mark job as failed
            job.status = JobStatus.FAILED
            job.error_message = str(e)
            job.updated_at = datetime.utcnow()
            job_store.update_job(job)

    def get_job(self, job_id: str) -> Optional[Job]:
        """Get job by ID"""
        return job_store.get_job(job_id)

    def get_all_jobs(self) -> List[Job]:
        """Get all jobs"""
        return job_store.get_all_jobs()

    def delete_job(self, job_id: str) -> bool:
        """Delete a job"""
        return job_store.delete_job(job_id)


# Singleton instance
job_service = JobService()
