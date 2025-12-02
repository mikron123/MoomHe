import React, { useEffect, useState } from 'react'
import { X, ChevronLeft } from 'lucide-react'

const OnboardingOverlay = ({ step, steps, onNext, onSkip, onComplete }) => {
  const [targetRect, setTargetRect] = useState(null)
  const [windowSize, setWindowSize] = useState({ width: window.innerWidth, height: window.innerHeight })
  const [isMobile, setIsMobile] = useState(window.innerWidth < 1024)
  const currentStep = steps[step]

  useEffect(() => {
    const updateRect = () => {
      const mobile = window.innerWidth < 1024
      setIsMobile(mobile)
      setWindowSize({ width: window.innerWidth, height: window.innerHeight })
      
      if (currentStep.targetRef && currentStep.targetRef.current) {
        const rect = currentStep.targetRef.current.getBoundingClientRect()
        // Check if element is visible (has dimensions and is not hidden)
        if (rect.width > 0 && rect.height > 0) {
          setTargetRect(rect)
        } else {
          // Element is hidden, use null to trigger mobile-centered view
          setTargetRect(null)
        }
      } else {
        setTargetRect(null)
      }
    }

    updateRect()
    window.addEventListener('resize', updateRect)
    window.addEventListener('scroll', updateRect, true)
    
    const tm = setTimeout(updateRect, 500)

    return () => {
      window.removeEventListener('resize', updateRect)
      window.removeEventListener('scroll', updateRect, true)
      clearTimeout(tm)
    }
  }, [step, currentStep])

  const isLastStep = step === steps.length - 1

  // If no target rect (mobile or element hidden), show centered tooltip
  if (!targetRect) {
    return (
      <div className="fixed inset-0 z-[100]">
        {/* Dark overlay */}
        <div className="absolute inset-0 bg-black/80" onClick={onSkip} />
        
        {/* Centered Tooltip for Mobile */}
        <div className="absolute inset-0 flex items-center justify-center p-4">
          <div 
            className="bg-white text-gray-900 p-6 rounded-2xl shadow-2xl w-full max-w-[340px] animate-bounce-in"
          >
            <div className="flex justify-between items-start mb-3" dir="rtl">
              <h3 className="font-bold text-xl text-primary-600">{currentStep.title}</h3>
              <button onClick={onSkip} className="text-gray-400 hover:text-gray-600 transition-colors p-1">
                <X size={20} />
              </button>
            </div>
            
            <p className="text-sm text-gray-600 mb-6 leading-relaxed" dir="rtl">
              {currentStep.description}
            </p>

            <div className="flex justify-between items-center" dir="rtl">
              <div className="flex gap-1.5">
                {steps.map((_, i) => (
                  <div 
                    key={i} 
                    className={`h-2 rounded-full transition-all duration-300 ${i === step ? 'w-8 bg-primary-500' : 'w-2 bg-gray-200'}`}
                  />
                ))}
              </div>
              
              <button 
                onClick={isLastStep ? onComplete : onNext}
                className="bg-primary-600 hover:bg-primary-700 text-white px-6 py-2.5 rounded-xl text-sm font-medium transition-all hover:shadow-lg flex items-center gap-2"
              >
                {isLastStep ? 'סיום' : 'הבא'}
                {!isLastStep && <ChevronLeft size={16} />} 
              </button>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // Positioning logic
  const tooltipWidth = 300
  const tooltipHeight = 200 // Approximate height
  const gap = 20
  
  const tooltipStyle = {}
  let arrowClass = ''
  
  // Detect position on screen
  const isRightSidebar = targetRect.left > windowSize.width - 350
  const isLeftSidebar = targetRect.left < 350
  
  if (isRightSidebar) {
      // Place to the left of the target
      tooltipStyle.left = targetRect.left - tooltipWidth - gap
      
      // Vertically center relative to target, but keep within bounds
      let top = targetRect.top + (targetRect.height / 2) - 80 // 80 is approx half tooltip height or arrow pos
      
      // Clamp top to be visible
      top = Math.max(20, Math.min(windowSize.height - tooltipHeight - 20, top))
      
      tooltipStyle.top = top
      
      // Arrow points to the right
      arrowClass = 'top-[80px] -right-[8px] -translate-y-1/2 border-l-white border-t-transparent border-b-transparent border-r-transparent border-[8px]'
      
      // If clamped, we might need to adjust arrow pos relative to tooltip top
      // For simplicity, we assume the button isn't wildly off-center from where we clamped.
      // If we clamped hard, the arrow might detach. Let's keep it simple for now.
      
  } else if (isLeftSidebar) {
      // Place to the right
      tooltipStyle.left = targetRect.right + gap
      
      let top = targetRect.top + (targetRect.height / 2) - 80
      top = Math.max(20, Math.min(windowSize.height - tooltipHeight - 20, top))
      
      tooltipStyle.top = top
      
      arrowClass = 'top-[80px] -left-[8px] -translate-y-1/2 border-r-white border-t-transparent border-b-transparent border-l-transparent border-[8px]'
  } else {
      // Center / Bottom / Top
      // Default: Try Top
      let left = targetRect.left + (targetRect.width / 2) - (tooltipWidth / 2)
      // Clamp left
      left = Math.max(20, Math.min(windowSize.width - tooltipWidth - 20, left))
      tooltipStyle.left = left

      const spaceAbove = targetRect.top
      const spaceBelow = windowSize.height - targetRect.bottom
      
      if (spaceAbove > tooltipHeight + gap) {
          // Place Above
          tooltipStyle.top = targetRect.top - tooltipHeight + 40 // Adjust manually based on estimated height
          // Better: measure height? No, just use safe margin
           tooltipStyle.top = targetRect.top - 180 // safe guess
           arrowClass = 'bottom-[-8px] left-1/2 -translate-x-1/2 border-t-white border-r-transparent border-l-transparent border-b-transparent border-[8px]'
      } else {
          // Place Below
          tooltipStyle.top = targetRect.bottom + gap
          arrowClass = 'top-[-8px] left-1/2 -translate-x-1/2 border-b-white border-r-transparent border-l-transparent border-t-transparent border-[8px]'
      }
  }

  return (
    <div className="fixed inset-0 z-[100] pointer-events-none">
      {/* SVG Spotlight Overlay */}
      <svg className="absolute inset-0 w-full h-full pointer-events-auto">
        <defs>
          <mask id="spotlight-mask">
            <rect x="0" y="0" width="100%" height="100%" fill="white" />
            <rect 
              x={targetRect.left - 5} 
              y={targetRect.top - 5} 
              width={targetRect.width + 10} 
              height={targetRect.height + 10} 
              rx="12" 
              fill="black" 
            />
          </mask>
        </defs>
        <rect 
          x="0" 
          y="0" 
          width="100%" 
          height="100%" 
          fill="rgba(0,0,0,0.7)" 
          mask="url(#spotlight-mask)" 
        />
      </svg>

      {/* Target Highlight Ring */}
      <div 
        className="absolute border-2 border-primary-400 rounded-xl animate-pulse pointer-events-none shadow-[0_0_15px_rgba(59,130,246,0.5)]"
        style={{
          left: targetRect.left - 5,
          top: targetRect.top - 5,
          width: targetRect.width + 10,
          height: targetRect.height + 10,
        }}
      />

      {/* Tooltip */}
      <div 
        className="absolute bg-white text-gray-900 p-5 rounded-xl shadow-2xl w-[300px] pointer-events-auto animate-bounce-in origin-center transition-all duration-300"
        style={tooltipStyle}
      >
        <div className={`absolute w-0 h-0 border-solid ${arrowClass}`}></div>

        <div className="flex justify-between items-start mb-2" dir="rtl">
            <h3 className="font-bold text-lg text-primary-600">{currentStep.title}</h3>
            <button onClick={onSkip} className="text-gray-400 hover:text-gray-600 transition-colors">
                <X size={16} />
            </button>
        </div>
        
        <p className="text-sm text-gray-600 mb-5 leading-relaxed" dir="rtl">
            {currentStep.description}
        </p>

        <div className="flex justify-between items-center" dir="rtl">
            <div className="flex gap-1">
                {steps.map((_, i) => (
                    <div 
                        key={i} 
                        className={`h-1.5 rounded-full transition-all duration-300 ${i === step ? 'w-6 bg-primary-500' : 'w-1.5 bg-gray-200'}`}
                    />
                ))}
            </div>
            
            <button 
                onClick={isLastStep ? onComplete : onNext}
                className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2 rounded-lg text-sm font-medium transition-all hover:shadow-lg flex items-center gap-2"
            >
                {isLastStep ? 'סיום' : 'הבא'}
                {!isLastStep && <ChevronLeft size={16} />} 
            </button>
        </div>
      </div>
    </div>
  )
}

export default OnboardingOverlay
