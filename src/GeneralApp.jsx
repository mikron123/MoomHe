import React, { useState, useRef, useEffect } from 'react'
import { Upload, Plus, Palette, RotateCcw, Download, Settings, Home, TreePine, Car, Heart, Hammer, Sparkles, Package, User, Share2, Palette as FreeStyle, Type, Loader2, RotateCw, Lightbulb, Sofa, Droplets, ArrowLeftRight, MessageCircle, ArrowLeft } from 'lucide-react'
import { fileToGenerativePart, urlToFile, signInUser, createOrUpdateUser, saveImageToHistory, saveUploadToHistory, loadUserHistory, loadUserHistoryPaginated, auth, uploadImageForSharing, compressImage, getDeviceFingerprint } from './firebase.js'
import { aiService } from './aiService.js'
import { onAuthStateChanged } from 'firebase/auth'
import LimitReachedModal from './LimitReachedModal'

function GeneralApp() {
  const [selectedCategory, setSelectedCategory] = useState('עיצוב פנים וחוץ')
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
  const [imageHistory, setImageHistory] = useState([])
  const [currentUser, setCurrentUser] = useState(null)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoadingHistory, setIsLoadingHistory] = useState(false)
  const [showImageModal, setShowImageModal] = useState(false)
  const [detectedObjects, setDetectedObjects] = useState([])
  const [isLoadingObjects, setIsLoadingObjects] = useState(false)
  const [currentHistoryId, setCurrentHistoryId] = useState(null)
  const [customPrompt, setCustomPrompt] = useState('')
  const [imageAspectRatio, setImageAspectRatio] = useState(16/9) // Default to 16:9
  const [activeColorCategory, setActiveColorCategory] = useState('אדומים') // Default to reds
  const [objectImage, setObjectImage] = useState(null)
  const [objectImageFile, setObjectImageFile] = useState(null)
  const [showMobileDropdown, setShowMobileDropdown] = useState(false)
  const [historyPage, setHistoryPage] = useState(1)
  const [hasMoreHistory, setHasMoreHistory] = useState(true)
  const [isLoadingMoreHistory, setIsLoadingMoreHistory] = useState(false)
  const [showAuthModal, setShowAuthModal] = useState(false)
  const [showLogoutModal, setShowLogoutModal] = useState(false)
  const [showLimitModal, setShowLimitModal] = useState(false)
  
  // Debug: Log when showAuthModal changes
  useEffect(() => {
    console.log('showAuthModal changed:', showAuthModal)
  }, [showAuthModal])
  const [authMode, setAuthMode] = useState('signup') // 'login' or 'signup'
  const [email, setEmail] = useState('')
  const [confirmEmail, setConfirmEmail] = useState('')
  const [password, setPassword] = useState('')
  const [isLoadingAuth, setIsLoadingAuth] = useState(false)
  const [isResettingPassword, setIsResettingPassword] = useState(false)
  const [showSuggestionsDropdown, setShowSuggestionsDropdown] = useState(false)
  const [showSuggestionsModal, setShowSuggestionsModal] = useState(false)
  const fileInputRef = useRef(null)
  const suggestionsDropdownRef = useRef(null)
  const objectInputRef = useRef(null)
  const historyScrollRef = useRef(null)


  // Authentication and history loading
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
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
        } finally {
          setIsLoadingHistory(false)
        }
      } else {
        // Sign in anonymously
        try {
          const userCredential = await signInUser()
          setCurrentUser(userCredential)
          setIsAuthenticated(true)
          await createOrUpdateUser(userCredential)
        } catch (error) {
          console.error('Failed to sign in anonymously:', error)
        }
      }
    })

    return () => unsubscribe()
  }, [])

  // Load default objects for initial category and when switching categories
  useEffect(() => {
    const isMobile = window.innerWidth < 1024
    if (!isMobile) {
      const defaultObjects = categoryDefaultObjects[selectedCategory] || []
      setDetectedObjects(defaultObjects)
      console.log('Loaded default objects for category:', selectedCategory, defaultObjects)
    }
  }, [selectedCategory])

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

  const categoryDefaultObjects = {
    'עיצוב פנים וחוץ': [
      "קירות בהירים",
      "ספה אפורה",
      "כורסא לבנה",
      "שולחן קפה עגול",
      "שתי מראות קש",
      "שטיח בהיר",
      "אגרטל לבן",
      "מנורת רצפה",
      "סלסלת קש",
      "כריות נוי",
      "שמיכת נוי",
      "הדום קש"
    ],
    'גינות ומרפסות': [
      "קיר בז'",
      "דק עץ",
      "עץ קטן",
      "עץ גדול",
      "כרית כחולה",
      "עששית שחורה קטנה",
      "עששית שחורה גדולה",
      "שולחן עגול",
      "קומקום כסף",
      "סל קש",
      "חלון גדול",
      "עציץ קטן"
    ],
    'איפור וטיפוח': [
      "פנים של אישה",
      "שיער חום",
      "כתפיים חשופות",
      "רקע בהיר"
    ],
    'פרסום ומוצרים': [
      "פחית שתייה",
      "משטח עץ"
    ],
    'פרופיל ותדמית': [
      "גבר מזוקן",
      "שיער אפור",
      "ז'קט בז'",
      "חולצה בהירה",
      "קיר זכוכית"
    ],
    'רכבים ודו גלגלי': [
      "מכונית כתומה",
      "עצים ירוקים",
      "שמיים בהירים",
      "כביש אספלט",
      "בניינים רחוקים",
      "עמוד תאורה"
    ],
    'קעקועים': [
      "אישה צעירה",
      "רקע לבן",
      "כתף חשופה",
      "שיער ג'ינג'י",
      "שפתיים אדומות"
    ]
  }

  const categoryActionButtons = {
    'עיצוב פנים וחוץ': [
      { name: 'שינוי טוטאלי', action: () => setShowStyleOptions(!showStyleOptions), icon: ArrowLeftRight },
      { name: 'תיקונים/נזקים', action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'תאורה', action: () => setShowLightingOptions(!showLightingOptions), icon: Lightbulb },
      { name: 'ריהוט', action: () => setShowFurnitureOptions(!showFurnitureOptions), icon: Sofa },
      { name: 'דלתות/חלונות', action: () => setShowDoorsWindowsOptions(!showDoorsWindowsOptions), icon: Home },
      { name: 'רחצה', action: () => setShowBathroomOptions(!showBathroomOptions), icon: Droplets }
    ],
    'גינות ומרפסות': [
      { name: 'שינוי טוטאלי', action: () => setShowStyleOptions(!showStyleOptions), icon: FreeStyle },
      { name: 'תיקונים/נזקים', action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'הוסף צמחים', action: () => addPromptToInput("Add beautiful plants and flowers to this garden"), icon: TreePine },
      { name: 'שיפור תאורה', action: () => addPromptToInput("Enhance the outdoor lighting"), icon: Settings }
    ],
    'רכבים ודו גלגלי': [
      { name: 'שינוי טוטאלי', action: () => setShowStyleOptions(!showStyleOptions), icon: FreeStyle },
      { name: 'תיקונים/נזקים', action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => addPromptToInput("Enhance the lighting and reflections on this vehicle"), icon: Settings },
      { name: 'הוסף אביזרים', action: () => addPromptToInput("Add accessories and modifications to this vehicle"), icon: Plus }
    ],
    'קעקועים': [
      { name: 'שינוי טוטאלי', action: () => setShowStyleOptions(!showStyleOptions), icon: FreeStyle },
      { name: 'תיקונים/נזקים', action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => addPromptToInput("Enhance the lighting to show the tattoo details"), icon: Settings },
      { name: 'הוסף פרטים', action: () => addPromptToInput("Add more details and shading to this tattoo"), icon: Plus }
    ],
    'איפור וטיפוח': [
      { name: 'שינוי טוטאלי', action: () => setShowStyleOptions(!showStyleOptions), icon: FreeStyle },
      { name: 'תיקונים/נזקים', action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => addPromptToInput("Enhance the lighting for better makeup visibility"), icon: Settings },
      { name: 'הוסף איפור', action: () => addPromptToInput("Add more makeup and beauty enhancements"), icon: Sparkles }
    ],
    'פרסום ומוצרים': [
      { name: 'שינוי טוטאלי', action: () => setShowStyleOptions(!showStyleOptions), icon: FreeStyle },
      { name: 'תיקונים/נזקים', action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => addPromptToInput("Enhance the product lighting and presentation"), icon: Settings },
      { name: 'הוסף פרטים', action: () => addPromptToInput("Add product details and features"), icon: Plus }
    ],
    'פרופיל ותדמית': [
      { name: 'שינוי טוטאלי', action: () => setShowStyleOptions(!showStyleOptions), icon: FreeStyle },
      { name: 'תיקונים/נזקים', action: () => setShowRepairsOptions(!showRepairsOptions), icon: Hammer },
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => addPromptToInput("Enhance the portrait lighting"), icon: Settings },
      { name: 'הוסף רקע', action: () => addPromptToInput("Add a professional background"), icon: Plus }
    ]
  }

  const handleImageUpload = async (event) => {
    const file = event.target.files[0]
    if (file) {
      // Check if it's a HEIC file and show user feedback
      const isHeicFile = file.type === 'image/heic' || file.type === 'image/heif' || file.name.toLowerCase().endsWith('.heic') || file.name.toLowerCase().endsWith('.heif')
      if (isHeicFile) {
        console.log('HEIC file detected, converting to JPEG...')
      }
      
      const reader = new FileReader()
      reader.onload = async (e) => {
        const originalImageDataUrl = e.target.result
        
        // Compress the image first (this will handle HEIC conversion if needed)
        let compressedImageDataUrl = originalImageDataUrl
        try {
          const compressedBlob = await compressImage(originalImageDataUrl, 1920, 1080, 0.8)
          // Convert compressed blob back to data URL for display
          const compressedReader = new FileReader()
          compressedImageDataUrl = await new Promise((resolve) => {
            compressedReader.onload = () => resolve(compressedReader.result)
            compressedReader.readAsDataURL(compressedBlob)
          })
          console.log('Image compressed for display')
        } catch (compressionError) {
          console.warn('Failed to compress image for display, using original:', compressionError)
          // If compression fails, try to use the original image
          if (isHeicFile) {
            console.error('HEIC conversion failed, please try uploading a JPEG or PNG image instead')
          }
        }
        
        setUploadedImage(compressedImageDataUrl)
        setMainImage(compressedImageDataUrl) // Display compressed image on main stage
        setImageAspectRatio(16/9) // Reset to default until new image loads
        setCurrentHistoryId(null) // Clear history ID for new upload
        
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
            console.log('Current history after reload:', historyResult.history.map(h => ({ id: h.id, prompt: h.prompt })))
            
            // Detect objects for uploaded image (desktop only) after setting the history ID
            const isMobile = window.innerWidth < 1024
            if (!isMobile) {
              console.log('About to detect objects for history ID:', newHistoryId)
              // Pass the compressed image for object detection
              detectObjectsWithId(compressedImageDataUrl, newHistoryId)
            }
          } catch (error) {
            console.error('Failed to save upload to Firebase:', error)
          } finally {
            setIsLoadingHistory(false)
          }
        } else {
          // For non-authenticated users, just detect objects locally
          const isMobile = window.innerWidth < 1024
          if (!isMobile) {
            // Use default objects for uploaded images when not authenticated
            const defaultObjects = categoryDefaultObjects[selectedCategory] || []
            setDetectedObjects(defaultObjects)
          }
        }
      }
      reader.readAsDataURL(file)
    }
  }

  const handleUploadClick = () => {
    fileInputRef.current.click()
  }

  const handleDownload = async () => {
    try {
      let imageUrl = mainImage
      
      // If it's a Firebase Storage URL, we can use it directly
      if (imageUrl.startsWith('https://firebasestorage.googleapis.com/')) {
        // For Firebase Storage URLs, we can download directly
        const link = document.createElement('a')
        link.href = imageUrl
        link.download = 'moomhe-design.png'
        link.target = '_blank'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
      } else {
        // For data URLs or other URLs, fetch and download
        const response = await fetch(imageUrl)
        const blob = await response.blob()
        const url = window.URL.createObjectURL(blob)
        const link = document.createElement('a')
        link.href = url
        link.download = 'moomhe-design.png'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        window.URL.revokeObjectURL(url)
      }
    } catch (error) {
      console.error('Download failed:', error)
      // Fallback: try to open the image in a new tab
      try {
        window.open(mainImage, '_blank')
      } catch (fallbackError) {
        console.error('Fallback download also failed:', fallbackError)
        alert('שגיאה בהורדת התמונה. נסה שוב.')
      }
    }
  }

  const handleWhatsAppShare = async () => {
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

  const handleCategorySelect = (category) => {
    setSelectedCategory(category)
    // Change default image based on category
    const defaultImage = categoryDefaultImages[category]
    if (defaultImage) {
      setMainImage(defaultImage)
      setImageAspectRatio(16/9) // Reset to default until new image loads
      setCurrentHistoryId(null) // Clear history ID for default image
      
      // Load hardcoded objects for default images (desktop only)
      const isMobile = window.innerWidth < 1024
      if (!isMobile) {
        const defaultObjects = categoryDefaultObjects[category] || []
        setDetectedObjects(defaultObjects)
        console.log('Loaded default objects for category:', category, defaultObjects)
      }
    }
  }

  const handleGalleryImageClick = (imageUrl) => {
    setMainImage(imageUrl)
    setImageAspectRatio(16/9) // Reset to default until new image loads
    setCurrentHistoryId(null) // Clear history ID for gallery image
    // Clear objects when selecting gallery image
    setDetectedObjects([])
  }

  const handleHistoryImageClick = (historyEntry) => {
    // Use storageUrl if available (from Firebase), otherwise use imageUrl (local)
    const imageUrl = historyEntry.storageUrl || historyEntry.imageUrl
    setMainImage(imageUrl)
    setImageAspectRatio(16/9) // Reset to default until new image loads
    // Store the history ID for object detection
    setCurrentHistoryId(historyEntry.id)
    
    // Load objects if they exist in the history entry
    if (historyEntry.objects) {
      let objectsArray = historyEntry.objects;
      
      // Handle array with comma-separated string in first element
      if (Array.isArray(historyEntry.objects) && historyEntry.objects.length > 0) {
        const firstElement = historyEntry.objects[0];
        if (typeof firstElement === 'string' && firstElement.includes(',')) {
          // Split the first element (comma-separated string) into array
          objectsArray = firstElement
            .split(',')
            .map(obj => obj.trim())
            .filter(obj => obj.length > 0);
        }
      } else if (typeof historyEntry.objects === 'string') {
        // Handle direct comma-separated string
        objectsArray = historyEntry.objects
          .split(',')
          .map(obj => obj.trim())
          .filter(obj => obj.length > 0);
      }
      
      if (objectsArray.length > 0) {
        setDetectedObjects(objectsArray)
        console.log('Loaded objects from history entry:', objectsArray)
      } else {
        setDetectedObjects([])
        console.log('No valid objects found in history entry')
      }
    } else {
      // Clear objects if no objects field
      setDetectedObjects([])
      console.log('No objects field in history entry')
    }
  }


  const handleMainImageClick = () => {
    if (!isProcessing) {
      setShowImageModal(true)
    }
  }

  const handleImageLoad = (event) => {
    const img = event.target
    const aspectRatio = img.naturalWidth / img.naturalHeight
    setImageAspectRatio(aspectRatio)
  }

  const handleObjectImageUpload = async (event) => {
    const file = event.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        setObjectImage(e.target.result)
        setObjectImageFile(file)
      }
      reader.readAsDataURL(file)
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
    
    // Validate email confirmation for signup
    if (authMode === 'signup' && email !== confirmEmail) {
      alert('כתובות האימייל אינן תואמות. נסה שוב.')
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
            alert('החשבון נוצר בהצלחה! כל הנתונים שלך נשמרו.')
          } catch (linkError) {
            if (linkError.code === 'auth/email-already-in-use') {
              // Email already exists, create new account and migrate data
              const { createUserWithEmailAndPassword } = await import('firebase/auth')
              const newUserCredential = await createUserWithEmailAndPassword(auth, email, password)
              
              // Migrate data from anonymous user to new user
              await migrateUserData(currentUser.uid, newUserCredential.user.uid)
              
              await createOrUpdateUser(newUserCredential.user)
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
          alert('החשבון נוצר בהצלחה!')
        }
      } else {
        // Sign in existing user
        const { signInWithEmailAndPassword } = await import('firebase/auth')
        const userCredential = await signInWithEmailAndPassword(auth, email, password)
        await createOrUpdateUser(userCredential.user)
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
      const { signOut } = await import('firebase/auth')
      await signOut(auth)
      // Clear local state
      setImageHistory([])
      setDetectedObjects([])
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

  const loadMoreHistory = async () => {
    if (!isAuthenticated || !currentUser || isLoadingMoreHistory || !hasMoreHistory) {
      console.log('Load more history blocked:', { isAuthenticated, currentUser: !!currentUser, isLoadingMoreHistory, hasMoreHistory })
      return
    }
    
    console.log('Loading more history, current page:', historyPage)
    setIsLoadingMoreHistory(true)
    try {
      const nextPage = historyPage + 1
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

  // Close mobile dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (showMobileDropdown && !event.target.closest('.mobile-dropdown')) {
        setShowMobileDropdown(false)
      }
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
  }, [showMobileDropdown, showSuggestionsDropdown, showSuggestionsModal])

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

  const handleCloseModal = () => {
    setShowImageModal(false)
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
      alert('שגיאה בעיבוד הבקשה. נסה שוב.')
    } finally {
      setIsProcessing(false)
    }
  }

  const detectObjects = async (imageUrl) => {
    if (!imageUrl) return
    
    // Allow object detection on history images or newly uploaded images with a history ID
    if (!currentHistoryId) {
      console.log('No current history ID available for object detection')
      return
    }
    
    console.log('detectObjects called with currentHistoryId:', currentHistoryId)
    console.log('detectObjects called with imageUrl:', imageUrl)
    
    return detectObjectsWithId(imageUrl, currentHistoryId)
  }

  const detectObjectsWithId = async (imageUrl, historyId) => {
    if (!imageUrl || !historyId) return
    
    console.log('detectObjectsWithId called with historyId:', historyId)
    console.log('detectObjectsWithId called with imageUrl:', imageUrl)
    
    setIsLoadingObjects(true)
    try {
      
      // Check if user can make requests
      if (isAuthenticated && currentUser) {
        const canMakeRequest = await aiService.canMakeRequest(currentUser.uid)
        if (!canMakeRequest) {
          setShowLimitModal(true)
          setIsLoadingObjects(false)
          return
        }
      }
      
      // Convert image to data URL if it's a local path
      let imageDataForServer = imageUrl;
      if (imageUrl.startsWith('/assets/') || imageUrl.startsWith('./assets/')) {
        // Convert local image to data URL
        try {
          const response = await fetch(imageUrl);
          const blob = await response.blob();
          const dataUrl = await new Promise((resolve) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.readAsDataURL(blob);
          });
          imageDataForServer = dataUrl;
        } catch (error) {
          console.error('Error converting local image to data URL:', error);
          throw new Error('Failed to load the image for object detection');
        }
      }
      
      // Submit request to server (HTTP function)
      console.log('Submitting object detection request for history ID:', historyId)
      const deviceId = await getDeviceFingerprint()
      const result = await aiService.submitObjectDetectionRequest(currentUser, imageDataForServer, historyId, deviceId)
      
      console.log('Object detection result:', result)
      console.log('Objects will be saved to history ID:', historyId)
      
      if (result && result.objects) {
        console.log('Raw objects from server:', result.objects)
        console.log('Type of objects:', typeof result.objects)
        
        // Parse objects - handle array with comma-separated string in first element
        let objectsArray = result.objects;
        
        if (Array.isArray(result.objects) && result.objects.length > 0) {
          console.log('Objects is array, checking first element...')
          const firstElement = result.objects[0];
          if (typeof firstElement === 'string' && firstElement.includes(',')) {
            console.log('First element is comma-separated string, parsing...')
            // Split the first element (comma-separated string) into array
            objectsArray = firstElement
              .split(',')
              .map(obj => obj.trim())
              .filter(obj => obj.length > 0);
            console.log('Parsed objects array:', objectsArray)
          } else {
            console.log('Using array as-is:', objectsArray)
          }
        } else if (typeof result.objects === 'string') {
          console.log('Parsing string objects...')
          // Split comma-separated string into array
          objectsArray = result.objects
            .split(',')
            .map(obj => obj.trim())
            .filter(obj => obj.length > 0);
          console.log('Parsed objects array:', objectsArray)
        } else {
          console.log('Objects is already an array:', objectsArray)
        }
        
        setDetectedObjects(objectsArray)
        console.log('Final detected objects:', objectsArray)
        
        // Update the local imageHistory state with the detected objects
        if (historyId && imageHistory.length > 0) {
          setImageHistory(prevHistory => 
            prevHistory.map(entry => 
              entry.id === historyId 
                ? { ...entry, objects: objectsArray }
                : entry
            )
          )
          console.log('Updated local imageHistory with detected objects for ID:', historyId, objectsArray)
        }
      } else {
        setDetectedObjects([])
      }
    } catch (error) {
      console.error('Object detection failed:', error)
      setDetectedObjects([])
      alert('שגיאה בזיהוי אובייקטים. נסה שוב.')
    } finally {
      setIsLoadingObjects(false)
    }
  }

  const colorCategoryColors = {
    'אדומים': '#C1121C',
    'כתומים': '#FF7514', 
    'צהובים': '#E5BE01',
    'ירוקים': '#287233',
    'כחולים': '#1E2460',
    'סגולים': '#6D3F5B',
    'אפורים': '#78858B',
    'לבנים ושחורים': '#F4F4F4'
  }

  const colorPalette = {
    'אדומים': [
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
    'כתומים': [
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
    'צהובים': [
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
    'ירוקים': [
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
    'כחולים': [
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
    'סגולים': [
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
    'אפורים': [
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
    'לבנים ושחורים': [
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

  // Helper function to convert hex to RGB
  const hexToRgb = (hex) => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null
  }

  const handleColorSelect = (color) => {
    setShowColorPalette(false)
    const rgb = hexToRgb(color.hex)
    const rgbString = rgb ? `RGB(${rgb.r}, ${rgb.g}, ${rgb.b})` : color.hex
    
    // Using English prompt structure for better results with the AI model
    // The format is: "Paint completely and opaquely in [Color Name] (RAL, RGB) the"
    // The user will complete the sentence (likely in Hebrew or English)
    // If the user completes in Hebrew, the mixed prompt will still be translated/handled by the backend
    const prompt = `Paint completely and opaquely in ${color.value} (${color.ral}, ${rgbString}) the`
    
    console.log('🎨 Color Selection - Prompt being added to input:', prompt)
    console.log('🎨 Selected color:', color.ral, color.name, rgbString)
    addPromptToInput(prompt)
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
    { name: 'בצע תיקונים להכל', value: 'repair everything', prompt: 'בצע תיקונים להכל' },
    { name: 'תסדר ותקנה את הכל', value: 'fix and repair everything', prompt: 'תסדר ותקנה את הכל' },
    { name: 'תבלגן את הכל', value: 'mess up everything', prompt: 'תבלגן את הכל' },
    { name: 'תהרוס ותגרום נזקים להכל', value: 'destroy and cause damage to everything', prompt: 'תהרוס ותגרום נזקים להכל' }
  ]

  const styleOptions = [
    { name: 'מינימליסטי', value: 'minimalist', prompt: 'שנה את סגנון החדר למינימליסטי - נקי, פשוט, לא עמוס' },
    { name: 'בוהו', value: 'bohemian', prompt: 'שנה את סגנון החדר לבוהו - אקלקטי, מרקם, חופשי' },
    { name: 'אינדוסטריאלי', value: 'industrial', prompt: 'שנה את סגנון החדר לסגנון תעשייתי - חומרים גולמיים וחשופים' },
    { name: 'מודרני אמצע המאה', value: 'mid-century modern', prompt: 'שנה את סגנון החדר למודרני אמצע המאה - חלק, רטרו, פונקציונלי' },
    { name: 'סקנדינבי', value: 'scandinavian', prompt: 'שנה את סגנון החדר לסקנדינבי - בהיר, נוח, פונקציונלי' },
    { name: 'מסורתי', value: 'traditional', prompt: 'שנה את סגנון החדר למסורתי - קלאסי, פורמלי, סימטרי' },
    { name: 'חווה מודרנית', value: 'modern farmhouse', prompt: 'שנה את סגנון החדר לחווה מודרנית - כפרי, ניטרלי, רגוע' },
    { name: 'עכשווי', value: 'contemporary', prompt: 'שנה את סגנון החדר לעכשווי - עדכני, חלק, מתוחכם' },
    { name: 'חופי', value: 'coastal', prompt: 'שנה את סגנון החדר לחופי - אוורירי, בהיר, רוחי' },
    { name: 'אר דקו', value: 'art deco', prompt: 'שנה את סגנון החדר לאר דקו - גיאומטרי, מפואר' }
  ]

  const handleAngleSelect = (angle) => {
    setShowAnglePanel(false)
    console.log('📐 Angle Selection - Prompt being added to input:', angle.prompt)
    console.log('📐 Selected angle:', angle.name, angle.value)
    addPromptToInput(angle.prompt)
  }

  const handleLightingSelect = (lighting) => {
    setShowLightingOptions(false)
    console.log('💡 Lighting Selection - Prompt being added to input:', lighting.prompt)
    console.log('💡 Selected lighting:', lighting.name, lighting.value)
    addPromptToInput(lighting.prompt)
  }

  const handleFurnitureSelect = (furniture) => {
    setShowFurnitureOptions(false)
    console.log('🪑 Furniture Selection - Prompt being added to input:', furniture.prompt)
    console.log('🪑 Selected furniture:', furniture.name, furniture.value)
    addPromptToInput(furniture.prompt)
  }

  const handleRepairsSelect = (repair) => {
    setShowRepairsOptions(false)
    console.log('🔨 Repairs Selection - Prompt being added to input:', repair.prompt)
    console.log('🔨 Selected repair:', repair.name, repair.value)
    addPromptToInput(repair.prompt)
  }

  const handleStyleSelect = (style) => {
    setShowStyleOptions(false)
    console.log('🎨 Style Selection - Prompt being added to input:', style.prompt)
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
    
    // Execute immediately if not in edit mode (or logic dictates immediate execution)
    // Based on previous pattern in App.jsx, we likely want immediate execution or just adding to prompt
    // But user request specifically asked to "clear the prompt text input" after selection
    // Assuming they mean after the action is taken.
    // If GeneralApp acts differently (e.g. accumulates prompt), we might only clear if we execute.
    
    // Checking handleColorDialogApply in GeneralApp (if exists) or similar handlers
    // In GeneralApp, handleStyleSelect calls addPromptToInput which just updates state.
    // If the intention is to EXECUTE then CLEAR, we need to call handleAIEdit.
    
    // Let's align with App.jsx behavior if possible, or at least clear if it executes.
    // However, in GeneralApp, handleStyleSelect previously just called addPromptToInput(style.prompt).
    // If the user wants to clear the prompt text input *after choosing*, it implies the choice triggers the action.
    
    // Let's check if handleAIEdit exists in GeneralApp
    handleAIEdit(newPrompt)
    setCustomPrompt('')
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
      // Normal case: add comma and space
      newPrompt = `${currentPrompt}, ${prompt}`
    }
    
    setCustomPrompt(newPrompt)
  }

  const handleAIEdit = async (prompt) => {
    if (!mainImage) return
    
    setIsProcessing(true)
    try {
      // Debug: Log the prompt being sent to AI
      console.log('🎨 AI Image Alteration - Prompt being sent:', prompt)
      console.log('📸 Main image URL:', mainImage)
      console.log('🖼️ Object image available:', !!objectImageFile)
      
      // Check if user can make requests
      if (isAuthenticated && currentUser) {
        const canMakeRequest = await aiService.canMakeRequest(currentUser.uid)
        if (!canMakeRequest) {
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
      } else {
        alert('התמונה לא עובדה בהצלחה. נסה עם תמונה אחרת או פעולה אחרת.')
      }
    } catch (error) {
      console.error('AI processing failed:', error)
      
      // Handle specific error types
      if (error.message?.includes('limit reached') || error.message?.includes('מגבלת הדורות')) {
        setShowLimitModal(true)
      } else if (error.message?.includes('timeout')) {
        alert('הבקשה ארכה יותר מדי זמן. נסה שוב.')
      } else {
        alert('שגיאה בעיבוד התמונה. אנא נסה שוב או עם תמונה אחרת.')
      }
    } finally {
      setIsProcessing(false)
    }
  }

  return (
    <div className="min-h-screen bg-background">
            {/* Combined Header with Categories */}
      <header className="bg-surface/90 shadow-sm border-b border-white/10 relative z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Desktop Layout */}
          <div className="hidden md:flex justify-between items-center py-3">
            <div className="flex items-center">
              <img src="/Logo.png" alt="MoomHe Logo" className="h-16 w-auto" />
              <span className="mr-2 text-sm text-gray-400">כל סוגי העיצוב</span>
            </div>
            <div className="flex items-center">
              <a 
                href="/" 
                className="flex items-center gap-2 px-4 py-2 text-sm text-gray-300 hover:text-gray-100 hover:bg-white/5 rounded-lg transition-colors duration-200"
              >
                <ArrowLeft className="w-4 h-4" />
                עיצוב פנים וחוץ
              </a>
            </div>
            <div className="flex items-center space-x-4">
              <button 
                className="bg-white/5 hover:bg-white/5 text-gray-300 hover:text-gray-100 rounded-full flex items-center gap-2 px-4 py-2 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed" 
                disabled={isProcessing}
                onClick={(e) => {
                  e.preventDefault()
                  e.stopPropagation()
                  console.log('Login button clicked', { 
                    currentUser, 
                    isAnonymous: currentUser?.isAnonymous,
                    hasEmail: !!currentUser?.email 
                  })
                  const isLoggedIn = currentUser && !currentUser.isAnonymous && currentUser.email
                  if (isLoggedIn) {
                    console.log('User is logged in, showing logout modal')
                    setShowLogoutModal(true)
                  } else {
                    console.log('User is not logged in, showing auth modal')
                    setShowAuthModal(true)
                    setAuthMode('login')
                  }
                }}
              >
                {currentUser && !currentUser.isAnonymous ? (
                  <>
                    <div className="w-5 h-5 bg-green-500 rounded-full flex items-center justify-center">
                      <svg className="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                    <span className="text-sm">{currentUser.email}</span>
                  </>
                ) : (
                  <>
                    <User className="w-5 h-5" />
                    התחבר
                  </>
                )}
              </button>
            </div>
          </div>
          
          {/* Mobile Layout */}
          <div className="md:hidden py-3">
            <div className="flex items-center justify-between">
              {/* Left: Profile Button */}
              <div className="flex items-center">
                <button 
                  className="bg-white/5 hover:bg-white/5 text-gray-300 hover:text-gray-100 rounded-full flex items-center gap-2 px-3 py-2 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-sm" 
                  disabled={isProcessing}
                  onClick={(e) => {
                    e.preventDefault()
                    e.stopPropagation()
                    console.log('Mobile login button clicked', { 
                      currentUser, 
                      isAnonymous: currentUser?.isAnonymous,
                      hasEmail: !!currentUser?.email 
                    })
                    const isLoggedIn = currentUser && !currentUser.isAnonymous && currentUser.email
                    if (isLoggedIn) {
                      console.log('User is logged in, showing logout modal (mobile)')
                      setShowLogoutModal(true)
                    } else {
                      console.log('User is not logged in, showing auth modal (mobile)')
                      setShowAuthModal(true)
                      setAuthMode('login')
                    }
                  }}
                >
                  {currentUser && !currentUser.isAnonymous ? (
                    <>
                      <div className="w-4 h-4 bg-green-500 rounded-full flex items-center justify-center">
                        <svg className="w-2.5 h-2.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                        </svg>
                      </div>
                      <span className="text-xs">{currentUser.email}</span>
                    </>
                  ) : (
                    <>
                      <User className="w-4 h-4" />
                      התחבר
                    </>
                  )}
                </button>
              </div>
              
              {/* Center: Logo */}
              <div className="flex items-center">
                <img src="/Logo.png" alt="MoomHe Logo" className="h-12 w-auto" />
              </div>
              
              {/* Right: Categories Dropdown */}
              <div className="flex items-center">
              <div className="relative mobile-dropdown">
                <button
                  onClick={() => setShowMobileDropdown(!showMobileDropdown)}
                  className="btn-secondary flex items-center"
                  disabled={isProcessing}
                >
                  <span className="text-sm">{selectedCategory}</span>
                  <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>
                
                {/* Dropdown Menu */}
                {showMobileDropdown && (
                  <div className="absolute top-full right-0 mt-2 w-64 bg-surface/90 rounded-lg shadow-lg border border-white/10 z-50 max-h-80 overflow-y-auto">
            {categories.map((category) => {
              const IconComponent = categoryIcons[category]
              return (
                <button
                  key={category}
                          onClick={() => {
                            handleCategorySelect(category)
                            setShowMobileDropdown(false)
                          }}
                          className={`w-full flex items-center px-4 py-3 text-right hover:bg-white/5 transition-colors duration-200 ${
                            selectedCategory === category ? 'bg-primary-500/10 text-primary-600' : 'text-gray-200'
                          }`}
                        >
                          <IconComponent className="w-4 h-4 ml-3" />
                          <span className="text-sm font-medium">{category}</span>
                        </button>
                      )
                    })}
                  </div>
                )}
              </div>
              </div>
            </div>
          </div>
          
          {/* Scrollable Category Buttons - Hidden on Mobile */}
          <div className="hidden md:flex space-x-reverse space-x-1 pb-3 overflow-x-auto scrollbar-hide">
            {categories.map((category) => {
              const IconComponent = categoryIcons[category]
              return (
                <button
                  key={category}
                  onClick={() => handleCategorySelect(category)}
                  disabled={isProcessing}
                  className={`flex-shrink-0 px-4 py-2 rounded-lg font-medium transition-all duration-200 text-sm flex items-center disabled:opacity-50 disabled:cursor-not-allowed ${
                    selectedCategory === category
                      ? 'bg-accent text-white shadow-lg'
                      : 'bg-surface/90 text-text hover:bg-white/5 border border-white/10'
                  }`}
                >
                  <IconComponent className="w-4 h-4 ml-2" />
                  {category}
                </button>
              )
            })}
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 md:py-8">
        {/* Mobile Layout */}
        <div className="block lg:hidden">
          {/* Main Stage - Primary on Mobile */}
          <div className="mb-6 -mt-4">
            <div className="bg-surface/90 shadow-sm border-b border-white/10 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 py-4">
              {/* Main Image Display */}
              <div className="relative mb-4">
                <div 
                  className="w-full rounded-lg shadow-lg overflow-hidden transition-all duration-300"
                  style={{ 
                    aspectRatio: imageAspectRatio,
                    maxHeight: '50vh' // Optimized for mobile
                  }}
                >
                  <img
                    src={mainImage}
                    alt="Main room design"
                    onClick={handleMainImageClick}
                    onLoad={handleImageLoad}
                    className={`w-full h-full object-contain rounded-lg transition-all duration-300 cursor-pointer hover:opacity-90 ${
                      isProcessing ? 'blur-sm cursor-not-allowed' : ''
                    }`}
                  />
                </div>
                
                {/* Upload Button Overlay - Mobile */}
                <button
                  onClick={handleUploadClick}
                  disabled={isProcessing}
                  className="absolute top-3 right-3 bg-primary-500/70 hover:bg-primary-500/90 text-white px-3 py-2 rounded-lg text-xs font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm flex items-center gap-1"
                >
                  <Upload className="w-3 h-3" />
                  העלה תמונה
                </button>

                {/* Download, WhatsApp and Add Object Buttons - Mobile (Top Left) */}
                <div className="absolute top-3 left-3 flex gap-2">
                  <button 
                    onClick={() => objectInputRef.current?.click()}
                    disabled={isProcessing}
                    className="w-8 h-8 bg-black/50 hover:bg-primary-600/70 text-white rounded-full flex items-center justify-center transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm border border-white/10"
                    title="אובייקט מתמונה"
                  >
                    <Plus className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={handleDownload}
                    disabled={isProcessing}
                    className="w-8 h-8 bg-black/50 hover:bg-green-600/70 text-white rounded-full flex items-center justify-center transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm border border-white/10"
                    title="הורדה"
                  >
                    <Download className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={handleWhatsAppShare}
                    disabled={isProcessing}
                    className="w-8 h-8 bg-black/50 hover:bg-green-600/70 text-white rounded-full flex items-center justify-center transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm border border-white/10"
                    title="שיתוף בווטסאפ"
                  >
                    <MessageCircle className="w-4 h-4" />
                  </button>
                </div>
                
                {/* Circular Loader Overlay */}
                {isProcessing && (
                  <div className="absolute inset-0 flex items-center justify-center bg-black/20 rounded-lg">
                <div className="relative">
                      <div className="w-12 h-12 border-4 border-white/30 border-t-white rounded-full animate-spin"></div>
                      <div className="absolute inset-0 flex items-center justify-center">
                        <div className="w-6 h-6 border-2 border-white/50 border-b-white rounded-full animate-spin" style={{ animationDirection: 'reverse', animationDuration: '0.8s' }}></div>
                      </div>
                    </div>
                  </div>
                )}
              </div>


              {/* Mobile Action Bar */}
              <div className="mb-4">
                <div className="flex gap-2 mb-4">
                  <div className="flex-1 relative">
                    <input
                      type="text"
                      value={customPrompt}
                      onChange={(e) => setCustomPrompt(e.target.value)}
                      placeholder="הקלד שינוי..."
                      disabled={isProcessing}
                      className="w-full px-3 py-2 pr-8 text-sm border border-white/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed overflow-x-auto"
                      style={{ 
                        textAlign: 'right',
                        direction: 'rtl',
                        overflowX: 'auto',
                        whiteSpace: 'nowrap'
                      }}
                      onKeyPress={(e) => {
                        if (e.key === 'Enter') {
                          handleCustomPromptSubmit()
                        }
                      }}
                    />

                    {customPrompt && (
                      <button
                        onClick={() => setCustomPrompt('')}
                        disabled={isProcessing}
                        className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-300 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        ×
                      </button>
                    )}
                  </div>
                </div>

              </div>


              {/* Mobile Action Buttons - Horizontal Scroll */}
              <div className="relative">
                <div className="flex gap-3 overflow-x-auto scrollbar-hide pb-2 mb-4" ref={(el) => {
                  if (el) {
                    el.addEventListener('scroll', () => {
                      const isScrollable = el.scrollWidth > el.clientWidth;
                      const isAtStart = el.scrollLeft <= 5;
                      const isAtEnd = el.scrollLeft + el.clientWidth >= el.scrollWidth - 5;
                      const leftFade = el.parentElement.querySelector('.fade-overlay-left');
                      const rightFade = el.parentElement.querySelector('.fade-overlay-right');
                      
                      if (leftFade) {
                        leftFade.style.opacity = isScrollable && !isAtEnd ? '1' : '0';
                      }
                      if (rightFade) {
                        rightFade.style.opacity = isScrollable && !isAtStart ? '1' : '0';
                      }
                    });
                  }
                }}>
                  {/* Object Image Upload - First Button */}
                  <button
                    onClick={isProcessing ? undefined : handleObjectUploadClick}
                    disabled={isProcessing}
                    className="flex-1 btn-secondary border-2 border-dashed border-primary-400 hover:border-primary-500 hover:bg-primary-500/10 flex items-center justify-center text-sm px-3 py-2 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {objectImage ? (
                      <div className="relative w-4 h-4 ml-2">
                        <img
                          src={objectImage}
                          alt="Object to add"
                          className="w-full h-full object-cover rounded border border-white/10"
                    />
                    <button
                          onClick={(e) => {
                            e.stopPropagation()
                            handleRemoveObjectImage()
                          }}
                      disabled={isProcessing}
                          className="absolute -top-1 -right-1 bg-red-500 hover:bg-red-600 text-white rounded-full w-3 h-3 flex items-center justify-center text-xs disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                          ×
                    </button>
                  </div>
                ) : (
                      <Plus className="w-4 h-4 text-primary-500 ml-2" />
                    )}
                    <span className="text-primary-600">הוסף אובייקט</span>
                  </button>
                  
                  {/* Suggestions Button - Mobile */}
                  <button
                    onClick={() => setShowSuggestionsModal(true)}
                    disabled={isProcessing}
                    className="flex-1 btn-secondary flex items-center justify-center text-sm px-3 py-2 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Settings className="w-4 h-4 ml-2" />
                    הצעות...
                  </button>
                  
                  {/* בצע Button - Mobile */}
                  <button
                    onClick={handleCustomPromptSubmit}
                    disabled={isProcessing || !customPrompt.trim()}
                    className="flex-1 px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg flex items-center justify-center gap-2 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <span className="text-sm font-medium">בצע</span>
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                    </svg>
                  </button>
                </div>
                
                {/* Fade overlays */}
                <div className="fade-overlay-left absolute top-0 left-0 w-8 h-full bg-gradient-to-r from-white to-transparent pointer-events-none transition-opacity duration-300 opacity-0"></div>
                <div className="fade-overlay-right absolute top-0 right-0 w-8 h-full bg-gradient-to-l from-white to-transparent pointer-events-none transition-opacity duration-300 opacity-0"></div>
              </div>
              
              {/* Hidden file input for object upload */}
              <input
                ref={objectInputRef}
                type="file"
                accept="image/*"
                onChange={handleObjectImageUpload}
                className="hidden"
              />


            </div>
          </div>

          {/* Hidden file input for upload functionality */}
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleImageUpload}
                className="hidden"
              />

          {/* Mobile Secondary Panels */}
          <div className="space-y-4">


            {/* History Panel - Mobile */}
            <div className="card p-4 relative">
              <h3 className="text-lg font-semibold text-text mb-3 flex items-center">
                <svg className="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                יצירות
              </h3>
              <div className={`transition-opacity duration-300 ${
                isLoadingHistory || isProcessing ? 'opacity-50 pointer-events-none' : ''
              }`}>
                {(imageHistory || []).length === 0 ? (
                  <div className="text-center py-6">
                    <div className="text-gray-400 mb-2">
                      <Sparkles className="w-6 h-6 mx-auto" />
            </div>
                    <p className="text-sm text-gray-400">אין עריכות עדיין</p>
                    <p className="text-xs text-gray-400 mt-1">התמונות שייווצרו יופיעו כאן</p>
                  </div>
                ) : (
                  <div className="relative">
                    <div 
                      ref={historyScrollRef}
                      className="flex gap-3 overflow-x-auto scrollbar-visible pb-2"
                      onScroll={(e) => {
                        if (isProcessing) return
                        const { scrollLeft, scrollWidth, clientWidth } = e.target
                        if (scrollLeft + clientWidth >= scrollWidth - 10 && hasMoreHistory && !isLoadingMoreHistory) {
                          loadMoreHistory()
                        }
                        
                        // Handle fade effects
                        const isScrollable = scrollWidth > clientWidth;
                        const isAtStart = scrollLeft <= 5;
                        const isAtEnd = scrollLeft + clientWidth >= scrollWidth - 5;
                        const leftFade = e.target.parentElement.querySelector('.image-fade-overlay-left');
                        const rightFade = e.target.parentElement.querySelector('.image-fade-overlay-right');
                        
                        if (leftFade) {
                          leftFade.style.opacity = isScrollable && !isAtEnd ? '1' : '0';
                        }
                        if (rightFade) {
                          rightFade.style.opacity = isScrollable && !isAtStart ? '1' : '0';
                        }
                      }}
                    >
                    {(imageHistory || []).map((entry) => (
                      <div
                        key={entry.id}
                        onClick={() => !isProcessing && handleHistoryImageClick(entry)}
                        className="cursor-pointer group flex-shrink-0 w-24"
                      >
                        <div className="relative">
                          <img
                            src={entry.thumbnailUrl || entry.storageUrl || entry.imageUrl}
                            alt="History entry"
                            className="w-24 h-24 object-cover rounded-lg group-hover:opacity-80 transition-opacity duration-200"
                          />
                          <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors duration-200 rounded-lg"></div>
                        </div>
                        <div className="mt-1">
                          <p className="text-xs text-gray-300 truncate" title={entry.prompt || 'No prompt'}>
                            {entry.prompt && entry.prompt.length > 15 ? `${entry.prompt.substring(0, 15)}...` : (entry.prompt || 'No prompt')}
                          </p>
                          <p className="text-xs text-gray-400">{displayTimestamp(entry)}</p>
                        </div>
                      </div>
                    ))}
                    
                    {/* Loading more indicator */}
                    {isLoadingMoreHistory && (
                      <div className="flex-shrink-0 flex items-center justify-center w-24">
                        <div className="w-6 h-6 border-2 border-white/10 border-t-primary-500 rounded-full animate-spin"></div>
                      </div>
                    )}
                    </div>
                    
                    {/* Fade overlays for images */}
                    <div className="image-fade-overlay-left absolute top-0 left-0 w-6 h-full bg-gradient-to-r from-white to-transparent pointer-events-none transition-opacity duration-300 opacity-0"></div>
                    <div className="image-fade-overlay-right absolute top-0 right-0 w-6 h-full bg-gradient-to-l from-white to-transparent pointer-events-none transition-opacity duration-300 opacity-0"></div>
                  </div>
                )}
              </div>
              
              {/* Loading Overlay for History */}
              {isLoadingHistory && (
                <div className="absolute inset-0 bg-surface/90/80 backdrop-blur-sm rounded-xl flex items-center justify-center">
                  <div className="relative">
                    <div className="w-8 h-8 border-4 border-white/10 border-t-purple-500 rounded-full animate-spin"></div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Desktop Layout */}
        <div className="hidden lg:grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Upload Panel */}
          <div className="lg:col-span-1 lg:order-1">

            {/* History Panel */}
            <div className="card p-4 relative">
               <h3 className="text-lg font-semibold text-text mb-3">יצירות</h3>
              <div className={`transition-opacity duration-300 ${
                isLoadingHistory || isProcessing ? 'opacity-50 pointer-events-none' : ''
              }`}>
              {(imageHistory || []).length === 0 ? (
                <div className="text-center py-8">
                  <div className="text-gray-400 mb-2">
                    <Sparkles className="w-8 h-8 mx-auto" />
                  </div>
                  <p className="text-sm text-gray-400">אין עריכות עדיין</p>
                  <p className="text-xs text-gray-400 mt-1">התמונות שייווצרו יופיעו כאן</p>
                </div>
              ) : (
                <div 
                  className={`space-y-3 max-h-96 overflow-y-auto scrollbar-visible ${isProcessing ? 'opacity-50 pointer-events-none' : ''}`}
                  onScroll={(e) => {
                    if (isProcessing) return
                    const { scrollTop, scrollHeight, clientHeight } = e.target
                    if (scrollTop + clientHeight >= scrollHeight - 10 && hasMoreHistory && !isLoadingMoreHistory) {
                      loadMoreHistory()
                    }
                  }}
                >
                  {(imageHistory || []).map((entry) => (
                    <div
                      key={entry.id}
                      onClick={() => !isProcessing && handleHistoryImageClick(entry)}
                      className="cursor-pointer group"
                    >
                      <div className="relative">
                        <img
                          src={entry.thumbnailUrl || entry.storageUrl || entry.imageUrl}
                          alt="History entry"
                          className="w-full h-24 object-cover rounded-lg group-hover:opacity-80 transition-opacity duration-200"
                        />
                        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors duration-200 rounded-lg"></div>
                      </div>
                      <div className="mt-2">
                        <p className="text-xs text-gray-300 truncate" title={entry.prompt || 'No prompt'}>
                          {entry.prompt && entry.prompt.length > 30 ? `${entry.prompt.substring(0, 30)}...` : (entry.prompt || 'No prompt')}
                        </p>
                        <p className="text-xs text-gray-400 mt-1">{displayTimestamp(entry)}</p>
                      </div>
                    </div>
                  ))}
                  
                  {/* Loading more indicator and manual load more button */}
                  {isLoadingMoreHistory ? (
                    <div className="flex justify-center py-4">
                      <div className="w-6 h-6 border-2 border-white/10 border-t-primary-500 rounded-full animate-spin"></div>
                    </div>
                  ) : hasMoreHistory ? (
                    <div className="flex justify-center py-4">
                      <button
                        onClick={loadMoreHistory}
                        disabled={isProcessing}
                        className="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors duration-200 text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        טען עוד
                      </button>
                    </div>
                  ) : null}
                </div>
              )}
              </div>
              
              {/* Loading Overlay for History */}
              {isLoadingHistory && (
                <div className="absolute inset-0 bg-surface/90/80 backdrop-blur-sm rounded-xl flex items-center justify-center">
                  <div className="relative">
                    <div className="w-12 h-12 border-4 border-white/10 border-t-purple-500 rounded-full animate-spin"></div>
                    <div className="absolute inset-0 flex items-center justify-center">
                      <div className="w-6 h-6 border-2 border-white/10 border-b-purple-600 rounded-full animate-spin" style={{ animationDirection: 'reverse', animationDuration: '0.8s' }}></div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Main Stage */}
          <div className="lg:col-span-2 lg:order-2">
            <div className="card p-6">

              {/* Main Image Display */}
              <div className="relative mb-6">
                <div 
                  className="w-full rounded-lg shadow-lg overflow-hidden transition-all duration-300"
                  style={{ 
                    aspectRatio: imageAspectRatio,
                    maxHeight: '70vh' // Prevent extremely tall images
                  }}
                >
                <img
                  src={mainImage}
                  alt="Main room design"
                  onClick={handleMainImageClick}
                    onLoad={handleImageLoad}
                    className={`w-full h-full object-contain rounded-lg transition-all duration-300 cursor-pointer hover:opacity-90 ${
                    isProcessing ? 'blur-sm cursor-not-allowed' : ''
                  }`}
                />
                </div>
                
                {/* Upload Button Overlay - Desktop */}
                <button
                  onClick={handleUploadClick}
                  disabled={isProcessing}
                  className="absolute top-4 right-4 bg-primary-500/70 hover:bg-primary-500/90 text-white px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm flex items-center gap-2"
                >
                  <Upload className="w-4 h-4" />
                  העלה תמונה
                </button>

                {/* Download, WhatsApp and Add Object Buttons - Desktop (Top Left) */}
                <div className="absolute top-4 left-4 flex gap-2">
                  <button 
                    onClick={() => objectInputRef.current?.click()}
                    disabled={isProcessing}
                    className="w-10 h-10 bg-black/50 hover:bg-primary-600/70 text-white rounded-full flex items-center justify-center transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm border border-white/10"
                    title="אובייקט מתמונה"
                  >
                    <Plus className="w-5 h-5" />
                  </button>
                  <button 
                    onClick={handleDownload}
                    disabled={isProcessing}
                    className="w-10 h-10 bg-black/50 hover:bg-green-600/70 text-white rounded-full flex items-center justify-center transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm border border-white/10"
                    title="הורדה"
                  >
                    <Download className="w-5 h-5" />
                  </button>
                  <button 
                    onClick={handleWhatsAppShare}
                    disabled={isProcessing}
                    className="w-10 h-10 bg-black/50 hover:bg-green-600/70 text-white rounded-full flex items-center justify-center transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm border border-white/10"
                    title="שיתוף בווטסאפ"
                  >
                    <MessageCircle className="w-5 h-5" />
                  </button>
                </div>
                
                {/* Circular Loader Overlay */}
                {isProcessing && (
                  <div className="absolute inset-0 flex items-center justify-center bg-black/20 rounded-lg">
                    <div className="relative">
                      <div className="w-16 h-16 border-4 border-white/30 border-t-white rounded-full animate-spin"></div>
                      <div className="absolute inset-0 flex items-center justify-center">
                        <div className="w-8 h-8 border-2 border-white/50 border-b-white rounded-full animate-spin" style={{ animationDirection: 'reverse', animationDuration: '0.8s' }}></div>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Custom Prompt Input */}
              <div className="mb-6">
                <div className="flex gap-3">
                  <div className="flex-1 relative">
                    <input
                      type="text"
                      value={customPrompt}
                      onChange={(e) => setCustomPrompt(e.target.value)}
                      placeholder="הקלד שינוי..."
                      disabled={isProcessing}
                      className="w-full px-4 py-3 pr-10 border border-white/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed overflow-x-auto"
                      style={{ 
                        textAlign: 'right',
                        direction: 'rtl',
                        overflowX: 'auto',
                        whiteSpace: 'nowrap'
                      }}
                      onKeyPress={(e) => {
                        if (e.key === 'Enter') {
                          handleCustomPromptSubmit()
                        }
                      }}
                    />

                    {customPrompt && (
                      <button
                        onClick={() => setCustomPrompt('')}
                        disabled={isProcessing}
                        className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-300 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        ×
                      </button>
                    )}
                  </div>
                </div>

              </div>

              {/* Action Buttons */}
              <div className="flex gap-4">
                {/* Object Image Upload - always available */}
                <div className="relative">
                  {objectImage ? (
                    <div className="relative btn-secondary h-10 w-24 flex items-center justify-center">
                      <img
                        src={objectImage}
                        alt="Object to add"
                        className="w-6 h-6 object-cover rounded border border-white/10"
                      />
                <button 
                        onClick={handleRemoveObjectImage}
                  disabled={isProcessing}
                        className="absolute -top-1 -right-1 bg-red-500 hover:bg-red-600 text-white rounded-full w-4 h-4 flex items-center justify-center text-xs disabled:opacity-50 disabled:cursor-not-allowed"
                >
                        ×
                </button>
                    </div>
                  ) : (
                    <button
                      onClick={isProcessing ? undefined : handleObjectUploadClick}
                      disabled={isProcessing}
                      className={`flex-1 btn-secondary h-10 border-2 border-dashed border-primary-400 hover:border-primary-500 hover:bg-primary-500/10 flex items-center justify-center transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed`}
                    >
                      <Plus className="w-4 h-4 text-primary-500 ml-2" />
                      <span className="text-sm text-primary-600">הוסף אובייקט</span>
                    </button>
                  )}
                  
                  <input
                    ref={objectInputRef}
                    type="file"
                    accept="image/*"
                    onChange={handleObjectImageUpload}
                    className="hidden"
                  />
                </div>
                
                {/* Suggestions Dropdown */}
                <div className="relative" ref={suggestionsDropdownRef}>
                  <button
                    onClick={() => setShowSuggestionsDropdown(!showSuggestionsDropdown)}
                    disabled={isProcessing}
                    className="flex-1 btn-secondary flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Settings className="w-4 h-4 ml-2" />
                    הצעות...
                  </button>
                  
                  {showSuggestionsDropdown && (
                    <div className="absolute top-full left-0 mt-1 bg-surface/90 border border-white/10 rounded-lg shadow-lg z-50 min-w-48">
                      {categoryActionButtons[selectedCategory]?.map((button, index) => (
                        <button
                          key={index}
                          onClick={() => {
                            button.action()
                            setShowSuggestionsDropdown(false)
                          }}
                          disabled={isProcessing}
                          className="w-full px-4 py-2 text-right hover:bg-white/5 flex items-center justify-end gap-2 disabled:opacity-50 disabled:cursor-not-allowed border-b border-white/10 last:border-b-0"
                        >
                          <span>{button.name}</span>
                          <button.icon className="w-4 h-4" />
                        </button>
                      ))}
                    </div>
                  )}
                </div>
                
                {/* בצע Button - Desktop */}
                <button
                  onClick={handleCustomPromptSubmit}
                  disabled={isProcessing || !customPrompt.trim()}
                  className="flex-1 px-4 py-3 bg-primary-600 hover:bg-primary-700 text-white rounded-lg flex items-center justify-center gap-2 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <span className="text-sm font-medium">בצע</span>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                  </svg>
                </button>
              </div>

            </div>
          </div>

        </div>
              </div>

              {/* Color Palette Modal */}
              {showColorPalette && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 h-[85vh] overflow-hidden max-w-[95vw] md:max-w-6xl">
            <div className="p-4 md:p-6">
                      <div className="flex justify-between items-center mb-6">
                        <h3 className="text-lg font-semibold text-text">בחר צבע RAL</h3>
                        <button
                          onClick={() => setShowColorPalette(false)}
                          disabled={isProcessing}
                          className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ×
                        </button>
                      </div>
                      
              {/* Color Category Tabs */}
              <div className="flex flex-wrap gap-1 md:gap-2 mb-4 md:mb-6 border-b border-white/10 pb-3 md:pb-4">
                {Object.keys(colorPalette).map((category) => (
                  <button
                    key={category}
                    onClick={() => setActiveColorCategory(category)}
                    disabled={isProcessing}
                    className={`flex items-center gap-2 px-2 md:px-4 py-1 md:py-2 rounded-lg font-medium text-xs md:text-sm transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed ${
                      activeColorCategory === category
                        ? 'bg-primary-600 text-white shadow-lg'
                        : 'bg-white/5 text-gray-200 hover:bg-white/5'
                    }`}
                  >
                    <div 
                      className="w-3 h-3 rounded-full border border-white/10"
                      style={{ backgroundColor: colorCategoryColors[category] }}
                    ></div>
                    {category}
                  </button>
                ))}
              </div>
              
              {/* Active Category Colors */}
              <div className="h-96 overflow-y-auto">
                <div className="grid grid-cols-4 md:grid-cols-8 gap-2 md:gap-3">
                  {colorPalette[activeColorCategory]?.map((color, index) => (
                              <button
                                key={index}
                                onClick={() => handleColorSelect(color)}
                                disabled={isProcessing}
                                className="flex flex-col items-center p-3 rounded-lg hover:bg-white/5 transition-colors duration-200 border border-white/10 disabled:opacity-50 disabled:cursor-not-allowed"
                              >
                                <div 
                        className="w-12 h-12 rounded-full border-2 border-white/10 shadow-sm mb-2"
                                  style={{ backgroundColor: color.hex }}
                                ></div>
                                <span className="text-xs text-text font-medium text-center leading-tight">
                                  {color.ral}
                                </span>
                                <span className="text-xs text-gray-400 text-center leading-tight mt-1">
                                  {color.name}
                                </span>
                              </button>
                            ))}
                          </div>
                        </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Angle Panel Modal */}
              {showAnglePanel && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-h-[70vh] overflow-y-auto max-w-[95vw] md:max-w-2xl">
            <div className="p-4 md:p-6">
                      <div className="flex justify-between items-center mb-6">
                        <h3 className="text-lg font-semibold text-text">בחר זווית ופרספקטיבה</h3>
                        <button
                          onClick={() => setShowAnglePanel(false)}
                          disabled={isProcessing}
                          className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ×
                        </button>
                      </div>
                      
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4">
                        {angleOptions.map((angle, index) => (
                          <button
                            key={index}
                            onClick={() => handleAngleSelect(angle)}
                            disabled={isProcessing}
                            className="flex items-center p-4 rounded-lg hover:bg-white/5 transition-colors duration-200 border border-white/10 disabled:opacity-50 disabled:cursor-not-allowed"
                          >
                            <span className="text-2xl ml-3">{angle.icon}</span>
                            <div className="text-right">
                              <div className="text-sm font-medium text-text">{angle.name}</div>
                              <div className="text-xs text-gray-400">{angle.value}</div>
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Lighting Options Modal */}
              {showLightingOptions && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-h-[70vh] overflow-y-auto max-w-[95vw] md:max-w-2xl">
            <div className="p-4 md:p-6">
                      <div className="flex justify-between items-center mb-6">
                        <h3 className="text-lg font-semibold text-text">בחר סוג תאורה</h3>
                        <button
                          onClick={() => setShowLightingOptions(false)}
                          disabled={isProcessing}
                          className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ×
                        </button>
                      </div>
                      
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4">
                        {lightingOptions.map((lighting, index) => (
                          <button
                            key={index}
                            onClick={() => handleLightingSelect(lighting)}
                            disabled={isProcessing}
                            className="flex items-center p-4 rounded-lg hover:bg-white/5 transition-colors duration-200 border border-white/10 disabled:opacity-50 disabled:cursor-not-allowed"
                          >
                            <span className="text-2xl ml-3">💡</span>
                            <div className="text-right">
                              <div className="text-sm font-medium text-text">{lighting.name}</div>
                              <div className="text-xs text-gray-400">{lighting.value}</div>
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Furniture Options Modal */}
              {showFurnitureOptions && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-h-[70vh] overflow-y-auto max-w-[95vw] md:max-w-2xl">
            <div className="p-4 md:p-6">
                      <div className="flex justify-between items-center mb-6">
                        <h3 className="text-lg font-semibold text-text">בחר סוג ריהוט</h3>
                        <button
                          onClick={() => setShowFurnitureOptions(false)}
                          disabled={isProcessing}
                          className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ×
                        </button>
                      </div>
                      
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4">
                        {furnitureOptions.map((furniture, index) => (
                          <button
                            key={index}
                            onClick={() => handleFurnitureSelect(furniture)}
                            disabled={isProcessing}
                            className="flex items-center p-4 rounded-lg hover:bg-white/5 transition-colors duration-200 border border-white/10 disabled:opacity-50 disabled:cursor-not-allowed"
                          >
                            <div className="text-right w-full">
                              <div className="text-sm font-medium text-text">{furniture.name}</div>
                              <div className="text-xs text-gray-400">{furniture.value}</div>
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}

      {/* Repairs Options Modal */}
      {showRepairsOptions && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-h-[70vh] overflow-y-auto max-w-[95vw] md:max-w-2xl">
            <div className="p-4 md:p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-semibold text-text">בחר סוג תיקון/נזק</h3>
                <button
                  onClick={() => setShowRepairsOptions(false)}
                  disabled={isProcessing}
                  className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  ×
                </button>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {repairsOptions.map((repair) => (
                  <button
                    key={repair.value}
                    onClick={() => handleRepairsSelect(repair)}
                    disabled={isProcessing}
                    className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                  >
                    <Hammer className="w-5 h-5 text-gray-300 flex-shrink-0" />
                    <span className="text-sm font-medium text-gray-100">{repair.name}</span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Style Options Modal */}
      {showStyleOptions && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-h-[80vh] overflow-y-auto max-w-[95vw] md:max-w-3xl">
            <div className="p-4 md:p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-semibold text-text">בחר סגנון עיצוב</h3>
                <button
                  onClick={() => setShowStyleOptions(false)}
                  disabled={isProcessing}
                  className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  ×
                </button>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {styleOptions.map((style) => (
                  <button
                    key={style.value}
                    onClick={() => handleStyleSelect(style)}
                    disabled={isProcessing}
                    className="flex flex-col items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-center"
                  >
                    <FreeStyle className="w-6 h-6 text-primary-600 flex-shrink-0" />
                    <div>
                      <div className="text-sm font-medium text-gray-100 mb-1">{style.name}</div>
                      <div className="text-xs text-gray-400">{style.value}</div>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Doors/Windows Options Modal */}
      {showDoorsWindowsOptions && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-h-[80vh] overflow-y-auto max-w-[95vw] md:max-w-4xl">
            <div className="p-4 md:p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-semibold text-text">דלתות וחלונות</h3>
                <button
                  onClick={() => setShowDoorsWindowsOptions(false)}
                  disabled={isProcessing}
                  className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  ×
                </button>
              </div>
              
              <div className="space-y-6">
                {/* Window Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות חלונות</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'חלון מפרץ/קשת', value: 'הוסף חלון מפרץ או קשת שמגדיל את החלל', hebrew: 'הוסף חלון מפרץ או קשת שמגדיל את החלל' },
                      { name: 'חלון תמונה', value: 'Picture Window: Large, fixed view.', hebrew: 'הוסף חלון תמונה גדול עם נוף קבוע' },
                      { name: 'חלון ציר', value: 'Casement Window: Outward crank open.', hebrew: 'הוסף חלון ציר שנפתח החוצה' },
                      { name: 'חלון גג/מנהרת שמש', value: 'Skylight / Sun Tunnel: Light from above.', hebrew: 'הוסף חלון גג או מנהרת שמש לאור מלמעלה' },
                      { name: 'חלון טרנזום', value: 'Transom Window: Sits over door.', hebrew: 'הוסף חלון טרנזום מעל הדלת' },
                      { name: 'חלון פנימי', value: 'Interior Window: Between two rooms.', hebrew: 'הוסף חלון פנימי בין שני חדרים' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowDoorsWindowsOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Home className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Door Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות דלתות</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'דלתות צרפתיות', value: 'French Doors: Glass pane entry.', hebrew: 'הוסף דלתות צרפתיות עם זכוכית' },
                      { name: 'דלת כיס', value: 'Pocket Door: Slides inside wall.', hebrew: 'הוסף דלת כיס שנכנסת לתוך הקיר' },
                      { name: 'דלת אסם', value: 'Barn Door: Sliding exposed track.', hebrew: 'הוסף דלת אסם עם מסילה גלויה' },
                      { name: 'דלת לובר', value: 'Louvered Door: Vented slats, air.', hebrew: 'הוסף דלת לובר עם סורגים לאוורור' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowDoorsWindowsOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Home className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Bathroom Options Modal */}
      {showBathroomOptions && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-h-[80vh] overflow-y-auto max-w-[95vw] md:max-w-4xl">
            <div className="p-4 md:p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-semibold text-text">אפשרויות רחצה</h3>
                <button
                  onClick={() => setShowBathroomOptions(false)}
                  disabled={isProcessing}
                  className="text-gray-400 hover:text-gray-200 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  ×
                </button>
              </div>
              
              <div className="space-y-6">
                {/* Toilet Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות אסלה</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'מושב אסלה', value: 'Toilet Seat: Slow-close lid', hebrew: 'הוסף מושב אסלה עם מכסה שנסגר לאט' },
                      { name: 'בידט מחומם', value: 'Toilet Seat: Heated bidet function', hebrew: 'הוסף מושב אסלה עם פונקציית בידט מחוממת' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowBathroomOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Settings className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Bathtub Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות אמבטיה</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'אמבטיה עומדת', value: 'Bathtub: Freestanding oval soak', hebrew: 'הוסף אמבטיה עומדת אליפטית' },
                      { name: 'אמבטיה וינטג', value: 'Bathtub: Clawfoot vintage design', hebrew: 'הוסף אמבטיה וינטג עם רגליים מעוצבות' },
                      { name: 'אמבטיה סטנדרטית', value: 'Bathtub: Drop-in standard size', hebrew: 'הוסף אמבטיה סטנדרטית מובנית' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowBathroomOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Settings className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Shower Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות מקלחת</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'מקלחת זכוכית', value: 'Shower: Walk-in frameless glass', hebrew: 'הוסף מקלחת עם זכוכית ללא מסגרת' },
                      { name: 'מקלחת גשם', value: 'Shower: Rainfall head system', hebrew: 'הוסף מקלחת עם מערכת ראש גשם' },
                      { name: 'מקלחת דלתות', value: 'Shower: Sliding door enclosure', hebrew: 'הוסף מקלחת עם דלתות הזזה' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowBathroomOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Settings className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Sink Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות כיור</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'כיור כלי', value: 'Sink (Vanity): Vessel bowl style', hebrew: 'הוסף כיור כלי בסגנון קערה' },
                      { name: 'כיור עמוד', value: 'Sink (Vanity): Pedestal classic look', hebrew: 'הוסף כיור עמוד בסגנון קלאסי' },
                      { name: 'כיור מובנה', value: 'Sink (Vanity): Undermount ceramic white', hebrew: 'הוסף כיור מובנה קרמי לבן' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowBathroomOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Settings className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Jacuzzi/Spa Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות ג\'קוזי/ספא</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'ג\'קוזי נייד', value: 'Jacuzzi / Spa: Portable vinyl bubble', hebrew: 'הוסף ג\'קוזי נייד ויניל' },
                      { name: 'ג\'קוזי מובנה', value: 'Jacuzzi / Spa: Built-in tiled perimeter', hebrew: 'הוסף ג\'קוזי מובנה עם אריחים' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowBathroomOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Settings className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Pool Options */}
                <div>
                  <h4 className="text-md font-semibold text-gray-100 mb-3">אפשרויות בריכה</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {[
                      { name: 'בריכה מעל הקרקע', value: 'Pool: Above-ground metal frame', hebrew: 'הוסף בריכה מעל הקרקע עם מסגרת מתכת' },
                      { name: 'בריכה בתוך הקרקע', value: 'Pool: In-ground concrete custom', hebrew: 'הוסף בריכה בתוך הקרקע מבטון מותאמת אישית' }
                    ].map((option, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          addPromptToInput(option.hebrew)
                          setShowBathroomOptions(false)
                        }}
                        disabled={isProcessing}
                        className="flex items-center gap-3 p-4 rounded-lg border border-white/10 hover:border-primary-300 hover:bg-primary-500/10 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-right"
                      >
                        <Settings className="w-5 h-5 text-gray-300 flex-shrink-0" />
                        <div>
                          <div className="text-sm font-medium text-gray-100">{option.name}</div>
                          <div className="text-xs text-gray-400">{option.hebrew}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Image Modal */}
      {showImageModal && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-90 flex items-center justify-center z-[60] p-4"
          onClick={handleCloseModal}
        >
          <div className="relative max-w-7xl max-h-full w-full h-full flex items-center justify-center">
            <img
              src={mainImage}
              alt="Full size view"
              className="max-w-full max-h-full object-contain rounded-lg shadow-2xl"
            />
            <button
              onClick={handleCloseModal}
              className="absolute top-4 right-4 bg-surface/90/20 hover:bg-surface/90/30 text-white p-3 rounded-full transition-colors duration-200 backdrop-blur-sm"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
            <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 bg-black/50 text-white px-4 py-2 rounded-full backdrop-blur-sm">
              <span className="text-sm">לחץ על התמונה או מחוץ לה לסגירה</span>
            </div>
          </div>
        </div>
      )}

      {/* Suggestions Modal - Mobile */}
      {showSuggestionsModal && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60] p-4"
          onClick={() => setShowSuggestionsModal(false)}
        >
          <div 
            className="suggestions-modal bg-surface/90 rounded-xl shadow-2xl w-full max-w-md max-h-[80vh] flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="p-6 border-b border-white/10">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-semibold text-text">הצעות עבור {selectedCategory}</h3>
                <button
                  onClick={() => setShowSuggestionsModal(false)}
                  className="text-gray-400 hover:text-gray-200 text-xl"
                >
                  ×
                </button>
              </div>
            </div>
            
            <div className="flex-1 overflow-y-auto p-6">
              <div className="space-y-3">
                {categoryActionButtons[selectedCategory]?.map((button, index) => (
                  <button
                    key={index}
                    onClick={() => {
                      button.action()
                      setShowSuggestionsModal(false)
                    }}
                    disabled={isProcessing}
                    className="w-full px-4 py-3 text-right hover:bg-white/5 flex items-center justify-start gap-3 disabled:opacity-50 disabled:cursor-not-allowed border border-white/10 rounded-lg transition-colors duration-200"
                  >
                    <button.icon className="w-5 h-5 text-gray-300" />
                    <span className="text-sm font-medium">{button.name}</span>
                  </button>
                ))}
              </div>
            </div>
            
            <div className="p-6 border-t border-white/10">
              <button
                onClick={() => setShowSuggestionsModal(false)}
                className="w-full bg-white/5 hover:bg-white/5 text-gray-200 font-medium py-3 px-4 rounded-lg transition-colors duration-200"
              >
                סגור
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Logout Modal */}
      {showLogoutModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60]">
          <div className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-w-md">
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-semibold text-text">התנתקות</h3>
                <button
                  onClick={() => setShowLogoutModal(false)}
                  className="text-gray-400 hover:text-gray-200 text-xl"
                >
                  ×
                </button>
              </div>
              
              <div className="text-center mb-6">
                <p className="text-gray-300 mb-4">
                  האם אתה בטוח שברצונך להתנתק?
                </p>
                <p className="text-sm text-gray-400">
                  {currentUser?.email}
                </p>
              </div>
              
              <div className="flex gap-3">
                <button
                  onClick={() => setShowLogoutModal(false)}
                  className="flex-1 bg-white/5 hover:bg-white/5 text-gray-200 font-medium py-2 px-4 rounded-lg transition-colors duration-200"
                >
                  ביטול
                </button>
                <button
                  onClick={handleLogout}
                  className="flex-1 bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200"
                >
                  התנתק
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <LimitReachedModal 
        isOpen={showLimitModal} 
        onClose={() => setShowLimitModal(false)} 
        onShowPricing={() => {
            setShowLimitModal(false)
            // Optionally redirect to main app or show contact modal
            setShowContactModal(true) 
        }}
        userSubscription={0}
        currentUsage={4}
        limit={4}
      />

      {/* Authentication Modal */}
      {showAuthModal && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[80]"
          style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0 }}
          onClick={(e) => {
            if (e.target === e.currentTarget) {
              setShowAuthModal(false)
            }
          }}
        >
          <div 
            className="bg-surface/90 rounded-xl shadow-2xl w-full mx-4 max-w-md"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-semibold text-text">
                  {authMode === 'login' ? 'התחברות' : 'יצירת חשבון'}
                </h3>
                <button
                  onClick={() => {
                    setShowAuthModal(false)
                    setEmail('')
                    setConfirmEmail('')
                    setPassword('')
                    setAuthMode('signup')
                  }}
                  className="text-gray-400 hover:text-gray-200 text-xl"
                >
                  ×
                </button>
              </div>
              
              <form onSubmit={handleAuthSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-200 mb-2">
                    כתובת אימייל
                  </label>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full px-3 py-2 border border-white/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="example@email.com"
                    required
                  />
                </div>
                
                {authMode === 'signup' && (
                  <div>
                    <label className="block text-sm font-medium text-gray-200 mb-2">
                      אישור כתובת אימייל
                    </label>
                    <input
                      type="email"
                      value={confirmEmail}
                      onChange={(e) => setConfirmEmail(e.target.value)}
                      className="w-full px-3 py-2 border border-white/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                      placeholder="הזן שוב את כתובת האימייל"
                      required
                    />
                  </div>
                )}
                
                <div>
                  <label className="block text-sm font-medium text-gray-200 mb-2">
                    סיסמה
                  </label>
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full px-3 py-2 border border-white/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="הזן סיסמה"
                    required
                    minLength={6}
                  />
                </div>
                
                {authMode === 'login' && (
                  <div className="text-center">
                    <button
                      type="button"
                      onClick={handlePasswordReset}
                      disabled={isResettingPassword || !email}
                      className="text-primary-600 hover:text-primary-800 text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isResettingPassword ? 'שולח...' : 'שכחת סיסמה?'}
                    </button>
                  </div>
                )}
                
                <button
                  type="submit"
                  disabled={isLoadingAuth || !email || !password || (authMode === 'signup' && !confirmEmail)}
                  className="w-full bg-primary-600 hover:bg-primary-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isLoadingAuth ? 'מעבד...' : (authMode === 'login' ? 'התחבר' : 'צור חשבון')}
                </button>
              </form>
              
              <div className="mt-4 text-center">
                <button
                  onClick={() => setAuthMode(authMode === 'login' ? 'signup' : 'login')}
                  className="border border-primary-600 text-primary-600 hover:bg-primary-500/10 px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200"
                >
                  {authMode === 'login' ? 'אין לך חשבון? צור חשבון חדש' : 'יש לך חשבון? התחבר'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Footer */}
      <footer className="bg-white/5 border-t border-white/10 py-6 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
            <div className="text-sm text-gray-400">
              © 2025 MoomHe. כל הזכויות שמורות.
            </div>
            <div className="flex space-x-6 space-x-reverse">
              <a
                href="/eula.html"
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-gray-300 hover:text-white transition-colors duration-200"
              >
                הסכם שימוש
              </a>
              <a
                href="/privacy.html"
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-gray-300 hover:text-white transition-colors duration-200"
              >
                מדיניות פרטיות
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default GeneralApp
