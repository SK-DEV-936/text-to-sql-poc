from pydantic import BaseModel, HttpUrl
from typing import List, Optional

class SMSVariation(BaseModel):
    variation_type: str
    copy_text: str
    mms_image_url: Optional[str] = None

class CampaignStrategy(BaseModel):
    campaign_name: str
    rationale: str
    target_segment_logic: str
    offer_type: str
    estimated_conversion_rate: float

class CampaignOnePager(BaseModel):
    restaurant_id: int
    strategy: CampaignStrategy
    target_audience_size: int
    sms_variations: List[SMSVariation]
    estimated_cost_usd: float
    is_safe: bool = True
    validation_feedback: Optional[str] = None

class ValidationResult(BaseModel):
    is_safe: bool
    feedback_reason: str
