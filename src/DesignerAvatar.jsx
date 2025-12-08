import React, { useState, useEffect } from 'react';
import { Sparkles, X } from 'lucide-react';
import avatarImage from './assets/avatar.png';

const DesignerAvatar = ({ suggestions, onSelect, onClose, isMobile = false, isThinking = false, initialShowSuggestions = true }) => {
  const [isVisible, setIsVisible] = useState(false);
  const [showSuggestions, setShowSuggestions] = useState(false);

  // Show avatar when thinking or when suggestions are ready
  useEffect(() => {
    if (isThinking) {
      setIsVisible(true);
      setShowSuggestions(false);
    } else if (suggestions && suggestions.length > 0) {
      // Small delay for entrance animation
      const timer = setTimeout(() => {
        setIsVisible(true);
        // Only show bubble/menu automatically if initialShowSuggestions is true AND not manually closed (minimized)
        // Actually, we want to allow minimizing.
        if (initialShowSuggestions) {
          setShowSuggestions(true);
        } else {
          setShowSuggestions(false);
        }
      }, 500);
      return () => clearTimeout(timer);
    } else {
      setIsVisible(false); // Hide if no suggestions and not thinking
    }
  }, [suggestions, isThinking, initialShowSuggestions]);

  const handleSelect = (suggestion) => {
    onSelect(suggestion);
    // Minimize after selection
    setShowSuggestions(false);
  };

  const handleDismiss = () => {
    setIsVisible(false);
    setTimeout(() => {
      onClose();
    }, 500); // Wait for exit animation
  };

  const toggleSuggestions = () => {
    if (!isThinking && suggestions && suggestions.length > 0) {
      setShowSuggestions(!showSuggestions);
    }
  };

  if (!isThinking && (!suggestions || suggestions.length === 0)) return null;

  // Mobile Inline Mode
  if (isMobile) {
    return (
      <>
        <div className="relative group cursor-pointer" onClick={toggleSuggestions}>
          <div className="w-14 h-14 rounded-2xl border border-purple-400/40 overflow-hidden bg-purple-100/50 relative z-10 transition-transform duration-300 transform active:scale-95 flex items-center justify-center">
            <img 
              src={avatarImage} 
              alt="AI Designer" 
              className="w-full h-full object-cover opacity-90 hover:opacity-100"
              onError={(e) => {
                e.target.onerror = null; 
                e.target.src = 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix'; // Fallback
              }}
            />
          </div>
          
          {/* Online/Status Indicator */}
          {isThinking && (
             <div className="absolute -top-1 -right-1 bg-white rounded-full p-1 shadow-sm z-20 animate-pulse">
               <div className="flex space-x-1">
                 <div className="w-1 h-1 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
                 <div className="w-1 h-1 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
                 <div className="w-1 h-1 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
               </div>
             </div>
          )}
        </div>

        {/* Mobile Menu Overlay */}
        {showSuggestions && !isThinking && (
          <div className="fixed inset-0 z-[100] flex items-end justify-center" onClick={() => setShowSuggestions(false)}>
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
            <div 
              className="relative w-full max-w-md bg-surface/95 backdrop-blur-xl rounded-t-3xl p-6 pb-8 animate-slide-up border-t border-white/10 max-h-[70vh] overflow-hidden flex flex-col"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-4 flex-row-reverse">
                <div className="flex items-center gap-3 flex-row-reverse">
                  <div className="w-10 h-10 rounded-full border-2 border-white/20 overflow-hidden bg-purple-100">
                    <img src={avatarImage} alt="AI" className="w-full h-full object-cover" />
                  </div>
                  <div className="text-right">
                    <h3 className="text-white font-bold text-sm">המעצבת שלך</h3>
                    <p className="text-xs text-purple-300">יש לי כמה רעיונות עבורך!</p>
                  </div>
                </div>
                <button 
                  onClick={() => setShowSuggestions(false)}
                  className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto custom-scrollbar space-y-2 p-1">
                {suggestions.map((suggestion, index) => (
                  <button
                    key={index}
                    onClick={() => handleSelect(suggestion)}
                    className="w-full text-right p-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/10 transition-all duration-200 group flex items-center justify-between gap-3 active:scale-95"
                  >
                    <Sparkles className="w-5 h-5 text-purple-400" />
                    <span className="text-white font-medium text-sm flex-1">{suggestion.label || suggestion.title_he}</span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}
      </>
    );
  }

  // Desktop Floating Mode
  return (
    <div 
      className={`fixed z-50 transition-all duration-500 ease-in-out ${
        isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-20 pointer-events-none'
      }`}
      style={{
        bottom: '40px',
        right: '40px', // Changed from left to right
        left: 'auto', // Reset left
        maxWidth: '400px'
      }}
    >
      <div className="flex flex-col items-end gap-4"> {/* Changed items-start to items-end */}
        
        {/* Avatar and Bubble Container */}
        <div className="flex items-end gap-3 flex-row-reverse"> {/* Added flex-row-reverse */}
          {/* Avatar */}
          <div className="relative group cursor-pointer" onClick={toggleSuggestions}>
            <div className="w-16 h-16 rounded-full border-4 border-white shadow-xl overflow-hidden bg-purple-100 relative z-10 transition-transform duration-300 transform group-hover:scale-105">
              <img 
                src={avatarImage} 
                alt="AI Designer" 
                className="w-full h-full object-cover"
                onError={(e) => {
                  e.target.onerror = null; 
                  e.target.src = 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix'; // Fallback
                }}
              />
            </div>
            
            {/* Online/Status Indicator */}
            {isThinking ? (
               <div className="absolute -top-1 -right-1 bg-white rounded-full p-1 shadow-sm z-20 animate-pulse">
                 <div className="flex space-x-1">
                   <div className="w-1.5 h-1.5 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
                   <div className="w-1.5 h-1.5 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
                   <div className="w-1.5 h-1.5 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
                 </div>
               </div>
            ) : (
               <div className="absolute -bottom-1 -right-1 bg-green-500 w-5 h-5 rounded-full border-2 border-white z-20"></div>
            )}
          </div>

          {/* Thinking / Intro Bubble - Only show if thinking OR showSuggestions is true */}
          {(isThinking || showSuggestions) && (
            <div className="bg-white rounded-2xl rounded-br-none p-4 shadow-xl border border-purple-100 max-w-[250px] animate-bounce-in relative">
               {/* Small triangle for speech bubble - positioned right */}
               <div className="absolute bottom-0 right-[-8px] w-0 h-0 border-r-[8px] border-r-transparent border-b-[12px] border-b-white border-l-[0px] border-l-transparent transform -rotate-12"></div>

              {isThinking ? (
                <div className="flex items-center gap-2" dir="rtl">
                  <p className="text-gray-600 text-sm font-medium">מנתחת את החלל...</p>
                  {/* Typing dots */}
                   <div className="flex space-x-1 flex-row-reverse">
                     <div className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
                     <div className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
                     <div className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
                   </div>
                </div>
              ) : (
                <p className="text-gray-800 text-sm font-medium text-right" dir="rtl">
                  היי! יש לי כמה רעיונות מעולים לשדרוג החדר הזה 🎨
                </p>
              )}
            </div>
          )}
        </div>

        {/* Suggestions List */}
        {!isThinking && showSuggestions && suggestions && suggestions.length > 0 && (
          <div className="bg-white/95 backdrop-blur-md p-4 rounded-2xl shadow-2xl border border-white/50 w-full animate-fade-in-up">
            <div className="flex flex-col gap-2 max-h-[300px] overflow-y-auto custom-scrollbar">
              {suggestions.map((suggestion, index) => (
                <button
                  key={index}
                  onClick={() => handleSelect(suggestion)}
                  className="w-full text-right p-3 rounded-xl bg-purple-50 hover:bg-purple-100 border border-purple-100 transition-all duration-200 group flex items-center justify-between gap-3 active:scale-95"
                >
                  <Sparkles className="w-4 h-4 text-purple-400 opacity-0 group-hover:opacity-100 transition-opacity" />
                  <span className="text-gray-700 font-medium text-sm flex-1">{suggestion.label || suggestion.title_he}</span>
                </button>
              ))}
            </div>

            <div className="mt-3 pt-3 border-t border-gray-100 flex justify-end">
              <button 
                onClick={handleDismiss}
                className="text-xs text-gray-400 hover:text-gray-600 font-medium px-3 py-1 rounded-full hover:bg-gray-100 transition-colors"
              >
                לא תודה
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default DesignerAvatar;
