import React, { useState, useRef, useEffect } from 'react'
import { Upload, Plus, Palette, RotateCcw, Download, Settings, Home, TreePine, Car, Heart, Hammer, Sparkles, Package, User, Share2, Palette as FreeStyle, Type, Loader2 } from 'lucide-react'
import { model, fileToGenerativePart, urlToFile, signInUser, createOrUpdateUser, saveImageToHistory, loadUserHistory, saveUploadToUserUploads, loadUserUploads, auth } from './firebase.js'
import { onAuthStateChanged } from 'firebase/auth'

function App() {
  const [selectedCategory, setSelectedCategory] = useState('עיצוב פנים וחוץ')
  const [uploadedImage, setUploadedImage] = useState(null)
  const [mainImage, setMainImage] = useState('https://images.unsplash.com/photo-1631679706909-1844bbd07221?w=1280&h=720&fit=crop&crop=center')
  const [isProcessing, setIsProcessing] = useState(false)
  const [showColorPalette, setShowColorPalette] = useState(false)
  const [showAnglePanel, setShowAnglePanel] = useState(false)
  const [imageHistory, setImageHistory] = useState([])
  const [userUploads, setUserUploads] = useState([])
  const [currentUser, setCurrentUser] = useState(null)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoadingHistory, setIsLoadingHistory] = useState(false)
  const [isLoadingUploads, setIsLoadingUploads] = useState(false)
  const [showImageModal, setShowImageModal] = useState(false)
  const [detectedObjects, setDetectedObjects] = useState([])
  const [isLoadingObjects, setIsLoadingObjects] = useState(false)
  const [selectedObject, setSelectedObject] = useState(null)
  const [customPrompt, setCustomPrompt] = useState('')
  const [imageAspectRatio, setImageAspectRatio] = useState(16/9) // Default to 16:9
  const [activeColorCategory, setActiveColorCategory] = useState('אדומים') // Default to reds
  const [objectImage, setObjectImage] = useState(null)
  const [objectImageFile, setObjectImageFile] = useState(null)
  const [showMobileDropdown, setShowMobileDropdown] = useState(false)
  const fileInputRef = useRef(null)
  const objectInputRef = useRef(null)

  // Authentication and history loading
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        setCurrentUser(user)
        setIsAuthenticated(true)
        
        // Create or update user record
        await createOrUpdateUser(user)
        
        // Load user history and uploads
        setIsLoadingHistory(true)
        setIsLoadingUploads(true)
        
        try {
          const [history, uploads] = await Promise.all([
            loadUserHistory(user.uid),
            loadUserUploads(user.uid)
          ])
          setImageHistory(history)
          setUserUploads(uploads)
        } finally {
          setIsLoadingHistory(false)
          setIsLoadingUploads(false)
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

  // Detect objects when main image changes
  useEffect(() => {
    if (mainImage && !isProcessing) {
      detectObjects(mainImage)
    }
  }, [mainImage, isProcessing])

  const categories = [
    'עיצוב פנים וחוץ',
    'גינות ומרפסות',
    'איפור וטיפוח',
    'הצגת מוצר ופרסום',
    'תמונות פרופיל ותדמית',
    'רכבים ודו גלגלי',
    'קעקועים',
  ]

  const categoryIcons = {
    'עיצוב פנים וחוץ': Home,
    'גינות ומרפסות': TreePine,
    'איפור וטיפוח': Sparkles,
    'הצגת מוצר ופרסום': Package,
    'תמונות פרופיל ותדמית': User,
    'רכבים ודו גלגלי': Car,
    'קעקועים': Heart
  }

  const categoryDefaultImages = {
    'עיצוב פנים וחוץ': 'https://images.unsplash.com/photo-1631679706909-1844bbd07221?w=1280&h=720&fit=crop&crop=center',
    'גינות ומרפסות': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=1280&h=720&fit=crop&crop=center',
    'איפור וטיפוח': 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=1280&h=720&fit=crop&crop=center',
    'הצגת מוצר ופרסום': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1280&h=720&fit=crop&crop=center',
    'תמונות פרופיל ותדמית': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1280&h=720&fit=crop&crop=center',
    'רכבים ודו גלגלי': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=1280&h=720&fit=crop&crop=center',
    'קעקועים': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=1280&h=720&fit=crop&crop=center'
  }

  const categoryActionButtons = {
    'עיצוב פנים וחוץ': [
      { name: 'שנה צבע קיר', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'תאורה', action: () => handleAIEdit("Enhance the lighting in this image"), icon: Settings },
      { name: 'הוסף ריהוט', action: () => handleAIEdit("Add modern furniture to this room"), icon: Plus },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'גינות ומרפסות': [
      { name: 'שנה צבע קיר', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'הוסף צמחים', action: () => handleAIEdit("Add beautiful plants and flowers to this garden"), icon: TreePine },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the outdoor lighting"), icon: Settings },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'רכבים ודו גלגלי': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the lighting and reflections on this vehicle"), icon: Settings },
      { name: 'הוסף אביזרים', action: () => handleAIEdit("Add accessories and modifications to this vehicle"), icon: Plus },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'קעקועים': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the lighting to show the tattoo details"), icon: Settings },
      { name: 'הוסף פרטים', action: () => handleAIEdit("Add more details and shading to this tattoo"), icon: Plus },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'נגרות ועץ': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the lighting to show wood grain details"), icon: Settings },
      { name: 'הוסף פרטים', action: () => handleAIEdit("Add more woodworking details and textures"), icon: Plus },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'איפור וטיפוח': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the lighting for better makeup visibility"), icon: Settings },
      { name: 'הוסף איפור', action: () => handleAIEdit("Add more makeup and beauty enhancements"), icon: Sparkles },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'מוצרים': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the product lighting and presentation"), icon: Settings },
      { name: 'הוסף פרטים', action: () => handleAIEdit("Add product details and features"), icon: Plus },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'תמונות פרופיל': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the portrait lighting"), icon: Settings },
      { name: 'הוסף רקע', action: () => handleAIEdit("Add a professional background"), icon: Plus },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'סושיאל': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the social media lighting"), icon: Settings },
      { name: 'הוסף אפקטים', action: () => handleAIEdit("Add social media effects and filters"), icon: Sparkles },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ],
    'סגנון חופשי': [
      { name: 'שנה צבע', action: () => setShowColorPalette(!showColorPalette), icon: Palette },
      { name: 'זווית', action: () => setShowAnglePanel(!showAnglePanel), icon: RotateCcw },
      { name: 'שיפור תאורה', action: () => handleAIEdit("Enhance the lighting in this image"), icon: Settings },
      { name: 'הוסף אלמנטים', action: () => handleAIEdit("Add creative elements to this image"), icon: Plus },
      { name: 'בצע תיקונים', action: () => handleAIEdit("edit and fix all the damages"), icon: Settings }
    ]
  }

  const handleImageUpload = async (event) => {
    const file = event.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = async (e) => {
        setUploadedImage(e.target.result)
        setMainImage(e.target.result) // Display uploaded image on main stage
        setImageAspectRatio(16/9) // Reset to default until new image loads
        
        // Save to Firebase if user is authenticated
        if (isAuthenticated && currentUser) {
          setIsLoadingUploads(true)
          try {
            const uploadData = {
              id: Date.now().toString(),
              file: file,
              timestamp: formatTimestamp(new Date())
            }
            
            await saveUploadToUserUploads(currentUser.uid, uploadData)
            
            // Reload uploads from Firebase to get the updated list
            const updatedUploads = await loadUserUploads(currentUser.uid)
            setUserUploads(updatedUploads)
          } catch (error) {
            console.error('Failed to save upload to Firebase:', error)
          } finally {
            setIsLoadingUploads(false)
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

  const handleCategorySelect = (category) => {
    setSelectedCategory(category)
    // Change default image based on category
    const defaultImage = categoryDefaultImages[category]
    if (defaultImage) {
      setMainImage(defaultImage)
      setImageAspectRatio(16/9) // Reset to default until new image loads
      // Detect objects for the new default image
      detectObjects(defaultImage)
    }
  }

  const handleGalleryImageClick = (imageUrl) => {
    setMainImage(imageUrl)
    setImageAspectRatio(16/9) // Reset to default until new image loads
    // Detect objects for the new gallery image
    detectObjects(imageUrl)
  }

  const handleHistoryImageClick = (historyEntry) => {
    // Use storageUrl if available (from Firebase), otherwise use imageUrl (local)
    const imageUrl = historyEntry.storageUrl || historyEntry.imageUrl
    setMainImage(imageUrl)
    setImageAspectRatio(16/9) // Reset to default until new image loads
    // Detect objects for the history image
    detectObjects(imageUrl)
  }

  const handleUploadImageClick = (uploadEntry) => {
    // Use storageUrl from Firebase
    setMainImage(uploadEntry.storageUrl)
    setImageAspectRatio(16/9) // Reset to default until new image loads
    // Detect objects for the uploaded image
    detectObjects(uploadEntry.storageUrl)
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

  // Close mobile dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (showMobileDropdown && !event.target.closest('.mobile-dropdown')) {
        setShowMobileDropdown(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [showMobileDropdown])

  const formatTimestamp = (date) => {
    const day = String(date.getDate()).padStart(2, '0')
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const year = String(date.getFullYear()).slice(-2)
    return `${day}/${month}/${year}`
  }

  const displayTimestamp = (timestamp) => {
    // If it's already in dd/mm/yy format, return as is
    if (/^\d{2}\/\d{2}\/\d{2}$/.test(timestamp)) {
      return timestamp
    }
    
    // If it's in the old format, try to parse and reformat
    try {
      const date = new Date(timestamp)
      if (!isNaN(date.getTime())) {
        return formatTimestamp(date)
      }
    } catch (error) {
      console.warn('Failed to parse timestamp:', timestamp)
    }
    
    // Fallback: return original timestamp
    return timestamp
  }

  const handleCloseModal = () => {
    setShowImageModal(false)
  }

  const handleObjectSelect = (object) => {
    setSelectedObject(selectedObject === object ? null : object)
  }

  const handleCustomPromptSubmit = async () => {
    if (!customPrompt.trim()) return
    
    setIsProcessing(true)
    try {
      // Translate Hebrew prompt to English
      const translationPrompt = `Translate this Hebrew text to English: "${customPrompt}"`
      const translationResult = await model.generateContent([translationPrompt])
      const englishPrompt = translationResult.response.text().trim()
      
      // Build final prompt
      let finalPrompt = englishPrompt
      if (selectedObject) {
        // Translate selected object to English if needed
        const objectTranslationPrompt = `Translate this Hebrew text to English: "${selectedObject}"`
        const objectTranslationResult = await model.generateContent([objectTranslationPrompt])
        const englishObject = objectTranslationResult.response.text().trim()
        
        finalPrompt = `edit the ${englishObject} ${englishPrompt}`
      }
      
      // If object image is available, modify prompt to include it
      if (objectImageFile) {
        finalPrompt = `Using the provided object image, ${finalPrompt}`
      }
      
      // Execute the AI edit
      await handleAIEdit(finalPrompt)
      
      // Clear the input and selection
      setCustomPrompt('')
      setSelectedObject(null)
      
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
    
    setIsLoadingObjects(true)
    try {
      let imagePart
      
      // Handle different URL types
      if (imageUrl.startsWith('data:')) {
        // For data URLs, convert directly
        const imageFile = await urlToFile(imageUrl)
        imagePart = await fileToGenerativePart(imageFile)
      } else if (imageUrl.startsWith('https://firebasestorage.googleapis.com/')) {
        // For Firebase Storage URLs, fetch the image and convert to file
        try {
          const response = await fetch(imageUrl, {
            mode: 'cors',
            credentials: 'omit'
          })
          if (!response.ok) {
            throw new Error(`Failed to fetch image: ${response.status}`)
          }
          const blob = await response.blob()
          const imageFile = new File([blob], 'firebase-image.jpg', { type: blob.type })
          imagePart = await fileToGenerativePart(imageFile)
        } catch (error) {
          console.error('Failed to process Firebase Storage URL:', error)
          setDetectedObjects([])
          setIsLoadingObjects(false)
          return
        }
      } else {
        // For other URLs, try the original method
        const imageFile = await urlToFile(imageUrl)
        imagePart = await fileToGenerativePart(imageFile)
      }
      
      const prompt = "make a very simple name list of the different objects (2-4 words each) that are in the image. include things like walls/sky etc. write the answer it in a json format only. write the names in Hebrew. if there are 2 similar named objects like \"window\" make it clear which window is which, e.g. \"small window\" and \"big window\""
      
      // Generate object detection
      const result = await model.generateContent([prompt, imagePart])
      const textResponse = result.response.text()
      
      console.log('Raw AI response:', textResponse) // Debug log
      
      try {
        // Clean the response from markdown formatting
        let cleanResponse = textResponse
          .replace(/```json\s*/gi, '') // Remove ```json
          .replace(/```\s*/g, '') // Remove ```
          .replace(/^objects?:\s*/gmi, '') // Remove "objects:" or "object:" prefix
          .trim()
        
        console.log('Cleaned response:', cleanResponse) // Debug log
        
        // Try to parse JSON response
        const objects = JSON.parse(cleanResponse)
        console.log('Parsed objects:', objects) // Debug log
        
        if (Array.isArray(objects)) {
          setDetectedObjects(objects)
        } else {
          // If it's an object with a list property, extract it
          const objectList = Object.values(objects).find(Array.isArray)
          if (objectList) {
            setDetectedObjects(objectList)
          } else {
            // Fallback: split by common delimiters
            const fallbackObjects = cleanResponse
              .replace(/[\[\]{}"]/g, '')
              .split(/[,;\n]/)
              .map(obj => obj.trim())
              .filter(obj => obj.length > 0 && !obj.match(/^(json|objects?|```)/i))
            console.log('Fallback objects:', fallbackObjects) // Debug log
            setDetectedObjects(fallbackObjects)
          }
        }
      } catch (parseError) {
        console.log('JSON parse error:', parseError) // Debug log
        // Fallback parsing if JSON parsing fails
        const fallbackObjects = textResponse
          .replace(/```json\s*/gi, '')
          .replace(/```\s*/g, '')
          .replace(/^objects?:\s*/gmi, '')
          .replace(/[\[\]{}"]/g, '')
          .split(/[,;\n]/)
          .map(obj => obj.trim())
          .filter(obj => obj.length > 0 && !obj.match(/^(json|objects?|```)/i))
        console.log('Final fallback objects:', fallbackObjects) // Debug log
        setDetectedObjects(fallbackObjects)
      }
    } catch (error) {
      console.error('Object detection failed:', error)
      setDetectedObjects([])
    } finally {
      setIsLoadingObjects(false)
    }
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
      { name: 'Pure white', value: 'pure white', hex: '#FFFFFF', ral: 'RAL 9010' },
      { name: 'Graphite black', value: 'graphite black', hex: '#1C1C1C', ral: 'RAL 9011' },
      { name: 'Traffic white', value: 'traffic white', hex: '#F6F6F6', ral: 'RAL 9016' },
      { name: 'Traffic black', value: 'traffic black', hex: '#1E1E1E', ral: 'RAL 9017' },
      { name: 'Papyrus white', value: 'papyrus white', hex: '#D7D7D7', ral: 'RAL 9018' }
    ]
  }

  const handleColorSelect = (color) => {
    setShowColorPalette(false)
    handleAIEdit(`Change the color of all the walls in the room to color ${color.ral}`)
  }

  const angleOptions = [
    { name: 'מבט מלמעלה', value: 'bird\'s eye view', icon: '⬆️', prompt: 'Transform this image to show the camera point of view from above' },
    { name: 'סובב שמאלה', value: 'left angle', icon: '⬅️', prompt: 'Rotate the camera 45 degrees looking left' },
    { name: 'סובב ימינה', value: 'right angle', icon: '➡️', prompt: 'Rotate the camera 45 degrees looking right' },
    { name: 'זום פנימה', value: 'zoom in', icon: '🔍+', prompt: 'Zoom in closer to show more detail in this image' },
    { name: 'זום החוצה', value: 'zoom out', icon: '🔍-', prompt: 'Zoom out to show a wider view of this image' },
    { name: 'זווית אחורית', value: 'back view', icon: '👁️‍🗨️', prompt: 'Transform this whole image to show a back view perspective 180 degrees looking forward' }
  ]

  const handleAngleSelect = (angle) => {
    setShowAnglePanel(false)
    handleAIEdit(angle.prompt)
  }

  const handleAIEdit = async (prompt) => {
    if (!mainImage) return
    
    setIsProcessing(true)
    try {
      // Convert current image to file
      const imageFile = await urlToFile(mainImage)
      const imagePart = await fileToGenerativePart(imageFile)
      
      // Prepare content array with main image and prompt
      const content = [prompt, imagePart]
      
      // Add object image if available
      if (objectImageFile) {
        const objectImagePart = await fileToGenerativePart(objectImageFile)
        content.push(objectImagePart)
      }
      
      // Generate AI-edited image
      const result = await model.generateContent(content)
      
      // Handle the generated image
      const inlineDataParts = result.response.inlineDataParts()
      if (inlineDataParts?.[0]) {
        const image = inlineDataParts[0].inlineData
        const imageDataUrl = `data:${image.mimeType};base64,${image.data}`
        
        // Add to history
        const historyEntry = {
          id: Date.now().toString(),
          imageUrl: imageDataUrl,
          prompt: prompt,
          timestamp: formatTimestamp(new Date())
        }
        
        // Save to Firebase if user is authenticated
        if (isAuthenticated && currentUser) {
          setIsLoadingHistory(true)
          try {
            await saveImageToHistory(currentUser.uid, historyEntry)
            // Reload history from Firebase to get the updated list
            const updatedHistory = await loadUserHistory(currentUser.uid)
            setImageHistory(updatedHistory)
          } catch (error) {
            console.error('Failed to save to Firebase, using local storage:', error)
            // Fallback to local state if Firebase fails
            setImageHistory(prev => [historyEntry, ...prev])
          } finally {
            setIsLoadingHistory(false)
          }
        } else {
          // Fallback to local state if not authenticated
          setImageHistory(prev => [historyEntry, ...prev])
        }
        
        setMainImage(imageDataUrl)
        setImageAspectRatio(16/9) // Reset to default until new image loads
        
        // Clear object image after successful processing
        setObjectImage(null)
        setObjectImageFile(null)
        if (objectInputRef.current) {
          objectInputRef.current.value = ''
        }
      } else {
        // If no image was generated, try to get text response
        const textResponse = result.response.text()
        console.log('AI Response:', textResponse)
        alert('התמונה לא עובדה בהצלחה. נסה עם תמונה אחרת או פעולה אחרת.')
      }
    } catch (error) {
      console.error('AI processing failed:', error)
      
      // Handle specific error types
      if (error.message?.includes('RECITATION')) {
        alert('התמונה נחסמה על ידי מערכת הבטיחות. נסה עם תמונה אחרת או פעולה פשוטה יותר.')
      } else if (error.message?.includes('SAFETY')) {
        alert('התמונה לא עומדת בקריטריוני הבטיחות. נסה עם תמונה אחרת.')
      } else if (error.message?.includes('BLOCKED')) {
        alert('הפעולה נחסמה. נסה פעולה אחרת או תמונה אחרת.')
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
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Desktop Layout */}
          <div className="hidden md:flex justify-between items-center py-3">
            <div className="flex items-center">
              <img src="/Logo.png" alt="MoomHe Logo" className="h-16 w-auto" />
              <span className="mr-2 text-sm text-gray-500">פלטפורמת עיצוב למקצוענים</span>
            </div>
            <div className="flex items-center space-x-4">
              <button className="btn-secondary flex items-center" disabled={isProcessing}>
                <User className="w-4 h-4 ml-2" />
                פרופיל
              </button>
            </div>
          </div>

          {/* Mobile Layout */}
          <div className="md:hidden relative py-3">
            {/* Left: Profile Button */}
            <div className="absolute top-3 left-0">
              <button className="btn-secondary flex items-center" disabled={isProcessing}>
                <User className="w-4 h-4 ml-2" />
                פרופיל
              </button>
            </div>
            
            {/* Center: Logo */}
            <div className="flex justify-center">
              <img src="/Logo.png" alt="MoomHe Logo" className="h-12 w-auto" />
            </div>
            
            {/* Right: Categories Dropdown */}
            <div className="absolute top-3 right-0">
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
                  <div className="absolute top-full right-0 mt-2 w-64 bg-white rounded-lg shadow-lg border border-gray-200 z-50 max-h-80 overflow-y-auto">
                    {categories.map((category) => {
                      const IconComponent = categoryIcons[category]
                      return (
                        <button
                          key={category}
                          onClick={() => {
                            handleCategorySelect(category)
                            setShowMobileDropdown(false)
                          }}
                          className={`w-full flex items-center px-4 py-3 text-right hover:bg-gray-50 transition-colors duration-200 ${
                            selectedCategory === category ? 'bg-blue-50 text-blue-600' : 'text-gray-700'
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
                      : 'bg-white text-text hover:bg-gray-50 border border-gray-200'
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
          <div className="mb-6">
            <div className="card p-4">
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
                  className="absolute top-3 right-3 bg-black/50 hover:bg-black/70 text-white px-3 py-2 rounded-lg text-xs font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm"
                >
                  העלה תמונה
                </button>
                
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
              <div className="flex items-center gap-2 mb-4">
                <input
                  type="text"
                  value={customPrompt}
                  onChange={(e) => setCustomPrompt(e.target.value)}
                  placeholder="הקלד שינוי..."
                  disabled={isProcessing}
                  className="flex-1 px-3 py-2 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed"
                  onKeyPress={(e) => {
                    if (e.key === 'Enter') {
                      handleCustomPromptSubmit()
                    }
                  }}
                />
                <button
                  onClick={handleCustomPromptSubmit}
                  disabled={isProcessing || !customPrompt.trim()}
                  className="w-10 h-10 bg-blue-600 hover:bg-blue-700 text-white rounded-lg flex items-center justify-center transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                  </svg>
                </button>
              </div>

              {/* Download Button - Mobile */}
              <button 
                onClick={handleDownload}
                disabled={isProcessing}
                className="w-full bg-green-600 hover:bg-green-700 text-white font-medium py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed shadow-lg mb-4"
              >
                <Download className="w-4 h-4 ml-2" />
                הורד תמונה
              </button>

              {/* Mobile Action Buttons - Horizontal Scroll */}
              <div className="flex gap-3 overflow-x-auto scrollbar-hide pb-2 mb-4">
                {/* Category-specific action buttons */}
                {categoryActionButtons[selectedCategory]?.map((button, index) => (
                  <button
                    key={index}
                    onClick={button.action}
                    disabled={isProcessing}
                    className="flex-shrink-0 btn-secondary flex items-center text-sm px-3 py-2 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <button.icon className="w-4 h-4 ml-2" />
                    {button.name}
                  </button>
                ))}
                
                {/* Object Image Upload */}
                <div className="flex-shrink-0 relative">
                  {objectImage ? (
                    <div className="relative w-10 h-10">
                      <img
                        src={objectImage}
                        alt="Object to add"
                        className="w-full h-full object-cover rounded-lg border-2 border-gray-300"
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
                    <div
                      onClick={isProcessing ? undefined : handleObjectUploadClick}
                      className={`w-10 h-10 border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center transition-colors duration-200 cursor-pointer hover:border-blue-400 hover:bg-blue-50 ${
                        isProcessing ? 'opacity-50 cursor-not-allowed' : ''
                      }`}
                    >
                      <Plus className="w-4 h-4 text-gray-400" />
                    </div>
                  )}
                  
                  <input
                    ref={objectInputRef}
                    type="file"
                    accept="image/*"
                    onChange={handleObjectImageUpload}
                    className="hidden"
                  />
                </div>
              </div>

              {selectedObject && (
                <p className="text-sm text-blue-600 text-center">
                  נבחר: {selectedObject}
                </p>
              )}
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

            {/* Objects Panel - Mobile */}
            <div className="card p-4 relative">
              <h3 className="text-lg font-semibold text-text mb-3 flex items-center">
                <Sparkles className="w-5 h-5 ml-2" />
                אובייקטים
              </h3>
              <div className={`transition-opacity duration-300 ${
                isLoadingObjects ? 'opacity-50' : ''
              }`}>
                {detectedObjects.length === 0 ? (
                  <div className="text-center py-6">
                    <div className="text-gray-400 mb-2">
                      <Sparkles className="w-6 h-6 mx-auto" />
                    </div>
                    <p className="text-sm text-gray-500">אין אובייקטים זוהו</p>
                    <p className="text-xs text-gray-400 mt-1">האובייקטים יופיעו כאן</p>
                  </div>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {detectedObjects.map((object, index) => (
                      <button
                        key={index}
                        onClick={() => handleObjectSelect(object)}
                        className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors duration-200 ${
                          selectedObject === object 
                            ? 'bg-blue-100 text-blue-700 border-2 border-blue-500' 
                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200 border-2 border-transparent'
                        }`}
                      >
                        {object}
                      </button>
                    ))}
                  </div>
                )}
              </div>
              
              {/* Loading Overlay for Objects */}
              {isLoadingObjects && (
                <div className="absolute inset-0 bg-white/80 backdrop-blur-sm rounded-xl flex items-center justify-center">
                  <div className="relative">
                    <div className="w-8 h-8 border-4 border-gray-300 border-t-orange-500 rounded-full animate-spin"></div>
                  </div>
                </div>
              )}
            </div>

            {/* History Panel - Mobile */}
            <div className="card p-4 relative">
              <h3 className="text-lg font-semibold text-text mb-3 flex items-center">
                <svg className="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                תמונות
              </h3>
              <div className={`transition-opacity duration-300 ${
                isLoadingHistory ? 'opacity-50' : ''
              }`}>
                {imageHistory.length === 0 ? (
                  <div className="text-center py-6">
                    <div className="text-gray-400 mb-2">
                      <Sparkles className="w-6 h-6 mx-auto" />
                    </div>
                    <p className="text-sm text-gray-500">אין עריכות עדיין</p>
                    <p className="text-xs text-gray-400 mt-1">התמונות שייווצרו יופיעו כאן</p>
                  </div>
                ) : (
                  <div className="grid grid-cols-3 gap-3 max-h-48 overflow-y-auto scrollbar-hide">
                    {imageHistory.map((entry) => (
                      <div
                        key={entry.id}
                        onClick={() => handleHistoryImageClick(entry)}
                        className="cursor-pointer group"
                      >
                        <div className="relative">
                          <img
                            src={entry.storageUrl || entry.imageUrl}
                            alt="History entry"
                            className="w-full h-20 object-cover rounded-lg group-hover:opacity-80 transition-opacity duration-200"
                          />
                          <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors duration-200 rounded-lg"></div>
                        </div>
                        <div className="mt-1">
                          <p className="text-xs text-gray-600 truncate" title={entry.prompt}>
                            {entry.prompt.length > 15 ? `${entry.prompt.substring(0, 15)}...` : entry.prompt}
                          </p>
                          <p className="text-xs text-gray-400">{displayTimestamp(entry.timestamp)}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              
              {/* Loading Overlay for History */}
              {isLoadingHistory && (
                <div className="absolute inset-0 bg-white/80 backdrop-blur-sm rounded-xl flex items-center justify-center">
                  <div className="relative">
                    <div className="w-8 h-8 border-4 border-gray-300 border-t-purple-500 rounded-full animate-spin"></div>
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
              <h3 className="text-lg font-semibold text-text mb-3">תמונות</h3>
              <div className={`transition-opacity duration-300 ${
                isLoadingHistory ? 'opacity-50' : ''
              }`}>
              {imageHistory.length === 0 ? (
                <div className="text-center py-8">
                  <div className="text-gray-400 mb-2">
                    <Sparkles className="w-8 h-8 mx-auto" />
                  </div>
                  <p className="text-sm text-gray-500">אין עריכות עדיין</p>
                  <p className="text-xs text-gray-400 mt-1">התמונות שייווצרו יופיעו כאן</p>
                </div>
              ) : (
                <div className="space-y-3 max-h-96 overflow-y-auto scrollbar-hide">
                  {imageHistory.map((entry) => (
                    <div
                      key={entry.id}
                      onClick={() => handleHistoryImageClick(entry)}
                      className="cursor-pointer group"
                    >
                      <div className="relative">
                        <img
                          src={entry.storageUrl || entry.imageUrl}
                          alt="History entry"
                          className="w-full h-24 object-cover rounded-lg group-hover:opacity-80 transition-opacity duration-200"
                        />
                        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors duration-200 rounded-lg"></div>
                      </div>
                      <div className="mt-2">
                        <p className="text-xs text-gray-600 truncate" title={entry.prompt}>
                          {entry.prompt.length > 30 ? `${entry.prompt.substring(0, 30)}...` : entry.prompt}
                        </p>
                        <p className="text-xs text-gray-400 mt-1">{displayTimestamp(entry.timestamp)}</p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
              </div>
              
              {/* Loading Overlay for History */}
              {isLoadingHistory && (
                <div className="absolute inset-0 bg-white/80 backdrop-blur-sm rounded-xl flex items-center justify-center">
                  <div className="relative">
                    <div className="w-12 h-12 border-4 border-gray-300 border-t-purple-500 rounded-full animate-spin"></div>
                    <div className="absolute inset-0 flex items-center justify-center">
                      <div className="w-6 h-6 border-2 border-gray-400 border-b-purple-600 rounded-full animate-spin" style={{ animationDirection: 'reverse', animationDuration: '0.8s' }}></div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Objects Panel */}
          <div className="lg:col-span-1 lg:order-3">
            {/* Download Button */}
            <div className="mb-4">
              <button 
                onClick={handleDownload}
                disabled={isProcessing}
                className="w-full bg-green-600 hover:bg-green-700 text-white font-medium py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed shadow-lg"
              >
                <Download className="w-4 h-4 ml-2" />
                הורד תמונה
              </button>
            </div>
            
            <div className="card p-4 relative">
              <h3 className="text-lg font-semibold text-text mb-3">אובייקטים</h3>
              <div className={`transition-opacity duration-300 ${
                isLoadingObjects ? 'opacity-50' : ''
              }`}>
                {detectedObjects.length === 0 ? (
                  <div className="text-center py-8">
                    <div className="text-gray-400 mb-2">
                      <Sparkles className="w-8 h-8 mx-auto" />
                    </div>
                    <p className="text-sm text-gray-500">אין אובייקטים זוהו</p>
                    <p className="text-xs text-gray-400 mt-1">
                      האובייקטים יופיעו כאן
                    </p>
                  </div>
                ) : (
                  <div className="space-y-2 max-h-96 overflow-y-auto scrollbar-hide">
                    {detectedObjects.map((object, index) => (
                      <div
                        key={index}
                        onClick={() => handleObjectSelect(object)}
                        className={`rounded-lg p-3 transition-colors duration-200 cursor-pointer ${
                          selectedObject === object 
                            ? 'bg-blue-100 border-2 border-blue-500' 
                            : 'bg-gray-50 hover:bg-gray-100 border-2 border-transparent'
                        }`}
                      >
                        <p className={`text-sm font-medium ${
                          selectedObject === object ? 'text-blue-700' : 'text-gray-700'
                        }`}>
                          {object}
                        </p>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              
              {/* Loading Overlay for Objects */}
              {isLoadingObjects && (
                <div className="absolute inset-0 bg-white/80 backdrop-blur-sm rounded-xl flex items-center justify-center">
                  <div className="relative">
                    <div className="w-12 h-12 border-4 border-gray-300 border-t-orange-500 rounded-full animate-spin"></div>
                    <div className="absolute inset-0 flex items-center justify-center">
                      <div className="w-6 h-6 border-2 border-gray-400 border-b-orange-600 rounded-full animate-spin" style={{ animationDirection: 'reverse', animationDuration: '0.8s' }}></div>
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
                  className="absolute top-4 right-4 bg-black/50 hover:bg-black/70 text-white px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed backdrop-blur-sm"
                >
                  העלה תמונה
                </button>
                
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
                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    value={customPrompt}
                    onChange={(e) => setCustomPrompt(e.target.value)}
                    placeholder="הקלד שינוי..."
                    disabled={isProcessing}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed"
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') {
                        handleCustomPromptSubmit()
                      }
                    }}
                  />
                  <button
                    onClick={handleCustomPromptSubmit}
                    disabled={isProcessing || !customPrompt.trim()}
                    className="w-12 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-lg flex items-center justify-center transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                    </svg>
                  </button>
                </div>
                {selectedObject && (
                  <p className="text-sm text-blue-600 mt-2">
                    נבחר: {selectedObject}
                  </p>
                )}
              </div>

              {/* Action Buttons */}
              <div className="flex flex-wrap gap-4">
                {/* Category-specific action buttons */}
                {categoryActionButtons[selectedCategory]?.map((button, index) => (
                  <button
                    key={index}
                    onClick={button.action}
                    disabled={isProcessing}
                    className="btn-secondary flex items-center disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <button.icon className="w-4 h-4 ml-2" />
                    {button.name}
                  </button>
                ))}
                
                {/* Object Image Upload - always available */}
                <div className="relative">
                  {objectImage ? (
                    <div className="relative w-24 h-24">
                      <img
                        src={objectImage}
                        alt="Object to add"
                        className="w-full h-full object-cover rounded-lg border-2 border-gray-300"
                      />
                      <button
                        onClick={handleRemoveObjectImage}
                        disabled={isProcessing}
                        className="absolute -top-2 -right-2 bg-red-500 hover:bg-red-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        ×
                      </button>
                    </div>
                  ) : (
                    <div
                      onClick={isProcessing ? undefined : handleObjectUploadClick}
                      className={`w-24 h-24 border-2 border-dashed border-gray-300 rounded-lg flex flex-col items-center justify-center transition-colors duration-200 cursor-pointer hover:border-blue-400 hover:bg-blue-50 ${
                        isProcessing ? 'opacity-50 cursor-not-allowed' : ''
                      }`}
                    >
                      <Plus className="w-6 h-6 text-gray-400 mb-1" />
                      <span className="text-xs text-gray-500 text-center leading-tight">הוסף אובייקט</span>
                    </div>
                  )}
                  
                  <input
                    ref={objectInputRef}
                    type="file"
                    accept="image/*"
                    onChange={handleObjectImageUpload}
                    className="hidden"
                  />
                </div>
              </div>

              {/* Color Palette Modal */}
              {showColorPalette && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                  <div className="bg-white rounded-xl shadow-2xl max-w-6xl w-full mx-4 max-h-[85vh] overflow-hidden">
                    <div className="p-6">
                      <div className="flex justify-between items-center mb-6">
                        <h3 className="text-lg font-semibold text-text">בחר צבע RAL לקיר</h3>
                        <button
                          onClick={() => setShowColorPalette(false)}
                          disabled={isProcessing}
                          className="text-gray-500 hover:text-gray-700 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ×
                        </button>
                      </div>
                      
                      {/* Color Category Tabs */}
                      <div className="flex flex-wrap gap-2 mb-6 border-b border-gray-200 pb-4">
                        {Object.keys(colorPalette).map((category) => (
                          <button
                            key={category}
                            onClick={() => setActiveColorCategory(category)}
                            disabled={isProcessing}
                            className={`px-4 py-2 rounded-lg font-medium text-sm transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed ${
                              activeColorCategory === category
                                ? 'bg-blue-600 text-white shadow-lg'
                                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                            }`}
                          >
                            {category}
                          </button>
                        ))}
                      </div>
                      
                      {/* Active Category Colors */}
                      <div className="max-h-96 overflow-y-auto">
                        <div className="grid grid-cols-8 gap-3">
                          {colorPalette[activeColorCategory]?.map((color, index) => (
                            <button
                              key={index}
                              onClick={() => handleColorSelect(color)}
                              disabled={isProcessing}
                              className="flex flex-col items-center p-3 rounded-lg hover:bg-gray-50 transition-colors duration-200 border border-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                              <div 
                                className="w-12 h-12 rounded-full border-2 border-gray-300 shadow-sm mb-2"
                                style={{ backgroundColor: color.hex }}
                              ></div>
                              <span className="text-xs text-text font-medium text-center leading-tight">
                                {color.ral}
                              </span>
                              <span className="text-xs text-gray-500 text-center leading-tight mt-1">
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
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                  <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 max-h-[70vh] overflow-y-auto">
                    <div className="p-6">
                      <div className="flex justify-between items-center mb-6">
                        <h3 className="text-lg font-semibold text-text">בחר זווית ופרספקטיבה</h3>
                        <button
                          onClick={() => setShowAnglePanel(false)}
                          disabled={isProcessing}
                          className="text-gray-500 hover:text-gray-700 text-xl disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          ×
                        </button>
                      </div>
                      
                      <div className="grid grid-cols-2 gap-4">
                        {angleOptions.map((angle, index) => (
                          <button
                            key={index}
                            onClick={() => handleAngleSelect(angle)}
                            disabled={isProcessing}
                            className="flex items-center p-4 rounded-lg hover:bg-gray-50 transition-colors duration-200 border border-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
                          >
                            <span className="text-2xl ml-3">{angle.icon}</span>
                            <div className="text-right">
                              <div className="text-sm font-medium text-text">{angle.name}</div>
                              <div className="text-xs text-gray-500">{angle.value}</div>
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

        </div>
      </div>

      {/* Image Modal */}
      {showImageModal && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-90 flex items-center justify-center z-50 p-4"
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
              className="absolute top-4 right-4 bg-white/20 hover:bg-white/30 text-white p-3 rounded-full transition-colors duration-200 backdrop-blur-sm"
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
    </div>
  )
}

export default App
