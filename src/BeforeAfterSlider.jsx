import React, { useState, useRef } from 'react';
import { ArrowLeftRight } from 'lucide-react';

const BeforeAfterSlider = ({ beforeImage, afterImage }) => {
  const [sliderPosition, setSliderPosition] = useState(50);
  const containerRef = useRef(null);
  const isDragging = useRef(false);

  const handleStart = (e) => {
    isDragging.current = true;
    updatePosition(e);
  };

  const handleEnd = () => {
    isDragging.current = false;
  };

  const updatePosition = (e) => {
    if (!containerRef.current) return;
    
    let clientX;
    if (e.touches) {
      clientX = e.touches[0].clientX;
    } else {
      clientX = e.clientX;
    }

    const rect = containerRef.current.getBoundingClientRect();
    const x = Math.max(0, Math.min(clientX - rect.left, rect.width));
    const percentage = (x / rect.width) * 100;
    setSliderPosition(percentage);
  };

  const handleMove = (e) => {
    if (!isDragging.current) return;
    updatePosition(e);
  };

  // We add touch events to container to support dragging anywhere, not just handle
  return (
    <div 
      className="relative w-full h-full select-none overflow-hidden group cursor-col-resize"
      ref={containerRef}
      onMouseDown={handleStart}
      onTouchStart={handleStart}
      onMouseMove={handleMove}
      onTouchMove={handleMove}
      onMouseUp={handleEnd}
      onMouseLeave={handleEnd}
      onTouchEnd={handleEnd}
    >
      {/* After Image (Background - Right Side) */}
      <img 
        src={afterImage} 
        alt="After" 
        className="absolute inset-0 w-full h-full object-contain pointer-events-none select-none"
        draggable={false}
      />

      {/* Before Image (Foreground - Left Side - Clipped) */}
      <div 
        className="absolute inset-0 w-full h-full pointer-events-none overflow-hidden select-none"
        style={{ clipPath: `inset(0 ${100 - sliderPosition}% 0 0)` }}
      >
        <img 
          src={beforeImage} 
          alt="Before" 
          className="absolute inset-0 w-full h-full object-contain select-none"
          draggable={false}
        />
      </div>

      {/* Slider Handle */}
      <div 
        className="absolute top-0 bottom-0 w-1 bg-white cursor-col-resize z-10 shadow-[0_0_10px_rgba(0,0,0,0.5)]"
        style={{ left: `${sliderPosition}%` }}
      >
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-lg text-primary-600 transition-transform group-hover:scale-110">
          <ArrowLeftRight size={16} />
        </div>
      </div>
      
      {/* Labels */}
      <div className="absolute bottom-4 left-4 bg-black/60 text-white px-3 py-1.5 rounded-full text-xs font-medium backdrop-blur-md pointer-events-none border border-white/10 z-20">
        לפני
      </div>
      <div className="absolute bottom-4 right-4 bg-primary-600/80 text-white px-3 py-1.5 rounded-full text-xs font-medium backdrop-blur-md pointer-events-none border border-white/10 z-20">
        אחרי
      </div>
    </div>
  );
};

export default BeforeAfterSlider;

