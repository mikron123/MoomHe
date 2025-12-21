import React from 'react';
import { X, User, Crown, LogOut, LogIn } from 'lucide-react';

const MobileMenuModal = ({ 
  isOpen, 
  onClose, 
  user, 
  userCredits, 
  userUsage, 
  onLogin, 
  onLogout, 
  onSubscriptionClick 
}) => {
  if (!isOpen) return null;

  const isLoggedIn = user && !user.isAnonymous && user.email;
  const initial = (user?.email || 'U')[0].toUpperCase();

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/60 backdrop-blur-sm animate-fade-in"
        onClick={onClose}
      />
      
      {/* Modal Content */}
      <div className="relative w-full max-w-sm bg-[#1a1a2e] rounded-3xl overflow-hidden shadow-2xl animate-scale-up border border-white/10">
        
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900/50 to-indigo-900/50 p-6 text-center border-b border-white/5">
          <div className="w-20 h-20 mx-auto rounded-full bg-gradient-to-tr from-primary-500 to-secondary-500 p-1 mb-3 shadow-lg shadow-purple-500/20">
            <div className="w-full h-full rounded-full bg-[#1a1a2e] flex items-center justify-center text-3xl font-bold text-white">
              {isLoggedIn ? initial : <User className="w-8 h-8 text-gray-300" />}
            </div>
          </div>
          <h2 className="text-xl font-bold text-white mb-1">
            {isLoggedIn ? (user.displayName || user.email.split('@')[0]) : 'אורח'}
          </h2>
          <p className="text-sm text-gray-400">
            {isLoggedIn ? user.email : 'התחבר כדי לשמור את העיצובים שלך'}
          </p>
        </div>

        {/* Actions */}
        <div className="p-6 space-y-4">
          
          {/* Subscription Button */}
          <button
            onClick={() => {
              onSubscriptionClick();
              onClose();
            }}
            className="w-full flex items-center justify-between p-4 rounded-2xl bg-gradient-to-r from-amber-500/10 to-orange-500/10 hover:from-amber-500/20 hover:to-orange-500/20 border border-amber-500/20 transition-all group"
          >
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-full bg-amber-500/20 flex items-center justify-center group-hover:scale-110 transition-transform">
                <Crown className="w-5 h-5 text-amber-400" />
              </div>
              <div className="text-right">
                <div className="text-white font-medium">המנוי שלי</div>
                <div className="text-xs text-amber-400/80">
                  {userCredits - userUsage > 0 ? `${userCredits - userUsage} קרדיטים נותרו` : 'שדרג לפרימיום'}
                </div>
              </div>
            </div>
            <div className="text-amber-400 text-lg">›</div>
          </button>

          {/* Auth Button */}
          <button
            onClick={() => {
              if (isLoggedIn) {
                onLogout();
              } else {
                onLogin();
              }
              onClose();
            }}
            className={`w-full flex items-center justify-between p-4 rounded-2xl border transition-all group ${
              isLoggedIn 
                ? 'bg-red-500/10 hover:bg-red-500/20 border-red-500/20' 
                : 'bg-blue-500/10 hover:bg-blue-500/20 border-blue-500/20'
            }`}
          >
            <div className="flex items-center gap-4">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center group-hover:scale-110 transition-transform ${
                isLoggedIn ? 'bg-red-500/20 text-red-400' : 'bg-blue-500/20 text-blue-400'
              }`}>
                {isLoggedIn ? <LogOut className="w-5 h-5" /> : <LogIn className="w-5 h-5" />}
              </div>
              <div className="text-right">
                <div className="text-white font-medium">
                  {isLoggedIn ? 'התנתק' : 'התחברות'}
                </div>
                <div className={`text-xs ${isLoggedIn ? 'text-red-400/80' : 'text-blue-400/80'}`}>
                  {isLoggedIn ? 'יציאה מהחשבון' : 'כניסה לחשבון קיים'}
                </div>
              </div>
            </div>
            <div className={isLoggedIn ? 'text-red-400 text-lg' : 'text-blue-400 text-lg'}>›</div>
          </button>
        </div>

        {/* Close Button */}
        <button 
          onClick={onClose}
          className="absolute top-4 right-4 p-2 text-gray-400 hover:text-white transition-colors"
        >
          <X className="w-5 h-5" />
        </button>
      </div>
    </div>
  );
};

export default MobileMenuModal;







