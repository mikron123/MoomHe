import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { X, ImageIcon, Loader2 } from 'lucide-react';
import { useLocalization } from './localization.jsx';
import { db } from './firebase.js';
import { collection, query, orderBy, getDocs } from 'firebase/firestore';

const ReadyDesignsModal = ({ isOpen, onClose, onSelectDesign }) => {
  const [mounted, setMounted] = useState(false);
  const [categories, setCategories] = useState([]);
  const [activeCategory, setActiveCategory] = useState(null);
  const [currentDesigns, setCurrentDesigns] = useState([]);
  const [loadingCategories, setLoadingCategories] = useState(true);
  const [loadingDesigns, setLoadingDesigns] = useState(false);
  const { t, isRTL } = useLocalization();

  useEffect(() => {
    setMounted(true);
  }, []);

  // Load categories from Firestore
  useEffect(() => {
    if (!isOpen) return;
    
    async function loadCategories() {
      setLoadingCategories(true);
      try {
        const categoriesQuery = query(collection(db, 'preDesigns'), orderBy('createdAt', 'desc'));
        const snapshot = await getDocs(categoriesQuery);
        
        const cats = [];
        snapshot.forEach((doc) => {
          cats.push({ id: doc.id, ...doc.data() });
        });
        
        setCategories(cats);
        
        // Select first category by default
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
  }, [isOpen]);

  // Load designs when category changes
  useEffect(() => {
    if (!activeCategory) return;
    
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

  if (!isOpen || !mounted) return null;

  return createPortal(
    <div 
      className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[100] flex items-center justify-center p-4 animate-fade-in" 
      dir={isRTL ? 'rtl' : 'ltr'}
      onClick={(e) => e.target === e.currentTarget && onClose()}
    >
      <div className="glass-card bg-surface relative overflow-hidden w-[90vw] h-[90vh] flex flex-col">
        {/* Header with close button */}
        <div className="flex items-center justify-between p-4 border-b border-white/10">
          <h2 className="text-xl font-bold text-white">{t('readyDesigns')}</h2>
          <button 
            onClick={onClose}
            className="text-textMuted hover:text-white p-2 rounded-full hover:bg-white/10 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Category tabs - horizontal scrollable */}
        <div className="border-b border-white/10 overflow-x-auto scrollbar-hide">
          <div className="flex gap-1 p-2 min-w-max">
            {loadingCategories ? (
              <div className="flex items-center gap-2 px-4 py-2 text-gray-400">
                <Loader2 className="w-4 h-4 animate-spin" />
                <span>{t('loading') || 'טוען...'}</span>
              </div>
            ) : categories.length > 0 ? (
              categories.map((category) => (
                <button
                  key={category.id}
                  onClick={() => setActiveCategory(category.id)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-all ${
                    activeCategory === category.id
                      ? 'bg-primary-500 text-white shadow-lg'
                      : 'bg-white/5 text-gray-300 hover:bg-white/10 hover:text-white'
                  }`}
                >
                  {category.label}
                </button>
              ))
            ) : (
              <div className="px-4 py-2 text-gray-400">
                {t('noCategories') || 'אין קטגוריות'}
              </div>
            )}
          </div>
        </div>

        {/* Gallery grid */}
        <div className="flex-1 overflow-y-auto p-4">
          {loadingDesigns ? (
            <div className="flex flex-col items-center justify-center h-full text-gray-400">
              <Loader2 className="w-12 h-12 animate-spin mb-4" />
              <p>{t('loadingDesigns') || 'טוען עיצובים...'}</p>
            </div>
          ) : currentDesigns.length > 0 ? (
            <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 xl:grid-cols-8 gap-3">
              {currentDesigns.map((design) => (
                <button
                  key={design.id}
                  onClick={() => onSelectDesign && onSelectDesign({ 
                    url: design.url, 
                    thumbnail: design.urlThumb || design.url,
                    title: design.title,
                    id: design.id,
                    categoryId: activeCategory
                  })}
                  className="rounded-lg overflow-hidden bg-white/5 border border-white/10 hover:border-primary-500/50 hover:scale-[1.02] transition-all group"
                >
                  <div className="aspect-[16/9]">
                    <img 
                      src={design.urlThumb || design.url} 
                      alt={design.title}
                      className="w-full h-full object-cover"
                      loading="lazy"
                    />
                  </div>
                  <div className="p-1.5 text-center">
                    <p className="text-[10px] text-gray-300 truncate">{design.title}</p>
                  </div>
                </button>
              ))}
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center h-full text-gray-400">
              <ImageIcon className="w-16 h-16 mb-4 opacity-50" />
              <p className="text-lg">{t('noDesigns') || 'אין עיצובים'}</p>
              <p className="text-sm mt-1 opacity-70">{t('noDesignsInCategory') || 'אין עיצובים בקטגוריה זו'}</p>
            </div>
          )}
        </div>
      </div>
    </div>,
    document.body
  );
};

export default ReadyDesignsModal;
