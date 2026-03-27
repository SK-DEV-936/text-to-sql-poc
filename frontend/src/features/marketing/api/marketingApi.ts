import axios from 'axios';
import { CampaignOnePager } from '../types';

export const generateMarketingCampaign = async (restaurantId: number): Promise<CampaignOnePager> => {
  const response = await axios.post<CampaignOnePager>(`/api/marketing/generate-campaign?restaurant_id=${restaurantId}`);
  return response.data;
};
