import React, { useState } from 'react'
import { X, Check, PaintBucket } from 'lucide-react'

const ColorApplicationDialog = ({ color, onClose, onApply }) => {
  const [customTarget, setCustomTarget] = useState('')
  const [mode, setMode] = useState('all') // 'all' or 'custom'

  // Helper function to convert hex to RGB
  const hexToRgb = (hex) => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null
  }

  const handleConfirm = () => {
    const rgb = hexToRgb(color.hex)
    const rgbString = rgb ? `RGB(${rgb.r}, ${rgb.g}, ${rgb.b})` : color.hex
    
    if (mode === 'all') {
      // Send English prompt directly for better results
      onApply(`Change the color of all walls to ${color.value} (${color.ral}, ${rgbString}) completely and opaquely, covering the original color entirely`)
    } else {
      if (customTarget.trim()) {
        // Check if the custom target contains Hebrew characters
        const hasHebrew = /[\u0590-\u05FF]/.test(customTarget);
        if (hasHebrew) {
           // If Hebrew is used for the target, keep the Hebrew prompt structure but try to use English color name if possible
           onApply(`צבע את ה${customTarget} בצבע ${color.value} (${color.ral}, ${rgbString}) באופן מלא ואטום, תוך כיסוי מוחלט של הצבע המקורי`)
        } else {
           // If target is English, send full English prompt
           onApply(`Paint the ${customTarget} in ${color.value} (${color.ral}, ${rgbString}) color completely and opaquely, covering the original color entirely`)
        }
      }
    }
  }

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[80] flex items-center justify-center p-4 animate-fade-in">
      <div className="bg-surface border border-white/10 rounded-2xl w-full max-w-md overflow-hidden shadow-2xl">
        <div className="p-4 border-b border-white/10 flex justify-between items-center bg-white/5">
          <div className="flex items-center gap-3">
            <div 
              className="w-8 h-8 rounded-full border border-white/20 shadow-inner"
              style={{ backgroundColor: color.hex }}
            ></div>
            <h3 className="text-lg font-semibold text-white">שינוי צבע</h3>
          </div>
          <button onClick={onClose} className="text-textMuted hover:text-white transition-colors">
            <X size={20} />
          </button>
        </div>

        <div className="p-6 space-y-6">
          <div className="space-y-3">
            <label className="flex items-center gap-3 p-3 rounded-xl bg-white/5 border border-white/10 cursor-pointer hover:bg-white/10 transition-all">
              <input 
                type="radio" 
                name="colorMode" 
                checked={mode === 'all'}
                onChange={() => setMode('all')}
                className="w-5 h-5 text-primary-500 focus:ring-offset-0 bg-transparent border-gray-500"
              />
              <div className="flex-1">
                <span className="font-medium text-white block">כל הקירות</span>
                <span className="text-xs text-gray-400">צבע את כל הקירות בחדר</span>
              </div>
            </label>

            <label className="flex items-center gap-3 p-3 rounded-xl bg-white/5 border border-white/10 cursor-pointer hover:bg-white/10 transition-all">
              <input 
                type="radio" 
                name="colorMode" 
                checked={mode === 'custom'}
                onChange={() => setMode('custom')}
                className="w-5 h-5 text-primary-500 focus:ring-offset-0 bg-transparent border-gray-500"
              />
              <div className="flex-1">
                <span className="font-medium text-white block">אובייקט ספציפי</span>
                <span className="text-xs text-gray-400">בחר מה תרצה לצבוע</span>
              </div>
            </label>
          </div>

          {mode === 'custom' && (
            <div className="animate-slide-up">
              <label className="block text-sm text-gray-400 mb-2">מה לצבוע?</label>
              <input
                type="text"
                value={customTarget}
                onChange={(e) => setCustomTarget(e.target.value)}
                placeholder="לדוגמה: ספה, תקרה, ארון..."
                className="w-full bg-black/20 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-primary-500/50 focus:ring-1 focus:ring-primary-500/50 transition-all"
                autoFocus
              />
            </div>
          )}

          <div className="pt-2 flex justify-end gap-3">
            <button 
              onClick={onClose}
              className="px-4 py-2 rounded-xl text-sm font-medium text-gray-400 hover:text-white hover:bg-white/5 transition-all"
            >
              ביטול
            </button>
            <button 
              onClick={handleConfirm}
              disabled={mode === 'custom' && !customTarget.trim()}
              className="px-6 py-2 rounded-xl text-sm font-medium bg-primary-600 hover:bg-primary-500 text-white disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center gap-2 shadow-lg shadow-primary-900/20"
            >
              <span>אישור</span>
              <Check size={16} />
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ColorApplicationDialog

