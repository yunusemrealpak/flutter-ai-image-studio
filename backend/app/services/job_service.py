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
        Create a new image editing job

        Args:
            original_image_url: Original image data URI
            job_data: Job creation data (prompt)

        Returns:
            Created job with AI-edited image

        Raises:
            Exception: If AI processing fails
        """
        # Create job record
        job = Job(
            original_image_url=original_image_url,
            prompt=job_data.prompt,
            status=JobStatus.PROCESSING
        )

        # Store job
        job_store.create_job(job)

        try:
            # Extract image bytes from data URI
            image_bytes, image_format = await self._get_image_bytes_from_data_uri(
                original_image_url
            )

            # Call fal.ai to edit image
            result = await fal_ai_service.edit_image(
                image_data=image_bytes,
                prompt=job_data.prompt,
                image_format=image_format
            )

            # Update job with result
            job.status = JobStatus.COMPLETED
            job.edited_image_url = result["images"][0]["url"]
            job.updated_at = datetime.utcnow()

            job_store.update_job(job)

        except Exception as e:
            # Mark job as failed
            job.status = JobStatus.FAILED
            job.error_message = str(e)
            job.updated_at = datetime.utcnow()
            job_store.update_job(job)
            raise Exception(f"Failed to process job: {str(e)}")

        return job

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
