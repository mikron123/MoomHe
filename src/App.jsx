import React, { useState, useRef, useEffect } from 'react'
import { Upload, Plus, Palette, RotateCcw, Download, Settings, Home, TreePine, Car, Heart, Hammer, Sparkles, Package, User, Share2, Wand2, Type, Loader2, RotateCw, Lightbulb, Sofa, Droplets, ArrowLeftRight, MessageCircle, HelpCircle, CheckCircle, Mail, History, MoreHorizontal, X, Power, Search, Globe, ChevronDown } from 'lucide-react'
import { 
  fileToGenerativePart, urlToFile, signInUser, createOrUpdateUser, saveImageToHistory, 
  saveUploadToHistory, loadUserHistory, loadUserHistoryPaginated, auth, uploadImageForSharing, 
  compressImage, db, getDeviceFingerprint,
  // Analytics imports
  trackSignUp, trackLogin, trackAnonymousSignIn, trackLogout, trackAccountLink,
  trackImageUpload, trackObjectImageUpload, trackImageDownload, trackImageShare,
  trackGenerationStart, trackGenerationComplete, trackGenerationError, trackLimitReached,
  trackObjectDetection, trackStyleSelect, trackColorSelect, trackAngleSelect,
  trackLightingSelect, trackFurnitureSelect, trackRepairsSelect, trackDoorsWindowsSelect,
  trackBathroomSelect, trackOnboardingStart, trackOnboardingStep, trackOnboardingComplete,
  trackOnboardingSkip, trackSubscriptionModalView, trackSubscriptionClick, trackWelcomePremiumShow,
  trackHistoryClick, trackHistoryLoadMore, trackContactFormSubmit, trackContactFormSuccess,
  trackAppOpen, trackFeatureUse
} from './firebase.js'
import { aiService } from './aiService.js'
import { onAuthStateChanged } from 'firebase/auth'
import { doc, onSnapshot, collection, setDoc } from 'firebase/firestore'
import OnboardingOverlay from './OnboardingOverlay'
import ColorApplicationDialog from './ColorApplicationDialog'
import LimitReachedModal from './LimitReachedModal'
import WelcomePremiumModal from './WelcomePremiumModal'
import BeforeAfterSlider from './BeforeAfterSlider'
import DesignerAvatar from './DesignerAvatar'
import MobileMenuModal from './MobileMenuModal'
import ReadyDesignsModal from './ReadyDesignsModal'
import { useLocalization } from './localization.jsx'

function App() {
  // Localization
  const { t, language, setLanguage, isRTL, countryCode } = useLocalization()
  // Onboarding State
  const [showOnboarding, setShowOnboarding] = useState(false)
  const [showMobileMenu, setShowMobileMenu] = useState(false)
  const [onboardingStep, setOnboardingStep] = useState(0)
  const [showNotification, setShowNotification] = useState(null)
  const [showFirstUploadTip, setShowFirstUploadTip] = useState(false)
  const [hasSeenFirstUploadTip, setHasSeenFirstUploadTip] = useState(() => {
    return localStorage.getItem('hasSeenFirstUploadTip') === 'true'
  })
  const [isMobile, setIsMobile] = useState(window.innerWidth < 1024)
  const [showMobileHistory, setShowMobileHistory] = useState(false)

  const uploadBtnDesktopRef = useRef(null)
  const uploadBtnMobileRef = useRef(null)
  const addObjectBtnDesktopRef = useRef(null)
  const addObjectBtnMobileRef = useRef(null)

  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth < 1024)
    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])
  const styleBtnRef = useRef(null)
  const styleBtnMobileRef = useRef(null)
  const createBtnRef = useRef(null)
  const createBtnMobileRef = useRef(null)
  const promptInputRef = useRef(null)
  const promptInputMobileRef = useRef(null)

  const [selectedCategory, setSelectedCategory] = useState('עיצוב פנים וחוץ') // Fixed to interior design only
  const [uploadedImage, setUploadedImage] = useState(null)
  const [mainImage, setMainImage] = useState('/assets/design_img.jpg')
  const [isProcessing, setIsProcessing] = useState(false)
  const [showColorPalette, setShowColorPalette] = useState(false)
  const [showAnglePanel, setShowAnglePanel] = useState(false)
  const [showLightingOptions, setShowLightingOptions] = useState(false)
  const [showFurnitureOptions, setShowFurnitureOptions] = useState(false)
  const [showRepairsOptions, setShowRepairsOptions] = useState(false)
  const [showStyleOptions, setShowStyleOptions] = useState(false)
  const [showDoorsWindowsOptions, setShowDoorsWindowsOptions] = useState(false)
  const [showBathroomOptions, setShowBathroomOptions] = useState(false)
  const [showMobileMoreTools, setShowMobileMoreTools] = useState(false)
  const [imageHistory, setImageHistory] = useState([])
  const [currentUser, setCurrentUser] = useState(null)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoadingHistory, setIsLoadingHistory] = useState(false)
  const [showImageModal, setShowImageModal] = useState(false)
  const [currentHistoryId, setCurrentHistoryId] = useState(null)
  const [avatarSuggestions, setAvatarSuggestions] = useState([])
  const [isAvatarThinking, setIsAvatarThinking] = useState(false)
  const [shouldAutoOpenAvatar, setShouldAutoOpenAvatar] = useState(false)
  const [isDesignerAvatarEnabled, setIsDesignerAvatarEnabled] = useState(() => {
    const saved = localStorage.getItem('designerAvatarEnabled')
    return saved === null ? true : saved === 'true' // Default to enabled
  })
  const [customPrompt, setCustomPrompt] = useState('')
  const [imageAspectRatio, setImageAspectRatio] = useState(16/9) // Default to 16:9
  const [activeColorCategory, setActiveColorCategory] = useState('reds') // Default to reds
  const [objectImage, setObjectImage] = useState(null)
  const [objectImageFile, setObjectImageFile] = useState(null)
  const [historyPage, setHistoryPage] = useState(1)
  const [hasMoreHistory, setHasMoreHistory] = useState(true)
  const [isLoadingMoreHistory, setIsLoadingMoreHistory] = useState(false)
  const [showAuthModal, setShowAuthModal] = useState(false)
  const [showLogoutModal, setShowLogoutModal] = useState(false)
  const [authMode, setAuthMode] = useState('signup') // 'login' or 'signup'
  const [email, setEmail] = useState('')
  const [confirmEmail, setConfirmEmail] = useState('')
  
  const [userCredits, setUserCredits] = useState(0)
  const [userSubscription, setUserSubscription] = useState(0)
  const [userUsage, setUserUsage] = useState(0)
  
  const subscriptionNames = {
    0: t('subscriptionFree'),
    1: t('subscriptionStarter'),
    2: t('subscriptionValue'),
    3: t('subscriptionPro')
  }
  const [password, setPassword] = useState('')
  const [isLoadingAuth, setIsLoadingAuth] = useState(false)
  const [isResettingPassword, setIsResettingPassword] = useState(false)
  const [showSuggestionsDropdown, setShowSuggestionsDropdown] = useState(false)
  const [showSuggestionsModal, setShowSuggestionsModal] = useState(false)
  const [showSubscriptionModal, setShowSubscriptionModal] = useState(false)
  const [showLoginConfirmDialog, setShowLoginConfirmDialog] = useState(false)
  const [pendingSubscription, setPendingSubscription] = useState(null)
  const [showPostPaymentModal, setShowPostPaymentModal] = useState(false)
  const [showLimitModal, setShowLimitModal] = useState(false)
  const [showWelcomePremiumModal, setShowWelcomePremiumModal] = useState(false)
  const [prevSubscription, setPrevSubscription] = useState(0)
  const [showCouponSuccessModal, setShowCouponSuccessModal] = useState(false)
  const [couponCreditsGranted, setCouponCreditsGranted] = useState(0)
  
  // Before/After Comparison
  const [beforeImage, setBeforeImage] = useState(null)
  const [showComparison, setShowComparison] = useState(false)
  const [hasConfirmedDesign, setHasConfirmedDesign] = useState(false)
  const [isNewGeneration, setIsNewGeneration] = useState(false)
  
  // Contact Form State
  const [showContactModal, setShowContactModal] = useState(false)
  const [showReadyDesignsModal, setShowReadyDesignsModal] = useState(false)
  const [contactPhone, setContactPhone] = useState('')
  const [contactEmail, setContactEmail] = useState('')
  const [contactMessage, setContactMessage] = useState('')
  const [isSubmittingContact, setIsSubmittingContact] = useState(false)
  const [showContactSuccess, setShowContactSuccess] = useState(false)
  const [contactError, setContactError] = useState('')

  // Language Selector State

  // Google Lens Selection State
  const [isGoogleLensMode, setIsGoogleLensMode] = useState(false)
  const [lensSelection, setLensSelection] = useState(null) // { startX, startY, endX, endY }
  const [isSelectingLens, setIsSelectingLens] = useState(false)
  const [isUploadingLensImage, setIsUploadingLensImage] = useState(false)
  const lensCanvasRef = useRef(null)
  const lensImageRef = useRef(null)
  const lensContainerRef = useRef(null)

  useEffect(() => {
    if (pendingSubscription && currentUser && !currentUser.isAnonymous) {
      setShowSubscriptionModal(true)
      trackSubscriptionModalView()
      setPendingSubscription(null)
    }
  }, [currentUser, pendingSubscription])

  const handleSubscriptionClick = (url) => {
    // Extract tier from URL for analytics
    const tier = url.includes('starter') ? 'starter' : url.includes('value') ? 'value' : url.includes('pro') ? 'pro' : 'unknown'
    trackSubscriptionClick(tier)
    
    // Always open the payment link regardless of login status
    hasInitiatedCheckout.current = true
    window.open(url, '_blank', 'noopener,noreferrer')
    setShowSubscriptionModal(false) // Close pricing modal
    
    // If not logged in, show post-payment modal asking to sign up
    if (!currentUser || currentUser.isAnonymous) {
      setShowPostPaymentModal(true)
    }
  }
  
  // Color Dialog State
  const [showColorDialog, setShowColorDialog] = useState(false)
  const [selectedColorForDialog, setSelectedColorForDialog] = useState(null)

  const fileInputRef = useRef(null)
  const suggestionsDropdownRef = useRef(null)
  const objectInputRef = useRef(null)
  const historyScrollRef = useRef(null)
  const isFirstSubscriptionLoad = useRef(true)
  const hasInitiatedCheckout = useRef(false)

  // App Open tracking
  useEffect(() => {
    trackAppOpen()
  }, [])

  // Onboarding Logic
  useEffect(() => {
    const hasSeenOnboarding = localStorage.getItem('hasSeenOnboarding_v2')
    if (!hasSeenOnboarding) {
      // Small delay to ensure UI is ready
      setTimeout(() => {
        setShowOnboarding(true)
        trackOnboardingStart()
      }, 1000)
    }
  }, [])

  const handleOnboardingComplete = () => {
    setShowOnboarding(false)
    localStorage.setItem('hasSeenOnboarding_v2', 'true')
    trackOnboardingComplete()
  }

  const handleOnboardingNext = () => {
    if (onboardingStep < 3) {
      const nextStep = onboardingStep + 1
      setOnboardingStep(nextStep)
      trackOnboardingStep(nextStep)
    } else {
      handleOnboardingComplete()
    }
  }
  
  const handleOnboardingSkip = () => {
    trackOnboardingSkip(onboardingStep)
    handleOnboardingComplete()
  }
  
  const openSubscriptionModal = () => {
    trackSubscriptionModalView()
    setShowSubscriptionModal(true)
  }

  const onboardingSteps = [
    {
      title: t('onboardingUploadTitle'),
      description: t('onboardingUploadDesc'),
      targetRef: isMobile ? uploadBtnMobileRef : uploadBtnDesktopRef
    },
    {
      title: t('onboardingStyleTitle'),
      description: t('onboardingStyleDesc'),
      targetRef: isMobile ? styleBtnMobileRef : styleBtnRef
    },
    {
      title: t('onboardingCreateTitle'),
      description: t('onboardingCreateDesc'),
      targetRef: isMobile ? createBtnMobileRef : createBtnRef
    },
    {
      title: t('onboardingItemTipTitle'),
      description: t('onboardingItemTipDesc'),
      targetRef: isMobile ? addObjectBtnMobileRef : addObjectBtnDesktopRef
    }
  ]


  // Authentication and history loading
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        console.log('User UID:', user.uid)
        setCurrentUser(user)
        setIsAuthenticated(true)
        
        // Create or update user record
        await createOrUpdateUser(user)
        
        // Load user history
        setIsLoadingHistory(true)
        
        try {
          const historyResult = await loadUserHistoryPaginated(user.uid, 1, 7)
          setImageHistory(historyResult.history)
          setHasMoreHistory(historyResult.hasMore)
          
          // Restore last image from history if available
          if (historyResult.history.length > 0) {
            const lastEntry = historyResult.history[0]
            const imageUrl = lastEntry.storageUrl || lastEntry.imageUrl
            if (imageUrl) {
              setMainImage(imageUrl)
              setCurrentHistoryId(lastEntry.id)
              
              // Also set before image for comparison if available
              if (lastEntry.originalImageUrl) {
                setBeforeImage(lastEntry.originalImageUrl)
              }
            }
          }
        } finally {
          setIsLoadingHistory(false)
        }
        
        // Listen to user document for credits/subscription changes
        const userDocRef = doc(db, 'users', user.uid)
        const unsubscribeUser = onSnapshot(userDocRef, (docSnapshot) => {
          if (docSnapshot.exists()) {
            const userData = docSnapshot.data()
            const newSubscription = userData.subscription !== undefined ? userData.subscription : 0
            
            // Check for upgrade: if subscription changed from 0 to > 0
            setUserSubscription(prevSub => {
              if (isFirstSubscriptionLoad.current) {
                isFirstSubscriptionLoad.current = false
                return newSubscription
              }

              // Only show modal if user actually upgraded in this session
              if (prevSub === 0 && newSubscription > 0 && hasInitiatedCheckout.current) {
                setShowWelcomePremiumModal(true)
                trackWelcomePremiumShow()
                // Reset checkout flag so we don't show it again unless they upgrade again (unlikely in same session but good hygiene)
                hasInitiatedCheckout.current = false
              }
              return newSubscription
            })
            
            setUserCredits(userData.credits !== undefined ? userData.credits : 0)
          }
        })
        
        // Listen to genCount for usage
        const now = new Date()
        const monthYear = `${String(now.getMonth() + 1).padStart(2, '0')}-${now.getFullYear()}`
        const genCountRef = doc(db, 'genCount', monthYear, 'users', user.uid)
        const unsubscribeGenCount = onSnapshot(genCountRef, (docSnapshot) => {
          if (docSnapshot.exists()) {
            setUserUsage(docSnapshot.data().count || 0)
          } else {
            setUserUsage(0)
          }
        })
        
        return () => {
          unsubscribeUser()
          unsubscribeGenCount()
        }
      } else {
        // Sign in anonymously
        try {
          const userCredential = await signInUser()
          setCurrentUser(userCredential)
          setIsAuthenticated(true)
          await createOrUpdateUser(userCredential)
          trackAnonymousSignIn()
        } catch (error) {
          console.error('Failed to sign in anonymously:', error)
        }
      }
    })

    return () => unsubscribe()
  }, [])


  // Note: Object detection is now only triggered manually via refresh button or image uploads

  const categories = [
    'עיצוב פנים וחוץ',
    'גינות ומרפסות',
    'רכבים ודו גלגלי',
    'פרופיל ותדמית',
    'איפור וטיפוח',
    'פרסום ומוצרים',
    'קעקועים',
  ]

  const categoryIcons = {
    'עיצוב פנים וחוץ': Home,
    'גינות ומרפסות': TreePine,
    'איפור וטיפוח': Sparkles,
    'פרסום ומוצרים': Package,
    'פרופיל ותדמית': User,
    'רכבים ודו גלגלי': Car,
    'קעקועים': Heart
  }

  const categoryDefaultImages = {
    'עיצוב פנים וחוץ': '/assets/design_img.jpg',
    'גינות ומרפסות': '/assets/balcony_img.jpg',
    'איפור וטיפוח': '/assets/makeup_img.jpg',
    'פרסום ומוצרים': '/assets/product_img.jpg',
    'פרופיל ותדמית': '/assets/profile_img.jpg',
    'רכבים ודו גלגלי': '/assets/car_img.jpg',
    'קעקועים': '/assets/tattoo_img.jpg'
  }

  // Interior design action buttons (localized)
  const interiorDesignButtons = [
    { name: t('readyDesigns'), action: () => setShowReadyDesignsModal(true), icon: Wand2 },
    { name: t('repairsDamages'), action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
    { name: t('changeColor'), action: () => setShowColorPalette(!showColorPalette), icon: Palette },
    { name: t('angle'), action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
    { name: t('lighting'), action: () => setShowLightingOptions(!showLightingOptions), icon: Lightbulb },
    { name: t('furniture'), action: () => setShowFurnitureOptions(!showFurnitureOptions), icon: Sofa },
    { name: t('doorsWindows'), action: () => setShowDoorsWindowsOptions(!showDoorsWindowsOptions), icon: Home },
    { name: t('bathroomShort'), action: () => setShowBathroomOptions(!showBathroomOptions), icon: Droplets }
  ]

  // Helper function to get category action buttons with localized names
  const getCategoryActionButtons = () => ({
    [t('categoryInteriorExterior')]: interiorDesignButtons,
    [t('categoryGardensBalconies')]: [
      { name: t('readyDesigns'), action: () => setShowReadyDesignsModal(true), icon: Wand2 },
      { name: t('repairsDamages'), action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: t('changeColor'), action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: t('angle'), action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: t('addPlants'), action: () => addPromptToInput("Add beautiful plants and flowers to this garden"), icon: TreePine },
      { name: t('enhanceLighting'), action: () => addPromptToInput("Enhance the outdoor lighting"), icon: Settings }
    ],
    [t('categoryVehicles')]: [
      { name: t('readyDesigns'), action: () => setShowReadyDesignsModal(true), icon: Wand2 },
      { name: t('repairsDamages'), action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: t('changeColor'), action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: t('angle'), action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: t('enhanceLighting'), action: () => addPromptToInput("Enhance the lighting and reflections on this vehicle"), icon: Settings },
      { name: t('addAccessories'), action: () => addPromptToInput("Add accessories and modifications to this vehicle"), icon: Plus }
    ],
    [t('categoryTattoos')]: [
      { name: t('readyDesigns'), action: () => setShowReadyDesignsModal(true), icon: Wand2 },
      { name: t('repairsDamages'), action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: t('changeColor'), action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: t('angle'), action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: t('enhanceLighting'), action: () => addPromptToInput("Enhance the lighting to show the tattoo details"), icon: Settings },
      { name: t('addDetails'), action: () => addPromptToInput("Add more details and shading to this tattoo"), icon: Plus }
    ],
    [t('categoryMakeupBeauty')]: [
      { name: t('readyDesigns'), action: () => setShowReadyDesignsModal(true), icon: Wand2 },
      { name: t('repairsDamages'), action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: t('changeColor'), action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: t('angle'), action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: t('enhanceLighting'), action: () => addPromptToInput("Enhance the lighting for better makeup visibility"), icon: Settings },
      { name: t('addMakeup'), action: () => addPromptToInput("Add more makeup and beauty enhancements"), icon: Sparkles }
    ],
    [t('categoryAdvertisingProducts')]: [
      { name: t('readyDesigns'), action: () => setShowReadyDesignsModal(true), icon: Wand2 },
      { name: t('repairsDamages'), action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: t('changeColor'), action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: t('angle'), action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: t('enhanceLighting'), action: () => addPromptToInput("Enhance the product lighting and presentation"), icon: Settings },
      { name: t('addDetails'), action: () => addPromptToInput("Add product details and features"), icon: Plus }
    ],
    [t('categoryProfileImage')]: [
      { name: t('readyDesigns'), action: () => setShowReadyDesignsModal(true), icon: Wand2 },
      { name: t('repairsDamages'), action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: t('changeColor'), action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: t('angle'), action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: t('enhanceLighting'), action: () => addPromptToInput("Enhance the portrait lighting"), icon: Settings },
      { name: t('addBackground'), action: () => addPromptToInput("Add a professional background"), icon: Plus }
    ]
  })
  
  const categoryActionButtons = getCategoryActionButtons()

  const handleImageUpload = async (event) => {
    const file = event.target.files[0]
    if (file) {
      // Track image upload
      const fileType = file.type || file.name.split('.').pop().toLowerCase()
      trackImageUpload(fileType)
      
      // Check if it's a HEIC file and convert it FIRST before FileReader
      const isHeicFile = file.type === 'image/heic' || file.type === 'image/heif' || file.name.toLowerCase().endsWith('.heic') || file.name.toLowerCase().endsWith('.heif')
      
      let fileToRead = file
      if (isHeicFile) {
        console.log('HEIC file detected, converting to JPEG...', { name: file.name, type: file.type, size: file.size })
        try {
          // Check if the file is already a displayable format (some systems auto-convert)
          if (file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/webp') {
            console.log('File already in displayable format, skipping HEIC conversion')
            fileToRead = file
          } else {
            // Use heic-to library for better HEIC support
            const { heicTo } = await import('heic-to')
            const convertedBlob = await heicTo({
              blob: file,
              type: 'image/jpeg',
              quality: 0.9
            })
            fileToRead = convertedBlob
            console.log('HEIC converted to JPEG successfully:', { type: fileToRead.type, size: fileToRead.size })
          }
        } catch (heicError) {
          console.error('HEIC conversion failed:', heicError)
          console.error('Error details:', heicError.message, heicError.stack)
          // Show user-friendly error with details for debugging
          alert(`Failed to convert HEIC image: ${heicError.message || 'Unknown error'}. Please try uploading a JPEG or PNG image instead.`)
          return
        }
      }
      
      const reader = new FileReader()
      reader.onload = async (e) => {
        const originalImageDataUrl = e.target.result
        
        // Compress the image (HEIC already converted above)
        let compressedImageDataUrl = originalImageDataUrl
        try {
          const compressedBlob = await compressImage(originalImageDataUrl, 1536, 0.8)
          // Convert compressed blob back to data URL for display
          const compressedReader = new FileReader()
          compressedImageDataUrl = await new Promise((resolve) => {
            compressedReader.onload = () => resolve(compressedReader.result)
            compressedReader.readAsDataURL(compressedBlob)
          })
          console.log('Image compressed for display')
        } catch (compressionError) {
          console.warn('Failed to compress image for display, using original:', compressionError)
        }
        
        setUploadedImage(compressedImageDataUrl)
        setMainImage(compressedImageDataUrl) // Display compressed image on main stage
        setBeforeImage(null) // Reset before image on new upload
        setShowComparison(false) // Reset comparison mode
        setImageAspectRatio(16/9) // Reset to default until new image loads
        setCurrentHistoryId(null) // Clear history ID for new upload
        
        // Show first upload tip if not seen before
        if (!hasSeenFirstUploadTip) {
          setTimeout(() => {
            setShowFirstUploadTip(true)
          }, 1000) // Delay to let the image load first
        }
        
        // Save to Firebase if user is authenticated
        if (isAuthenticated && currentUser) {
          setIsLoadingHistory(true)
          try {
            const uploadResult = await saveUploadToHistory(currentUser.uid, file, `Uploaded: ${file.name}`)
            
            // Use the ID from the upload result directly
            const newHistoryId = uploadResult.id
            console.log('Upload result ID:', newHistoryId)
            console.log('Upload result:', uploadResult)
            
            // Reload history from Firebase to get the updated list first
            const historyResult = await loadUserHistoryPaginated(currentUser.uid, 1, 7)
            setImageHistory(historyResult.history)
            setHistoryPage(1)
            setHasMoreHistory(historyResult.hasMore)
            
            // Set the current history ID after reloading history
            setCurrentHistoryId(newHistoryId)
            console.log('Set current history ID to newly uploaded image:', newHistoryId)
            
            // Set thinking state for avatar suggestions (only if enabled)
            if (isDesignerAvatarEnabled) {
              setIsAvatarThinking(true)
              setShouldAutoOpenAvatar(true) // Auto-open suggestions when they arrive
            }
            
            console.log('Current history after reload:', historyResult.history.map(h => ({ id: h.id, prompt: h.prompt })))
          } catch (error) {
            console.error('Failed to save upload to Firebase:', error)
          } finally {
            setIsLoadingHistory(false)
          }
        }
      }
      reader.readAsDataURL(fileToRead)
    }
  }

  const handleUploadClick = () => {
    fileInputRef.current.click()
  }

  const handleDownload = async () => {
    trackImageDownload()
    try {
      let imageUrl = mainImage
      
      // Fetch the image as a blob to force download
      const response = await fetch(imageUrl)
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      
      const link = document.createElement('a')
      link.href = url
      link.download = `moomhe-design-${Date.now()}.png`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
      
    } catch (error) {
      console.error('Download failed:', error)
      // Fallback: try to open the image in a new tab if blob fetch fails
      try {
        window.open(mainImage, '_blank')
      } catch (fallbackError) {
        console.error('Fallback download also failed:', fallbackError)
        alert('שגיאה בהורדת התמונה. נסה שוב.')
      }
    }
  }

  // Google Lens Selection Handlers
  const handleGoogleLensStart = () => {
    setIsGoogleLensMode(true)
    setLensSelection(null)
    trackFeatureUse('google_lens_start')
  }

  const handleLensMouseDown = (e) => {
    if (!isGoogleLensMode) return
    
    const rect = e.currentTarget.getBoundingClientRect()
    const x = (e.clientX || e.touches?.[0]?.clientX) - rect.left
    const y = (e.clientY || e.touches?.[0]?.clientY) - rect.top
    
    setIsSelectingLens(true)
    setLensSelection({ startX: x, startY: y, endX: x, endY: y })
  }

  const handleLensMouseMove = (e) => {
    if (!isSelectingLens || !isGoogleLensMode) return
    
    const rect = e.currentTarget.getBoundingClientRect()
    const x = Math.max(0, Math.min((e.clientX || e.touches?.[0]?.clientX) - rect.left, rect.width))
    const y = Math.max(0, Math.min((e.clientY || e.touches?.[0]?.clientY) - rect.top, rect.height))
    
    setLensSelection(prev => prev ? { ...prev, endX: x, endY: y } : null)
  }

  const handleLensMouseUp = async () => {
    if (!isSelectingLens || !lensSelection) return
    setIsSelectingLens(false)
    
    // Check if selection is valid (minimum size)
    const width = Math.abs(lensSelection.endX - lensSelection.startX)
    const height = Math.abs(lensSelection.endY - lensSelection.startY)
    
    if (width < 20 || height < 20) {
      setLensSelection(null)
      return
    }
    
    // Selection is valid, now crop and search
    await cropAndSearchGoogleLens()
  }

  const cropAndSearchGoogleLens = async () => {
    if (!lensSelection || !lensImageRef.current || !lensContainerRef.current) return
    
    setIsUploadingLensImage(true)
    trackFeatureUse('google_lens_search')
    
    try {
      const img = lensImageRef.current
      const container = lensContainerRef.current
      const containerRect = container.getBoundingClientRect()
      const imgRect = img.getBoundingClientRect()
      
      // Use the actual image rect to get real displayed position and size
      const displayedWidth = imgRect.width
      const displayedHeight = imgRect.height
      
      // Calculate offset of the image within the container
      const offsetX = imgRect.left - containerRect.left
      const offsetY = imgRect.top - containerRect.top
      
      // Calculate scale factors from displayed size to natural size
      const scaleX = img.naturalWidth / displayedWidth
      const scaleY = img.naturalHeight / displayedHeight
      
      // Get selection bounds in container coordinates
      const minX = Math.min(lensSelection.startX, lensSelection.endX)
      const minY = Math.min(lensSelection.startY, lensSelection.endY)
      const selWidth = Math.abs(lensSelection.endX - lensSelection.startX)
      const selHeight = Math.abs(lensSelection.endY - lensSelection.startY)
      
      // Convert selection from container coordinates to image coordinates
      // Subtract the image offset within the container
      const imgRelativeX = minX - offsetX
      const imgRelativeY = minY - offsetY
      
      // Scale to natural image pixels
      const cropX = Math.max(0, imgRelativeX * scaleX)
      const cropY = Math.max(0, imgRelativeY * scaleY)
      const cropWidth = Math.min(selWidth * scaleX, img.naturalWidth - cropX)
      const cropHeight = Math.min(selHeight * scaleY, img.naturalHeight - cropY)
      
      // Ensure we have valid crop dimensions
      if (cropWidth <= 0 || cropHeight <= 0) {
        alert('בחר אזור בתוך התמונה')
        setIsUploadingLensImage(false)
        return
      }
      
      // Fetch the image as blob to avoid CORS issues with canvas
      // This is necessary for images from Firebase Storage after generation
      const imageBlob = await fetch(mainImage).then(r => r.blob())
      const imageBitmap = await createImageBitmap(imageBlob)
      
      // Create canvas and crop
      const canvas = document.createElement('canvas')
      canvas.width = Math.max(1, Math.round(cropWidth))
      canvas.height = Math.max(1, Math.round(cropHeight))
      const ctx = canvas.getContext('2d')
      
      // Draw cropped region from the fetched bitmap (CORS-safe)
      ctx.drawImage(
        imageBitmap,
        Math.round(cropX), Math.round(cropY), Math.round(cropWidth), Math.round(cropHeight),
        0, 0, canvas.width, canvas.height
      )
      
      // Upload to Firebase Storage
      const { downloadURL } = await uploadImageForSharing(currentUser?.uid || 'anonymous', canvas.toDataURL('image/jpeg', 0.9))
      
      // Open Google Lens in a new tab (can't embed due to X-Frame-Options)
      const lensUrl = `https://lens.google.com/uploadbyurl?url=${encodeURIComponent(downloadURL)}`
      window.open(lensUrl, '_blank', 'noopener,noreferrer')
      
      // Reset selection state
      setIsGoogleLensMode(false)
      setLensSelection(null)
      
    } catch (error) {
      console.error('Google Lens search failed:', error)
      alert('שגיאה בחיפוש. נסה שוב.')
    } finally {
      setIsUploadingLensImage(false)
    }
  }

  const cancelGoogleLens = () => {
    setIsGoogleLensMode(false)
    setLensSelection(null)
    setIsSelectingLens(false)
  }

  // Listen for suggestions on current uploaded image
  useEffect(() => {
    if (!currentHistoryId || !isDesignerAvatarEnabled) {
      setAvatarSuggestions([])
      setIsAvatarThinking(false)
      return
    }
    
    const unsubscribe = onSnapshot(doc(db, 'userHistory', currentHistoryId), (docSnapshot) => {
      if (docSnapshot.exists()) {
        const data = docSnapshot.data()
        // Only show if we have suggestions and avatar is enabled
        if (isDesignerAvatarEnabled && data.suggestions && Array.isArray(data.suggestions) && data.suggestions.length > 0) {
          setAvatarSuggestions(data.suggestions)
          setIsAvatarThinking(false)
        }
      }
    })
    
    return () => unsubscribe()
  }, [currentHistoryId, isDesignerAvatarEnabled])

  const handleAvatarSuggestionSelect = (suggestion) => {
    const prompt = suggestion.prompt
    setCustomPrompt(prompt)
    handleAIEdit(prompt)
    
    // Clear the input field after execution (setCustomPrompt updates the state used by input, so setting it empty effectively clears it, 
    // BUT handleAIEdit uses the passed prompt argument, so we can clear customPrompt state immediately or after a short delay)
    // However, handleAIEdit is async. We might want to clear it after initiation.
    // Wait, handleAIEdit uses `mainImage`. It doesn't use `customPrompt` directly if passed as arg.
    // So clearing `customPrompt` here is fine for the UI.
    setTimeout(() => setCustomPrompt(''), 100)
    
    // Don't clear suggestions - keep them available for other choices
    // setAvatarSuggestions([]) <-- removed this line to keep suggestions visible
  }

  const toggleDesignerAvatar = () => {
    const newValue = !isDesignerAvatarEnabled
    setIsDesignerAvatarEnabled(newValue)
    localStorage.setItem('designerAvatarEnabled', newValue.toString())
    // If disabling, clear current suggestions
    if (!newValue) {
      setAvatarSuggestions([])
      setIsAvatarThinking(false)
    }
  }

  const handleWhatsAppShare = async () => {
    trackImageShare('whatsapp')
    try {
      let imageUrl = mainImage
      
      // Check if we're on mobile
      const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
      
      // Handle data URLs (base64) - upload to temporary Firebase Storage
      if (imageUrl.startsWith('data:')) {
        try {
          // Show loading state
          setIsProcessing(true)
          
          // Upload to temporary Firebase Storage
          const { downloadURL } = await uploadImageForSharing(currentUser?.uid || 'anonymous', imageUrl)
          imageUrl = downloadURL
          
          console.log('📤 Image uploaded to temporary storage:', downloadURL)
        } catch (error) {
          console.error('Error uploading image to Firebase:', error)
          alert('שגיאה בהעלאת התמונה. נסה שוב.')
          return
        } finally {
          setIsProcessing(false)
        }
      }
      
      // Now share the image URL (either original or temporary Firebase URL)
      if (isMobile) {
        // On mobile, open WhatsApp with the image URL
        const whatsappUrl = `whatsapp://send?text=צפה בעיצוב שיצרתי עם MoomHe: ${encodeURIComponent(imageUrl)}`
        window.open(whatsappUrl, '_blank')
      } else {
        // On desktop/web, open WhatsApp Web with the image URL
        const whatsappWebUrl = `https://web.whatsapp.com/send?text=צפה בעיצוב שיצרתי עם MoomHe: ${encodeURIComponent(imageUrl)}`
        window.open(whatsappWebUrl, '_blank')
      }
    } catch (error) {
      console.error('WhatsApp share failed:', error)
      alert('שגיאה בשיתוף לוואטסאפ. נסה שוב.')
    }
  }

  // Contact Form Submit Handler
  const handleContactSubmit = async () => {
    // Validate that at least email or phone is provided
    if (!contactEmail.trim() && !contactPhone.trim()) {
      setContactError('נא להזין לפחות אימייל או טלפון')
      return
    }
    
    // Validate email format if provided
    if (contactEmail.trim() && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(contactEmail)) {
      setContactError('נא להזין כתובת אימייל תקינה')
      return
    }
    
    // Validate message is provided
    if (!contactMessage.trim()) {
      setContactError('נא להזין הודעה')
      return
    }
    
    setContactError('')
    setIsSubmittingContact(true)
    trackContactFormSubmit()
    
    try {
      const messageId = `msg_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`
      const messageData = {
        id: messageId,
        uid: currentUser?.uid || 'anonymous',
        email: contactEmail.trim() || null,
        phone: contactPhone.trim() || null,
        message: contactMessage.trim(),
        createdAt: new Date(),
        userEmail: currentUser?.email || null,
        isAnonymous: currentUser?.isAnonymous || true
      }

      // Submit to Formspree
      let formspreeError = null
      try {
        const formspreeResponse = await fetch('https://formspree.io/f/xkgdpbjg', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            email: contactEmail.trim() || null,
            phone: contactPhone.trim() || null,
            message: contactMessage.trim()
          })
        })
        
        if (!formspreeResponse.ok) {
          const errorText = await formspreeResponse.text()
          formspreeError = `HTTP ${formspreeResponse.status}: ${errorText}`
          console.error('Formspree error:', formspreeError)
        }
      } catch (err) {
        formspreeError = `Network error: ${err.message}`
        console.error('Formspree network error:', err)
      }

      await setDoc(doc(db, 'supportMsgs', messageId), {
        ...messageData,
        formspreeError: formspreeError
      })
      
      // Clear form and show success
      setContactPhone('')
      setContactEmail('')
      setContactMessage('')
      setShowContactModal(false)
      setShowContactSuccess(true)
      trackContactFormSuccess()
      
      // Auto-hide success message after 5 seconds
      setTimeout(() => setShowContactSuccess(false), 5000)
      
    } catch (error) {
      console.error('Error submitting contact form:', error)
      setContactError('שגיאה בשליחת ההודעה. נסה שוב.')
    } finally {
      setIsSubmittingContact(false)
    }
  }


  const handleGalleryImageClick = (imageUrl) => {
    setMainImage(imageUrl)
    setImageAspectRatio(16/9) // Reset to default until new image loads
    setCurrentHistoryId(null) // Clear history ID for gallery image
    // Clear objects when selecting gallery image
    setDetectedObjects([])
    // Don't auto-open avatar for gallery images
    setShouldAutoOpenAvatar(false)
  }

  const handleHistoryImageClick = (historyEntry) => {
    trackHistoryClick()
    // Use storageUrl if available (from Firebase), otherwise use imageUrl (local)
    const imageUrl = historyEntry.storageUrl || historyEntry.imageUrl
    setMainImage(imageUrl)
    
    // Check if we have an originalImageUrl to enable comparison
    if (historyEntry.originalImageUrl) {
      setBeforeImage(historyEntry.originalImageUrl)
      // Optional: Auto-enable comparison or just make button available
      setShowComparison(false) 
    } else {
      setBeforeImage(null)
      setShowComparison(false)
    }
    
    setImageAspectRatio(16/9) // Reset to default until new image loads
    setCurrentHistoryId(historyEntry.id)
    
    // Don't auto-open avatar suggestions when navigating history
    // Only auto-open for newly uploaded images
    setShouldAutoOpenAvatar(false)
  }


  const handleMainImageClick = () => {
    if (!isProcessing) {
      setShowImageModal(true)
      // Enable comparison by default when opening modal
      if (beforeImage) {
        setShowComparison(true)
      }
      // When opening from click (not fresh generation), skip confirmation
      setIsNewGeneration(false)
      setHasConfirmedDesign(true)
    }
  }

  const handleCloseModal = () => {
    setShowImageModal(false)
    setShowComparison(false)
    setIsNewGeneration(false)
    setHasConfirmedDesign(false)
    // Reset Google Lens state
    setIsGoogleLensMode(false)
    setLensSelection(null)
    setIsSelectingLens(false)
  }

  // Handle reverting to original image
  const handleRevertToOriginal = () => {
    if (beforeImage) {
      setMainImage(beforeImage)
      setBeforeImage(null)
    }
    handleCloseModal()
  }

  // Handle confirming the new design
  const handleConfirmDesign = () => {
    setHasConfirmedDesign(true)
  }

  const handleImageLoad = (event) => {
    const img = event.target
    const aspectRatio = img.naturalWidth / img.naturalHeight
    setImageAspectRatio(aspectRatio)
  }

  const handleObjectImageUpload = async (event) => {
    const file = event.target.files[0]
    if (file) {
      trackObjectImageUpload()
      
      // Check if it's a HEIC file and convert it FIRST
      const isHeicFile = file.type === 'image/heic' || file.type === 'image/heif' || file.name.toLowerCase().endsWith('.heic') || file.name.toLowerCase().endsWith('.heif')
      
      let fileToRead = file
      if (isHeicFile) {
        console.log('HEIC object image detected, converting to JPEG...', { name: file.name, type: file.type, size: file.size })
        try {
          // Check if the file is already a displayable format (some systems auto-convert)
          if (file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/webp') {
            console.log('File already in displayable format, skipping HEIC conversion')
            fileToRead = file
          } else {
            // Use heic-to library for better HEIC support
            const { heicTo } = await import('heic-to')
            const convertedBlob = await heicTo({
              blob: file,
              type: 'image/jpeg',
              quality: 0.9
            })
            fileToRead = convertedBlob
            console.log('HEIC object image converted to JPEG successfully')
          }
        } catch (heicError) {
          console.error('HEIC conversion failed:', heicError)
          alert(`Failed to convert HEIC image: ${heicError.message || 'Unknown error'}. Please try uploading a JPEG or PNG image instead.`)
          return
        }
      }
      
      const reader = new FileReader()
      reader.onload = (e) => {
        // Resize image if needed
        const img = new Image()
        img.onload = () => {
          const canvas = document.createElement('canvas')
          let width = img.width
          let height = img.height
          const maxDimension = 1200

          if (width > maxDimension || height > maxDimension) {
            if (width > height) {
              height = Math.round((height * maxDimension) / width)
              width = maxDimension
            } else {
              width = Math.round((width * maxDimension) / height)
              height = maxDimension
            }
          }

          canvas.width = width
          canvas.height = height
          const ctx = canvas.getContext('2d')
          ctx.drawImage(img, 0, 0, width, height)

          const resizedDataUrl = canvas.toDataURL('image/jpeg', 0.9)
          setObjectImage(resizedDataUrl)
          
          // Create file from resized data URL
          fetch(resizedDataUrl)
            .then(res => res.blob())
            .then(blob => {
              const resizedFile = new File([blob], file.name, { type: 'image/jpeg' })
              setObjectImageFile(resizedFile)
            })
        }
        img.src = e.target.result

        showToast('תמונת אובייקט נטענה! תאר בשורת הפרומפט איפה להוסיף אותו.')
        
        // Add default prompt if input is empty or append it
        const defaultPrompt = "הוסף את הפריט המצורף לתמונה"
        const currentPrompt = customPrompt.trim()
        if (!currentPrompt) {
          setCustomPrompt(defaultPrompt)
        } else if (!currentPrompt.includes(defaultPrompt)) {
          setCustomPrompt(`${currentPrompt} ${defaultPrompt}`)
        }
      }
      reader.readAsDataURL(fileToRead)
    }
  }

  const handleObjectUploadClick = () => {
    objectInputRef.current.click()
  }

  const handleRemoveObjectImage = () => {
    setObjectImage(null)
    setObjectImageFile(null)
    if (objectInputRef.current) {
      objectInputRef.current.value = ''
    }
  }

  const handleAuthSubmit = async (e) => {
    e.preventDefault()
    if (!email || !password) return
    
    // Validate password confirmation for signup
    if (authMode === 'signup' && password !== confirmEmail) {
      alert('הסיסמאות אינן תואמות. נסה שוב.')
      return
    }
    
    setIsLoadingAuth(true)
    try {
      if (authMode === 'signup') {
        // Check if user is currently anonymous
        const isAnonymous = currentUser && currentUser.isAnonymous
        
        if (isAnonymous) {
          // Link anonymous account to email/password account
          const { linkWithCredential, EmailAuthProvider } = await import('firebase/auth')
          const credential = EmailAuthProvider.credential(email, password)
          
          try {
            // Try to link the anonymous account
            const userCredential = await linkWithCredential(currentUser, credential)
            await createOrUpdateUser(userCredential.user)
            trackAccountLink(true)
            trackSignUp('email_link')
            alert('החשבון נוצר בהצלחה! כל הנתונים שלך נשמרו.')
          } catch (linkError) {
            trackAccountLink(false)
            if (linkError.code === 'auth/email-already-in-use') {
              // Email already exists, create new account and migrate data
              const { createUserWithEmailAndPassword } = await import('firebase/auth')
              const newUserCredential = await createUserWithEmailAndPassword(auth, email, password)
              
              // Migrate data from anonymous user to new user
              await migrateUserData(currentUser.uid, newUserCredential.user.uid)
              
              await createOrUpdateUser(newUserCredential.user)
              trackSignUp('email_migrate')
              alert('החשבון נוצר בהצלחה! כל הנתונים שלך הועברו לחשבון החדש.')
            } else {
              throw linkError
            }
          }
        } else {
          // Create new account normally
          const { createUserWithEmailAndPassword } = await import('firebase/auth')
          const userCredential = await createUserWithEmailAndPassword(auth, email, password)
          await createOrUpdateUser(userCredential.user)
          trackSignUp('email')
          alert('החשבון נוצר בהצלחה!')
        }
      } else {
        // Sign in existing user
        const { signInWithEmailAndPassword } = await import('firebase/auth')
        const userCredential = await signInWithEmailAndPassword(auth, email, password)
        await createOrUpdateUser(userCredential.user)
        trackLogin('email')
        alert('התחברת בהצלחה!')
      }
      
      // Close modal and reset form
      setShowAuthModal(false)
      setEmail('')
      setConfirmEmail('')
      setPassword('')
      setAuthMode('signup')
    } catch (error) {
      console.error('Authentication error:', error)
      if (error.code === 'auth/email-already-in-use') {
        alert('כתובת האימייל כבר בשימוש. נסה להתחבר במקום.')
        setAuthMode('login')
      } else if (error.code === 'auth/user-not-found') {
        alert('משתמש לא נמצא. נסה ליצור חשבון חדש.')
        setAuthMode('signup')
      } else if (error.code === 'auth/wrong-password') {
        alert('סיסמה שגויה. נסה שוב.')
      } else if (error.code === 'auth/weak-password') {
        alert('הסיסמה חלשה מדי. השתמש בסיסמה של לפחות 6 תווים.')
      } else {
        alert('שגיאה בהתחברות. נסה שוב.')
      }
    } finally {
      setIsLoadingAuth(false)
    }
  }

  const handleAuth = (e) => {
    e.preventDefault()
    handleAuthSubmit(e)
  }

  const handlePasswordReset = async () => {
    if (!email) {
      alert('אנא הזן כתובת אימייל תחילה.')
      return
    }
    
    setIsResettingPassword(true)
    try {
      const { sendPasswordResetEmail } = await import('firebase/auth')
      await sendPasswordResetEmail(auth, email)
      alert('נשלח אימייל לאיפוס סיסמה לכתובת שלך.')
    } catch (error) {
      console.error('Password reset error:', error)
      if (error.code === 'auth/user-not-found') {
        alert('כתובת האימייל לא נמצאה במערכת.')
      } else {
        alert('שגיאה בשליחת אימייל איפוס. נסה שוב.')
      }
    } finally {
      setIsResettingPassword(false)
    }
  }

  const migrateUserData = async (fromUid, toUid) => {
    try {
      // Import Firestore functions
      const { collection, query, where, getDocs, doc, setDoc, deleteDoc } = await import('firebase/firestore')
      const { db } = await import('./firebase.js')
      
      // Migrate user history
      const historyRef = collection(db, 'userHistory')
      const historyQuery = query(historyRef, where('userId', '==', fromUid))
      const historySnapshot = await getDocs(historyQuery)
      
      const historyPromises = []
      historySnapshot.forEach((docSnapshot) => {
        const data = docSnapshot.data()
        // Update userId to new UID
        data.userId = toUid
        // Create new document with new UID
        const newDocRef = doc(collection(db, 'userHistory'))
        historyPromises.push(setDoc(newDocRef, data))
        // Delete old document
        historyPromises.push(deleteDoc(docSnapshot.ref))
      })
      
      await Promise.all(historyPromises)
      console.log(`Migrated ${historySnapshot.size} history entries from ${fromUid} to ${toUid}`)
      
      // Reload user history after migration
      if (isAuthenticated) {
        const historyResult = await loadUserHistoryPaginated(toUid, 1, 7)
        setImageHistory(historyResult.history)
        setHistoryPage(1)
        setHasMoreHistory(historyResult.hasMore)
      }
      
    } catch (error) {
      console.error('Error migrating user data:', error)
      // Don't throw error to prevent blocking the auth flow
      // User will still get their account, just without migrated data
    }
  }

  const handleLogout = async () => {
    try {
      trackLogout()
      const { signOut } = await import('firebase/auth')
      await signOut(auth)
      // Clear local state
      setImageHistory([])
      setCurrentUser(null)
      setIsAuthenticated(false)
      setShowLogoutModal(false)
      // Refresh the page to reset the app state
      window.location.reload()
    } catch (error) {
      console.error('Logout error:', error)
      alert('שגיאה בהתנתקות. נסה שוב.')
    }
  }

  const handleRedeemCoupon = async (couponCode) => {
    try {
      // Get auth token (works for both anonymous and logged-in users)
      const authToken = await currentUser.getIdToken()
      
      // Get device fingerprint
      const deviceId = await getDeviceFingerprint()
      
      // Call the Cloud Function
      const response = await fetch('https://us-central1-moomhe-6de30.cloudfunctions.net/redeemCoupon', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          couponCode: couponCode,
          authToken: authToken,
          deviceId: deviceId
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        // Track successful coupon redemption
        trackFeatureUse('coupon_redeemed', couponCode)
      }
      
      return result
    } catch (error) {
      console.error('Coupon redemption error:', error)
      return { success: false, error: 'שגיאה במימוש הקופון. נסה שוב.' }
    }
  }

  const loadMoreHistory = async () => {
    if (!isAuthenticated || !currentUser || isLoadingMoreHistory || !hasMoreHistory) {
      console.log('Load more history blocked:', { isAuthenticated, currentUser: !!currentUser, isLoadingMoreHistory, hasMoreHistory })
      return
    }
    
    console.log('Loading more history, current page:', historyPage)
    setIsLoadingMoreHistory(true)
    try {
      const nextPage = historyPage + 1
      trackHistoryLoadMore(nextPage)
      const result = await loadUserHistoryPaginated(currentUser.uid, nextPage, 7)
      
      console.log('Load more result:', { nextPage, historyCount: result.history.length, hasMore: result.hasMore })
      
      if (result.history.length > 0) {
        setImageHistory(prev => [...prev, ...result.history])
        setHistoryPage(nextPage)
        setHasMoreHistory(result.hasMore)
      } else {
        setHasMoreHistory(false)
      }
    } catch (error) {
      console.error('Failed to load more history:', error)
    } finally {
      setIsLoadingMoreHistory(false)
    }
  }

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (showSuggestionsDropdown && suggestionsDropdownRef.current && !suggestionsDropdownRef.current.contains(event.target)) {
        setShowSuggestionsDropdown(false)
      }
      if (showSuggestionsModal && !event.target.closest('.suggestions-modal')) {
        setShowSuggestionsModal(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [showSuggestionsDropdown, showSuggestionsModal])

  const formatTimestamp = (date) => {
    const day = String(date.getDate()).padStart(2, '0')
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const year = String(date.getFullYear()).slice(-2)
    return `${day}/${month}/${year}`
  }

  const getRelativeTime = (date) => {
    const now = new Date()
    const diffInSeconds = Math.floor((now - date) / 1000)
    
    if (diffInSeconds < 60) {
      return 'לפני רגע'
    } else if (diffInSeconds < 3600) {
      const minutes = Math.floor(diffInSeconds / 60)
      return `לפני ${minutes} דקות`
    } else if (diffInSeconds < 86400) {
      const hours = Math.floor(diffInSeconds / 3600)
      return `לפני ${hours} שעות`
    } else if (diffInSeconds < 172800) {
      return 'אתמול'
    } else if (diffInSeconds < 604800) {
      const days = Math.floor(diffInSeconds / 86400)
      return `לפני ${days} ימים`
    } else if (diffInSeconds < 2592000) {
      const weeks = Math.floor(diffInSeconds / 604800)
      return `לפני ${weeks} שבועות`
    } else if (diffInSeconds < 31536000) {
      const months = Math.floor(diffInSeconds / 2592000)
      return `לפני ${months} חודשים`
    } else {
      const years = Math.floor(diffInSeconds / 31536000)
      return `לפני ${years} שנים`
    }
  }

  const displayTimestamp = (entry) => {
    // Use createdAt as the primary timestamp field
    const timestamp = entry.createdAt
    
    // If no createdAt found, return fallback
    if (!timestamp) {
      return 'תאריך לא זמין'
    }
    
    // If it's already in dd/mm/yy format, return as is
    if (/^\d{2}\/\d{2}\/\d{2}$/.test(timestamp)) {
      return timestamp
    }
    
    // Try to parse the timestamp
    try {
      let date
      
      // Handle Firestore Timestamp objects
      if (timestamp && typeof timestamp === 'object' && timestamp.toDate) {
        date = timestamp.toDate()
      } else if (timestamp && typeof timestamp === 'object' && timestamp.seconds) {
        // Handle Firestore Timestamp with seconds property
        date = new Date(timestamp.seconds * 1000)
      } else {
        // Handle string timestamps
        date = new Date(timestamp)
      }
      
      if (!isNaN(date.getTime())) {
        return getRelativeTime(date)
      }
    } catch (error) {
      console.warn('Failed to parse timestamp:', timestamp, error)
    }
    
    // Fallback: return original timestamp or fallback message
    return timestamp || 'תאריך לא זמין'
  }

  const handleObjectSelect = (object) => {
    addPromptToInput(object)
  }

  const handleCustomPromptSubmit = async () => {
    if (!customPrompt.trim()) return
    
      // Check if user can make requests
      if (isAuthenticated && currentUser) {
        const canMakeRequest = await aiService.canMakeRequest(currentUser.uid)
        if (!canMakeRequest) {
          trackLimitReached(userSubscription, userUsage, userCredits)
          setShowLimitModal(true)
          return
        }
      }
      
      setIsProcessing(true)
    try {
      // For now, we'll use the prompt as-is (translation can be handled server-side)
      const finalPrompt = customPrompt
      
      // If object image is available, modify prompt to include it
      let promptWithObject = finalPrompt
      if (objectImageFile) {
        promptWithObject = `השתמש בתמונות שצורפו, ${finalPrompt}`
      }
      
      console.log('🎯 Final prompt for AI:', promptWithObject)
      
      // Execute the AI edit using server-side processing
      await handleAIEdit(promptWithObject)
      
      // Clear the input
      setCustomPrompt('')
      
      // Clear object image after processing
      setObjectImage(null)
      setObjectImageFile(null)
      if (objectInputRef.current) {
        objectInputRef.current.value = ''
      }
    } catch (error) {
      console.error('Custom prompt failed:', error)
      if (error.message && (error.message.includes('limit reached') || error.message.includes('credits'))) {
        setShowLimitModal(true)
      } else {
        alert('שגיאה בעיבוד הבקשה. נסה שוב.')
      }
    } finally {
      setIsProcessing(false)
    }
  }

  // Handle preset design generation (from ReadyDesignsModal)
  const handlePresetDesignGeneration = async (prompt, presetImageFile) => {
    // Check if user can make requests
    if (isAuthenticated && currentUser) {
      const canMakeRequest = await aiService.canMakeRequest(currentUser.uid)
      if (!canMakeRequest) {
        trackLimitReached(userSubscription, userUsage, userCredits)
        setShowLimitModal(true)
        setIsProcessing(false)
        return
      }
    }
    
    try {
      console.log('🎨 Preset Design Generation - Prompt:', prompt)
      console.log('📸 Main image URL:', mainImage)
      console.log('🖼️ Preset design image:', presetImageFile?.name)
      
      // Save current image as 'Before' image for comparison
      setBeforeImage(mainImage)
      
      // Process preset image for AI
      const objectImageData = await fileToGenerativePart(presetImageFile)
      console.log('🖼️ Preset image processed successfully')
      
      // Get device fingerprint
      const deviceId = await getDeviceFingerprint()
      
      // Get the image data for the server
      let imageDataForServer = mainImage
      if (mainImage.startsWith('blob:')) {
        const response = await fetch(mainImage)
        const blob = await response.blob()
        imageDataForServer = await new Promise((resolve) => {
          const reader = new FileReader()
          reader.onloadend = () => resolve(reader.result)
          reader.readAsDataURL(blob)
        })
      }
      
      // Call the AI service
      const result = await aiService.processImageWithPrompt(
        currentUser, 
        prompt, 
        imageDataForServer, 
        objectImageData,
        deviceId
      )
      
      if (result.success && result.imageUrl) {
        const imageDataUrl = result.imageUrl.startsWith('data:') 
          ? result.imageUrl 
          : `data:image/png;base64,${result.imageUrl}`
        
        setMainImage(imageDataUrl)
        setImageAspectRatio(16/9)
        setCurrentHistoryId(null)
        
        // Clear object image after successful processing
        setObjectImage(null)
        setObjectImageFile(null)
        if (objectInputRef.current) {
          objectInputRef.current.value = ''
        }
        
        setCustomPrompt('')
        showToast('העיצוב הוחל בהצלחה!')
        
        // Update usage count
        if (isAuthenticated && currentUser) {
          const newUsage = await aiService.getUserUsage(currentUser.uid)
          if (newUsage !== null) {
            setUserUsage(newUsage)
          }
        }
      } else {
        throw new Error(result.error || 'Failed to process preset design')
      }
    } catch (error) {
      console.error('Preset design generation failed:', error)
      if (error.message && (error.message.includes('limit reached') || error.message.includes('credits'))) {
        setShowLimitModal(true)
      } else {
        showToast('שגיאה בעיבוד העיצוב. נסה שוב.')
      }
    } finally {
      setIsProcessing(false)
    }
  }

  const colorCategoryColors = {
    'reds': '#C1121C',
    'oranges': '#FF7514', 
    'yellows': '#E5BE01',
    'greens': '#287233',
    'blues': '#1E2460',
    'purples': '#6D3F5B',
    'grays': '#78858B',
    'whitesAndBlacks': '#F4F4F4'
  }
  
  // Translation keys for color categories
  const colorCategoryNames = {
    'reds': t('colorReds'),
    'oranges': t('colorOranges'),
    'yellows': t('colorYellows'),
    'greens': t('colorGreens'),
    'blues': t('colorBlues'),
    'purples': t('colorPurples'),
    'grays': t('colorGrays'),
    'whitesAndBlacks': t('colorWhitesAndBlacks')
  }

  const colorPalette = {
    'reds': [
      { name: 'Flame red', value: 'flame red', hex: '#C1121C', ral: 'RAL 3000' },
      { name: 'Signal red', value: 'signal red', hex: '#A52019', ral: 'RAL 3001' },
      { name: 'Carmine red', value: 'carmine red', hex: '#A2231D', ral: 'RAL 3002' },
      { name: 'Ruby red', value: 'ruby red', hex: '#9B111E', ral: 'RAL 3003' },
      { name: 'Purple red', value: 'purple red', hex: '#75151E', ral: 'RAL 3004' },
      { name: 'Wine red', value: 'wine red', hex: '#5E2129', ral: 'RAL 3005' },
      { name: 'Black red', value: 'black red', hex: '#412227', ral: 'RAL 3007' },
      { name: 'Oxide red', value: 'oxide red', hex: '#642424', ral: 'RAL 3009' },
      { name: 'Brown red', value: 'brown red', hex: '#781F19', ral: 'RAL 3011' },
      { name: 'Beige red', value: 'beige red', hex: '#C1876B', ral: 'RAL 3012' },
      { name: 'Tomato red', value: 'tomato red', hex: '#A12312', ral: 'RAL 3013' },
      { name: 'Antique pink', value: 'antique pink', hex: '#D36E70', ral: 'RAL 3014' },
      { name: 'Light pink', value: 'light pink', hex: '#EA899A', ral: 'RAL 3015' },
      { name: 'Coral red', value: 'coral red', hex: '#B32821', ral: 'RAL 3016' },
      { name: 'Rose', value: 'rose', hex: '#E63244', ral: 'RAL 3017' },
      { name: 'Strawberry red', value: 'strawberry red', hex: '#D53032', ral: 'RAL 3018' },
      { name: 'Traffic red', value: 'traffic red', hex: '#CC0605', ral: 'RAL 3020' },
      { name: 'Salmon pink', value: 'salmon pink', hex: '#D95030', ral: 'RAL 3022' },
      { name: 'Raspberry red', value: 'raspberry red', hex: '#C51D34', ral: 'RAL 3027' },
      { name: 'Orient red', value: 'orient red', hex: '#B32428', ral: 'RAL 3031' }
    ],
    'oranges': [
      { name: 'Red orange', value: 'red orange', hex: '#C93C20', ral: 'RAL 2001' },
      { name: 'Vermilion', value: 'vermilion', hex: '#CB2821', ral: 'RAL 2002' },
      { name: 'Pastel orange', value: 'pastel orange', hex: '#FF7514', ral: 'RAL 2003' },
      { name: 'Pure orange', value: 'pure orange', hex: '#F44611', ral: 'RAL 2004' },
      { name: 'Bright red orange', value: 'bright red orange', hex: '#F75E25', ral: 'RAL 2008' },
      { name: 'Traffic orange', value: 'traffic orange', hex: '#F54021', ral: 'RAL 2009' },
      { name: 'Signal orange', value: 'signal orange', hex: '#D84B20', ral: 'RAL 2010' },
      { name: 'Deep orange', value: 'deep orange', hex: '#EC7C26', ral: 'RAL 2011' },
      { name: 'Salmon range', value: 'salmon range', hex: '#E55137', ral: 'RAL 2012' }
    ],
    'yellows': [
      { name: 'Green beige', value: 'green beige', hex: '#BEBD7F', ral: 'RAL 1000' },
      { name: 'Beige', value: 'beige', hex: '#C2B078', ral: 'RAL 1001' },
      { name: 'Sand yellow', value: 'sand yellow', hex: '#C6A664', ral: 'RAL 1002' },
      { name: 'Signal yellow', value: 'signal yellow', hex: '#E5BE01', ral: 'RAL 1003' },
      { name: 'Golden yellow', value: 'golden yellow', hex: '#CDA434', ral: 'RAL 1004' },
      { name: 'Honey yellow', value: 'honey yellow', hex: '#A98307', ral: 'RAL 1005' },
      { name: 'Maize yellow', value: 'maize yellow', hex: '#E4A010', ral: 'RAL 1006' },
      { name: 'Daffodil yellow', value: 'daffodil yellow', hex: '#DC9D00', ral: 'RAL 1007' },
      { name: 'Brown beige', value: 'brown beige', hex: '#8A6642', ral: 'RAL 1011' },
      { name: 'Lemon yellow', value: 'lemon yellow', hex: '#C7B446', ral: 'RAL 1012' },
      { name: 'Oyster white', value: 'oyster white', hex: '#EAE6CA', ral: 'RAL 1013' },
      { name: 'Ivory', value: 'ivory', hex: '#E1CC4F', ral: 'RAL 1014' },
      { name: 'Light ivory', value: 'light ivory', hex: '#E6D690', ral: 'RAL 1015' },
      { name: 'Sulfur yellow', value: 'sulfur yellow', hex: '#EDFF21', ral: 'RAL 1016' },
      { name: 'Saffron yellow', value: 'saffron yellow', hex: '#F5D033', ral: 'RAL 1017' },
      { name: 'Zinc yellow', value: 'zinc yellow', hex: '#F8F32B', ral: 'RAL 1018' },
      { name: 'Grey beige', value: 'grey beige', hex: '#a28f7a', ral: 'RAL 1019' },
      { name: 'Olive yellow', value: 'olive yellow', hex: '#999950', ral: 'RAL 1020' },
      { name: 'Rape yellow', value: 'rape yellow', hex: '#F3DA0B', ral: 'RAL 1021' },
      { name: 'Traffic yellow', value: 'traffic yellow', hex: '#FAD201', ral: 'RAL 1023' },
      { name: 'Ochre yellow', value: 'ochre yellow', hex: '#AEA04B', ral: 'RAL 1024' },
      { name: 'Curry', value: 'curry', hex: '#9D9101', ral: 'RAL 1027' },
      { name: 'Melon yellow', value: 'melon yellow', hex: '#F4A900', ral: 'RAL 1028' },
      { name: 'Broom yellow', value: 'broom yellow', hex: '#D6AE01', ral: 'RAL 1032' },
      { name: 'Dahlia yellow', value: 'dahlia yellow', hex: '#F3A505', ral: 'RAL 1033' },
      { name: 'Pastel yellow', value: 'pastel yellow', hex: '#EFA94A', ral: 'RAL 1034' },
      { name: 'Sun yellow', value: 'sun yellow', hex: '#F39F18', ral: 'RAL 1037' }
    ],
    'greens': [
      { name: 'Patina green', value: 'patina green', hex: '#316650', ral: 'RAL 6000' },
      { name: 'Emerald green', value: 'emerald green', hex: '#287233', ral: 'RAL 6001' },
      { name: 'Leaf green', value: 'leaf green', hex: '#2D572C', ral: 'RAL 6002' },
      { name: 'Olive green', value: 'olive green', hex: '#424632', ral: 'RAL 6003' },
      { name: 'Blue green', value: 'blue green', hex: '#1F3A3D', ral: 'RAL 6004' },
      { name: 'Moss green', value: 'moss green', hex: '#2F4538', ral: 'RAL 6005' },
      { name: 'Bottle green', value: 'bottle green', hex: '#343B29', ral: 'RAL 6007' },
      { name: 'Brown green', value: 'brown green', hex: '#39352A', ral: 'RAL 6008' },
      { name: 'Fir green', value: 'fir green', hex: '#31372B', ral: 'RAL 6009' },
      { name: 'Grass green', value: 'grass green', hex: '#35682D', ral: 'RAL 6010' },
      { name: 'Reseda green', value: 'reseda green', hex: '#587246', ral: 'RAL 6011' },
      { name: 'Black green', value: 'black green', hex: '#343E40', ral: 'RAL 6012' },
      { name: 'Reed green', value: 'reed green', hex: '#6C7156', ral: 'RAL 6013' },
      { name: 'Yellow olive', value: 'yellow olive', hex: '#47402E', ral: 'RAL 6014' },
      { name: 'Black olive', value: 'black olive', hex: '#3B3C36', ral: 'RAL 6015' },
      { name: 'Turquoise green', value: 'turquoise green', hex: '#1E5945', ral: 'RAL 6016' },
      { name: 'May green', value: 'may green', hex: '#4C9141', ral: 'RAL 6017' },
      { name: 'Yellow green', value: 'yellow green', hex: '#57A639', ral: 'RAL 6018' },
      { name: 'Pastel green', value: 'pastel green', hex: '#BDECB6', ral: 'RAL 6019' },
      { name: 'Chrome green', value: 'chrome green', hex: '#2E3A23', ral: 'RAL 6020' },
      { name: 'Pale green', value: 'pale green', hex: '#89AC76', ral: 'RAL 6021' },
      { name: 'Olive drab', value: 'olive drab', hex: '#25221B', ral: 'RAL 6022' },
      { name: 'Traffic green', value: 'traffic green', hex: '#308446', ral: 'RAL 6024' },
      { name: 'Fern green', value: 'fern green', hex: '#3D642D', ral: 'RAL 6025' },
      { name: 'Opal green', value: 'opal green', hex: '#015D52', ral: 'RAL 6026' },
      { name: 'Light green', value: 'light green', hex: '#84C3BE', ral: 'RAL 6027' },
      { name: 'Pine green', value: 'pine green', hex: '#2C5545', ral: 'RAL 6028' },
      { name: 'Mint green', value: 'mint green', hex: '#20603D', ral: 'RAL 6029' },
      { name: 'Signal green', value: 'signal green', hex: '#317F43', ral: 'RAL 6032' },
      { name: 'Mint turquoise', value: 'mint turquoise', hex: '#497E76', ral: 'RAL 6033' },
      { name: 'Pastel turquoise', value: 'pastel turquoise', hex: '#7FB5B5', ral: 'RAL 6034' }
    ],
    'blues': [
      { name: 'Violet blue', value: 'violet blue', hex: '#354D73', ral: 'RAL 5000' },
      { name: 'Green blue', value: 'green blue', hex: '#1F3438', ral: 'RAL 5001' },
      { name: 'Ultramarine blue', value: 'ultramarine blue', hex: '#20214F', ral: 'RAL 5002' },
      { name: 'Saphire blue', value: 'saphire blue', hex: '#1D1E33', ral: 'RAL 5003' },
      { name: 'Black blue', value: 'black blue', hex: '#18171C', ral: 'RAL 5004' },
      { name: 'Signal blue', value: 'signal blue', hex: '#1E2460', ral: 'RAL 5005' },
      { name: 'Brillant blue', value: 'brillant blue', hex: '#3E5F8A', ral: 'RAL 5007' },
      { name: 'Grey blue', value: 'grey blue', hex: '#26252D', ral: 'RAL 5008' },
      { name: 'Azure blue', value: 'azure blue', hex: '#225f78', ral: 'RAL 5009' },
      { name: 'Gentian blue', value: 'gentian blue', hex: '#0E294B', ral: 'RAL 5010' },
      { name: 'Steel blue', value: 'steel blue', hex: '#231A24', ral: 'RAL 5011' },
      { name: 'Light blue', value: 'light blue', hex: '#3B83BD', ral: 'RAL 5012' },
      { name: 'Cobalt blue', value: 'cobalt blue', hex: '#1E213D', ral: 'RAL 5013' },
      { name: 'Pigeon blue', value: 'pigeon blue', hex: '#606E8C', ral: 'RAL 5014' },
      { name: 'Sky blue', value: 'sky blue', hex: '#2271B3', ral: 'RAL 5015' },
      { name: 'Traffic blue', value: 'traffic blue', hex: '#063971', ral: 'RAL 5017' },
      { name: 'Turquoise blue', value: 'turquoise blue', hex: '#3F888F', ral: 'RAL 5018' },
      { name: 'Capri blue', value: 'capri blue', hex: '#1B5583', ral: 'RAL 5019' },
      { name: 'Ocean blue', value: 'ocean blue', hex: '#1D334A', ral: 'RAL 5020' },
      { name: 'Water blue', value: 'water blue', hex: '#256D7B', ral: 'RAL 5021' },
      { name: 'Night blue', value: 'night blue', hex: '#252850', ral: 'RAL 5022' },
      { name: 'Distant blue', value: 'distant blue', hex: '#49678D', ral: 'RAL 5023' },
      { name: 'Pastel blue', value: 'pastel blue', hex: '#5D9B9B', ral: 'RAL 5024' }
    ],
    'purples': [
      { name: 'Red lilac', value: 'red lilac', hex: '#6D3F5B', ral: 'RAL 4001' },
      { name: 'Red violet', value: 'red violet', hex: '#922B3E', ral: 'RAL 4002' },
      { name: 'Heather violet', value: 'heather violet', hex: '#DE4C8A', ral: 'RAL 4003' },
      { name: 'Claret violet', value: 'claret violet', hex: '#641C34', ral: 'RAL 4004' },
      { name: 'Blue lilac', value: 'blue lilac', hex: '#6C4675', ral: 'RAL 4005' },
      { name: 'Traffic purple', value: 'traffic purple', hex: '#A03472', ral: 'RAL 4006' },
      { name: 'Purple violet', value: 'purple violet', hex: '#4A192C', ral: 'RAL 4007' },
      { name: 'Signal violet', value: 'signal violet', hex: '#924E7D', ral: 'RAL 4008' },
      { name: 'Pastel violet', value: 'pastel violet', hex: '#A18594', ral: 'RAL 4009' },
      { name: 'Telemagenta', value: 'telemagenta', hex: '#CF3476', ral: 'RAL 4010' }
    ],
    'grays': [
      { name: 'Squirrel grey', value: 'squirrel grey', hex: '#78858B', ral: 'RAL 7000' },
      { name: 'Silver grey', value: 'silver grey', hex: '#8A9597', ral: 'RAL 7001' },
      { name: 'Olive grey', value: 'olive grey', hex: '#7E7B52', ral: 'RAL 7002' },
      { name: 'Moss grey', value: 'moss grey', hex: '#6C7059', ral: 'RAL 7003' },
      { name: 'Signal grey', value: 'signal grey', hex: '#969992', ral: 'RAL 7004' },
      { name: 'Mouse grey', value: 'mouse grey', hex: '#646B63', ral: 'RAL 7005' },
      { name: 'Beige grey', value: 'beige grey', hex: '#6D6552', ral: 'RAL 7006' },
      { name: 'Khaki grey', value: 'khaki grey', hex: '#6A5F31', ral: 'RAL 7008' },
      { name: 'Green grey', value: 'green grey', hex: '#4D5645', ral: 'RAL 7009' },
      { name: 'Tarpaulin grey', value: 'tarpaulin grey', hex: '#4C514A', ral: 'RAL 7010' },
      { name: 'Iron grey', value: 'iron grey', hex: '#434B4D', ral: 'RAL 7011' },
      { name: 'Basalt grey', value: 'basalt grey', hex: '#4E5754', ral: 'RAL 7012' },
      { name: 'Brown grey', value: 'brown grey', hex: '#464531', ral: 'RAL 7013' },
      { name: 'Slate grey', value: 'slate grey', hex: '#434750', ral: 'RAL 7015' },
      { name: 'Anthracite grey', value: 'anthracite grey', hex: '#293133', ral: 'RAL 7016' },
      { name: 'Black grey', value: 'black grey', hex: '#23282B', ral: 'RAL 7021' },
      { name: 'Umbra grey', value: 'umbra grey', hex: '#332F2C', ral: 'RAL 7022' },
      { name: 'Concrete grey', value: 'concrete grey', hex: '#686C5E', ral: 'RAL 7023' },
      { name: 'Graphite grey', value: 'graphite grey', hex: '#474A51', ral: 'RAL 7024' },
      { name: 'Granite grey', value: 'granite grey', hex: '#2F353B', ral: 'RAL 7026' },
      { name: 'Stone grey', value: 'stone grey', hex: '#8B8C7A', ral: 'RAL 7030' },
      { name: 'Blue grey', value: 'blue grey', hex: '#8B8C7A', ral: 'RAL 7031' },
      { name: 'Pebble grey', value: 'pebble grey', hex: '#B8B799', ral: 'RAL 7032' },
      { name: 'Cement grey', value: 'cement grey', hex: '#7D8471', ral: 'RAL 7033' },
      { name: 'Yellow grey', value: 'yellow grey', hex: '#8F8B66', ral: 'RAL 7034' },
      { name: 'Light grey', value: 'light grey', hex: '#D7D7D7', ral: 'RAL 7035' },
      { name: 'Platinum grey', value: 'platinum grey', hex: '#7F7679', ral: 'RAL 7036' },
      { name: 'Dusty grey', value: 'dusty grey', hex: '#7D7F7D', ral: 'RAL 7037' },
      { name: 'Agate grey', value: 'agate grey', hex: '#B5B8B1', ral: 'RAL 7038' },
      { name: 'Quartz grey', value: 'quartz grey', hex: '#6C6960', ral: 'RAL 7039' },
      { name: 'Window grey', value: 'window grey', hex: '#9DA1AA', ral: 'RAL 7040' },
      { name: 'Traffic grey A', value: 'traffic grey A', hex: '#8D948D', ral: 'RAL 7042' },
      { name: 'Traffic grey B', value: 'traffic grey B', hex: '#4E5452', ral: 'RAL 7043' },
      { name: 'Silk grey', value: 'silk grey', hex: '#CAC4B0', ral: 'RAL 7044' },
      { name: 'Telegrey 1', value: 'telegrey 1', hex: '#909090', ral: 'RAL 7045' },
      { name: 'Telegrey 2', value: 'telegrey 2', hex: '#82898F', ral: 'RAL 7046' },
      { name: 'Telegrey 4', value: 'telegrey 4', hex: '#D0D0D0', ral: 'RAL 7047' }
    ],
    'whitesAndBlacks': [
      { name: 'Cream', value: 'cream', hex: '#FDF4E3', ral: 'RAL 9001' },
      { name: 'Grey white', value: 'grey white', hex: '#E7EBDA', ral: 'RAL 9002' },
      { name: 'Signal white', value: 'signal white', hex: '#F4F4F4', ral: 'RAL 9003' },
      { name: 'Signal black', value: 'signal black', hex: '#282828', ral: 'RAL 9004' },
      { name: 'Jet black', value: 'jet black', hex: '#0A0A0A', ral: 'RAL 9005' },
      { name: 'Simply white', value: 'simply white', hex: '#FFFFFF', ral: 'RAL 9010' },
      { name: 'Graphite black', value: 'graphite black', hex: '#1C1C1C', ral: 'RAL 9011' },
      { name: 'Traffic white', value: 'traffic white', hex: '#F6F6F6', ral: 'RAL 9016' },
      { name: 'Traffic black', value: 'traffic black', hex: '#1E1E1E', ral: 'RAL 9017' },
      { name: 'Papyrus white', value: 'papyrus white', hex: '#D7D7D7', ral: 'RAL 9018' }
    ]
  }

  const handleColorSelect = (color) => {
    trackColorSelect(color.value, activeColorCategory)
    setSelectedColorForDialog(color)
    setShowColorDialog(true)
  }

  const handleColorDialogApply = (prompt) => {
    setShowColorDialog(false)
    setShowColorPalette(false)
    setSelectedColorForDialog(null)
    
    console.log('🎨 Color Selection - Prompt being added to input and executing:', prompt)
    
    // Add to input logic (similar to addPromptToInput but returning value)
    const currentPrompt = customPrompt.trim()
    let newPrompt
    
    if (!currentPrompt) {
      newPrompt = prompt
    } else if (currentPrompt.endsWith('את ה')) {
      newPrompt = `${currentPrompt}${prompt}`
    } else {
      newPrompt = `${currentPrompt}, ${prompt}`
    }
    
    setCustomPrompt(newPrompt)
    
    // Execute immediately
    handleAIEdit(newPrompt)
    
    // Reset prompt after execution
    setCustomPrompt('')
  }

  const angleOptions = [
    { name: 'מבט מלמעלה', value: 'bird\'s eye view', icon: '⬆️', prompt: 'שנה את התמונה להציג מבט מלמעלה' },
    { name: 'סובב שמאלה', value: 'left angle', icon: '⬅️', prompt: 'סובב את המצלמה 45 מעלות שמאלה' },
    { name: 'סובב ימינה', value: 'right angle', icon: '➡️', prompt: 'סובב את המצלמה 45 מעלות ימינה' },
    { name: 'זום פנימה', value: 'zoom in', icon: '🔍+', prompt: 'זום פנימה להציג יותר פרטים בתמונה' },
    { name: 'זום החוצה', value: 'zoom out', icon: '🔍-', prompt: 'זום החוצה להציג מבט רחב יותר של התמונה' },
    { name: 'זווית אחורית', value: 'back view', icon: '👁️‍🗨️', prompt: 'שנה את כל התמונה להציג מבט אחורי 180 מעלות' }
  ]

  const lightingOptions = [
    { name: 'תאורה מוסתרת', value: 'recessed lighting', prompt: 'הוסף תאורה מוסתרת' },
    { name: 'נברשת', value: 'pendant lights', prompt: 'הוסף נברשת' },
    { name: 'נברשת גדולה', value: 'chandeliers', prompt: 'הוסף נברשת גדולה' },
    { name: 'מנורת שולחן', value: 'table lamps', prompt: 'הוסף מנורת שולחן' },
    { name: 'מנורת רצפה', value: 'floor lamps', prompt: 'הוסף מנורת רצפה' },
    { name: 'מנורת קיר', value: 'wall sconces', prompt: 'הוסף מנורת קיר' },
    { name: 'תאורת מסילה', value: 'track lighting', prompt: 'הוסף תאורת מסילה' },
    { name: 'תאורת תקרה', value: 'ceiling fixtures', prompt: 'הוסף תאורת תקרה' },
    { name: 'תאורת מטבח', value: 'under-cabinet lighting', prompt: 'הוסף תאורת מטבח' },
    { name: 'תאורה דקורטיבית', value: 'string lights', prompt: 'הוסף תאורה דקורטיבית' },
    { name: 'יום', value: 'day', prompt: 'שנה את התאורה לתאורת יום' },
    { name: 'לילה', value: 'night', prompt: 'שנה את התאורה לתאורת לילה' },
    { name: 'שקיעה', value: 'sunset', prompt: 'שנה את התאורה לתאורת שקיעה' },
    { name: 'זריחה', value: 'sunrise', prompt: 'שנה את התאורה לתאורת זריחה' }
  ]

  const furnitureOptions = [
    { name: 'ספה', value: 'sofa', prompt: 'הוסף ספה' },
    { name: 'ספה פינתית', value: 'sectional sofa', prompt: 'הוסף ספה פינתית' },
    { name: 'כורסא', value: 'armchair', prompt: 'הוסף כורסא' },
    { name: 'כיסא דקורטיבי', value: 'accent chair', prompt: 'הוסף כיסא דקורטיבי' },
    { name: 'כיסא אוכל', value: 'dining chair', prompt: 'הוסף כיסא אוכל' },
    { name: 'שרפרף', value: 'bar stool', prompt: 'הוסף שרפרף' },
    { name: 'מיטה יחידה', value: 'single bed', prompt: 'הוסף מיטה יחידה' },
    { name: 'מיטה זוגית', value: 'double bed', prompt: 'הוסף מיטה זוגית' },
    { name: 'פוף', value: 'beanbag', prompt: 'הוסף פוף' },
    { name: 'הדום', value: 'ottoman', prompt: 'הוסף הדום' },
    { name: 'ספסל', value: 'bench', prompt: 'הוסף ספסל' },
    { name: 'שולחן קפה', value: 'coffee table', prompt: 'הוסף שולחן קפה' },
    { name: 'שולחן צד', value: 'end table', prompt: 'הוסף שולחן צד' },
    { name: 'שולחן לילה', value: 'nightstand', prompt: 'הוסף שולחן לילה' },
    { name: 'שולחן אוכל', value: 'dining table', prompt: 'הוסף שולחן אוכל' },
    { name: 'שולחן עבודה', value: 'desk', prompt: 'הוסף שולחן עבודה' },
    { name: 'שידה', value: 'dresser', prompt: 'הוסף שידה' },
    { name: 'ארון בגדים', value: 'wardrobe', prompt: 'הוסף ארון בגדים' },
    { name: 'מדף ספרים', value: 'bookcase', prompt: 'הוסף מדף ספרים' },
    { name: 'עמדת טלוויזיה', value: 'tv stand', prompt: 'הוסף עמדת טלוויזיה' },
    { name: 'ארונות מטבח', value: 'cabinetry', prompt: 'הוסף ארונות מטבח' }
  ]

  const repairsOptions = [
    { name: t('repairEverything'), value: 'repair everything', prompt: 'repair everything' },
    { name: t('fixAndRepairEverything'), value: 'fix and repair everything', prompt: 'fix and repair everything' },
    { name: t('messUpEverything'), value: 'mess up everything', prompt: 'mess up everything' },
    { name: t('destroyAndCauseDamage'), value: 'destroy and cause damage to everything', prompt: 'destroy and cause damage to everything' }
  ]

  const styleOptions = [
    { 
      name: 'ים תיכוני מודרני', 
      value: 'mediterranean-modern', 
      thumbnail: '/assets/styles/mediterranean.png',
      prompt: 'Transform this room into a Modern Mediterranean interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Use natural materials like Jerusalem stone walls, terracotta tiles, and light oak wood flooring. Add arched doorways and windows. Use a warm color palette with white, cream, sand, and olive green accents. Include linen curtains, woven textures, ceramic vases with olive branches, and modern furniture with clean lines. Maximize natural light with large windows. Add indoor plants like olive trees and succulents. Create an airy, relaxed, and sophisticated atmosphere inspired by Israeli coastal living.'
    },
    { 
      name: 'מינימליזם חם', 
      value: 'warm-minimalism', 
      thumbnail: '/assets/styles/warm-minimalism.jpg',
      prompt: 'Transform this room into Warm Minimalism interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Keep the space clean and uncluttered but add warmth through natural materials. Use oak wood floors, cream-colored walls, and natural stone accents. Include low-profile modern furniture in warm neutrals like camel, beige, and soft terracotta. Add texture through wool rugs, linen cushions, and organic cotton throws. Use rounded furniture edges and soft curves. Include subtle decorative elements like a single large plant, minimalist art, and sculptural ceramic pieces. Emphasize natural light with sheer curtains. Create a serene, cozy, and sophisticated atmosphere.'
    },
    { 
      name: 'ביופילי', 
      value: 'biophilic', 
      thumbnail: '/assets/styles/biophilic.jpg',
      prompt: 'Transform this room into Biophilic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a strong connection to nature inside the home. Add abundant indoor plants including large statement plants like fiddle leaf figs, monstera, and hanging pothos. Use natural materials throughout: raw wood furniture, stone surfaces, bamboo accents, and cork flooring. Include a living green wall or plant shelf. Use earthy colors: forest green, terracotta, sand, and natural wood tones. Maximize natural light through existing windows. Include water features or natural elements like driftwood and pebbles. Create a fresh, calming, and nature-immersive atmosphere.'
    },
    { 
      name: 'מודרני יוקרתי', 
      value: 'modern-luxury', 
      thumbnail: '/assets/styles/modern-luxury.jpg',
      prompt: 'Transform this room into Modern Luxury interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create an elegant and sophisticated high-end space. Use premium materials: Italian marble floors or feature walls, rich wood veneers, brushed brass or gold metal accents. Include designer furniture with sculptural forms and plush velvet upholstery in jewel tones like emerald green, sapphire blue, or deep burgundy. Add statement lighting fixtures like a modern chandelier or sculptural pendant lights. Use a refined color palette with charcoal, cream, and metallic accents. Include floor-to-ceiling curtains, large abstract art, and designer accessories. Create a glamorous, refined, and opulent atmosphere.'
    },
    { 
      name: 'יפנדי', 
      value: 'japandi', 
      thumbnail: '/assets/styles/japandi.jpg',
      prompt: 'Transform this room into Japandi interior design style - a fusion of Japanese and Scandinavian aesthetics. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Use a muted, neutral color palette with soft whites, warm grays, and natural wood tones. Include low-profile furniture with clean lines and natural materials like light ash or oak wood. Add Japanese elements: shoji-style screens, floor cushions, bonsai plants, and ceramic pottery. Incorporate Scandinavian hygge with cozy textiles, wool throws, and sheepskin rugs. Keep the space minimal and functional with hidden storage. Use paper lanterns or simple pendant lighting. Add indoor plants like bamboo or peace lilies. Create a zen-like, harmonious, and tranquil atmosphere.'
    },
    { 
      name: 'סקנדינבי', 
      value: 'scandinavian', 
      thumbnail: '/assets/styles/scandinavian.jpg',
      prompt: 'Transform this room into Scandinavian interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Use a bright, airy color palette dominated by white and light gray walls. Add light wood floors in birch or pine. Include minimalist furniture with clean lines and functional design in natural wood and white finishes. Add cozy textiles: chunky knit blankets, sheepskin throws, and soft wool rugs. Include statement lighting with modern pendant lamps. Use indoor plants like eucalyptus and ferns for natural touches. Add black accents through frames, fixtures, and accessories for contrast. Keep decor minimal but meaningful. Create a bright, cozy, and hygge-inspired atmosphere with excellent natural lighting.'
    },
    { 
      name: 'בוהו שיק', 
      value: 'boho-chic', 
      thumbnail: '/assets/styles/boho.jpg',
      prompt: 'Transform this room into Bohemian Chic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create an eclectic, artistic, and free-spirited space. Layer rich textures with Moroccan rugs, macramé wall hangings, and woven baskets. Use warm, earthy colors mixed with vibrant accents: terracotta, mustard yellow, teal, and burnt orange. Include rattan and wicker furniture, vintage pieces, and floor cushions. Add abundant plants in decorative pots, hanging planters, and trailing vines. Include global-inspired decor: Turkish lanterns, Indian textiles, and African baskets. Add fairy lights or warm Edison bulb lighting. Create a relaxed, artistic, and globally-inspired atmosphere full of personality and warmth.'
    },
    { 
      name: 'אינדוסטריאלי', 
      value: 'industrial', 
      thumbnail: '/assets/styles/industrial.jpg',
      prompt: 'Transform this room into Industrial interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Expose raw architectural elements: brick walls, concrete ceilings, metal pipes, and ductwork. Use a color palette of charcoal gray, black, rust, and raw concrete tones. Include metal and iron furniture: steel-framed shelving, iron coffee tables, and metal bar stools. Add distressed leather sofas and vintage factory-style lighting with exposed bulbs. Include reclaimed wood elements for warmth: wooden dining tables, floating shelves, or accent walls. Add large factory-style mirrors. Include industrial accessories: metal clocks, wire baskets, and vintage signs. Create a raw, edgy, urban loft atmosphere with character and history.'
    },
    { 
      name: 'טבעי וארצי', 
      value: 'earthy-natural', 
      thumbnail: '/assets/styles/earthy-natural.jpg',
      prompt: 'Transform this room into Earthy Natural interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a grounded, organic, and serene space connected to nature. Use a warm earth-tone color palette: terracotta, ochre, olive green, warm browns, and sandy beige. Include natural materials: raw wood furniture, stone surfaces, clay pottery, and jute or sisal rugs. Add textured walls with lime wash or clay plaster in warm tones. Include linen and cotton textiles in natural undyed colors. Add organic shapes and handcrafted elements: ceramic vases, woven baskets, and artisanal objects. Include large indoor plants and dried flowers or pampas grass. Create a warm, grounded, and nature-inspired sanctuary.'
    },
    { 
      name: 'ירושלמי', 
      value: 'jerusalem', 
      thumbnail: '/assets/styles/jerusalem.jpg',
      prompt: 'Transform this room into Contemporary Israeli interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a bright, modern space that reflects Mediterranean living. Use Jerusalem stone or natural stone feature walls, terrazzo floors, and light wood accents. Use a neutral palette with white walls, warm beige, and pops of earthy colors like olive and terracotta. Add modern Israeli design furniture with clean lines and functional aesthetics. Include local crafts: ceramic pieces, woven textiles, and modern Israeli art. Add olive branches, succulents, and Mediterranean plants. Create an airy, sophisticated, and culturally-rooted atmosphere that celebrates Israeli design heritage.'
    },
    { 
      name: 'מינימליסטי', 
      value: 'minimalist', 
      thumbnail: '/assets/styles/minimalist.jpg',
      prompt: 'Transform this room into Minimalist interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a clean, uncluttered, and intentional space. Use an all-white or monochromatic color palette with subtle texture variations. Include streamlined furniture with geometric forms and hidden storage solutions. Keep surfaces completely clear with minimal decorative objects - only one or two statement pieces. Use high-quality materials: polished concrete floors, seamless white walls, and sleek fixtures. Add architectural interest through recessed lighting, clean lines, and negative space. Include one bold statement element like a large plant or single artwork. Create a serene, peaceful, and focused atmosphere where less is more.'
    },
    { 
      name: 'קלאסי עדכני', 
      value: 'modern-classic', 
      thumbnail: '/assets/styles/modern-classic.jpg',
      prompt: 'Transform this room into Modern Classic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Blend timeless elegance with contemporary comfort. Use a sophisticated color palette of cream, soft gray, navy blue, and gold accents. Include classic architectural details: crown moldings, wainscoting, and paneled walls with modern interpretation. Add furniture that combines classic silhouettes with updated fabrics: tufted sofas, wingback chairs in modern fabrics, and elegant side tables. Include crystal or modern chandeliers and wall sconces. Add marble surfaces, silk or velvet textiles, and gilded mirrors. Include fresh flowers, classic art, and refined accessories. Create an elegant, sophisticated, and timeless atmosphere that feels both grand and welcoming.'
    }
  ]

  const handleAngleSelect = (angle) => {
    setShowAnglePanel(false)
    trackAngleSelect(angle.value)
    console.log('📐 Angle Selection - Prompt being added to input:', angle.prompt)
    console.log('📐 Selected angle:', angle.name, angle.value)
    addPromptToInput(angle.prompt)
  }

  const handleLightingSelect = (lighting) => {
    setShowLightingOptions(false)
    trackLightingSelect(lighting.value)
    console.log('💡 Lighting Selection - Prompt being added to input:', lighting.prompt)
    console.log('💡 Selected lighting:', lighting.name, lighting.value)
    addPromptToInput(lighting.prompt)
  }

  const handleFurnitureSelect = (furniture) => {
    setShowFurnitureOptions(false)
    trackFurnitureSelect(furniture.value)
    console.log('🪑 Furniture Selection - Prompt being added to input:', furniture.prompt)
    console.log('🪑 Selected furniture:', furniture.name, furniture.value)
    addPromptToInput(furniture.prompt)
  }

  const handleRepairsSelect = (repair) => {
    setShowRepairsOptions(false)
    trackRepairsSelect(repair.value)
    console.log('🔨 Repairs Selection - Prompt being added to input:', repair.prompt)
    console.log('🔨 Selected repair:', repair.name, repair.value)
    addPromptToInput(repair.prompt)
  }

  const handleStyleSelect = (style) => {
    setShowStyleOptions(false)
    trackStyleSelect(style.value)
    
    console.log('🎨 Style Selection - Prompt being added to input and executing:', style.prompt)
    console.log('🎨 Selected style:', style.name, style.value)
    
    // Add to input logic
    const currentPrompt = customPrompt.trim()
    let newPrompt
    
    if (!currentPrompt) {
      newPrompt = style.prompt
    } else if (currentPrompt.endsWith('את ה')) {
      newPrompt = `${currentPrompt}${style.prompt}`
    } else {
      newPrompt = `${currentPrompt}, ${style.prompt}`
    }
    
    setCustomPrompt(newPrompt)
    
    // Execute immediately
    handleAIEdit(newPrompt)

    // Clear the prompt input after execution
    setCustomPrompt('')
  }

  const handleImmediateOptionClick = (prompt, optionType = 'other') => {
    // Track the feature use
    if (showDoorsWindowsOptions) {
      trackDoorsWindowsSelect(prompt)
    } else if (showBathroomOptions) {
      trackBathroomSelect(prompt)
    } else if (showRepairsOptions) {
      trackRepairsSelect(prompt)
    }
    
    // Close all modals
    setShowDoorsWindowsOptions(false)
    setShowBathroomOptions(false)
    setShowRepairsOptions(false)
    
    // Add to input logic
    const currentPrompt = customPrompt.trim()
    let newPrompt
    
    if (!currentPrompt) {
      newPrompt = prompt
    } else if (currentPrompt.endsWith('את ה')) {
      newPrompt = `${currentPrompt}${prompt}`
    } else {
      newPrompt = `${currentPrompt}, ${prompt}`
    }
    
    setCustomPrompt(newPrompt)
    
    // Execute immediately
    handleAIEdit(newPrompt)

    // Clear the prompt input after execution
    setCustomPrompt('')
  }

  const showToast = (message) => {
    setShowNotification(message)
    setTimeout(() => setShowNotification(null), 3000)
  }

  const addPromptToInput = (prompt) => {
    const currentPrompt = customPrompt.trim()
    let newPrompt
    
    if (!currentPrompt) {
      newPrompt = prompt
    } else if (currentPrompt.endsWith('את ה')) {
      // If current prompt ends with "את ה" (color prompt), don't add comma or space
      newPrompt = `${currentPrompt}${prompt}`
    } else {
      // Normal case: add space
      newPrompt = `${currentPrompt} ${prompt}`
    }
    
    setCustomPrompt(newPrompt)
    showToast(t('promptUpdated'))
  }

  const handleAIEdit = async (prompt) => {
    if (!mainImage) return
    
    const startTime = Date.now()
    setIsProcessing(true)
    
    // Determine prompt type for analytics
    const getPromptType = (p) => {
      if (p.includes('סגנון') || p.includes('מינימליסטי') || p.includes('בוהו') || p.includes('מודרני')) return 'style'
      if (p.includes('צבע') || p.includes('לצבע')) return 'color'
      if (p.includes('תאורה') || p.includes('מנורה')) return 'lighting'
      if (p.includes('ספה') || p.includes('כורסא') || p.includes('שולחן') || p.includes('ריהוט')) return 'furniture'
      if (p.includes('זווית') || p.includes('סובב') || p.includes('זום')) return 'angle'
      if (p.includes('תיקון') || p.includes('נזק')) return 'repairs'
      if (p.includes('חלון') || p.includes('דלת')) return 'doors_windows'
      if (p.includes('אמבט') || p.includes('מקלחת') || p.includes('כיור')) return 'bathroom'
      return 'custom'
    }
    const promptType = getPromptType(prompt)
    trackGenerationStart(promptType, !!objectImageFile)
    
    // Save current image as 'Before' image for comparison
    setBeforeImage(mainImage)
    setShowComparison(false) // Disable comparison view during processing
    
    try {
      // Debug: Log the prompt being sent to AI
      console.log('🎨 AI Image Alteration - Prompt being sent:', prompt)
      console.log('📸 Main image URL:', mainImage)
      console.log('🖼️ Object image available:', !!objectImageFile)
      
      // Check if user can make requests
      if (isAuthenticated && currentUser) {
        const canMakeRequest = await aiService.canMakeRequest(currentUser.uid)
        if (!canMakeRequest) {
          trackLimitReached(userSubscription, userUsage, userCredits)
          setShowLimitModal(true)
          setIsProcessing(false)
          return
        }
      }
      
      // Convert image to data URL if it's a local path
      let imageDataForServer = mainImage;
      if (mainImage.startsWith('/assets/') || mainImage.startsWith('./assets/')) {
        // Convert local image to data URL
        try {
          const response = await fetch(mainImage);
          const blob = await response.blob();
          const dataUrl = await new Promise((resolve) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.readAsDataURL(blob);
          });
          imageDataForServer = dataUrl;
        } catch (error) {
          console.error('Error converting local image to data URL:', error);
          throw new Error('Failed to load the default image');
        }
      }
      
      // Process object image if available
      let objectImageData = null;
      if (objectImageFile) {
        console.log('🖼️ Processing object image file:', objectImageFile.name, objectImageFile.type, objectImageFile.size);
        objectImageData = await fileToGenerativePart(objectImageFile);
        console.log('🖼️ Object image processed successfully:', !!objectImageData);
      } else {
        console.log('🖼️ No object image file available');
      }
      
      // Submit request to server
      const deviceId = await getDeviceFingerprint()
      const requestId = await aiService.submitImageGenerationRequest(
        currentUser, 
        prompt, 
        imageDataForServer, 
        objectImageData,
        deviceId
      )
      
      // Wait for completion
      const result = await aiService.waitForRequestCompletion(requestId)
      
      console.log('AI Service result:', result)
      
      if (result && result.storageUrl) {
        const durationMs = Date.now() - startTime
        trackGenerationComplete(promptType, durationMs)
        
        const imageDataUrl = result.storageUrl
        
        // Add to history
        const historyEntry = {
          imageUrl: imageDataUrl,
          prompt: prompt,
          timestamp: formatTimestamp(new Date())
        }
        
        // Reload history to get the server-processed result
        if (isAuthenticated && currentUser) {
          setIsLoadingHistory(true)
          try {
            // Reload first page of history from Firebase to get the updated list
            const historyResult = await loadUserHistoryPaginated(currentUser.uid, 1, 7)
            setImageHistory(historyResult.history)
            setHistoryPage(1)
            setHasMoreHistory(historyResult.hasMore)
          } catch (error) {
            console.error('Failed to reload history from Firebase:', error)
          } finally {
            setIsLoadingHistory(false)
          }
        } else {
          // Fallback to local state if not authenticated
          const localHistoryEntry = {
            id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
            ...historyEntry
          }
          setImageHistory(prev => [localHistoryEntry, ...prev])
          setHistoryPage(1)
          setHasMoreHistory(true)
        }
        
        setMainImage(imageDataUrl)
        setImageAspectRatio(16/9) // Reset to default until new image loads
        setCurrentHistoryId(null) // Clear history ID for new generated image
        
        // Clear object image after successful processing
        setObjectImage(null)
        setObjectImageFile(null)
        if (objectInputRef.current) {
          objectInputRef.current.value = ''
        }

        // Clear input after successful execution
        setCustomPrompt('')

        // Auto-open modal with comparison enabled
        setShowImageModal(true)
        setShowComparison(true)
        setIsNewGeneration(true)
        setHasConfirmedDesign(false)
      } else {
        alert('התמונה לא עובדה בהצלחה. נסה עם תמונה אחרת או פעולה אחרת.')
      }
    } catch (error) {
      console.error('AI processing failed:', error)
      
      // Handle specific error types
      if (error.message?.includes('limit reached') || error.message?.includes('מגבלת הדורות')) {
        trackGenerationError('limit_reached')
        trackLimitReached(userSubscription, userUsage, userCredits)
        setShowLimitModal(true)
      } else if (error.message?.includes('timeout')) {
        trackGenerationError('timeout')
        alert('הבקשה ארכה יותר מדי זמן. נסה שוב.')
      } else {
        trackGenerationError('unknown')
        alert('שגיאה בעיבוד התמונה. אנא נסה שוב או עם תמונה אחרת.')
      }
    } finally {
      setIsProcessing(false)
    }
  }

  const doorsWindowsOptions = [
    {
      titleKey: 'windowOptions',
      items: [
        { nameKey: 'fixedWindow', name: 'Fixed Window', description: 'Add a large picture window with fixed view', icon: Home },
        { nameKey: 'slidingWindow', name: 'Sliding Window', description: 'Add a sliding window', icon: Home },
        { nameKey: 'casementWindow', name: 'Casement Window', description: 'Add a casement window', icon: Home },
        { nameKey: 'tiltTurnWindow', name: 'Tilt-Turn Window', description: 'Add a tilt-turn window', icon: Home },
        { nameKey: 'awningWindow', name: 'Awning Window', description: 'Add an awning window', icon: Home },
        { nameKey: 'doubleHungWindow', name: 'Double-Hung Window', description: 'Add a double-hung window', icon: Home },
        { nameKey: 'pocketWindow', name: 'Pocket Window', description: 'Add a pocket window', icon: Home },
        { nameKey: 'archWindow', name: 'Arch Window', description: 'Add an arch window to expand the space', icon: Home },
      ]
    },
    {
      titleKey: 'doorOptions',
      items: [
        { nameKey: 'pocketDoor', name: 'Pocket Door', description: 'Add a pocket door that slides into the wall', icon: Home },
        { nameKey: 'frenchDoors', name: 'French Doors', description: 'Add French doors with glass panels', icon: Home },
        { nameKey: 'louverDoor', name: 'Louver Door', description: 'Add a louver door with ventilation slats', icon: Home },
        { nameKey: 'barnDoor', name: 'Barn Door', description: 'Add a barn door with exposed track', icon: Home },
      ]
    }
  ]

  const bathroomOptions = [
    {
      titleKey: 'toiletOptions',
      items: [
        { nameKey: 'bidetSeat', name: 'Bidet Seat', description: 'Add a heated bidet toilet seat', icon: Droplets },
        { nameKey: 'toiletSeat', name: 'Toilet Seat', description: 'Add a toilet seat', icon: Droplets },
      ]
    },
    {
      titleKey: 'bathtubOptions',
      items: [
        { nameKey: 'freestandingTub', name: 'Freestanding Tub', description: 'Add a freestanding bathtub', icon: Droplets },
        { nameKey: 'vintageTub', name: 'Vintage Tub', description: 'Add a vintage bathtub', icon: Droplets },
        { nameKey: 'standardTub', name: 'Standard Tub', description: 'Add a standard bathtub', icon: Droplets },
      ]
    },
    {
      titleKey: 'showerOptions',
      items: [
        { nameKey: 'rainShower', name: 'Rain Shower', description: 'Add a shower with rain head system', icon: Droplets },
        { nameKey: 'showerEnclosure', name: 'Shower Enclosure', description: 'Add a shower enclosure', icon: Droplets },
        { nameKey: 'slidingShower', name: 'Sliding Shower', description: 'Add a shower enclosure with sliding doors', icon: Droplets },
      ]
    },
    {
      titleKey: 'sinkOptions',
      items: [
        { nameKey: 'pedestalSink', name: 'Pedestal Sink', description: 'Add a classic pedestal sink', icon: Droplets },
        { nameKey: 'stainlessSink', name: 'Stainless Sink', description: 'Add a stainless steel sink', icon: Droplets },
        { nameKey: 'undermountSink', name: 'Undermount Sink', description: 'Add a white ceramic undermount sink', icon: Droplets },
      ]
    },
    {
      titleKey: 'jacuzziSpaOptions',
      items: [
        { nameKey: 'builtInJacuzzi', name: 'Built-in Jacuzzi', description: 'Add a built-in jacuzzi with tiles', icon: Droplets },
        { nameKey: 'portableJacuzzi', name: 'Portable Jacuzzi', description: 'Add a standard portable jacuzzi', icon: Droplets },
      ]
    },
    {
      titleKey: 'poolOptions',
      items: [
        { nameKey: 'ingroundPool', name: 'Inground Pool', description: 'Add a custom concrete inground pool', icon: Droplets },
        { nameKey: 'abovegroundPool', name: 'Above-ground Pool', description: 'Add an above-ground pool with metal frame', icon: Droplets },
      ]
    }
  ]

  return (
    <div className="min-h-screen text-text font-sans selection:bg-primary-500/30 overflow-x-hidden" dir={isRTL ? 'rtl' : 'ltr'}>
      {/* Top Navigation Bar */}
      <nav className="fixed top-0 left-0 right-0 z-50 glass-panel border-b-0 rounded-b-2xl mx-2 sm:mx-4 mt-2 px-4 sm:px-6 py-3 flex justify-between items-center animate-slide-up">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <div className="relative">
              <div className="absolute inset-0 bg-gradient-to-r from-primary-500 to-secondary-500 blur-lg opacity-30 rounded-full"></div>
              <h1 className="relative text-2xl sm:text-3xl font-bold bg-gradient-to-r from-primary-300 via-white to-secondary-300 bg-clip-text text-transparent tracking-tight">
                {t('appName')}
                <span className={`text-lg sm:text-xl align-super ${isRTL ? 'mr-1' : 'ml-1'} bg-gradient-to-r from-secondary-400 to-secondary-300 bg-clip-text text-transparent font-light`}>AI</span>
              </h1>
            </div>
          </div>
          <button 
            onClick={openSubscriptionModal}
            className={`hidden md:flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-medium shadow-lg transition-all duration-300 hover:-translate-y-0.5 ${
              userSubscription > 0 
                ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 hover:bg-emerald-500/30 shadow-emerald-900/20' 
                : 'bg-gradient-to-r from-secondary-500 to-secondary-600 hover:from-secondary-400 hover:to-secondary-500 text-white shadow-secondary-900/20'
            }`}
          >
            {userSubscription > 0 ? (
              <CheckCircle className="w-5 h-5" />
            ) : (
              <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M5 16L3 5L8.5 7L12 4L15.5 7L21 5L19 16H5Z" fill="url(#crownGradient)" stroke="rgba(255,255,255,0.3)" strokeWidth="0.5"/>
                <path d="M9 16L12 9L15 16H9Z" fill="rgba(255,255,255,0.2)"/>
                <defs>
                  <linearGradient id="crownGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#FFD700" stopOpacity="0.9"/>
                    <stop offset="50%" stopColor="#FFA500" stopOpacity="0.95"/>
                    <stop offset="100%" stopColor="#FFD700" stopOpacity="0.9"/>
                  </linearGradient>
                </defs>
              </svg>
            )}
            {userSubscription > 0 ? (
              <div className="flex flex-col items-start leading-none">
                <span>{t('activeSubscription')}</span>
                <span className="text-[10px] opacity-80">{userCredits - userUsage > 0 ? userCredits - userUsage : 0} {t('credits')}</span>
              </div>
            ) : (
              t('professionalSubscription')
            )}
          </button>
          <button 
            onClick={() => {
              setOnboardingStep(0)
              setShowOnboarding(true)
              trackOnboardingStart()
            }}
            className="p-2 text-gray-400 hover:text-white hover:bg-white/10 rounded-full transition-all"
            title={t('tutorial')}
          >
            <HelpCircle className="w-5 h-5" />
          </button>
          <button 
            onClick={() => setShowContactModal(true)}
            className="p-2 text-gray-400 hover:text-white hover:bg-white/10 rounded-full transition-all"
            title={t('contactUs')}
          >
            <MessageCircle className="w-5 h-5" />
          </button>
        </div>
        
        <div className="flex items-center gap-3">
           {/* Mobile Connected View */}
           <div className="md:hidden flex items-center bg-surface/50 backdrop-blur-md rounded-full border border-white/10 p-1 pl-3 pr-1 gap-1">
             <button 
               onClick={() => setShowMobileMenu(true)}
               className="flex items-center gap-3"
             >
               {/* User Avatar */}
               {isAuthenticated ? (
                 <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-primary-500 to-secondary-500 p-0.5">
                   <div className="w-full h-full rounded-full bg-surface flex items-center justify-center text-xs font-bold text-white">
                     {(currentUser?.email || 'U')[0].toUpperCase()}
                   </div>
                 </div>
               ) : (
                 <div className="w-8 h-8 rounded-full bg-surfaceHighlight flex items-center justify-center">
                   <User className="w-4 h-4 text-white" />
                 </div>
               )}

               {/* Subscription Badge (Combined) */}
               <div className="flex items-center gap-1.5 px-2 py-1 rounded-full bg-gradient-to-r from-secondary-500/20 to-secondary-600/20 border border-secondary-500/30">
                 <span className="text-xs font-bold text-white tabular-nums">
                   {userCredits - userUsage > 0 ? userCredits - userUsage : 0}
                 </span>
                 <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                   <path d="M5 16L3 5L8.5 7L12 4L15.5 7L21 5L19 16H5Z" fill="url(#crownGradientMobile)" stroke="rgba(255,255,255,0.3)" strokeWidth="0.5"/>
                   <path d="M9 16L12 9L15 16H9Z" fill="rgba(255,255,255,0.2)"/>
                   <defs>
                     <linearGradient id="crownGradientMobile" x1="0%" y1="0%" x2="100%" y2="100%">
                       <stop offset="0%" stopColor="#FFD700" stopOpacity="0.9"/>
                       <stop offset="50%" stopColor="#FFA500" stopOpacity="0.95"/>
                       <stop offset="100%" stopColor="#FFD700" stopOpacity="0.9"/>
                     </linearGradient>
                   </defs>
                 </svg>
               </div>
             </button>
           </div>
           
           {/* Desktop User Profile & Auth */}
           <button 
             onClick={() => setShowMobileMenu(true)}
             className="hidden md:flex items-center gap-3 px-3 sm:px-4 py-2 rounded-full bg-surface/50 hover:bg-surfaceHighlight/50 border border-white/5 hover:border-white/20 transition-all duration-300 group"
           >
             {isAuthenticated ? (
               <>
                 <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-primary-500 to-secondary-500 p-0.5">
                   <div className="w-full h-full rounded-full bg-surface flex items-center justify-center text-xs font-bold text-white">
                     {(currentUser?.email || 'U')[0].toUpperCase()}
                   </div>
                 </div>
                 
                 <div className="text-right hidden sm:block">
                   {!currentUser?.isAnonymous && <div className="text-xs text-textMuted">{t('loggedInAs')}</div>}
                   <div className="text-sm font-medium leading-none text-white">{(currentUser?.email || '').split('@')[0] || t('guest')}</div>
                 </div>
               </>
             ) : (
               <>
                 <div className="w-8 h-8 rounded-full bg-surfaceHighlight flex items-center justify-center group-hover:scale-110 transition-transform">
                   <User className="w-4 h-4 text-white" />
                 </div>
                 <span className="text-sm font-medium hidden sm:block text-white">{t('login')}</span>
               </>
             )}
           </button>
        </div>
      </nav>

      <main className="pt-24 pb-24 lg:pb-6 px-2 sm:px-4 h-screen flex flex-col lg:flex-row gap-4 sm:gap-6 overflow-hidden">
        
        {/* Left Panel - Tools (Desktop) - KISS Layout */}
        <aside className="hidden lg:flex flex-col gap-4 w-28 glass-panel rounded-2xl p-3 items-center animate-slide-in-right relative" style={{animationDelay: '0.1s'}}>
           <div className="flex flex-col gap-2.5 w-full">
             <button 
               ref={uploadBtnDesktopRef}
               onClick={handleUploadClick}
               disabled={isProcessing}
               className="w-full py-3 px-2 flex flex-col items-center justify-center gap-2 group bg-gradient-to-br from-blue-500/20 to-primary-500/20 hover:from-blue-500/30 hover:to-primary-500/30 border border-blue-400/30 hover:border-blue-400/50 rounded-xl transition-all duration-300 shadow-lg shadow-blue-500/10 hover:shadow-blue-500/20"
               title={t('uploadImage')}
             >
               <Upload className="w-6 h-6 group-hover:scale-110 transition-transform text-blue-400" />
               <span className="text-[11px] text-blue-300 font-medium">{t('uploadImage')}</span>
             </button>

             <button 
               ref={addObjectBtnDesktopRef}
               onClick={handleObjectUploadClick}
               disabled={isProcessing}
               className={`w-full py-3 px-2 flex flex-col items-center justify-center gap-2 group ${objectImageFile ? 'bg-gradient-to-br from-primary-500/30 to-secondary-500/30 border-primary-400/50' : 'bg-gradient-to-br from-green-500/20 to-emerald-500/20 border-green-400/30 hover:border-green-400/50'} hover:from-green-500/30 hover:to-emerald-500/30 border rounded-xl transition-all duration-300 shadow-lg shadow-green-500/10 hover:shadow-green-500/20 disabled:opacity-50 disabled:cursor-not-allowed`}
               title={t('uploadItem')}
             >
               <Plus className={`w-6 h-6 group-hover:scale-110 transition-transform ${objectImageFile ? 'text-primary-400' : 'text-green-400'}`} />
               <span className={`text-[11px] font-medium ${objectImageFile ? 'text-primary-300' : 'text-green-300'}`}>{t('uploadItem')}</span>
             </button>

             <div className="h-px w-full bg-white/10 my-1"></div>

            {/* Main Tool - Ready Designs */}
            <button
              ref={styleBtnRef}
              onClick={() => setShowReadyDesignsModal(true)}
              disabled={isProcessing}
              className={`w-full py-3 px-2 flex flex-col items-center justify-center gap-2 group bg-gradient-to-br from-purple-500/20 to-pink-500/20 hover:from-purple-500/30 hover:to-pink-500/30 border border-purple-400/30 hover:border-purple-400/50 rounded-xl transition-all duration-300 shadow-lg shadow-purple-500/10 hover:shadow-purple-500/20 ${showReadyDesignsModal ? 'ring-2 ring-purple-400/50' : ''} disabled:opacity-50 disabled:cursor-not-allowed`}
              title={t('readyDesigns')}
            >
              <Wand2 className={`w-6 h-6 group-hover:scale-110 transition-transform text-purple-400`} />
              <span className="text-[11px] text-purple-300 font-medium">{t('readyDesigns')}</span>
            </button>

{/* More Tools Button */}
            <button
               onClick={() => setShowMobileMoreTools(!showMobileMoreTools)}
               disabled={isProcessing}
               className={`w-full py-3 px-2 flex flex-col items-center justify-center gap-2 group bg-surfaceHighlight/40 border border-white/80 rounded-xl transition-all duration-300 ${showMobileMoreTools ? 'bg-surfaceHighlight/60' : 'hover:bg-surfaceHighlight/50'} disabled:opacity-50 disabled:cursor-not-allowed`}
               title={t('moreTools')}
             >
               <MoreHorizontal className={`w-5 h-5 group-hover:scale-110 transition-transform ${showMobileMoreTools ? 'text-primary-300' : 'text-textMuted'}`} />
               <span className="text-[11px] text-textMuted font-medium">{t('more')}</span>
             </button>
           </div>

        </aside>

        {/* Desktop More Tools Dropdown - fixed position with backdrop */}
        {showMobileMoreTools && (
          <>
            {/* Invisible backdrop to close menu on click */}
            <div 
              className="hidden lg:block fixed inset-0 z-40" 
              onClick={() => setShowMobileMoreTools(false)}
            />
            <div className={`hidden lg:block fixed top-1/2 -translate-y-1/2 w-48 bg-surface/95 backdrop-blur-xl rounded-xl p-3 shadow-2xl border border-white/10 z-50 animate-fade-in ${isRTL ? 'right-32' : 'left-32'}`}>
              <div className="flex items-center justify-between mb-3 pb-2 border-b border-white/10">
                <span className="text-sm font-medium text-white">{t('moreTools')}</span>
                <button 
                  onClick={() => setShowMobileMoreTools(false)}
                  className="p-1 rounded-full hover:bg-white/10 transition-colors"
                >
                  <X className="w-4 h-4 text-textMuted" />
                </button>
              </div>
              <div className="flex flex-col gap-1">
                {[
                  { icon: Palette, label: t('colors'), action: () => { setShowColorPalette(!showColorPalette); setShowMobileMoreTools(false); } },
                  { icon: Sofa, label: t('furniture'), action: () => { setShowFurnitureOptions(!showFurnitureOptions); setShowMobileMoreTools(false); } },
                  { icon: Lightbulb, label: t('lighting'), action: () => { setShowLightingOptions(!showLightingOptions); setShowMobileMoreTools(false); } },
                  { icon: Home, label: t('doorsWindows'), action: () => { setShowDoorsWindowsOptions(!showDoorsWindowsOptions); setShowMobileMoreTools(false); } },
                  { icon: Droplets, label: t('bathroomShort'), action: () => { setShowBathroomOptions(!showBathroomOptions); setShowMobileMoreTools(false); } },
                  { icon: Hammer, label: t('repairs'), action: () => { setShowRepairsOptions(!showRepairsOptions); setShowMobileMoreTools(false); } },
                ].map((tool, i) => (
                  <button
                    key={i}
                    onClick={tool.action}
                    disabled={isProcessing}
                    className="flex items-center gap-3 w-full p-2 rounded-lg hover:bg-white/10 transition-colors text-right disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <tool.icon className="w-5 h-5 text-primary-400" />
                    <span className="text-sm text-white">{tool.label}</span>
                  </button>
                ))}
              </div>
              
              {/* Designer Avatar Toggle */}
              <div className="mt-2 pt-2 border-t border-white/10">
                <button 
                  onClick={toggleDesignerAvatar}
                  className={`flex items-center justify-between w-full p-2 rounded-lg transition-all ${
                    isDesignerAvatarEnabled 
                      ? 'bg-emerald-500/20 hover:bg-emerald-500/30' 
                      : 'hover:bg-white/10'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <Power className={`w-5 h-5 ${isDesignerAvatarEnabled ? 'text-emerald-400' : 'text-gray-500'}`} />
                    <span className="text-sm text-white">{t('aiDesigner')}</span>
                  </div>
                  <div 
                    className={`w-9 h-5 rounded-full p-0.5 transition-all ${
                      isDesignerAvatarEnabled ? 'bg-emerald-500' : 'bg-gray-600'
                    }`}
                    dir="ltr"
                  >
                    <div className={`w-4 h-4 rounded-full bg-white shadow-sm transition-transform ${
                      isDesignerAvatarEnabled ? 'translate-x-4' : 'translate-x-0'
                    }`} />
                  </div>
                </button>
              </div>
            </div>
          </>
        )}

        {/* Center Canvas */}
        <section className="flex-1 relative flex flex-col min-h-0 glass-card p-1 animate-fade-in mb-36 lg:mb-0">
           <div className="flex-1 relative rounded-xl overflow-hidden bg-black/20 group flex items-center justify-center">
             
             {/* Image or Slider */}
             {showComparison && beforeImage ? (
               <BeforeAfterSlider 
                 beforeImage={beforeImage}
                 afterImage={mainImage}
               />
             ) : (
               <img 
                 src={mainImage} 
                 alt="Canvas" 
                 className={`w-full h-full object-contain transition-all duration-500 ${isProcessing ? 'scale-[1.02] blur-sm brightness-50' : 'group-hover:scale-[1.01]'}`}
                 onClick={handleMainImageClick}
                 onLoad={handleImageLoad}
                 style={{ objectPosition: 'center' }}
               />
             )}

             {/* Loading Overlay */}
             {isProcessing && (
               <div className="absolute inset-0 flex flex-col items-center justify-center z-20 pointer-events-none">
                 <div className="w-20 h-20 relative">
                   <div className="absolute inset-0 rounded-full border-4 border-primary-500/30 animate-ping"></div>
                   <div className="absolute inset-0 rounded-full border-4 border-t-primary-400 border-r-secondary-400 border-b-primary-600 border-l-secondary-600 animate-spin"></div>
                 </div>
                 <p className="mt-4 text-lg font-medium text-white animate-pulse">{t('processingNewDesign')}</p>
               </div>
             )}

             {/* Floating Actions on Canvas - Horizontal Layout Top Right */}
             {/* Removed as requested - Actions are now only in the Image Modal */}

             {/* Mobile History Button - Top Left of Image */}
             <button 
               onClick={() => setShowMobileHistory(true)}
               className="lg:hidden absolute top-4 left-4 p-2 bg-black/50 text-white rounded-lg backdrop-blur-md hover:bg-black/70 transition-colors shadow-lg border border-white/10 z-10"
               title={t('history')}
             >
               <History className="w-5 h-5" />
             </button>

             {/* Object Thumbnail on Stage (Desktop) */}
             {objectImage && (
               <div className="absolute bottom-4 right-4 z-20 animate-fade-in hidden lg:block">
                 <div className="relative group">
                   <div className="w-20 h-20 rounded-xl border-2 border-white/30 overflow-hidden shadow-lg bg-black/40 backdrop-blur-sm">
                     <img src={objectImage} alt="Object" className="w-full h-full object-cover" />
                   </div>
                   <button 
                     onClick={handleRemoveObjectImage}
                     className="absolute -top-2 -left-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center shadow-md hover:bg-red-600 transition-colors"
                     title="הסר אובייקט"
                   >
                     <span className="text-xs font-bold">✕</span>
                   </button>
                 </div>
               </div>
             )}

             {/* Mobile Prompt Input Overlay (Bottom) - Visual Only, functional one is fixed */}
             <div className="lg:hidden absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-black/80 to-transparent pointer-events-none"></div>
           </div>

           {/* Desktop Prompt Input Bar */}
           <div className="hidden lg:flex items-center gap-4 p-4 bg-surface/30 border-t border-white/5 backdrop-blur-md">
             <div className="flex-1 relative">
               <input 
                 type="text" 
                 value={customPrompt}
                 onChange={(e) => setCustomPrompt(e.target.value)}
                 placeholder={t('promptPlaceholder')}
                 disabled={isProcessing}
                 className="w-full bg-surface/50 border border-white/10 rounded-xl px-4 py-3 pr-10 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500/50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                 onKeyPress={(e) => e.key === 'Enter' && !isProcessing && handleCustomPromptSubmit()}
               />
               <Sparkles className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 pointer-events-none" />
               {customPrompt && (
                 <button 
                   onClick={() => !isProcessing && setCustomPrompt('')}
                   disabled={isProcessing}
                   className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed"
                 >
                   ×
                 </button>
               )}
             </div>

             <button
               ref={createBtnRef}
               onClick={handleCustomPromptSubmit}
               disabled={isProcessing || !customPrompt.trim()}
               className="btn-primary flex items-center gap-2 px-8 disabled:opacity-50 disabled:cursor-not-allowed"
             >
               <span>{t('create')}</span>
               <Sparkles className="w-4 h-4" />
             </button>
           </div>
        </section>

        {/* Right Panel - History & Details (Desktop) */}
        <aside className="hidden lg:flex flex-col gap-4 w-80 glass-panel rounded-2xl p-4 animate-slide-in-right" style={{animationDelay: '0.2s'}}>
          <h3 className="text-sm font-semibold text-textMuted uppercase tracking-wider mb-2">{t('designHistory')}</h3>
          
          <div className={`flex-1 overflow-y-auto scrollbar-custom pr-1 -mr-1 space-y-3 ${isProcessing ? 'opacity-50 pointer-events-none' : ''}`}>
            {imageHistory.length === 0 ? (
              <div className="text-center py-10 opacity-50">
                <Sparkles className="w-8 h-8 mx-auto mb-2" />
                <p className="text-xs">{t('noHistoryYet')}</p>
              </div>
            ) : (
              imageHistory.map((entry) => (
                <div 
                  key={entry.id} 
                  onClick={() => !isProcessing && handleHistoryImageClick(entry)}
                  className="group relative rounded-xl overflow-hidden border border-white/5 hover:border-primary-500/30 transition-all cursor-pointer bg-surface/40"
                >
                  <img 
                    src={entry.thumbnailUrl || entry.storageUrl || entry.imageUrl} 
                    alt="" 
                    className="w-full h-32 object-cover transition-transform duration-700 group-hover:scale-110" 
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-3">
                    <p className="text-xs text-white line-clamp-2 mb-1">{entry.prompt || 'ללא תיאור'}</p>
                    <p className="text-[10px] text-gray-400">{displayTimestamp(entry)}</p>
                  </div>
                </div>
              ))
            )}
            
            {isLoadingHistory && (
               <div className="flex justify-center py-4">
                 <Loader2 className="w-6 h-6 text-primary-400 animate-spin" />
               </div>
            )}
            
            {hasMoreHistory && !isLoadingHistory && imageHistory.length > 0 && (
              <button onClick={loadMoreHistory} disabled={isProcessing} className="w-full py-2 text-xs text-primary-300 hover:text-primary-200 hover:bg-white/5 rounded-lg transition-colors border border-white/5 disabled:opacity-50 disabled:cursor-not-allowed">
                טען עוד
              </button>
            )}
          </div>
        </aside>


      {/* Notification Toast */}
      {showNotification && (
        <div className="fixed bottom-36 lg:bottom-10 left-1/2 transform -translate-x-1/2 bg-emerald-600/90 text-white px-6 py-3 rounded-2xl shadow-lg z-[100] animate-fade-in-up flex items-center gap-2 backdrop-blur-md border border-white/10 text-center">
          <Sparkles className="w-4 h-4 text-white flex-shrink-0" />
          <span className="text-sm font-medium">
            <span className="md:inline block">שורת פרומפט עודכנה.</span>
            <span className="hidden md:inline"> </span>
            <span className="md:inline block">{t('promptUpdated')}</span>
          </span>
        </div>
      )}

      {/* First Upload Tip */}
      {showFirstUploadTip && (
        <div className="fixed inset-0 z-[100]" onClick={() => {
          setShowFirstUploadTip(false)
          setHasSeenFirstUploadTip(true)
          localStorage.setItem('hasSeenFirstUploadTip', 'true')
        }}>
          {/* Dark overlay */}
          <div className="absolute inset-0 bg-black/70" />
          
          {/* Tooltip */}
          <div className="absolute left-1/2 -translate-x-1/2 bottom-44 lg:bottom-32 w-[90%] max-w-[340px] bg-white text-gray-900 p-5 rounded-2xl shadow-2xl animate-bounce-in" dir={isRTL ? 'rtl' : 'ltr'} onClick={(e) => e.stopPropagation()}>
            {/* Arrow pointing down */}
            <div className="absolute bottom-[-8px] left-1/2 -translate-x-1/2 w-0 h-0 border-solid border-t-white border-r-transparent border-l-transparent border-b-transparent border-[8px]"></div>
            
            <div className="flex justify-between items-start mb-3">
              <h3 className="font-bold text-lg text-primary-600">🎨 {t('imageUploadedSuccess')}</h3>
              <button 
                onClick={() => {
                  setShowFirstUploadTip(false)
                  setHasSeenFirstUploadTip(true)
                  localStorage.setItem('hasSeenFirstUploadTip', 'true')
                }} 
                className="text-gray-400 hover:text-gray-600 transition-colors p-1"
              >
                <X size={18} />
              </button>
            </div>
            
            <p className="text-sm text-gray-600 mb-4 leading-relaxed">
              {t('describeWhatToChange')}
              <br /><br />
              {t('tipClickMore')}
            </p>
            
            <div className="flex items-center gap-2 p-3 bg-primary-50 rounded-xl mb-4">
              <span className="text-2xl">👇</span>
              <span className="text-sm text-primary-700 font-medium">{t('writeRequestAndCreate')}</span>
            </div>
            
            <button 
              onClick={() => {
                setShowFirstUploadTip(false)
                setHasSeenFirstUploadTip(true)
                localStorage.setItem('hasSeenFirstUploadTip', 'true')
              }}
              className="w-full bg-primary-600 hover:bg-primary-700 text-white py-2.5 rounded-xl text-sm font-medium transition-all hover:shadow-lg"
            >
              {t('gotItLetsStart')}
            </button>
          </div>
        </div>
      )}

      </main>

      {/* Mobile Bottom Sheet / Controls */}
      <div className="lg:hidden fixed bottom-0 left-0 right-0 z-40 bg-surface/95 backdrop-blur-xl border-t border-white/10 pb-safe pt-3 rounded-t-2xl shadow-[0_-10px_40px_rgba(0,0,0,0.5)] transition-transform duration-300 transform translate-y-0">
        <div className="px-4 space-y-3 pb-6">
          {/* Prompt Input */}
          <div className="relative">
            {/* Object Thumbnail (Mobile) */}
            {objectImage && (
              <div className="absolute -top-20 right-0 z-20 animate-fade-in lg:hidden">
                <div className="relative group">
                   <div className="w-16 h-16 rounded-lg border border-white/30 overflow-hidden shadow-lg bg-black/40 backdrop-blur-sm">
                     <img src={objectImage} alt="Object" className="w-full h-full object-cover" />
                   </div>
                   <button 
                     onClick={handleRemoveObjectImage}
                     className="absolute -top-2 -left-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center shadow-md hover:bg-red-600 transition-colors"
                     title="הסר אובייקט"
                   >
                     <span className="text-xs font-bold">✕</span>
                   </button>
                 </div>
              </div>
            )}

            <div className="flex items-center gap-2 bg-black/20 rounded-xl p-1 border border-white/5">
            <input 
               type="text" 
               value={customPrompt}
               onChange={(e) => setCustomPrompt(e.target.value)}
               placeholder={t('whatToChange')}
               disabled={isProcessing}
               className="flex-1 bg-transparent border-none text-white placeholder-gray-500 focus:ring-0 px-2 text-sm py-2 disabled:opacity-50 disabled:cursor-not-allowed"
               onKeyPress={(e) => e.key === 'Enter' && !isProcessing && handleCustomPromptSubmit()}
            />
            {customPrompt && (
              <button 
                onClick={() => !isProcessing && setCustomPrompt('')}
                disabled={isProcessing}
                className="text-gray-500 hover:text-white p-1 rounded-full hover:bg-white/10 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                ×
              </button>
            )}
            <button 
              ref={createBtnMobileRef}
              onClick={handleCustomPromptSubmit} 
              disabled={!customPrompt.trim() || isProcessing}
              className="p-3 bg-primary-500 rounded-xl text-white shadow-lg shadow-primary-900/20 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Sparkles className="w-5 h-5" />
            </button>
          </div>
          </div>
          
          {/* Quick Tools - Simplified KISS Layout */}
          <div className="flex justify-center gap-4 py-1">
             <button 
               ref={uploadBtnMobileRef}
               onClick={handleUploadClick} 
               disabled={isProcessing}
               className="flex flex-col items-center gap-1 disabled:opacity-50 disabled:cursor-not-allowed"
             >
               <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-blue-500/30 to-primary-500/30 flex items-center justify-center border border-blue-400/40 active:scale-95 transition-transform shadow-lg shadow-blue-500/20">
                 <Upload className="w-6 h-6 text-blue-400" />
               </div>
               <span className="text-[10px] text-blue-300 font-medium">{t('uploadImage')}</span>
             </button>
             
             <button 
               ref={addObjectBtnMobileRef}
               onClick={handleObjectUploadClick}
               disabled={isProcessing}
               className="flex flex-col items-center gap-1 disabled:opacity-50 disabled:cursor-not-allowed"
             >
               <div className={`w-14 h-14 rounded-2xl ${objectImageFile ? 'bg-gradient-to-br from-primary-500/30 to-secondary-500/30 border-primary-400/40' : 'bg-gradient-to-br from-green-500/30 to-emerald-500/30 border-green-400/40'} flex items-center justify-center border active:scale-95 transition-transform shadow-lg shadow-green-500/20`}>
                 <Plus className={`w-6 h-6 ${objectImageFile ? 'text-primary-400' : 'text-green-400'}`} />
               </div>
               <span className={`text-[10px] font-medium ${objectImageFile ? 'text-primary-300' : 'text-green-300'}`}>{t('uploadItem')}</span>
             </button>

            <button 
              ref={styleBtnMobileRef}
              onClick={() => setShowReadyDesignsModal(true)}
              disabled={isProcessing}
              className="flex flex-col items-center gap-1 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-purple-500/30 to-pink-500/30 flex items-center justify-center border border-purple-400/40 active:scale-95 transition-transform shadow-lg shadow-purple-500/20">
                <Wand2 className="w-6 h-6 text-purple-400" />
              </div>
              <span className="text-[10px] text-purple-300 font-medium">{t('readyDesigns')}</span>
            </button>

             {/* Mobile Designer Avatar Trigger - Inside Toolbar - Placed before "More" button */}
             {isMobile && !isProcessing && isDesignerAvatarEnabled && (avatarSuggestions.length > 0 || isAvatarThinking) && (
                <div className="relative flex flex-col items-center gap-1">
                  <div className="w-14 h-14 flex items-center justify-center">
                    <DesignerAvatar 
                      suggestions={avatarSuggestions} 
                      onSelect={handleAvatarSuggestionSelect} 
                      onClose={() => setAvatarSuggestions([])}
                      isMobile={true}
                      isThinking={isAvatarThinking}
                      initialShowSuggestions={shouldAutoOpenAvatar} 
                    />
                  </div>
                  <span className="text-[10px] text-purple-300 font-medium">{t('aiDesigner')}</span>
                </div>
             )}

             <button 
               onClick={() => setShowMobileMoreTools(true)}
               disabled={isProcessing}
               className="flex flex-col items-center gap-1 disabled:opacity-50 disabled:cursor-not-allowed"
             >
               <div className="w-14 h-14 rounded-2xl bg-surfaceHighlight/40 flex items-center justify-center border border-white/80 active:scale-95 transition-transform">
                 <MoreHorizontal className="w-6 h-6 text-textMuted" />
               </div>
               <span className="text-[10px] text-textMuted font-medium">{t('more')}</span>
             </button>

          </div>

          {/* More Tools Modal */}
          {showMobileMoreTools && (
            <div className="fixed inset-0 z-50 flex items-end justify-center" onClick={() => setShowMobileMoreTools(false)}>
              <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
              <div 
                className="relative w-full max-w-md bg-surface/95 backdrop-blur-xl rounded-t-3xl p-6 pb-8 animate-slide-up border-t border-white/10"
                onClick={(e) => e.stopPropagation()}
              >
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-lg font-semibold text-white">{t('moreTools')}</h3>
                  <button 
                    onClick={() => setShowMobileMoreTools(false)}
                    className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
                  >
                    <X className="w-5 h-5 text-white" />
                  </button>
                </div>
                <div className="grid grid-cols-3 gap-4">
                  {[
                    { icon: Palette, label: t('colors'), action: () => { setShowColorPalette(true); setShowMobileMoreTools(false); } },
                    { icon: Sofa, label: t('furniture'), action: () => { setShowFurnitureOptions(true); setShowMobileMoreTools(false); } },
                    { icon: Lightbulb, label: t('lighting'), action: () => { setShowLightingOptions(true); setShowMobileMoreTools(false); } },
                    { icon: Home, label: t('doorsWindows'), action: () => { setShowDoorsWindowsOptions(true); setShowMobileMoreTools(false); } },
                    { icon: Droplets, label: t('bathroomShort'), action: () => { setShowBathroomOptions(true); setShowMobileMoreTools(false); } },
                    { icon: Hammer, label: t('repairs'), action: () => { setShowRepairsOptions(true); setShowMobileMoreTools(false); } },
             ].map((tool, i) => (
               <button 
                 key={i}
                 onClick={tool.action} 
                 disabled={isProcessing}
                      className="flex flex-col items-center gap-2 p-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/10 active:scale-95 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      <tool.icon className="w-7 h-7 text-primary-400" />
                      <span className="text-xs text-white font-medium">{tool.label}</span>
               </button>
             ))}
          </div>
                
                {/* Designer Avatar Toggle */}
                <div className="mt-4 pt-4 border-t border-white/10">
                  <button 
                    onClick={toggleDesignerAvatar}
                    className={`w-full flex items-center justify-between p-4 rounded-2xl transition-all active:scale-[0.98] ${
                      isDesignerAvatarEnabled 
                        ? 'bg-gradient-to-r from-emerald-500/20 to-green-500/20 border border-emerald-400/30' 
                        : 'bg-white/5 border border-white/10'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <Power className={`w-6 h-6 ${isDesignerAvatarEnabled ? 'text-emerald-400' : 'text-gray-500'}`} />
                      <div className="text-right">
                        <span className="text-sm text-white font-medium block">{t('aiDesigner')}</span>
                        <span className={`text-xs ${isDesignerAvatarEnabled ? 'text-emerald-300' : 'text-gray-500'}`}>
                          {isDesignerAvatarEnabled ? t('aiDesignerActiveClickToDisable') : t('aiDesignerInactiveClickToEnable')}
                        </span>
                      </div>
                    </div>
                    <div 
                      className={`w-12 h-7 rounded-full p-1 transition-all ${
                        isDesignerAvatarEnabled ? 'bg-emerald-500' : 'bg-gray-600'
                      }`}
                      dir="ltr"
                    >
                      <div className={`w-5 h-5 rounded-full bg-white shadow-md transition-transform ${
                        isDesignerAvatarEnabled ? 'translate-x-5' : 'translate-x-0'
                      }`} />
                    </div>
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Recent History Horizontal Scroll - Hidden on Mobile */}
          <div className="hidden">
          {imageHistory.length > 0 && (
             <div className={`pt-2 border-t border-white/5 ${isProcessing ? 'opacity-50 pointer-events-none' : ''}`}>
               <div className="text-[10px] text-textMuted mb-2">{t('history')} ({imageHistory.length})</div>
               <div 
                 className="flex gap-3 overflow-x-auto scrollbar-hide -mx-4 px-4"
                 onScroll={(e) => {
                   if (isProcessing) return
                   const { scrollLeft, scrollWidth, clientWidth } = e.target
                   if (scrollLeft + clientWidth >= scrollWidth - 10 && hasMoreHistory && !isLoadingMoreHistory) {
                     loadMoreHistory()
                   }
                 }}
               >
                 {imageHistory.map((entry) => (
                    <div 
                      key={entry.id} 
                      onClick={() => !isProcessing && handleHistoryImageClick(entry)}
                      className="flex-shrink-0 w-16 h-16 rounded-lg overflow-hidden border border-white/10 relative hover:border-primary-500/50 transition-colors"
                    >
                      <img src={entry.thumbnailUrl || entry.storageUrl || entry.imageUrl} alt="" className="w-full h-full object-cover" />
                    </div>
                 ))}
                 
                 {/* Loading more indicator */}
                 {isLoadingMoreHistory && (
                   <div className="flex-shrink-0 w-16 h-16 rounded-lg bg-white/5 flex items-center justify-center">
                     <Loader2 className="w-5 h-5 text-primary-400 animate-spin" />
                   </div>
                 )}
                 
                 {/* Load more button */}
                 {hasMoreHistory && !isLoadingMoreHistory && (
                   <button 
                     onClick={loadMoreHistory}
                     disabled={isProcessing}
                     className="flex-shrink-0 w-16 h-16 rounded-lg bg-white/5 border border-white/10 border-dashed flex flex-col items-center justify-center text-textMuted hover:bg-white/10 hover:border-primary-500/30 transition-all active:scale-95 gap-1 disabled:opacity-50 disabled:cursor-not-allowed"
                   >
                     <span className="text-[10px]">{t('more')}</span>
                     <span className="text-lg">←</span>
                   </button>
                 )}
               </div>
             </div>
          )}
          </div>
        </div>
      </div>

      {/* Modals Implementation */}

      {/* Mobile History Drawer */}
      {showMobileHistory && (
        <>
          {/* Backdrop for closing */}
          <div 
            className="fixed inset-0 z-[59] lg:hidden" 
            onClick={() => setShowMobileHistory(false)}
          />
          
          {/* History Panel - Floating on top left of image stage */}
          <div className="fixed top-24 left-4 w-72 max-h-[60vh] bg-surface/95 backdrop-blur-md border border-white/10 shadow-2xl rounded-xl z-[60] flex flex-col lg:hidden animate-fade-in overflow-hidden">
            <div className="flex justify-between items-center p-4 border-b border-white/10 bg-surface/50">
              <h3 className="text-lg font-bold text-white flex items-center gap-2">
                <History className="w-5 h-5 text-primary-400" />
                {t('designHistory')}
              </h3>
              <button 
                onClick={() => setShowMobileHistory(false)} 
                className="p-1 rounded-full hover:bg-white/10 text-gray-400 hover:text-white transition-colors"
              >
                <span className="text-xl leading-none">×</span>
              </button>
            </div>
            
            <div className="flex-1 overflow-y-auto p-3 scrollbar-custom space-y-2">
              {imageHistory.length === 0 ? (
                <div className="text-center py-8 opacity-50">
                  <Sparkles className="w-6 h-6 mx-auto mb-2" />
                  <p className="text-xs text-gray-400">{t('noHistoryYet')}</p>
                </div>
              ) : (
                imageHistory.map((entry) => (
                  <div 
                    key={entry.id} 
                    onClick={() => {
                      if (!isProcessing) {
                        handleHistoryImageClick(entry)
                        setShowMobileHistory(false)
                      }
                    }}
                    className="group relative rounded-lg overflow-hidden border border-white/5 hover:border-primary-500/30 transition-all cursor-pointer bg-surface/40 flex items-center gap-3 p-2"
                  >
                    <img 
                      src={entry.thumbnailUrl || entry.storageUrl || entry.imageUrl} 
                      alt="" 
                      className="w-16 h-12 object-cover rounded-md" 
                    />
                    <div className="flex-1 min-w-0">
                      <p className="text-xs text-white line-clamp-1 mb-0.5">{entry.prompt || 'ללא תיאור'}</p>
                      <p className="text-[10px] text-gray-400">{displayTimestamp(entry)}</p>
                    </div>
                  </div>
                ))
              )}
              
              {isLoadingHistory && (
                 <div className="flex justify-center py-2">
                   <Loader2 className="w-5 h-5 text-primary-400 animate-spin" />
                 </div>
              )}
              
              {hasMoreHistory && !isLoadingHistory && imageHistory.length > 0 && (
                <button onClick={loadMoreHistory} disabled={isProcessing} className="w-full py-2 text-xs text-primary-300 hover:text-primary-200 hover:bg-white/5 rounded-lg transition-colors border border-white/5 disabled:opacity-50 disabled:cursor-not-allowed">
                  טען עוד
                </button>
              )}
            </div>
          </div>
        </>
      )}
      
      {/* Image Modal - Full Size View with Actions */}
      {showImageModal && (
        <div 
          className="fixed inset-0 bg-black/95 backdrop-blur-sm flex items-center justify-center z-[70] p-4 md:p-8 animate-fade-in"
          onClick={handleCloseModal}
        >
          <div className="relative w-full h-full flex flex-col items-center justify-center gap-4" onClick={(e) => e.stopPropagation()}>
            
            {/* Top Close Button (Corner X) */}
            <button
              onClick={handleCloseModal}
              className="absolute top-2 right-2 bg-black/40 hover:bg-black/60 text-white p-2 md:p-3 rounded-full backdrop-blur-md border border-white/10 z-50 transition-all hover:scale-110"
            >
              <X className="w-5 h-5 md:w-6 md:h-6" />
            </button>

            {/* Content Area */}
            <div 
              ref={lensContainerRef}
              className={`flex-1 w-full relative flex items-center justify-center overflow-hidden rounded-2xl bg-black/50 border border-white/5 ${isMobile ? 'mb-20' : ''} ${isGoogleLensMode ? 'cursor-crosshair' : ''}`}
              onMouseDown={isGoogleLensMode ? handleLensMouseDown : undefined}
              onMouseMove={isGoogleLensMode ? handleLensMouseMove : undefined}
              onMouseUp={isGoogleLensMode ? handleLensMouseUp : undefined}
              onMouseLeave={isGoogleLensMode ? handleLensMouseUp : undefined}
              onTouchStart={isGoogleLensMode ? handleLensMouseDown : undefined}
              onTouchMove={isGoogleLensMode ? handleLensMouseMove : undefined}
              onTouchEnd={isGoogleLensMode ? handleLensMouseUp : undefined}
            >
              {beforeImage && showComparison && !isGoogleLensMode ? (
                <BeforeAfterSlider 
                  beforeImage={beforeImage} 
                  afterImage={mainImage} 
                />
              ) : (
                <img
                  ref={lensImageRef}
                  src={mainImage}
                  alt="Full size view"
                  className={`max-w-full max-h-full object-contain rounded-lg shadow-2xl ${isGoogleLensMode ? 'select-none pointer-events-none' : ''}`}
                  draggable={false}
                  crossOrigin="anonymous"
                />
              )}
              
              {/* Google Lens Selection Overlay */}
              {isGoogleLensMode && lensSelection && (
                <div
                  className="absolute border-2 border-blue-500 bg-blue-500/20 pointer-events-none"
                  style={{
                    left: Math.min(lensSelection.startX, lensSelection.endX),
                    top: Math.min(lensSelection.startY, lensSelection.endY),
                    width: Math.abs(lensSelection.endX - lensSelection.startX),
                    height: Math.abs(lensSelection.endY - lensSelection.startY),
                  }}
                >
                  <div className="absolute -top-6 left-1/2 -translate-x-1/2 bg-blue-500 text-white text-xs px-2 py-1 rounded whitespace-nowrap">
                    סמן אזור לחיפוש
                  </div>
                </div>
              )}
              
              {/* Google Lens Mode Instructions */}
              {isGoogleLensMode && !lensSelection && (
                <div className="absolute top-3 left-1/2 -translate-x-1/2 z-30 pointer-events-none">
                  <div className="bg-blue-600/90 backdrop-blur-sm text-white px-4 py-2 rounded-full text-center shadow-lg flex items-center gap-2">
                    <Search className="w-4 h-4" />
                    <p className="text-sm font-medium">גרור מלבן מסביב לאובייקט לחיפוש</p>
                  </div>
                </div>
              )}
              
              {/* Uploading Indicator */}
              {isUploadingLensImage && (
                <div className="absolute inset-0 flex items-center justify-center bg-black/60 z-20">
                  <div className="text-center">
                    <Loader2 className="w-10 h-10 text-blue-400 animate-spin mx-auto mb-2" />
                    <p className="text-white">מחפש ב-Google Lens...</p>
                  </div>
                </div>
              )}
            </div>

            {/* Mobile Bottom Bar */}
            {isMobile ? (
              isNewGeneration && !hasConfirmedDesign && beforeImage ? (
                /* Mobile Design Confirmation - Minimal */
                <div className="fixed bottom-0 left-0 right-0 bg-black/90 backdrop-blur-xl border-t border-white/10 px-3 py-3 pb-7 z-50">
                  <div className="flex items-center gap-2">
                    <button 
                      onClick={handleRevertToOriginal}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2.5 px-3 rounded-xl bg-white/5 border border-white/10 text-gray-300 active:bg-white/10 transition-all"
                    >
                      <RotateCcw className="w-4 h-4" />
                      <span className="text-sm font-medium">חזור למקור</span>
                    </button>
                    
                    <button 
                      onClick={handleConfirmDesign}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2.5 px-3 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 text-white font-semibold active:from-emerald-600 active:to-teal-600 transition-all"
                    >
                      <CheckCircle className="w-4 h-4" />
                      <span className="text-sm">{t('loveItSave')}</span>
                    </button>
                  </div>
                </div>
              ) : (
                /* Mobile Action Buttons */
                <div className="fixed bottom-0 left-0 right-0 bg-surface/95 backdrop-blur-xl border-t border-white/10 p-2 pb-8 z-50 grid grid-cols-5 gap-1">
                  <button 
                    onClick={() => setShowComparison(!showComparison)}
                    disabled={!beforeImage || isGoogleLensMode}
                    className={`flex flex-col items-center justify-center gap-1 p-2 rounded-xl transition-all ${
                      showComparison 
                        ? 'text-primary-300 bg-primary-500/20' 
                        : 'text-gray-400 hover:text-white disabled:opacity-30'
                    }`}
                  >
                    <ArrowLeftRight className="w-5 h-5" />
                    <span className="text-[10px] font-medium">{t('comparison')}</span>
                  </button>

                  {/* Google Lens Button */}
                  {isGoogleLensMode ? (
                    <button 
                      onClick={cancelGoogleLens}
                      className="flex flex-col items-center justify-center gap-1 p-2 rounded-xl text-red-400 bg-red-500/10 hover:bg-red-500/20 transition-all"
                    >
                      <X className="w-5 h-5" />
                      <span className="text-[10px] font-medium">{t('cancel')}</span>
                    </button>
                  ) : (
                    <button 
                      onClick={handleGoogleLensStart}
                      className="flex flex-col items-center justify-center gap-1 p-2 rounded-xl text-blue-400 bg-blue-500/10 hover:bg-blue-500/20 transition-all"
                    >
                      <Search className="w-5 h-5" />
                      <span className="text-[10px] font-medium">{t('products')}</span>
                    </button>
                  )}

                  <button 
                    onClick={handleWhatsAppShare}
                    disabled={isGoogleLensMode}
                    className="flex flex-col items-center justify-center gap-1 p-2 rounded-xl text-green-400 bg-green-500/10 hover:bg-green-500/20 transition-all disabled:opacity-30"
                  >
                    <Share2 className="w-5 h-5" />
                    <span className="text-[10px] font-medium">{t('whatsApp')}</span>
                  </button>
                  
                  <button 
                    onClick={handleDownload}
                    disabled={isGoogleLensMode}
                    className="flex flex-col items-center justify-center gap-1 p-2 rounded-xl text-gray-300 hover:text-white hover:bg-white/10 transition-all disabled:opacity-30"
                  >
                    <Download className="w-5 h-5" />
                    <span className="text-[10px] font-medium">{t('download')}</span>
                  </button>

                  <button 
                    onClick={isGoogleLensMode ? cancelGoogleLens : handleCloseModal}
                    className="flex flex-col items-center justify-center gap-1 p-2 rounded-xl text-red-400 hover:bg-red-500/10 transition-all"
                  >
                    <X className="w-5 h-5" />
                    <span className="text-[10px] font-medium">{t('close')}</span>
                  </button>
                </div>
              )
            ) : (
              isNewGeneration && !hasConfirmedDesign && beforeImage ? (
                /* Desktop Design Confirmation Question */
                <div className="w-full flex justify-center">
                  <div className="bg-gradient-to-r from-surface/95 via-surface/90 to-surface/95 backdrop-blur-xl p-6 rounded-3xl border border-white/10 shadow-2xl">
                    <div className="flex items-center gap-8">
                      {/* Icon & Question */}
                      <div className="flex items-center gap-4">
                        <div className="flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 shadow-lg shadow-amber-500/30">
                          <Sparkles className="w-7 h-7 text-white" />
                        </div>
                        <div>
                          <h3 className="text-lg font-bold text-white">{t('whatDoYouThink')}</h3>
                          <p className="text-sm text-gray-400">{t('dragSliderForComparison')}</p>
                        </div>
                      </div>

                      {/* Divider */}
                      <div className="w-px h-12 bg-white/10"></div>

                      {/* Action Buttons */}
                      <div className="flex items-center gap-3">
                        <button 
                          onClick={handleRevertToOriginal}
                          className="flex items-center gap-2 px-5 py-3 rounded-xl bg-white/5 border border-white/10 text-gray-300 hover:bg-white/10 hover:text-white hover:border-white/20 transition-all whitespace-nowrap group"
                        >
                          <RotateCcw className="w-5 h-5 group-hover:-rotate-45 transition-transform" />
                          <span className="font-medium">{t('returnToOriginal')}</span>
                        </button>
                        
                        <button 
                          onClick={handleConfirmDesign}
                          className="flex items-center gap-2 px-6 py-3 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 text-white font-semibold hover:from-emerald-600 hover:to-teal-600 transition-all shadow-lg shadow-emerald-500/30 hover:shadow-emerald-500/40 whitespace-nowrap group"
                        >
                          <CheckCircle className="w-5 h-5 group-hover:scale-110 transition-transform" />
                          <span>{t('loveItSaveDesign')}</span>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                /* Desktop Floating Bar - Action Buttons */
                <div className="flex items-center gap-3 bg-gradient-to-r from-gray-900/90 via-gray-800/90 to-gray-900/90 backdrop-blur-xl p-4 px-8 rounded-2xl border border-white/15 shadow-2xl shadow-black/50">
                  <button 
                    onClick={() => setShowComparison(!showComparison)}
                    disabled={!beforeImage || isGoogleLensMode}
                    className={`group flex items-center gap-2.5 px-5 py-3.5 rounded-xl border transition-all duration-200 whitespace-nowrap ${
                      showComparison 
                        ? 'bg-primary-500/25 text-primary-300 border-primary-500/40 shadow-lg shadow-primary-500/20' 
                        : 'bg-white/5 text-gray-300 border-white/10 hover:bg-white/10 hover:border-white/20 hover:text-white hover:scale-[1.02] disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:scale-100'
                    }`}
                  >
                    <ArrowLeftRight className="w-5 h-5 group-hover:scale-110 transition-transform" />
                    <span className="font-medium">{t('comparison')}</span>
                  </button>

                  <div className="w-px h-10 bg-gradient-to-b from-transparent via-white/20 to-transparent mx-2"></div>

                  {/* Google Lens Button */}
                  {isGoogleLensMode ? (
                    <button 
                      onClick={cancelGoogleLens}
                      className="group flex items-center gap-2.5 px-5 py-3.5 bg-red-500/20 hover:bg-red-500/30 text-red-400 rounded-xl border border-red-500/30 hover:border-red-500/50 transition-all duration-200 whitespace-nowrap hover:scale-[1.02] hover:shadow-lg hover:shadow-red-500/20"
                    >
                      <X className="w-5 h-5 group-hover:rotate-90 transition-transform" />
                      <span className="font-medium">{t('cancelSearch')}</span>
                    </button>
                  ) : (
                    <button 
                      onClick={handleGoogleLensStart}
                      className="group flex items-center gap-2.5 px-5 py-3.5 bg-blue-600/20 hover:bg-blue-600/35 text-blue-400 hover:text-blue-300 rounded-xl border border-blue-500/30 hover:border-blue-500/50 transition-all duration-200 whitespace-nowrap hover:scale-[1.02] hover:shadow-lg hover:shadow-blue-500/20"
                    >
                      <Search className="w-5 h-5 group-hover:scale-110 transition-transform" />
                      <span className="font-medium">{t('searchSimilarProducts')}</span>
                    </button>
                  )}

                  <div className="w-px h-10 bg-gradient-to-b from-transparent via-white/20 to-transparent mx-2"></div>

                  <button 
                    onClick={handleWhatsAppShare}
                    disabled={isGoogleLensMode}
                    className="group flex items-center gap-2.5 px-5 py-3.5 bg-green-600/20 hover:bg-green-600/35 text-green-400 hover:text-green-300 rounded-xl border border-green-500/30 hover:border-green-500/50 transition-all duration-200 whitespace-nowrap disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:scale-100 hover:scale-[1.02] hover:shadow-lg hover:shadow-green-500/20"
                  >
                    <Share2 className="w-5 h-5 group-hover:scale-110 group-hover:-rotate-12 transition-transform" />
                    <span className="font-medium">{t('whatsApp')}</span>
                  </button>
                  
                  <button 
                    onClick={handleDownload}
                    disabled={isGoogleLensMode}
                    className="group flex items-center gap-2.5 px-5 py-3.5 bg-white/10 hover:bg-white/20 text-white rounded-xl border border-white/15 hover:border-white/30 transition-all duration-200 whitespace-nowrap disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:scale-100 hover:scale-[1.02] hover:shadow-lg hover:shadow-white/10"
                  >
                    <Download className="w-5 h-5 group-hover:translate-y-0.5 transition-transform" />
                    <span className="font-medium">{t('download')}</span>
                  </button>

                  <div className="w-px h-10 bg-gradient-to-b from-transparent via-white/20 to-transparent mx-2"></div>

                  <button 
                    onClick={isGoogleLensMode ? cancelGoogleLens : handleCloseModal}
                    className="group flex items-center gap-2.5 px-5 py-3.5 bg-red-500/10 hover:bg-red-500/25 text-red-400 hover:text-red-300 rounded-xl border border-red-500/20 hover:border-red-500/40 transition-all duration-200 whitespace-nowrap hover:scale-[1.02]"
                  >
                    <X className="w-5 h-5 group-hover:rotate-90 transition-transform" />
                    <span className="font-medium">{t('close')}</span>
                  </button>
                </div>
              )
            )}

          </div>
        </div>
      )}

      
      {/* Color Palette Modal */}
      {showColorPalette && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[60] flex items-center justify-center p-4 animate-fade-in" dir={isRTL ? 'rtl' : 'ltr'}>
          <div className="glass-card w-full max-w-2xl h-[600px] overflow-hidden flex flex-col bg-surface">
            <div className="p-4 border-b border-white/10 flex justify-between items-center">
              <h3 className="text-lg font-semibold text-white">{t('colorPalette')}</h3>
              <button onClick={() => setShowColorPalette(false)} className="text-textMuted hover:text-white p-2"><span className="text-2xl">×</span></button>
            </div>
            <div className="flex-1 overflow-y-auto p-4 scrollbar-custom">
               {/* Category Tabs */}
               <div className="flex gap-2 overflow-x-auto pb-4 mb-2 scrollbar-hide">
                 {Object.keys(colorCategoryColors).map(cat => (
                   <button 
                     key={cat}
                     onClick={() => setActiveColorCategory(cat)}
                     className={`px-4 py-2 rounded-full whitespace-nowrap text-sm transition-all border ${activeColorCategory === cat ? 'bg-primary-500 border-primary-400 text-white shadow-glow' : 'bg-white/5 border-white/5 text-textMuted hover:bg-white/10'}`}
                   >
                     {colorCategoryNames[cat]}
                   </button>
                 ))}
               </div>
               
               {/* Color Grid */}
               <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  {colorPalette[activeColorCategory]?.map((color, idx) => (
                    <button 
                      key={idx} 
                      onClick={() => handleColorSelect(color)}
                      className="group flex flex-col gap-2 p-2 rounded-xl bg-white/5 hover:bg-white/10 transition-all border border-transparent hover:border-white/20 text-right"
                    >
                      <div className="w-full aspect-video rounded-lg shadow-inner relative overflow-hidden">
                        <div className="absolute inset-0" style={{backgroundColor: color.hex}}></div>
                      </div>
                      <div>
                        <div className="text-xs font-medium text-white group-hover:text-primary-300">{color.name}</div>
                        <div className="text-[10px] text-gray-500">{color.ral}</div>
                      </div>
                    </button>
                  ))}
               </div>
            </div>
          </div>
        </div>
      )}

      {/* General Options Modal Wrapper - Used for Furniture, Lighting, etc */}
      {[
        { show: showFurnitureOptions, close: () => setShowFurnitureOptions(false), title: t('selectFurnitureType'), options: furnitureOptions, onSelect: handleFurnitureSelect },
        { show: showLightingOptions, close: () => setShowLightingOptions(false), title: t('selectLightingType'), options: lightingOptions, onSelect: handleLightingSelect },
        { show: showStyleOptions, close: () => setShowStyleOptions(false), title: t('selectDesignStyle'), options: styleOptions, onSelect: handleStyleSelect },
      ].map((modal, i) => modal.show && (
        <div key={i} className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[60] flex items-center justify-center p-4 animate-fade-in">
          <div className="glass-card w-full max-w-2xl max-h-[70vh] overflow-hidden flex flex-col bg-surface">
            <div className="p-4 border-b border-white/10 flex justify-between items-center">
              <h3 className="text-lg font-semibold text-white">{modal.title}</h3>
              <button onClick={modal.close} className="text-textMuted hover:text-white p-2"><span className="text-2xl">×</span></button>
            </div>
            <div className="flex-1 overflow-y-auto p-4 scrollbar-custom">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {modal.options.map((option, idx) => (
                  <button
                    key={idx}
                    onClick={() => modal.onSelect(option)}
                    className={`flex items-center p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 hover:border-primary-500/30 transition-all duration-200 text-right group ${option.thumbnail ? 'h-24' : ''}`}
                  >
                    {option.thumbnail ? (
                      <div className="ml-3 h-20 w-auto min-w-[80px] rounded-lg overflow-hidden flex-shrink-0 border border-white/10 group-hover:border-primary-500/50 transition-colors bg-black/20">
                         <img src={option.thumbnail} alt={option.name} className="h-full w-auto object-contain" />
                      </div>
                    ) : (
                      <div className="ml-3 w-10 h-10 rounded-full bg-surfaceHighlight flex items-center justify-center text-xl group-hover:scale-110 transition-transform flex-shrink-0">
                        💡
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-medium text-white group-hover:text-primary-300 truncate">{isRTL ? option.name : option.value}</div>
                      <div className="text-xs text-gray-400 truncate">{isRTL ? option.value : option.name}</div>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      ))}

      {/* Complex Options Modals (Doors, Bathroom, Repairs) - Simplified for brevity in this redesign but maintaining functionality */}
      {/* I'm simplifying the code by not duplicating all HTML but in a real app we'd componentize these */}
      {(showDoorsWindowsOptions || showBathroomOptions || showRepairsOptions) && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[60] flex items-center justify-center p-4 animate-fade-in">
           <div className="glass-card w-full max-w-4xl max-h-[80vh] overflow-hidden flex flex-col bg-surface">
              <div className="p-4 border-b border-white/10 flex justify-between items-center">
                 <h3 className="text-lg font-semibold text-white">
                   {showDoorsWindowsOptions ? t('doorsWindows') : showBathroomOptions ? t('bathroomOptions') : t('selectRepairType')}
                 </h3>
                 <button onClick={() => {
                   setShowDoorsWindowsOptions(false); 
                   setShowBathroomOptions(false); 
                   setShowRepairsOptions(false);
                 }} className="text-textMuted hover:text-white p-2"><span className="text-2xl">×</span></button>
              </div>
              <div className="flex-1 overflow-y-auto p-6 scrollbar-custom">
                 <p className="text-center text-gray-400 mb-6">{t('pleaseSelectOption')}</p>
                 
                 <div className="grid grid-cols-1 gap-6">
                    {showDoorsWindowsOptions && doorsWindowsOptions.map((section, idx) => (
                      <div key={idx}>
                         <h4 className="text-white font-semibold mb-3 text-right">{t(section.titleKey)}</h4>
                         <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                           {section.items.map((item, i) => (
                             <button 
                               key={i}
                               onClick={() => { addPromptToInput(item.description); setShowDoorsWindowsOptions(false); }} 
                               className="p-3 bg-white/5 rounded-xl text-white hover:bg-white/10 text-right border border-white/5 flex flex-col gap-1 group"
                             >
                                <div className="flex justify-between items-center w-full">
                                  <span className="font-medium">{isRTL ? t(item.nameKey) : item.name}</span>
                                  <item.icon className="w-4 h-4 text-gray-400 group-hover:text-white transition-colors" />
                                </div>
                                <span className="text-xs text-gray-400 group-hover:text-gray-300">{item.description}</span>
                             </button>
                           ))}
                         </div>
                      </div>
                    ))}

                    {showBathroomOptions && bathroomOptions.map((section, idx) => (
                      <div key={idx}>
                         <h4 className="text-white font-semibold mb-3 text-right">{t(section.titleKey)}</h4>
                         <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                           {section.items.map((item, i) => (
                             <button 
                               key={i}
                               onClick={() => { addPromptToInput(item.description); setShowBathroomOptions(false); }} 
                               className="p-3 bg-white/5 rounded-xl text-white hover:bg-white/10 text-right border border-white/5 flex flex-col gap-1 group"
                             >
                                <div className="flex justify-between items-center w-full">
                                  <span className="font-medium">{isRTL ? t(item.nameKey) : item.name}</span>
                                  <item.icon className="w-4 h-4 text-gray-400 group-hover:text-white transition-colors" />
                                </div>
                                <span className="text-xs text-gray-400 group-hover:text-gray-300">{item.description}</span>
                             </button>
                           ))}
                         </div>
                      </div>
                    ))}

                    {showRepairsOptions && (
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <button onClick={() => handleImmediateOptionClick('fix and repair everything')} className="p-4 bg-white/5 rounded-xl text-white hover:bg-white/10 text-right border border-white/5 flex items-center justify-between group">
                          <span>{t('fixAndRepairEverything')}</span>
                          <Hammer className="w-5 h-5 text-gray-400 group-hover:text-white transition-colors" />
                        </button>
                        <button onClick={() => handleImmediateOptionClick('repair everything')} className="p-4 bg-white/5 rounded-xl text-white hover:bg-white/10 text-right border border-white/5 flex items-center justify-between group">
                          <span>{t('repairEverything')}</span>
                          <Hammer className="w-5 h-5 text-gray-400 group-hover:text-white transition-colors" />
                        </button>
                        <button onClick={() => handleImmediateOptionClick('destroy and cause damage to everything')} className="p-4 bg-white/5 rounded-xl text-white hover:bg-white/10 text-right border border-white/5 flex items-center justify-between group">
                          <span>{t('destroyAndCauseDamage')}</span>
                          <Hammer className="w-5 h-5 text-gray-400 group-hover:text-white transition-colors" />
                        </button>
                         <button onClick={() => handleImmediateOptionClick('mess up everything')} className="p-4 bg-white/5 rounded-xl text-white hover:bg-white/10 text-right border border-white/5 flex items-center justify-between group">
                          <span>{t('messUpEverything')}</span>
                          <Hammer className="w-5 h-5 text-gray-400 group-hover:text-white transition-colors" />
                        </button>
                      </div>
                    )}
                 </div>
              </div>
           </div>
        </div>
      )}

      {/* Auth Modal */}
      {showAuthModal && (
        <div className="fixed inset-0 bg-black/90 backdrop-blur-md z-[70] flex items-center justify-center p-4 animate-fade-in">
          <div className="glass-card w-full max-w-md p-8 relative bg-surface border border-white/10 shadow-2xl overflow-hidden">
            <button onClick={() => setShowAuthModal(false)} className="absolute top-4 left-4 text-gray-400 hover:text-white z-10">✕</button>
            
            <div className="text-center mb-6">
              <div className="flex justify-center mb-4">
                <div className="relative">
                  <div className="absolute inset-0 bg-gradient-to-r from-primary-500 to-secondary-500 blur-lg opacity-30 rounded-full"></div>
                  <h1 className="relative text-3xl font-bold bg-gradient-to-r from-primary-300 via-white to-secondary-300 bg-clip-text text-transparent tracking-tight">
                    {t('appName')}
                    <span className={`text-xl align-super ${isRTL ? 'mr-1' : 'ml-1'} bg-gradient-to-r from-secondary-400 to-secondary-300 bg-clip-text text-transparent font-light`}>AI</span>
                  </h1>
                </div>
              </div>
              
              {/* Tabbed Interface */}
              <div className="flex bg-black/40 rounded-xl p-1 mb-4 relative">
                {/* Slider Background */}
                <div 
                  className={`absolute inset-y-1 w-[calc(50%-4px)] bg-primary-600 shadow-lg rounded-lg transition-all duration-300 ease-in-out ${authMode === 'signup' ? 'left-[50%]' : 'left-1'}`}
                ></div>
                
                {/* Signup Button (Right in RTL) */}
                <button
                  onClick={() => setAuthMode('signup')}
                  className={`flex-1 py-2 text-sm font-medium rounded-lg relative z-10 transition-colors ${authMode === 'signup' ? 'text-white font-bold' : 'text-gray-400 hover:text-gray-200'}`}
                >
                  {t('createNewAccount')}
                </button>

                {/* Login Button (Left in RTL) */}
                <button
                  onClick={() => setAuthMode('login')}
                  className={`flex-1 py-2 text-sm font-medium rounded-lg relative z-10 transition-colors ${authMode === 'login' ? 'text-white font-bold' : 'text-gray-400 hover:text-gray-200'}`}
                >
                  {t('login')}
                </button>
              </div>

              <p className="text-sm text-gray-400 min-h-[20px]">
                {authMode === 'login' 
                  ? t('welcomeBack') 
                  : t('joinUs')}
              </p>
            </div>

            <div className="space-y-4">
              <input
                type="email"
                placeholder={t('email')}
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="input-glass w-full"
              />
              <input
                type="password"
                placeholder={t('password')}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="input-glass w-full"
              />
              
              {authMode === 'signup' && (
                <div className="animate-slide-down">
                  <input
                    type="password"
                    placeholder={t('confirmPassword')}
                    value={confirmEmail}
                    onChange={(e) => setConfirmEmail(e.target.value)}
                    className="input-glass w-full"
                  />
                </div>
              )}

              <div className="text-xs text-gray-400 text-center mt-2 mb-4 px-2">
                {t('termsAgreement')}
                <a href={t('termsOfServiceUrl')} target="_blank" rel="noopener noreferrer" className="text-primary-300 hover:text-primary-200 mx-1 underline">{t('termsOfService')}</a>
                {t('and')}
                <a href={t('privacyPolicyUrl')} target="_blank" rel="noopener noreferrer" className="text-primary-300 hover:text-primary-200 mx-1 underline">{t('privacyPolicy')}</a>
              </div>

              <button
                onClick={handleAuth}
                disabled={isLoadingAuth}
                className="btn-primary w-full py-3 text-lg mt-4"
              >
                {isLoadingAuth ? <Loader2 className="w-6 h-6 animate-spin mx-auto" /> : (authMode === 'login' ? t('loginButton') : t('createAccountButton'))}
              </button>
              
              <div className="flex justify-center items-center mt-4 text-sm">
                {authMode === 'login' && (
                  <button onClick={handlePasswordReset} className="text-gray-400 hover:text-white text-xs">
                    {t('forgotPassword')}
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Logout Modal */}
      {showLogoutModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[70] flex items-center justify-center p-4">
          <div className="glass-card max-w-sm w-full p-6 text-center bg-surface">
            <h3 className="text-xl font-bold text-white mb-4">{t('logout')}</h3>
            <p className="text-gray-400 mb-6">{language === 'he' ? 'האם אתה בטוח שברצונך להתנתק?' : 'Are you sure you want to log out?'}</p>
            <div className="flex gap-3 justify-center">
              <button onClick={() => setShowLogoutModal(false)} className="px-6 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white transition-colors">{t('cancel')}</button>
              <button onClick={handleLogout} className="px-6 py-2 rounded-xl bg-red-500/80 hover:bg-red-600/80 text-white transition-colors">התנתק</button>
            </div>
          </div>
        </div>
      )}

      {/* Hidden Inputs */}
      <input ref={fileInputRef} type="file" accept="image/*" onChange={handleImageUpload} className="hidden" />
      <input ref={objectInputRef} type="file" accept="image/*" onChange={handleObjectImageUpload} className="hidden" />
      
      {/* Login Confirmation Dialog */}
      <LimitReachedModal 
        isOpen={showLimitModal} 
        onClose={() => setShowLimitModal(false)} 
        onShowPricing={openSubscriptionModal}
        userSubscription={userSubscription}
        currentUsage={userUsage}
        limit={userCredits}
      />

      <ReadyDesignsModal
        isOpen={showReadyDesignsModal}
        onClose={() => setShowReadyDesignsModal(false)}
        onSelectDesign={async (design) => {
          console.log('Selected design:', design)
          setShowReadyDesignsModal(false)
          
          // Check if main image is loaded
          if (!mainImage) {
            showToast('יש להעלות תמונה ראשית לפני בחירת עיצוב')
            return
          }
          
          setIsProcessing(true)
          
          try {
            // Fetch the design image from URL
            const response = await fetch(design.url)
            const blob = await response.blob()
            
            // Create data URL for preview
            const dataUrl = await new Promise((resolve) => {
              const reader = new FileReader()
              reader.onload = () => resolve(reader.result)
              reader.readAsDataURL(blob)
            })
            
            // Create File object
            const file = new File([blob], `preset_${design.id}.jpg`, { type: 'image/jpeg' })
            
            // Set object image state for UI preview
            setObjectImage(dataUrl)
            setObjectImageFile(file)
            
            // Generate prompt based on category
            let prompt = ''
            if (design.categoryId === 'kitchen' || design.categoryId === 'kitchens') {
              prompt = "Use the attached image, remove the current kitchen from the main image and disregard it, and apply the attached image kitchen design including all of its elements. IMPORTANT: MAINTAIN the same structure, proportion, room size, windows and camera angle! DO NOT EXPAND THE KITCHEN SPACE - ESTIMATE THE FURNITURE SIZE OF BOTH IMAGES TO APPLY IT SO THAT IT WOULD KEEP THE SAME ACTUAL SPACE SIZE AND PROPORTIONS. IF there are no handles on the attached image's new design, then do not keep the original's image handles."
            } else {
              // Default prompt for other categories
              prompt = `Use the attached image as a reference design. Apply this ${design.title} style to the room while maintaining the same structure, proportion, room size, windows and camera angle.`
            }
            
            setCustomPrompt(prompt)
            
            // Immediately trigger the AI generation with the preset design
            await handlePresetDesignGeneration(prompt, file)
            
          } catch (error) {
            console.error('Error loading preset design:', error)
            showToast('שגיאה בטעינת העיצוב')
            setIsProcessing(false)
          }
        }}
      />

      <MobileMenuModal
        isOpen={showMobileMenu}
        onClose={() => setShowMobileMenu(false)}
        user={currentUser}
        userCredits={userCredits}
        userUsage={userUsage}
        userSubscription={userSubscription}
        onLogin={() => {
          setAuthMode('login')
          setShowAuthModal(true)
        }}
        onLogout={() => setShowLogoutModal(true)}
        onSubscriptionClick={openSubscriptionModal}
        onRedeemCoupon={handleRedeemCoupon}
        onCouponSuccess={(credits) => {
          setCouponCreditsGranted(credits)
          setShowCouponSuccessModal(true)
        }}
      />

      <WelcomePremiumModal 
        isOpen={showWelcomePremiumModal}
        onClose={() => setShowWelcomePremiumModal(false)}
        subscriptionName={subscriptionNames[userSubscription]}
      />

      {/* Coupon Success Modal */}
      {showCouponSuccessModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-[100] flex items-center justify-center p-4 animate-fade-in">
          <div className="relative w-full max-w-sm bg-gradient-to-br from-emerald-900/90 to-teal-900/90 rounded-3xl overflow-hidden shadow-2xl border border-emerald-500/30 animate-scale-up">
            {/* Confetti-like decorations */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
              <div className="absolute top-4 left-8 w-3 h-3 bg-yellow-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
              <div className="absolute top-12 right-12 w-2 h-2 bg-emerald-300 rounded-full animate-bounce" style={{ animationDelay: '0.3s' }}></div>
              <div className="absolute top-8 left-1/3 w-2 h-2 bg-pink-400 rounded-full animate-bounce" style={{ animationDelay: '0.5s' }}></div>
              <div className="absolute top-16 right-1/4 w-3 h-3 bg-blue-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
            </div>
            
            <div className="relative p-8 text-center">
              {/* Icon */}
              <div className="w-24 h-24 mx-auto mb-6 rounded-full bg-gradient-to-br from-emerald-400 to-teal-500 flex items-center justify-center shadow-lg shadow-emerald-500/30 animate-pulse">
                <Sparkles className="w-12 h-12 text-white" />
              </div>
              
              {/* Title */}
              <h2 className="text-2xl font-bold text-white mb-2">
                מזל טוב! 🎉
              </h2>
              
              {/* Credits Display */}
              <div className="my-6 py-4 px-6 rounded-2xl bg-white/10 border border-white/20">
                <div className="text-5xl font-bold text-emerald-300 mb-1">
                  {couponCreditsGranted}
                </div>
                <div className="text-emerald-100/80 text-lg">
                  קרדיטים נוספו לחשבונך
                </div>
              </div>
              
              {/* Message */}
              <p className="text-emerald-100/70 mb-6">
                תהנה מהעיצובים! ✨
              </p>
              
              {/* Close Button */}
              <button
                onClick={() => setShowCouponSuccessModal(false)}
                className="w-full py-4 rounded-2xl bg-white text-emerald-900 font-bold text-lg hover:bg-emerald-50 transition-colors shadow-lg"
              >
                יופי, בואו נתחיל!
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Post-Payment Sign Up Modal */}
      {showPostPaymentModal && (
        <div className="fixed inset-0 bg-black/90 backdrop-blur-md z-[90] flex items-center justify-center p-4 animate-fade-in">
          <div className="glass-card w-full max-w-md p-8 relative bg-surface border border-white/10 shadow-2xl flex flex-col rounded-2xl">
            <div className="text-center mb-6">
              <div className="w-16 h-16 bg-emerald-500/20 rounded-full flex items-center justify-center mx-auto mb-4 text-emerald-400">
                <CheckCircle size={32} />
              </div>
              <h3 className="text-2xl font-bold text-white mb-2">תודה על הרכישה! 🎉</h3>
              <p className="text-gray-300">
                לאחר השלמת התשלום, הירשם עם <span className="text-secondary-400 font-medium">אותו המייל</span> שבו השתמשת בתשלום כדי לקבל את ההטבות שלך.
              </p>
            </div>
            <button 
              onClick={() => {
                setShowPostPaymentModal(false)
                setAuthMode('signup')
                setShowAuthModal(true)
              }}
              className="w-full py-3 rounded-xl bg-gradient-to-r from-secondary-500 to-secondary-600 text-white font-bold shadow-lg shadow-secondary-900/20 hover:shadow-secondary-900/40 transition-all"
            >
              הירשם עכשיו
            </button>
            <button 
              onClick={() => setShowPostPaymentModal(false)}
              className="w-full py-2 mt-3 text-gray-400 hover:text-white transition-colors text-sm"
            >
              אעשה זאת מאוחר יותר
            </button>
          </div>
        </div>
      )}

      {showLoginConfirmDialog && (
        <div className="fixed inset-0 bg-black/90 backdrop-blur-md z-[90] flex items-center justify-center p-4 animate-fade-in">
          <div className="glass-card w-full max-w-md p-8 relative bg-surface border border-white/10 shadow-2xl flex flex-col rounded-2xl">
            <div className="text-center mb-6">
              <div className="w-16 h-16 bg-secondary-500/20 rounded-full flex items-center justify-center mx-auto mb-4 text-secondary-400">
                <User size={32} />
              </div>
              <h3 className="text-2xl font-bold text-white mb-2">{t('loginRequired')}</h3>
              <p className="text-gray-300">
                {t('loginRequiredMessage')}
                <br />
                {t('wantToLogin')}
              </p>
            </div>
            <div className="flex gap-4">
              <button 
                onClick={() => {
                  setShowLoginConfirmDialog(false)
                  setPendingSubscription(null)
                }}
                className="flex-1 py-3 rounded-xl bg-white/5 hover:bg-white/10 text-gray-300 transition-colors font-medium"
              >
                {t('notNowThanks')}
              </button>
              <button 
                onClick={() => {
                  setShowLoginConfirmDialog(false)
                  setShowAuthModal(true)
                }}
                className="flex-1 py-3 rounded-xl bg-gradient-to-r from-secondary-500 to-secondary-600 text-white font-bold shadow-lg shadow-secondary-900/20"
              >
                התחבר / הרשם
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Subscription Modal */}
      {showSubscriptionModal && (
        <div className="fixed inset-0 bg-black/90 backdrop-blur-md z-[80] flex items-center justify-center p-0 md:p-4 animate-fade-in">
          <div className="glass-card w-full h-full md:h-auto md:max-w-4xl md:max-h-[90vh] p-0 relative bg-surface border border-white/10 shadow-2xl overflow-hidden flex flex-col" dir={isRTL ? 'rtl' : 'ltr'}>
            <div className="p-6 sm:p-8 text-center border-b border-white/5 bg-gradient-to-b from-white/5 to-transparent flex-shrink-0">
              <button onClick={() => setShowSubscriptionModal(false)} className={`absolute top-4 ${isRTL ? 'left-4' : 'right-4'} text-gray-400 hover:text-white transition-colors p-2 z-10 bg-black/20 rounded-full md:bg-transparent`}>
                 <span className="text-2xl leading-none">×</span>
              </button>
              
              <h2 className="text-2xl md:text-3xl font-bold text-white mb-2 mt-2 md:mt-0">{t('professionalSubscription')}</h2>
              <div className="inline-block px-4 py-1 rounded-full bg-gradient-to-r from-secondary-500 to-secondary-600 text-white text-sm font-medium shadow-glow mb-2 md:mb-4">
                {t('specialLaunchPrices')}
              </div>
              <p className="text-gray-300 max-w-lg mx-auto text-sm md:text-base">
                {t('upgradeYourDesignAbilities')}
              </p>
            </div>

            <div className="flex-1 overflow-y-auto overflow-x-hidden p-4 md:p-6 pt-6 md:pt-8 scrollbar-custom">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6 pb-safe">
                
                {/* Starter Plan */}
                <div className="relative">
                  <div className="absolute inset-0 bg-gradient-to-b from-white/5 to-transparent rounded-2xl"></div>
                  <div className="relative bg-surfaceHighlight/20 border border-white/10 rounded-2xl p-5 md:p-6 flex flex-col h-full">
                    <div className="mb-4">
                      <h3 className="text-xl font-bold text-white mb-1">{t('starter')}</h3>
                      <div className="flex items-baseline gap-1">
                        <span className="text-3xl font-bold text-white">₪19</span>
                        <span className="text-sm text-gray-400">{t('perMonth')}</span>
                      </div>
                    </div>
                    
                    <div className="space-y-3 mb-6 flex-1">
                      <div className="flex items-center gap-2 text-sm text-gray-300">
                        <div className="w-5 h-5 rounded-full bg-white/10 flex items-center justify-center text-secondary-400">✓</div>
                        <span>{t('imagesPerMonth', { count: 50 })}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-300">
                        <div className="w-5 h-5 rounded-full bg-white/10 flex items-center justify-center text-secondary-400">✓</div>
                        <span>{t('accessToAllTools')}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-300">
                        <div className="w-5 h-5 rounded-full bg-white/10 flex items-center justify-center text-secondary-400">✓</div>
                        <span>{t('emailSupport')}</span>
                      </div>
                    </div>

                    <button 
                      onClick={() => handleSubscriptionClick('https://pay.grow.link/f8f8414d5e65d2b80b262486d3ea3e3c-Mjc1ODQ5MA')}
                      disabled={userSubscription === 1 && userCredits === 50}
                      className={`w-full py-3 rounded-xl font-medium border block text-center ${
                        userSubscription === 1 && userCredits === 50
                          ? 'bg-emerald-600/20 border-emerald-500/50 text-emerald-400 cursor-not-allowed' 
                          : 'bg-white/5 text-white border-white/10 hover:bg-white/10 transition-all'
                      }`}
                    >
                      {userSubscription === 1 && userCredits === 50 ? (
                        <span className="flex items-center justify-center gap-2">
                          <CheckCircle className="w-5 h-5" />
                          {t('yourCurrentPlan')}
                        </span>
                      ) : (
                        t('selectPlan')
                      )}
                    </button>
                  </div>
                </div>

                {/* Value Plan */}
                <div className="relative md:-mt-4 md:-mb-4 z-10">
                  <div className="absolute inset-0 bg-gradient-to-b from-secondary-900/50 to-transparent rounded-2xl"></div>
                  <div className="relative bg-surfaceHighlight/40 border border-secondary-500/50 rounded-2xl p-5 md:p-6 flex flex-col h-full shadow-lg shadow-secondary-900/20">
                    <div className="absolute top-0 right-1/2 transform translate-x-1/2 -translate-y-1/2 bg-secondary-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-lg whitespace-nowrap">
                      {t('mostValue')}
                    </div>
                    
                    <div className="mb-4 mt-2">
                      <h3 className="text-xl font-bold text-white mb-1">{t('value')}</h3>
                      <div className="flex items-baseline gap-1">
                        <span className="text-3xl font-bold text-secondary-400">₪49</span>
                        <span className="text-sm text-gray-400">{t('perMonth')}</span>
                      </div>
                      <div className="text-xs text-green-400 font-medium mt-1">
                        {t('savePerImage')}
                      </div>
                    </div>
                    
                    <div className="space-y-3 mb-6 flex-1">
                      <div className="flex items-center gap-2 text-sm text-white">
                        <div className="w-5 h-5 rounded-full bg-secondary-500/20 flex items-center justify-center text-secondary-400">✓</div>
                        <span className="font-medium">{t('imagesPerMonth', { count: 200 })}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-white">
                        <div className="w-5 h-5 rounded-full bg-secondary-500/20 flex items-center justify-center text-secondary-400">✓</div>
                        <span>{t('earlyAccess')}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-white">
                        <div className="w-5 h-5 rounded-full bg-secondary-500/20 flex items-center justify-center text-secondary-400">✓</div>
                        <span>{t('prioritySupport')}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-white">
                        <div className="w-5 h-5 rounded-full bg-secondary-500/20 flex items-center justify-center text-secondary-400">✓</div>
                        <span>{t('historyStorage')}</span>
                      </div>
                    </div>

                    <button 
                      onClick={() => handleSubscriptionClick('https://pay.grow.link/bf7845c990da58c287bf83a84a87e11c-MjcwMjgzNQ')}
                      disabled={userSubscription === 2 && userCredits === 200}
                      className={`w-full py-3 rounded-xl font-bold shadow-lg block text-center ${
                        userSubscription === 2 && userCredits === 200
                          ? 'bg-emerald-600/20 border-2 border-emerald-500/50 text-emerald-400 cursor-not-allowed shadow-emerald-900/30'
                          : 'bg-gradient-to-r from-secondary-500 to-secondary-600 text-white shadow-secondary-900/30 hover:from-secondary-400 hover:to-secondary-500 transition-all'
                      }`}
                    >
                      {userSubscription === 2 && userCredits === 200 ? (
                        <span className="flex items-center justify-center gap-2">
                          <CheckCircle className="w-5 h-5" />
                          {t('yourCurrentPlan')}
                        </span>
                      ) : (
                        t('selectPlan')
                      )}
                    </button>
                  </div>
                </div>

                {/* Professional Plan */}
                <div className="relative">
                  <div className="absolute inset-0 bg-gradient-to-b from-amber-900/30 to-transparent rounded-2xl"></div>
                  <div className="relative bg-surfaceHighlight/30 border border-amber-500/30 rounded-2xl p-5 md:p-6 flex flex-col h-full shadow-lg shadow-amber-900/10">
                    <div className="absolute top-0 right-1/2 transform translate-x-1/2 -translate-y-1/2 bg-gradient-to-r from-amber-500 to-yellow-500 text-black text-xs font-bold px-3 py-1 rounded-full shadow-lg whitespace-nowrap">
                      ⭐ {t('forProfessionals')}
                    </div>
                    
                    <div className="mb-4 mt-2">
                      <h3 className="text-xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-amber-300 to-yellow-400">{t('professional')}</h3>
                      <div className="flex items-baseline gap-1">
                        <span className="text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-amber-300 to-yellow-400">₪99</span>
                        <span className="text-sm text-gray-400">{t('perMonth')}</span>
                      </div>
                      <div className="text-xs text-green-400 font-medium mt-1">
                        {t('save42PerImage')}
                      </div>
                    </div>
                    
                    <div className="space-y-3 mb-6 flex-1">
                      <div className="flex items-center gap-2 text-sm text-gray-300">
                        <div className="w-5 h-5 rounded-full bg-amber-500/20 flex items-center justify-center text-amber-400">✓</div>
                        <span className="font-medium">{t('imagesPerMonth', { count: 450 })}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-300">
                        <div className="w-5 h-5 rounded-full bg-amber-500/20 flex items-center justify-center text-amber-400">✓</div>
                        <span>{t('allAdvancedFeatures')}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-300">
                        <div className="w-5 h-5 rounded-full bg-amber-500/20 flex items-center justify-center text-amber-400">✓</div>
                        <span>{t('premiumSupport')}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-300">
                        <div className="w-5 h-5 rounded-full bg-amber-500/20 flex items-center justify-center text-amber-400">✓</div>
                        <span>{t('forIndustryProfessionals')}</span>
                      </div>
                    </div>

                    <button 
                      onClick={() => handleSubscriptionClick('https://pay.grow.link/31f92ee464c112077b30007432dc8226-Mjc1ODQ4NQ')}
                      disabled={userSubscription === 3 && userCredits === 450}
                      className={`w-full py-3 rounded-xl font-bold shadow-lg block text-center ${
                        userSubscription === 3 && userCredits === 450
                          ? 'bg-emerald-600/20 border-2 border-emerald-500/50 text-emerald-400 cursor-not-allowed shadow-emerald-900/30'
                          : 'bg-gradient-to-r from-amber-500 to-yellow-500 text-black shadow-amber-900/30 hover:from-amber-400 hover:to-yellow-400 transition-all'
                      }`}
                    >
                      {userSubscription === 3 && userCredits === 450 ? (
                        <span className="flex items-center justify-center gap-2">
                          <CheckCircle className="w-5 h-5" />
                          {t('yourCurrentPlan')}
                        </span>
                      ) : (
                        t('selectPlan')
                      )}
                    </button>
                  </div>
                </div>

              </div>
            </div>
            
            <div className="p-4 text-center text-xs text-gray-500 border-t border-white/5 bg-black/20">
              {t('subscriptionDisclaimer')}
            </div>
          </div>
        </div>
      )}

      {/* Designer Avatar Component */}
      {(!isMobile && !isProcessing && isDesignerAvatarEnabled) && (
        <DesignerAvatar 
          suggestions={avatarSuggestions} 
          onSelect={handleAvatarSuggestionSelect} 
          onClose={() => setAvatarSuggestions([])}
          isMobile={false}
          isThinking={isAvatarThinking}
          initialShowSuggestions={shouldAutoOpenAvatar} 
        />
      )}

      {showOnboarding && (
        <OnboardingOverlay 
          step={onboardingStep} 
          steps={onboardingSteps} 
          onNext={handleOnboardingNext} 
          onSkip={handleOnboardingSkip} 
          onComplete={handleOnboardingComplete} 
        />
      )}

      {showColorDialog && selectedColorForDialog && (
        <ColorApplicationDialog 
          color={selectedColorForDialog} 
          onClose={() => setShowColorDialog(false)} 
          onApply={handleColorDialogApply} 
        />
      )}

      <LimitReachedModal 
        isOpen={showLimitModal} 
        onClose={() => setShowLimitModal(false)} 
        onShowPricing={openSubscriptionModal}
        userSubscription={userSubscription}
        currentUsage={userUsage}
        limit={userCredits}
      />

      {/* Contact Form Modal */}
      {showContactModal && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-gradient-to-br from-surface via-surface to-surfaceHighlight rounded-2xl shadow-2xl w-full max-w-md border border-white/10 overflow-hidden">
            {/* Header */}
            <div className="bg-gradient-to-r from-primary-500/20 to-secondary-500/20 p-6 border-b border-white/10">
              <div className="flex justify-between items-center">
                <h3 className="text-xl font-bold text-white flex items-center gap-2">
                  <Mail className="w-5 h-5 text-primary-400" />
                  {t('contactUs')}
                </h3>
                <button 
                  onClick={() => {
                    setShowContactModal(false)
                    setContactError('')
                  }}
                  className="text-gray-400 hover:text-white p-1 hover:bg-white/10 rounded-full transition-all"
                >
                  <span className="text-2xl leading-none">×</span>
                </button>
              </div>
              <p className="text-gray-400 text-sm mt-2">{t('contactSubtitle')}</p>
            </div>
            
            {/* Form */}
            <div className="p-6 space-y-4">
              {contactError && (
                <div className="bg-red-500/20 border border-red-500/30 text-red-300 px-4 py-3 rounded-lg text-sm">
                  {contactError}
                </div>
              )}
              
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">{t('phone')}</label>
                <input
                  type="tel"
                  value={contactPhone}
                  onChange={(e) => setContactPhone(e.target.value)}
                  placeholder="050-1234567"
                  className="w-full bg-surface/50 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500/50 transition-all"
                  dir="ltr"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">{t('email')}</label>
                <input
                  type="email"
                  value={contactEmail}
                  onChange={(e) => setContactEmail(e.target.value)}
                  placeholder="example@email.com"
                  className="w-full bg-surface/50 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500/50 transition-all"
                  dir="ltr"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">{t('message')}</label>
                <textarea
                  value={contactMessage}
                  onChange={(e) => setContactMessage(e.target.value)}
                  placeholder={t('writeYourMessage')}
                  rows={4}
                  className="w-full bg-surface/50 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500/50 transition-all resize-none"
                  dir={isRTL ? 'rtl' : 'ltr'}
                />
              </div>
              
              <p className="text-xs text-gray-500 text-center">{t('enterPhoneOrEmail')}</p>
              
              <button
                onClick={handleContactSubmit}
                disabled={isSubmittingContact}
                className="w-full py-3 rounded-xl bg-gradient-to-r from-primary-500 to-secondary-500 text-white font-bold shadow-lg hover:shadow-primary-500/30 transform hover:-translate-y-0.5 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center gap-2"
              >
                {isSubmittingContact ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    {t('sending')}
                  </>
                ) : (
                  <>
                    <Mail className="w-5 h-5" />
                    {t('sendMessage')}
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Contact Success Message */}
      {showContactSuccess && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-gradient-to-br from-surface via-surface to-surfaceHighlight rounded-2xl shadow-2xl w-full max-w-md border border-white/10 overflow-hidden animate-fade-in">
            {/* Success Icon */}
            <div className="bg-gradient-to-r from-emerald-500/20 to-green-500/20 p-8 flex flex-col items-center">
              <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-emerald-400/30 to-green-500/30 flex items-center justify-center mb-4 border border-emerald-500/30 shadow-lg shadow-emerald-500/20">
                <CheckCircle className="w-10 h-10 text-emerald-400" />
              </div>
              <h3 className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-emerald-200 via-emerald-400 to-green-400">
                {t('messageSentSuccess')}
              </h3>
            </div>
            
            {/* Message */}
            <div className="p-6 text-center">
              <p className="text-gray-300 mb-6 leading-relaxed">
                {language === 'he' ? 'ההודעה שלך התקבלה בהצלחה.' : 'Your message has been received successfully.'}<br />
                {language === 'he' ? 'נחזור אליך בהקדם האפשרי.' : 'We will get back to you as soon as possible.'}
              </p>
              
              <button
                onClick={() => setShowContactSuccess(false)}
                className="px-8 py-3 rounded-xl bg-gradient-to-r from-emerald-500 to-green-600 text-white font-bold shadow-lg hover:shadow-emerald-500/30 transform hover:-translate-y-0.5 transition-all duration-200"
              >
                {t('close')}
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  )
}

export default App


