import React from 'react';
import { CampaignOnePager } from '../types';
import { SMSPhonePreview } from './SMSPhonePreview';

interface Props {
  proposal: CampaignOnePager;
}

export const CampaignProposalCard: React.FC<Props> = ({ proposal }) => {
  const { strategy, target_audience_size, estimated_cost_usd, sms_variations, is_safe, validation_feedback } = proposal;

  return (
    <div className="bg-white rounded-2xl shadow-xl shadow-blue-900/5 border border-gray-100 overflow-hidden max-w-5xl mx-auto my-8 font-sans">
      {/* Header Banner */}
      <div className="bg-gradient-to-r from-blue-700 via-blue-600 to-indigo-700 p-8">
        <div className="flex justify-between items-center">
          <div>
            <span className="bg-blue-500/30 text-blue-100 border border-blue-400/30 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider mb-3 inline-block">AI Suggested Campaign</span>
            <h2 className="text-3xl font-bold text-white mb-2">{strategy.campaign_name}</h2>
            <p className="text-blue-100 font-medium text-lg">{strategy.offer_type} Strategy</p>
          </div>
        </div>
      </div>

      <div className="p-8">
        {!is_safe && validation_feedback && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl flex items-start gap-3">
            <span className="text-red-600 text-xl font-bold">⚠️</span>
            <div>
              <h4 className="text-red-800 font-bold mb-1">AI Watcher Flag (High Risk Campaign)</h4>
              <p className="text-red-700 text-sm">{validation_feedback}</p>
            </div>
          </div>
        )}
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 mb-8">
          {/* Left Column: Data Rationale */}
          <div>
            <h3 className="text-xl font-bold text-gray-800 border-b border-gray-100 pb-3 mb-4">Strategic Rationale</h3>
            <p className="text-gray-600 mb-6 leading-relaxed">{strategy.rationale}</p>
            
            <h3 className="text-xl font-bold text-gray-800 border-b border-gray-100 pb-3 mb-4">Targeting Logic</h3>
            <p className="text-gray-600 text-sm mb-6 bg-gray-50 p-4 rounded-xl border border-gray-100">
              <span className="font-semibold text-gray-800">Segment:</span> {strategy.target_segment_logic}
            </p>
            
            <div className="flex gap-4 mt-6">
              <div className="bg-blue-50/50 p-5 rounded-xl border border-blue-100 flex-1 relative overflow-hidden">
                <div className="absolute top-0 right-0 w-16 h-16 bg-blue-100/50 rounded-bl-full -mr-4 -mt-4"></div>
                <p className="text-xs text-blue-600 font-bold uppercase tracking-wider mb-2">Audience Size</p>
                <p className="text-3xl font-bold text-blue-900">{target_audience_size}</p>
                <p className="text-sm font-medium text-blue-700/70 mt-1">qualifying guests</p>
              </div>
              <div className="bg-emerald-50/50 p-5 rounded-xl border border-emerald-100 flex-1 relative overflow-hidden">
                <div className="absolute top-0 right-0 w-16 h-16 bg-emerald-100/50 rounded-bl-full -mr-4 -mt-4"></div>
                <p className="text-xs text-emerald-600 font-bold uppercase tracking-wider mb-2">Est. Conversion</p>
                <p className="text-3xl font-bold text-emerald-900">{strategy.estimated_conversion_rate}%</p>
                <p className="text-sm font-medium text-emerald-700/70 mt-1">projected click rate</p>
              </div>
            </div>
            
            <div className="mt-6 bg-slate-50 p-5 rounded-xl border border-slate-200">
              <div className="flex justify-between items-center mb-1">
                <span className="text-sm font-bold text-slate-700">Estimated SMS Cost (Twilio API)</span>
                <span className="text-xl font-bold text-slate-900">${estimated_cost_usd}</span>
              </div>
              <p className="text-xs text-slate-500">Based on standard carrier fees of $0.0079 per segment.</p>
            </div>
          </div>

          {/* Right Column: Creative Preview */}
          <div>
            <h3 className="text-xl font-bold text-gray-800 border-b border-gray-100 pb-3 mb-4">AI Copywriter Preview</h3>
            <SMSPhonePreview variations={sms_variations} />
          </div>
        </div>

        {/* Footer Actions */}
        <div className="border-t border-gray-100 pt-6 flex justify-end gap-4 mt-4">
          <button className="px-6 py-3 rounded-xl text-gray-500 hover:text-gray-700 hover:bg-gray-50 font-semibold transition-colors">
            Dismiss Idea
          </button>
          <button className="px-8 py-3 rounded-xl bg-gradient-to-r from-emerald-500 to-emerald-600 hover:from-emerald-600 hover:to-emerald-700 text-white font-bold shadow-lg shadow-emerald-200 transition-all transform hover:-translate-y-0.5">
            Approve & Send Campaign
          </button>
        </div>
      </div>
    </div>
  );
};
