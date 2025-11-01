from typing import Dict, List, Optional
from app.models import Job


class JobStore:
    """Simple in-memory storage for jobs"""

    def __init__(self):
        self.jobs: Dict[str, Job] = {}

    def create_job(self, job: Job) -> Job:
        """Store a new job"""
        self.jobs[job.id] = job
        return job

    def get_job(self, job_id: str) -> Optional[Job]:
        """Get job by ID"""
        return self.jobs.get(job_id)

    def get_all_jobs(self) -> List[Job]:
        """Get all jobs, sorted by creation date (newest first)"""
        return sorted(
            self.jobs.values(),
            key=lambda j: j.created_at,
            reverse=True
        )

    def update_job(self, job: Job) -> Job:
        """Update existing job"""
        self.jobs[job.id] = job
        return job

    def delete_job(self, job_id: str) -> bool:
        """Delete a job"""
        if job_id in self.jobs:
            del self.jobs[job_id]
            return True
        return False


# Singleton instance
job_store = JobStore()
