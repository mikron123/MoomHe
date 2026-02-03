import React, { useEffect, useState, useCallback, useRef } from 'react';
import { createPortal } from 'react-dom';
import { X, ImageIcon, Loader2, LayoutGrid, ArrowRight } from 'lucide-react';
import { useLocalization } from './localization.jsx';
import { db } from './firebase.js';
import { collection, query, orderBy, getDocs } from 'firebase/firestore';

// Cache key prefix for localStorage
const THUMBNAIL_CACHE_PREFIX = 'moomhe_thumb_';
const CACHE_VERSION = 'v2_';

// Simple hash function for URL
const hashUrl = (url) => {
  let hash = 0;
  for (let i = 0; i < url.length; i++) {
    const char = url.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  return Math.abs(hash).toString(36);
};

// Get cached thumbnail from localStorage
const getCachedThumbnail = (url) => {
  try {
    const key = THUMBNAIL_CACHE_PREFIX + CACHE_VERSION + hashUrl(url);
    return localStorage.getItem(key);
  } catch {
    return null;
  }
};

// Save thumbnail to localStorage cache
const cacheThumbnail = (url, dataUrl) => {
  try {
    const key = THUMBNAIL_CACHE_PREFIX + CACHE_VERSION + hashUrl(url);
    localStorage.setItem(key, dataUrl);
  } catch (e) {
    console.warn('Could not cache thumbnail:', e);
  }
};

// Premium cached thumbnail component
const CachedThumbnail = ({ src, alt, className }) => {
  const [imageSrc, setImageSrc] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    if (!src) {
      setLoading(false);
      setError(true);
      return;
    }

    const cached = getCachedThumbnail(src);
    if (cached) {
      setImageSrc(cached);
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(false);

    const img = new Image();
    img.crossOrigin = 'anonymous';
    
    img.onload = () => {
      try {
        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);
        const dataUrl = canvas.toDataURL('image/jpeg', 0.8);
        
        cacheThumbnail(src, dataUrl);
        setImageSrc(dataUrl);
      } catch {
        setImageSrc(src);
      }
      setLoading(false);
    };

    img.onerror = () => {
      setImageSrc(src);
      setLoading(false);
    };

    img.src = src;
  }, [src]);

  if (loading) {
    return (
      <div className={`${className} flex items-center justify-center bg-gradient-to-br from-white/5 to-transparent`}>
        <div className="w-7 h-7 border-2 border-secondary-400/30 border-t-secondary-400 rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !imageSrc) {
    return (
      <div className={`${className} flex items-center justify-center bg-gradient-to-br from-white/5 to-transparent`}>
        <ImageIcon className="w-8 h-8 text-gray-600" />
      </div>
    );
  }

  return (
    <img 
      src={imageSrc} 
      alt={alt}
      className={className}
    />
  );
};

// Premium Design Card component
const DesignCard = ({ design, onClick }) => {
  const [isPressed, setIsPressed] = useState(false);

  return (
    <button
      onClick={onClick}
      onMouseDown={() => setIsPressed(true)}
      onMouseUp={() => setIsPressed(false)}
      onMouseLeave={() => setIsPressed(false)}
      className={`
        rounded-2xl overflow-hidden 
        bg-gradient-to-br from-white/[0.08] to-white/[0.02] 
        border transition-all duration-200 group
        ${isPressed 
          ? 'border-secondary-400/50 scale-[0.97] shadow-xl shadow-secondary-500/20' 
          : 'border-white/[0.1] hover:border-secondary-400/40 hover:shadow-xl hover:shadow-secondary-500/15 hover:scale-[1.02]'
        }
      `}
    >
      <div className="aspect-[4/3] relative overflow-hidden">
        <CachedThumbnail 
          src={design.urlThumb || design.url} 
          alt={design.title}
          className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
        />
        {/* Top shine effect */}
        <div className="absolute inset-x-0 top-0 h-16 bg-gradient-to-b from-white/10 to-transparent pointer-events-none" />
        {/* Bottom gradient overlay */}
        <div className="absolute inset-x-0 bottom-0 h-20 bg-gradient-to-t from-black/70 via-black/30 to-transparent pointer-events-none" />
        {/* Press overlay */}
        {isPressed && (
          <div className="absolute inset-0 bg-secondary-400/10 pointer-events-none" />
        )}
      </div>
      {/* Title section with glass effect */}
      <div className="p-3.5 bg-white/[0.03] backdrop-blur-sm border-t border-white/[0.08] flex items-center gap-2">
        <p className="text-sm text-white font-semibold truncate flex-1 tracking-tight">{design.title}</p>
        <div className="w-6 h-6 rounded-md bg-secondary-400/20 flex items-center justify-center flex-shrink-0">
          <ArrowRight className="w-3.5 h-3.5 text-secondary-300" />
        </div>
      </div>
    </button>
  );
};

// Helper to get localized category label
const getLocalizedCategoryLabel = (category, t) => {
  const idLower = category.id.toLowerCase().replace(/[\s-]/g, '_');
  switch (idLower) {
    case 'kitchen':
    case 'kitchens':
      return t('categoryKitchen') || category.label;
    case 'kids_bedroom':
    case 'kids_bedrooms':
    case 'kidsbedroom':
      return t('categoryKidsBedroom') || category.label;
    case 'bathroom':
    case 'bathrooms':
      return t('categoryBathroom') || category.label;
    case 'living_room':
    case 'living_rooms':
    case 'livingroom':
      return t('categoryLivingRoom') || category.label;
    case 'master_bedroom':
    case 'master_bedrooms':
    case 'masterbedroom':
      return t('categoryMasterBedroom') || category.label;
    default:
      return category.label;
  }
};

// Category chip component
const CategoryChip = ({ category, isActive, onClick, t }) => {
  const label = getLocalizedCategoryLabel(category, t);
  
  return (
    <button
      onClick={onClick}
      className={`
        px-5 py-2.5 rounded-full text-sm font-medium whitespace-nowrap 
        transition-all duration-250 ease-out
        ${isActive
          ? 'bg-gradient-to-r from-secondary-500 to-secondary-600 text-white shadow-lg shadow-secondary-500/35 border-1.5 border-secondary-400/50 scale-[1.02]'
          : 'bg-white/[0.04] text-gray-400 hover:bg-white/[0.08] hover:text-gray-200 border border-white/[0.08]'
        }
      `}
    >
      {label}
    </button>
  );
};

const ReadyDesignsModal = ({ isOpen, onClose, onSelectDesign }) => {
  const [mounted, setMounted] = useState(false);
  const [categories, setCategories] = useState([]);
  const [activeCategory, setActiveCategory] = useState(null);
  const [currentDesigns, setCurrentDesigns] = useState([]);
  const [loadingCategories, setLoadingCategories] = useState(false);
  const [loadingDesigns, setLoadingDesigns] = useState(false);
  const [hasLoadedCategories, setHasLoadedCategories] = useState(false);
  const { t, isRTL } = useLocalization();
  
  // Cache for designs by category (persistent across modal opens)
  const designsCacheRef = useRef({});
  const gridScrollRef = useRef(null);

  useEffect(() => {
    setMounted(true);
  }, []);

  // Load categories from Firestore (only once)
  useEffect(() => {
    if (hasLoadedCategories || !isOpen) return;
    
    async function loadCategories() {
      setLoadingCategories(true);
      try {
        const categoriesQuery = query(collection(db, 'preDesigns'), orderBy('createdAt', 'asc'));
        const snapshot = await getDocs(categoriesQuery);
        
        const cats = [];
        snapshot.forEach((doc) => {
          cats.push({ id: doc.id, ...doc.data() });
        });
        
        setCategories(cats);
        setHasLoadedCategories(true);
        
        if (cats.length > 0 && !activeCategory) {
          setActiveCategory(cats[0].id);
        }
      } catch (error) {
        console.error('Error loading categories:', error);
      } finally {
        setLoadingCategories(false);
      }
    }
    
    loadCategories();
  }, [isOpen, hasLoadedCategories, activeCategory]);

  // Load designs when category changes
  useEffect(() => {
    if (!activeCategory) return;
    
    // Check cache first
    if (designsCacheRef.current[activeCategory]) {
      setCurrentDesigns(designsCacheRef.current[activeCategory]);
      return;
    }
    
    async function loadDesigns() {
      setLoadingDesigns(true);
      try {
        const itemsQuery = query(
          collection(db, 'preDesigns', activeCategory, 'items'),
          orderBy('createdAt', 'desc')
        );
        const snapshot = await getDocs(itemsQuery);
        
        const designs = [];
        snapshot.forEach((doc) => {
          designs.push({ id: doc.id, ...doc.data() });
        });
        
        // Cache the results
        designsCacheRef.current[activeCategory] = designs;
        setCurrentDesigns(designs);
      } catch (error) {
        console.error('Error loading designs:', error);
        setCurrentDesigns([]);
      } finally {
        setLoadingDesigns(false);
      }
    }
    
    loadDesigns();
  }, [activeCategory]);

  if (!mounted) return null;

  // Always render the modal, but control visibility with CSS
  return createPortal(
    <div 
      className={`
        fixed inset-0 z-[100] flex items-center justify-center p-4
        transition-all duration-300 ease-out
        ${isOpen 
          ? 'opacity-100 pointer-events-auto' 
          : 'opacity-0 pointer-events-none'
        }
      `}
      dir={isRTL ? 'rtl' : 'ltr'}
    >
      {/* Backdrop */}
      <div 
        className={`
          absolute inset-0 bg-black/80 backdrop-blur-md
          transition-opacity duration-300
          ${isOpen ? 'opacity-100' : 'opacity-0'}
        `}
        onClick={onClose}
      />

      {/* Modal Container */}
      <div 
        className={`
          relative w-[92vw] max-w-6xl h-[88vh] flex flex-col
          rounded-3xl overflow-hidden
          bg-gradient-to-b from-[#1A2744] to-[#0F172A]
          shadow-2xl shadow-primary-500/10
          border border-white/[0.08]
          transition-all duration-300 ease-out
          ${isOpen 
            ? 'scale-100 translate-y-0' 
            : 'scale-95 translate-y-8'
          }
        `}
      >
        {/* Decorative background elements */}
        <div className="absolute inset-0 pointer-events-none overflow-hidden">
          {/* Top right orb */}
          <div 
            className="absolute -top-24 -right-12 w-64 h-64 rounded-full"
            style={{
              background: 'radial-gradient(circle, rgba(181,146,89,0.15) 0%, transparent 70%)'
            }}
          />
          {/* Left orb */}
          <div 
            className="absolute top-48 -left-20 w-52 h-52 rounded-full"
            style={{
              background: 'radial-gradient(circle, rgba(115,149,189,0.1) 0%, transparent 70%)'
            }}
          />
        </div>

        {/* Header */}
        <div className="relative px-6 pt-5 pb-4 border-b border-white/[0.06]">
          {/* Drag handle */}
          <div className="flex justify-center mb-4">
            <div className="w-10 h-1 rounded-full bg-white/20" />
          </div>
          
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3.5">
              {/* Icon container */}
              <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-secondary-400/20 to-secondary-600/10 border border-secondary-400/30 flex items-center justify-center">
                <LayoutGrid className="w-5 h-5 text-secondary-300" />
              </div>
              {/* Title with gradient */}
              <h2 className="text-2xl font-semibold tracking-tight bg-gradient-to-r from-white to-secondary-200 bg-clip-text text-transparent">
                {t('readyDesigns')}
              </h2>
            </div>
            
            {/* Close button */}
            <button 
              onClick={onClose}
              className="w-10 h-10 rounded-xl bg-white/[0.05] border border-white/[0.08] flex items-center justify-center text-gray-400 hover:text-white hover:bg-white/[0.1] transition-all duration-200"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Category tabs */}
        <div className="relative px-5 py-4">
          <div className="flex gap-2.5 overflow-x-auto scrollbar-hide pb-1">
            {loadingCategories ? (
              <div className="flex items-center gap-3 px-4 py-2 text-gray-400">
                <div className="w-4 h-4 border-2 border-secondary-400/30 border-t-secondary-400 rounded-full animate-spin" />
                <span className="text-sm">{t('loading') || 'Loading...'}</span>
              </div>
            ) : categories.length > 0 ? (
              categories.map((category) => (
                <CategoryChip
                  key={category.id}
                  category={category}
                  isActive={activeCategory === category.id}
                  onClick={() => {
                    setActiveCategory(category.id);
                    // Reset scroll to top when switching categories
                    if (gridScrollRef.current) {
                      gridScrollRef.current.scrollTop = 0;
                    }
                  }}
                  t={t}
                />
              ))
            ) : (
              <div className="px-4 py-2 text-gray-500 text-sm">
                {t('noCategories') || 'No categories'}
              </div>
            )}
          </div>
        </div>

        {/* Gallery grid */}
        <div 
          ref={gridScrollRef}
          className="flex-1 overflow-y-auto px-6 pb-6 scrollbar-custom"
        >
          {loadingDesigns ? (
            <div className="flex flex-col items-center justify-center h-full text-gray-400">
              {/* Premium loading state */}
              <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-secondary-400/15 to-secondary-600/8 border border-secondary-400/20 flex items-center justify-center mb-5">
                <div className="w-8 h-8 border-[2.5px] border-secondary-400/30 border-t-secondary-400 rounded-full animate-spin" />
              </div>
              <p className="text-gray-400 font-medium">{t('loadingDesigns') || 'Loading designs...'}</p>
            </div>
          ) : currentDesigns.length > 0 ? (
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
              {currentDesigns.map((design) => (
                <DesignCard
                  key={design.id}
                  design={design}
                  onClick={() => {
                    if (onSelectDesign) {
                      const category = categories.find(c => c.id === activeCategory);
                      onSelectDesign({ 
                        url: design.url, 
                        thumbnail: design.urlThumb || design.url,
                        title: design.title,
                        id: design.id,
                        categoryId: activeCategory,
                        categoryLabel: category ? getLocalizedCategoryLabel(category, t) : activeCategory
                      });
                    }
                  }}
                />
              ))}
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center h-full text-gray-400">
              {/* Empty state */}
              <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.08] flex items-center justify-center mb-5">
                <ImageIcon className="w-9 h-9 text-gray-600" />
              </div>
              <p className="text-white font-semibold text-lg mb-1.5">{t('comingSoon') || 'Coming soon...'}</p>
              <p className="text-gray-500 text-sm">{t('newDesignsWillBeAdded') || 'New designs will be added here'}</p>
            </div>
          )}
        </div>
      </div>
    </div>,
    document.body
  );
};

export default ReadyDesignsModal;
