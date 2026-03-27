export interface SMSVariation {
  variation_type: string;
  copy_text: string;
  mms_image_url?: string;
}

export interface CampaignStrategy {
  campaign_name: string;
  rationale: string;
  target_segment_logic: string;
  offer_type: string;
  estimated_conversion_rate: number;
}

export interface CampaignOnePager {
  restaurant_id: number;
  strategy: CampaignStrategy;
  target_audience_size: number;
  sms_variations: SMSVariation[];
  estimated_cost_usd: number;
  is_safe: boolean;
  validation_feedback?: string;
}
