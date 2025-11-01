import os
import base64
from typing import Optional, Dict, Any, Callable
from io import BytesIO
from PIL import Image
import fal_client
from app.config import settings


class FalAIService:
    """Service for interacting with fal.ai image editing API"""

    def __init__(self):
        """Initialize fal.ai client with API key"""
        # Configure fal client with API key from settings
        os.environ['FAL_KEY'] = settings.fal_ai_api_key

    async def edit_image(
        self,
        image_data: bytes,
        prompt: str,
        image_format: str = "png",
        on_progress: Optional[Callable[[int], None]] = None
    ) -> Dict[str, Any]:
        """
        Edit an image using fal.ai's Seedream v4 model with progress tracking

        Args:
            image_data: Raw image bytes
            prompt: Text description of desired edits
            image_format: Image format (png, jpg, etc.)
            on_progress: Optional callback for progress updates (0-100)

        Returns:
            Dict containing edited image URL and metadata

        Raises:
            Exception: If API call fails
        """
        try:
            # Get original image dimensions
            image = Image.open(BytesIO(image_data))
            width, height = image.size

            # Convert image to base64 data URI
            image_base64 = base64.b64encode(image_data).decode('utf-8')
            image_url = f"data:image/{image_format};base64,{image_base64}"

            # Prepare arguments for fal.ai API
            arguments = {
                "prompt": prompt,
                "image_urls": [image_url],
                "num_images": 1,
                "enable_safety_checker": True,
                "image_size": {
                    "width": width,
                    "height": height
                }
            }

            # Submit request and get handle for progress tracking
            handle = await fal_client.submit_async(
                "fal-ai/bytedance/seedream/v4/edit",
                arguments=arguments
            )

            # Report initial progress
            if on_progress:
                on_progress(10)

            # Subscribe to status updates
            async for event in fal_client.stream_async(handle):
                # Check event type and update progress
                if isinstance(event, dict):
                    # Extract progress from logs if available
                    if "logs" in event:
                        logs = event["logs"]
                        if logs:
                            # Estimate progress based on log messages
                            if "Downloading" in str(logs[-1]):
                                if on_progress:
                                    on_progress(30)
                            elif "Processing" in str(logs[-1]):
                                if on_progress:
                                    on_progress(50)
                            elif "Generating" in str(logs[-1]):
                                if on_progress:
                                    on_progress(70)

            # Get final result
            result = await fal_client.result_async(handle)

            # Report completion
            if on_progress:
                on_progress(100)

            return result

        except Exception as e:
            raise Exception(f"Failed to edit image with fal.ai: {str(e)}")

    async def check_job_status(self, request_id: str) -> Optional[Dict[str, Any]]:
        """
        Check the status of a fal.ai job

        Args:
            request_id: The fal.ai request ID

        Returns:
            Job status and result if available
        """
        try:
            # Note: fal.ai's subscribe method handles polling automatically
            # This method is for future extensibility if needed
            return None
        except Exception as e:
            raise Exception(f"Failed to check job status: {str(e)}")


# Singleton instance
fal_ai_service = FalAIService()
