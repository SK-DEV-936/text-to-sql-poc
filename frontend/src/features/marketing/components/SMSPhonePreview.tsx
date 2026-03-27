import React, { useState } from 'react';
import { SMSVariation } from '../types';

interface Props {
  variations: SMSVariation[];
}

export const SMSPhonePreview: React.FC<Props> = ({ variations }) => {
  const [activeIndex, setActiveIndex] = useState(0);
  if (!variations.length) return null;
  
  const activeVar = variations[activeIndex];

  return (
    <div className="flex flex-col md:flex-row gap-6">
      {/* Phone Mockup */}
      <div className="w-64 h-96 border-4 border-gray-800 rounded-3xl overflow-hidden relative bg-white shadow-xl">
        <div className="bg-gray-100 p-2 text-center text-xs text-gray-500 font-bold border-b border-gray-200">
          Messages
        </div>
        <div className="p-3">
          {activeVar.mms_image_url && (
            <img src={activeVar.mms_image_url} alt="MMS Flyer" className="w-full rounded-lg mb-2 shadow-sm" />
          )}
          <div className="bg-blue-500 text-white p-3 rounded-2xl rounded-tr-sm text-sm inline-block shadow-sm">
            {activeVar.copy_text}
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex flex-col gap-2 flex-1">
        <h4 className="font-bold text-gray-700 text-sm uppercase tracking-wide">Select Variation:</h4>
        {variations.map((v, idx) => (
          <button
            key={idx}
            onClick={() => setActiveIndex(idx)}
            className={`px-4 py-3 rounded-xl text-left transition-all border ${
              activeIndex === idx 
                ? 'bg-blue-50 border-blue-500 text-blue-900 shadow-sm font-semibold' 
                : 'bg-white border-gray-200 text-gray-600 hover:bg-gray-50 hover:border-gray-300'
            }`}
          >
            {v.variation_type}
          </button>
        ))}
      </div>
    </div>
  );
};
