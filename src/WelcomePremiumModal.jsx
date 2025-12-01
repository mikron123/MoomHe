import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { Crown, Star, Sparkles, Check, X } from 'lucide-react';

const WelcomePremiumModal = ({ isOpen, onClose, subscriptionName }) => {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  // Confetti animation removed temporarily to resolve import issues
  // useEffect(() => {
  //   if (isOpen) {
  //     // Trigger confetti when modal opens
  //     const duration = 3000;
  //     const end = Date.now() + duration;

  //     const frame = () => {
  //       confetti({
  //         particleCount: 2,
  //         angle: 60,
  //         spread: 55,
  //         origin: { x: 0 },
  //         colors: ['#FFD700', '#FFA500', '#ffffff']
  //       });
  //       confetti({
  //         particleCount: 2,
  //         angle: 120,
  //         spread: 55,
  //         origin: { x: 1 },
  //         colors: ['#FFD700', '#FFA500', '#ffffff']
  //       });

  //       if (Date.now() < end) {
  //         requestAnimationFrame(frame);
  //       }
  //     };
  //     frame();
  //   }
  // }, [isOpen]);

  if (!isOpen || !mounted) return null;

  return createPortal(
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[100] flex items-center justify-center p-4 animate-fade-in">
      <div className="glass-card w-full max-w-md bg-surface relative overflow-hidden border-2 border-yellow-500/30 shadow-[0_0_50px_rgba(255,215,0,0.2)]">
        {/* Close button */}
        <button 
          onClick={onClose}
          className="absolute top-4 left-4 text-textMuted hover:text-white p-1 rounded-full hover:bg-white/10 transition-colors z-20"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Decorative background glow */}
        <div className="absolute -top-20 -right-20 w-60 h-60 bg-yellow-500/20 rounded-full blur-3xl pointer-events-none animate-pulse" />
        <div className="absolute -bottom-20 -left-20 w-60 h-60 bg-orange-500/20 rounded-full blur-3xl pointer-events-none animate-pulse" />
        
        {/* Animated stars background */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-10 right-10 text-yellow-400/40 animate-bounce duration-1000"><Star size={16} fill="currentColor" /></div>
          <div className="absolute bottom-20 right-20 text-yellow-400/30 animate-bounce duration-1500 delay-100"><Star size={12} fill="currentColor" /></div>
          <div className="absolute top-20 left-10 text-yellow-400/30 animate-bounce duration-2000 delay-200"><Star size={14} fill="currentColor" /></div>
        </div>

        <div className="p-8 flex flex-col items-center text-center relative z-10">
          {/* Icon */}
          <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-yellow-400/30 to-orange-500/30 flex items-center justify-center mb-6 border border-yellow-500/30 shadow-lg shadow-yellow-500/20 relative">
            <Crown className="w-10 h-10 text-yellow-400" />
            <div className="absolute -top-1 -right-1 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-full p-1.5 shadow-lg">
              <Check className="w-4 h-4 text-white stroke-[3]" />
            </div>
          </div>

          {/* Title */}
          <h3 className="text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-yellow-200 via-yellow-400 to-orange-400 mb-2">
            ברוך הבא למנוי {subscriptionName}!
          </h3>

          {/* Description */}
          <p className="text-gray-300 mb-8 leading-relaxed">
            תודה שהצטרפת למשפחת המנויים שלנו. החשבון שלך שודרג בהצלחה וכעת יש לך גישה לכל התכונות המתקדמות ולקרדיטים נוספים.
          </p>

          {/* Features Highlight */}
          <div className="w-full bg-gradient-to-r from-yellow-500/10 to-orange-500/10 rounded-xl p-4 mb-8 border border-yellow-500/20">
            <div className="flex items-center gap-3 text-sm text-yellow-100 mb-2">
              <Sparkles className="w-4 h-4 text-yellow-400" />
              <span>קרדיטים נוספו לחשבונך</span>
            </div>
            <div className="flex items-center gap-3 text-sm text-yellow-100 mb-2">
              <Check className="w-4 h-4 text-yellow-400" />
              <span>גישה ללא הגבלה לכל הסגנונות</span>
            </div>
            <div className="flex items-center gap-3 text-sm text-yellow-100">
              <Crown className="w-4 h-4 text-yellow-400" />
              <span>תמיכה ביוצרים ומעצבים</span>
            </div>
          </div>

          {/* Action Button */}
          <button
            onClick={onClose}
            className="w-full py-3.5 rounded-xl bg-gradient-to-r from-yellow-500 to-orange-600 text-white font-bold shadow-lg shadow-orange-900/20 hover:shadow-orange-900/40 transform hover:-translate-y-0.5 transition-all duration-200 flex items-center justify-center gap-2"
          >
            התחל לעצב
            <Sparkles className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
};

export default WelcomePremiumModal;

