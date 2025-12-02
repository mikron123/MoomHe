import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { Crown, Check, X } from 'lucide-react';

const LimitReachedModal = ({ isOpen, onClose, onShowPricing, userSubscription, currentUsage, limit }) => {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!isOpen || !mounted) return null;

  return createPortal(
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[100] flex items-center justify-center p-4 animate-fade-in">
      <div className="glass-card w-full max-w-md bg-surface relative overflow-hidden">
        {/* Close button */}
        <button 
          onClick={onClose}
          className="absolute top-4 left-4 text-textMuted hover:text-white p-1 rounded-full hover:bg-white/10 transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Decorative background glow */}
        <div className="absolute -top-20 -right-20 w-40 h-40 bg-primary-500/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-20 -left-20 w-40 h-40 bg-secondary-500/20 rounded-full blur-3xl pointer-events-none" />

        <div className="p-8 flex flex-col items-center text-center relative z-10">
          {/* Icon */}
          <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-primary-500/20 to-secondary-500/20 flex items-center justify-center mb-6 border border-white/10">
            <Crown className="w-8 h-8 text-primary-400" />
          </div>

          {/* Title */}
          <h3 className="text-2xl font-bold text-white mb-2">
            {userSubscription > 0 ? 'נגמרו הקרדיטים לחודש זה' : 'הגעת למגבלת השימוש החינמי'}
          </h3>

          {/* Description */}
          <p className="text-gray-300 mb-8 leading-relaxed">
            {userSubscription > 0 
              ? `הגעת למגבלת הקרדיטים שלך (${limit} קרדיטים). ניתן לשדרג לחבילה גדולה יותר או לחכות לחודש הבא.`
              : `ניצלת את כל ${limit} הקרדיטים החינמיים שלך. כדי להמשיך לעצב ללא הגבלה ולקבל תכונות מתקדמות, שדרג למנוי מקצועי.`
            }
          </p>

          {/* Stats Box */}
          <div className="w-full bg-white/5 rounded-xl p-4 mb-8 border border-white/10 flex justify-between items-center">
            <div className="text-right">
              <div className="text-xs text-gray-400 mb-1">שימוש נוכחי</div>
              <div className="text-lg font-bold text-white">{currentUsage} עיצובים</div>
            </div>
            <div className="h-8 w-px bg-white/10 mx-4" />
            <div className="text-right">
              <div className="text-xs text-gray-400 mb-1">מגבלה</div>
              <div className="text-lg font-bold text-white">{limit} עיצובים</div>
            </div>
          </div>

          {/* Action Buttons */}
          <button
            onClick={() => {
              onClose();
              onShowPricing();
            }}
            className="w-full py-3.5 rounded-xl bg-gradient-to-r from-primary-500 to-secondary-600 text-white font-semibold shadow-lg shadow-primary-900/20 flex items-center justify-center gap-2 mb-3"
          >
            <Crown className="w-5 h-5" />
            {userSubscription > 0 ? 'שדרג חבילה' : 'עבור למנוי מקצועי'}
          </button>

          <button
            onClick={onClose}
            className="text-sm text-gray-400 hover:text-white transition-colors"
          >
            לא עכשיו, תודה
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
};

export default LimitReachedModal;

