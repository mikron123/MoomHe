import React, { useState } from 'react';
import { X, User, Crown, LogOut, LogIn, Gift, Loader2, CheckCircle, AlertCircle, Globe } from 'lucide-react';
import { useLocalization, SUPPORTED_LANGUAGES } from './localization.jsx';

const MobileMenuModal = ({ 
  isOpen, 
  onClose, 
  user, 
  userCredits, 
  userUsage,
  userSubscription,
  onLogin, 
  onLogout, 
  onSubscriptionClick,
  onRedeemCoupon,
  onCouponSuccess
}) => {
  const { t, language, setLanguage, isRTL } = useLocalization();
  const [showCouponInput, setShowCouponInput] = useState(false);
  const [showLanguageSelector, setShowLanguageSelector] = useState(false);
  const [couponCode, setCouponCode] = useState('');
  const [couponStatus, setCouponStatus] = useState(null); // 'loading' | 'success' | 'error'
  const [couponMessage, setCouponMessage] = useState('');
  
  if (!isOpen) return null;

  const isLoggedIn = user && !user.isAnonymous && user.email;
  const initial = (user?.email || 'U')[0].toUpperCase();

  const handleCouponClick = () => {
    // Reset state when opening
    setCouponStatus(null);
    setCouponMessage('');
    setCouponCode('');
    
    if (userSubscription > 0) {
      setCouponStatus('error');
      setCouponMessage(t('errorRedeemingCoupon'));
      setShowCouponInput(false);
      return;
    }
    
    setShowCouponInput(true);
  };

  const handleRedeemCoupon = async () => {
    if (!couponCode.trim()) {
      setCouponStatus('error');
      setCouponMessage(t('mustEnterCoupon'));
      return;
    }
    
    setCouponStatus('loading');
    setCouponMessage('');
    
    try {
      const result = await onRedeemCoupon(couponCode.trim());
      if (result.success) {
        // Close the menu and show success modal
        setCouponCode('');
        setShowCouponInput(false);
        setCouponStatus(null);
        setCouponMessage('');
        onClose();
        // Trigger success modal with credits info
        if (onCouponSuccess) {
          onCouponSuccess(result.creditsAdded || 0);
        }
      } else {
        setCouponStatus('error');
        setCouponMessage(result.error || t('errorRedeemingCoupon'));
      }
    } catch (error) {
      setCouponStatus('error');
      setCouponMessage(error.message || t('errorRedeemingCoupon'));
    }
  };

  const currentLanguage = SUPPORTED_LANGUAGES.find(l => l.code === language);

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4" dir={isRTL ? 'rtl' : 'ltr'}>
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/60 backdrop-blur-sm animate-fade-in"
        onClick={onClose}
      />
      
      {/* Modal Content */}
      <div className="relative w-full max-w-sm bg-[#1a1a2e] rounded-3xl overflow-hidden shadow-2xl animate-scale-up border border-white/10 max-h-[90vh] flex flex-col">
        
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900/50 to-indigo-900/50 p-6 text-center border-b border-white/5">
          <div className="w-20 h-20 mx-auto rounded-full bg-gradient-to-tr from-primary-500 to-secondary-500 p-1 mb-3 shadow-lg shadow-purple-500/20">
            <div className="w-full h-full rounded-full bg-[#1a1a2e] flex items-center justify-center text-3xl font-bold text-white">
              {isLoggedIn ? initial : <User className="w-8 h-8 text-gray-300" />}
            </div>
          </div>
          <h2 className="text-xl font-bold text-white mb-1">
            {isLoggedIn ? (user.displayName || user.email.split('@')[0]) : t('guest')}
          </h2>
          <p className="text-sm text-gray-400">
            {isLoggedIn ? user.email : t('loginToSaveDesigns')}
          </p>
        </div>

        {/* Actions - Scrollable */}
        <div className="p-6 space-y-4 overflow-y-auto flex-1">
          
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
              <div className={isRTL ? 'text-right' : 'text-left'}>
                <div className="text-white font-medium">{t('mySubscription')}</div>
                <div className="text-xs text-amber-400/80">
                  {userCredits - userUsage > 0 ? t('creditsRemaining', { count: userCredits - userUsage }) : t('upgradeToPremium')}
                </div>
              </div>
            </div>
            <div className="text-amber-400 text-lg">{isRTL ? '‹' : '›'}</div>
          </button>

          {/* Coupon Code Section */}
          <div className="space-y-3">
            {!showCouponInput ? (
              <button
                onClick={handleCouponClick}
                className="w-full flex items-center justify-between p-4 rounded-2xl bg-gradient-to-r from-emerald-500/10 to-teal-500/10 hover:from-emerald-500/20 hover:to-teal-500/20 border border-emerald-500/20 transition-all group"
              >
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-emerald-500/20 flex items-center justify-center group-hover:scale-110 transition-transform">
                    <Gift className="w-5 h-5 text-emerald-400" />
                  </div>
                  <div className={isRTL ? 'text-right' : 'text-left'}>
                    <div className="text-white font-medium">{t('iHaveCoupon')}</div>
                    <div className="text-xs text-emerald-400/80">{t('enterCouponCode')}</div>
                  </div>
                </div>
                <div className="text-emerald-400 text-lg">{isRTL ? '‹' : '›'}</div>
              </button>
            ) : (
              <div className="p-4 rounded-2xl bg-gradient-to-r from-emerald-500/10 to-teal-500/10 border border-emerald-500/20 space-y-3">
                <div className="flex items-center gap-2 text-emerald-400">
                  <Gift className="w-5 h-5" />
                  <span className="font-medium">{t('enterCouponCodeTitle')}</span>
                </div>
                <input
                  type="text"
                  value={couponCode}
                  onChange={(e) => setCouponCode(e.target.value.replace(/\s/g, '').toUpperCase())}
                  placeholder={t('couponCode')}
                  className="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-white placeholder-gray-500 focus:outline-none focus:border-emerald-500/50 text-center tracking-wider uppercase"
                  disabled={couponStatus === 'loading'}
                  autoFocus
                />
                <div className="flex gap-2">
                  <button
                    onClick={() => {
                      setShowCouponInput(false);
                      setCouponCode('');
                      setCouponStatus(null);
                      setCouponMessage('');
                    }}
                    className="flex-1 py-2.5 rounded-xl bg-white/5 hover:bg-white/10 text-gray-300 font-medium transition-colors"
                    disabled={couponStatus === 'loading'}
                  >
                    {t('cancel')}
                  </button>
                  <button
                    onClick={handleRedeemCoupon}
                    disabled={couponStatus === 'loading' || !couponCode.trim()}
                    className="flex-1 py-2.5 rounded-xl bg-emerald-500/80 hover:bg-emerald-500 text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                  >
                    {couponStatus === 'loading' ? (
                      <>
                        <Loader2 className="w-4 h-4 animate-spin" />
                        {t('processing')}
                      </>
                    ) : (
                      t('redeemCoupon')
                    )}
                  </button>
                </div>
              </div>
            )}
            
            {/* Status Message */}
            {couponStatus && couponMessage && (
              <div className={`flex items-center gap-2 p-3 rounded-xl text-sm ${
                couponStatus === 'success' 
                  ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' 
                  : couponStatus === 'error'
                  ? 'bg-red-500/20 text-red-300 border border-red-500/30'
                  : 'bg-white/10 text-gray-300'
              }`}>
                {couponStatus === 'success' ? (
                  <CheckCircle className="w-4 h-4 flex-shrink-0" />
                ) : couponStatus === 'error' ? (
                  <AlertCircle className="w-4 h-4 flex-shrink-0" />
                ) : null}
                <span>{couponMessage}</span>
              </div>
            )}
          </div>

          {/* Language Selector */}
          {!showLanguageSelector ? (
            <button
              onClick={() => setShowLanguageSelector(true)}
              className="w-full flex items-center justify-between p-4 rounded-2xl bg-gradient-to-r from-violet-500/10 to-purple-500/10 hover:from-violet-500/20 hover:to-purple-500/20 border border-violet-500/20 transition-all group"
            >
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-full bg-violet-500/20 flex items-center justify-center group-hover:scale-110 transition-transform">
                  <Globe className="w-5 h-5 text-violet-400" />
                </div>
                <div className={isRTL ? 'text-right' : 'text-left'}>
                  <div className="text-white font-medium">{t('language')}</div>
                  <div className="text-xs text-violet-400/80">{currentLanguage?.nativeName || 'English'}</div>
                </div>
              </div>
              <div className="text-violet-400 text-lg">{isRTL ? '‹' : '›'}</div>
            </button>
          ) : (
            <div className="p-4 rounded-2xl bg-gradient-to-r from-violet-500/10 to-purple-500/10 border border-violet-500/20 space-y-3">
              <div className="flex items-center justify-between text-violet-400 mb-2">
                <div className="flex items-center gap-2">
                  <Globe className="w-5 h-5" />
                  <span className="font-medium">{t('selectLanguage')}</span>
                </div>
                <button 
                  onClick={() => setShowLanguageSelector(false)}
                  className="p-1 hover:bg-white/10 rounded"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
              <div className="max-h-48 overflow-y-auto space-y-1">
                {SUPPORTED_LANGUAGES.map((lang) => (
                  <button
                    key={lang.code}
                    onClick={() => {
                      setLanguage(lang.code);
                      setShowLanguageSelector(false);
                    }}
                    className={`w-full px-3 py-2.5 rounded-xl text-sm flex items-center justify-between transition-all ${
                      language === lang.code
                        ? 'bg-violet-500/30 border border-violet-500/50'
                        : 'bg-white/5 border border-transparent hover:bg-white/10'
                    }`}
                  >
                    <span className="text-white">{lang.nativeName}</span>
                    {language === lang.code && (
                      <CheckCircle className="w-4 h-4 text-violet-400" />
                    )}
                  </button>
                ))}
              </div>
            </div>
          )}

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
              <div className={isRTL ? 'text-right' : 'text-left'}>
                <div className="text-white font-medium">
                  {isLoggedIn ? t('logout') : t('login')}
                </div>
                <div className={`text-xs ${isLoggedIn ? 'text-red-400/80' : 'text-blue-400/80'}`}>
                  {isLoggedIn ? t('exitAccount') : t('loginWithEmail')}
                </div>
              </div>
            </div>
            <div className={isLoggedIn ? 'text-red-400 text-lg' : 'text-blue-400 text-lg'}>{isRTL ? '‹' : '›'}</div>
          </button>
        </div>

        {/* Close Button */}
        <button 
          onClick={onClose}
          className={`absolute top-4 ${isRTL ? 'left-4' : 'right-4'} p-2 text-gray-400 hover:text-white transition-colors`}
        >
          <X className="w-5 h-5" />
        </button>
      </div>
    </div>
  );
};

export default MobileMenuModal;
