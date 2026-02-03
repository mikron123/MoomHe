import React, { createContext, useContext, useState, useEffect } from 'react';
import * as additionalTranslations from './translations.js';

// Country code to language mapping
const COUNTRY_TO_LANGUAGE = {
  // Hebrew
  IL: 'he',
  
  // Arabic
  SA: 'ar', AE: 'ar', EG: 'ar', JO: 'ar', LB: 'ar', SY: 'ar', IQ: 'ar', KW: 'ar', 
  QA: 'ar', BH: 'ar', OM: 'ar', YE: 'ar', LY: 'ar', TN: 'ar', MA: 'ar', DZ: 'ar',
  
  // German
  DE: 'de', AT: 'de', CH: 'de', LI: 'de',
  
  // Spanish
  ES: 'es', MX: 'es', AR: 'es', CO: 'es', PE: 'es', VE: 'es', CL: 'es', EC: 'es',
  GT: 'es', CU: 'es', BO: 'es', DO: 'es', HN: 'es', PY: 'es', SV: 'es', NI: 'es',
  CR: 'es', PA: 'es', UY: 'es', PR: 'es',
  
  // French
  FR: 'fr', BE: 'fr', CA: 'fr', SN: 'fr', CI: 'fr', ML: 'fr', BF: 'fr', NE: 'fr',
  TG: 'fr', BJ: 'fr', GA: 'fr', CG: 'fr', CD: 'fr', CM: 'fr', MG: 'fr', HT: 'fr',
  
  // Italian
  IT: 'it', SM: 'it', VA: 'it',
  
  // Portuguese
  PT: 'pt', BR: 'pt', AO: 'pt', MZ: 'pt',
  
  // Dutch
  NL: 'nl',
  
  // Polish
  PL: 'pl',
  
  // Russian - map to English (no Russian translation yet)
  RU: 'en', BY: 'en', KZ: 'en', UA: 'en',
  
  // Japanese
  JP: 'ja',
  
  // Korean
  KR: 'ko',
  
  // Chinese
  CN: 'zh', TW: 'zh', HK: 'zh_HK', MO: 'zh_HK',
  
  // Swedish
  SE: 'sv',
  
  // Norwegian
  NO: 'nb',
  
  // Danish
  DK: 'da',
  
  // Finnish
  FI: 'fi',
  
  // Czech
  CZ: 'cs',
  
  // Hungarian
  HU: 'hu',
  
  // Romanian
  RO: 'ro',
  
  // Greek
  GR: 'el', CY: 'el',
  
  // Croatian
  HR: 'hr',
  
  // Slovenian
  SI: 'sl',
  
  // Lithuanian
  LT: 'lt',
  
  // Estonian
  EE: 'et',
  
  // Icelandic
  IS: 'is',
  
  // Georgian
  GE: 'ka',
  
  // Irish
  IE: 'ga',
  
  // English (default)
  US: 'en', GB: 'en', AU: 'en', NZ: 'en', ZA: 'en', IN: 'en', PH: 'en', SG: 'en',
  MY: 'en', NG: 'en', KE: 'en', GH: 'en', TZ: 'en', UG: 'en', ZW: 'en', JM: 'en',
  TT: 'en', BB: 'en', BS: 'en', BZ: 'en', GY: 'en',
};

// RTL languages
const RTL_LANGUAGES = ['he', 'ar'];

// Supported languages with display names
export const SUPPORTED_LANGUAGES = [
  { code: 'en', name: 'English', nativeName: 'English' },
  { code: 'ar', name: 'Arabic', nativeName: 'العربية' },
  { code: 'cs', name: 'Czech', nativeName: 'Čeština' },
  { code: 'da', name: 'Danish', nativeName: 'Dansk' },
  { code: 'de', name: 'German', nativeName: 'Deutsch' },
  { code: 'el', name: 'Greek', nativeName: 'Ελληνικά' },
  { code: 'es', name: 'Spanish', nativeName: 'Español' },
  { code: 'et', name: 'Estonian', nativeName: 'Eesti' },
  { code: 'fi', name: 'Finnish', nativeName: 'Suomi' },
  { code: 'fr', name: 'French', nativeName: 'Français' },
  { code: 'ga', name: 'Irish', nativeName: 'Gaeilge' },
  { code: 'he', name: 'Hebrew', nativeName: 'עברית' },
  { code: 'hr', name: 'Croatian', nativeName: 'Hrvatski' },
  { code: 'hu', name: 'Hungarian', nativeName: 'Magyar' },
  { code: 'is', name: 'Icelandic', nativeName: 'Íslenska' },
  { code: 'it', name: 'Italian', nativeName: 'Italiano' },
  { code: 'ja', name: 'Japanese', nativeName: '日本語' },
  { code: 'ka', name: 'Georgian', nativeName: 'ქართული' },
  { code: 'ko', name: 'Korean', nativeName: '한국어' },
  { code: 'lt', name: 'Lithuanian', nativeName: 'Lietuvių' },
  { code: 'nb', name: 'Norwegian', nativeName: 'Norsk' },
  { code: 'nl', name: 'Dutch', nativeName: 'Nederlands' },
  { code: 'pl', name: 'Polish', nativeName: 'Polski' },
  { code: 'pt', name: 'Portuguese', nativeName: 'Português' },
  { code: 'ro', name: 'Romanian', nativeName: 'Română' },
  { code: 'sl', name: 'Slovenian', nativeName: 'Slovenščina' },
  { code: 'sv', name: 'Swedish', nativeName: 'Svenska' },
  { code: 'zh_HK', name: 'Cantonese', nativeName: '廣東話' },
  { code: 'zh', name: 'Chinese', nativeName: '中文' },
];

// All translations
const translations = {
  en: {
    // App
    appTitle: "Expert AI",
    appName: "Expert",
    
    // Auth
    guest: "Guest",
    loginToSaveDesigns: "Log in to save your designs",
    loggedOutSuccess: "Logged out successfully",
    login: "Login",
    logout: "Logout",
    createAccount: "Create Account",
    createNewAccount: "New Account",
    welcomeBack: "Welcome back! Log in to continue",
    joinUs: "Join us to save designs and access all features",
    email: "Email",
    password: "Password",
    confirmPassword: "Confirm Password",
    fillAllFields: "Please fill all fields",
    passwordsNotMatch: "Passwords do not match",
    loginButton: "Log In",
    createAccountButton: "Create Account",
    forgotPassword: "Forgot password?",
    enterEmailFirst: "Please enter an email address first",
    passwordResetEmailSent: "Password reset email sent! Check your inbox and spam folder.",
    passwordResetError: "Error sending password reset email",
    termsAgreement: "By logging in you agree to the",
    termsOfService: "Terms of Service",
    and: "and",
    privacyPolicy: "Privacy Policy",
    privacyPolicyUrl: "https://moomhe.com/privacy-en.html",
    termsOfServiceUrl: "https://moomhe.com/eula-en.html",
    loggingIn: "Logging in...",
    creatingAccount: "Creating account...",
    loginSuccess: "Logged in successfully! 🎉",
    accountCreated: "Account created successfully! 🎉",
    loginError: "Login error",
    userNotFound: "User not found",
    wrongPassword: "Wrong password",
    emailInUse: "Email already in use",
    weakPassword: "Password is too weak",
    invalidEmail: "Invalid email address",
    exitAccount: "Exit account",
    loginWithEmail: "Log in with email to save your designs",
    
    // Upload
    uploadImage: "Upload Image",
    clickToUploadImage: "Click here to upload an image from gallery",
    gallery: "Gallery",
    camera: "Camera",
    uploadItem: "Add Item",
    redesign: "Redesign",
    readyDesigns: "Design Gallery",
    // Design Gallery Categories
    categoryKitchen: "Kitchen",
    categoryKidsBedroom: "Kids Bedroom",
    categoryBathroom: "Bathroom",
    categoryLivingRoom: "Living Room",
    categoryMasterBedroom: "Master Bedroom",
    comingSoon: "Coming soon...",
    newDesignsWillBeAdded: "New designs will be added here",
    more: "More",
    moreOptions: "More Options",
    history: "History",
    noHistoryYet: "No history yet",
    uploadedImagesWillAppear: "Images you upload and edit will appear here",
    whatToChange: "What to change?",
    uploadImageFirst: "Please upload an image first",
    uploadingImage: "Uploading image...",
    errorUploadingImage: "Error uploading image",
    
    // Item
    itemImageLoaded: "Item image loaded! Describe in the prompt where to add it.",
    addAttachedItem: "Add the attached item to the image",
    
    // Processing
    processingStarting: "Starting...",
    processingMagic: "The magic is happening",
    processing: "Processing...",
    connectingToCloud: "Connecting to cloud... ☁️",
    sendingToAI: "Sending to AI... 🤖",
    analyzingItem: "Analyzing item... 🔍",
    creatingDesign: "Creating design... ✨",
    
    // Fun phrases
    funPhrase1: "Sending the image through another dimension... 🌀",
    funPhrase2: "Teaching the AI to appreciate good design... 🎨",
    funPhrase3: "Convincing the pixels to cooperate... 🤝",
    funPhrase4: "A little digital magic on the way... ✨",
    funPhrase5: "Asking the AI what it thinks... 🤔",
    funPhrase6: "Mixing colors like a real artist... 🖌️",
    funPhrase7: "Calculating the perfect angle... 📐",
    funPhrase8: "Adding some style to your life... 💫",
    funPhrase9: "Making the room look more expensive... 💎",
    funPhrase10: "Activating the design magic... 🪄",
    funPhrase11: "Consulting with the digital interior designers... 🏠",
    funPhrase12: "Trying not to get too excited about the result... 😍",
    funPhrase13: "You'll see something amazing in a moment... 🚀",
    funPhrase14: "Making sure everything is perfect for you... 👌",
    
    // Tools
    designStyle: "Design Style",
    wallColor: "Change Color",
    lighting: "Lighting",
    furniture: "Furniture",
    doorsWindows: "Doors & Windows",
    bathroom: "Bathroom",
    repairs: "Repairs",
    general: "General",
    
    // Panels
    selectDesignStyle: "Select Design Style",
    colorPalette: "Color Palette",
    
    // Color Categories
    colorReds: "Reds",
    colorOranges: "Oranges",
    colorYellows: "Yellows",
    colorGreens: "Greens",
    colorBlues: "Blues",
    colorPurples: "Purples",
    colorGrays: "Grays",
    colorWhitesAndBlacks: "Whites & Blacks",
    selectLightingType: "Select Lighting Type",
    selectFurnitureType: "Select Furniture Type",
    selectRepairType: "Select Repair/Damage Type",
    bathroomOptions: "Bathroom Options",
    pleaseSelectOption: "Please select an option from the list below.",
    
    // Repair Options
    repairEverything: "Repair everything",
    fixAndRepairEverything: "Fix and repair everything",
    messUpEverything: "Mess up everything",
    destroyAndCauseDamage: "Destroy and cause damage to everything",
    
    // Doors/Windows Options
    windowOptions: "Window Options",
    doorOptions: "Door Options",
    fixedWindow: "Fixed Window",
    slidingWindow: "Sliding Window",
    casementWindow: "Casement Window",
    tiltTurnWindow: "Tilt-Turn Window",
    awningWindow: "Awning Window",
    doubleHungWindow: "Double-Hung Window",
    pocketWindow: "Pocket Window",
    archWindow: "Arch Window",
    pocketDoor: "Pocket Door",
    frenchDoors: "French Doors",
    louverDoor: "Louver Door",
    barnDoor: "Barn Door",
    
    // Bathroom Options
    toiletOptions: "Toilet Options",
    bathtubOptions: "Bathtub Options",
    showerOptions: "Shower Options",
    sinkOptions: "Sink Options",
    jacuzziSpaOptions: "Jacuzzi/Spa Options",
    poolOptions: "Pool Options",
    bidetSeat: "Bidet Seat",
    toiletSeat: "Toilet Seat",
    freestandingTub: "Freestanding Tub",
    vintageTub: "Vintage Tub",
    standardTub: "Standard Tub",
    rainShower: "Rain Shower",
    showerEnclosure: "Shower Enclosure",
    slidingShower: "Sliding Shower",
    pedestalSink: "Pedestal Sink",
    stainlessSink: "Stainless Sink",
    undermountSink: "Undermount Sink",
    builtInJacuzzi: "Built-in Jacuzzi",
    portableJacuzzi: "Portable Jacuzzi",
    ingroundPool: "Inground Pool",
    abovegroundPool: "Above-ground Pool",
    
    // Actions
    whatToDo: "What to do?",
    describeChange: "Describe the desired change...",
    cancel: "Cancel",
    execute: "Execute",
    confirm: "Confirm",
    close: "Close",
    tryAgain: "Try Again",
    
    // Color
    colorChange: "Change Color",
    allWalls: "All Walls",
    paintAllWalls: "Paint all walls in the room",
    specificObject: "Specific Object",
    selectWhatToPaint: "Choose what you want to paint",
    exampleObjects: "For example: sofa, ceiling, cabinet...",
    
    // Subscription
    professionalSubscription: "Professional Plan",
    specialLaunchPrices: "Special launch prices 🚀",
    purchaseFailed: "Purchase failed",
    yourCurrentPlan: "Your current plan",
    selectPlan: "Select Plan",
    perMonth: "/month",
    starterPlan: "Starter",
    valuePlan: "Value",
    proPlan: "Professional",
    imagesPerMonth: "{count} images per month",
    whatsappSupport: "WhatsApp Support",
    historyStorage: "History Storage",
    vipWhatsappSupport: "VIP WhatsApp Support",
    processingPriority: "Processing Priority",
    bestValue: "Best value: 4x more images! 🔥",
    forProfessionals: "For professionals ⭐",
    allDesignTools: "All design tools",
    fastSupport: "Fast support",
    noAds: "No ads",
    restorePurchases: "Restore Purchases",
    
    // Credits
    mySubscription: "My Subscription",
    creditsRemaining: "{count} credits remaining",
    upgradeToPremium: "Upgrade to Premium",
    iHaveCoupon: "I have a coupon",
    enterCouponCode: "Enter coupon code to get free credits",
    enterCouponCodeTitle: "Enter Coupon Code",
    enterCouponCodeSubtitle: "Enter the coupon code you received to get free credits",
    couponCode: "Coupon code",
    mustEnterCoupon: "You must enter a coupon code",
    couponActivated: "Coupon activated successfully!",
    errorRedeemingCoupon: "Error redeeming coupon",
    redeemCoupon: "Redeem Coupon",
    creditsAddedToAccount: "{count} credits added to your account! 🎉",
    
    // Contact
    contactUs: "Contact Us",
    contactSubtitle: "We'd love to hear from you! Fill in the details and we'll get back to you soon.",
    phone: "Phone",
    message: "Message",
    writeYourMessage: "Write your message here...",
    enterPhoneOrEmail: "* Please enter at least phone or email",
    pleaseEnterPhoneOrEmail: "Please enter at least phone or email",
    pleaseEnterMessage: "Please enter a message",
    errorSendingMessage: "Error sending message. Please try again.",
    sendMessage: "Send Message",
    messageSentSuccess: "Message sent successfully!",
    
    // Errors
    contentNotAllowed: "Content Not Allowed",
    requestFailed: "Request Failed",
    oopsSomethingWrong: "Oops! Something went wrong",
    moderationError: "Cannot process this image or request.\n\nThe image or request may contain content that is not allowed for processing.\n\nTry with a different image or change the request.",
    timeoutError: "The request took too long.\n\nPlease try again later.",
    genericError: "We couldn't process the request.\n\nTry again or contact support if the issue persists.",
    errorUnknown: "Unknown error",
    
    // Image actions
    imageSavedToGallery: "Image saved to gallery!",
    errorDownloadingImage: "Error downloading image",
    errorSharing: "Error sharing",
    shareText: "🏠 I designed this with MoomHe AI!\n📸 Want to try it too? https://moomhe.com",
    comparison: "Comparison",
    download: "Download",
    share: "Share",
    revertToOriginal: "Revert to Original",
    loveItSave: "Love it! Save",
    whatsApp: "WhatsApp",
    products: "Products",
    cancelSearch: "Cancel Search",
    searchSimilarProducts: "Search Similar Products",
    whatDoYouThink: "What do you think of the new design?",
    dragSliderForComparison: "Drag the slider for full comparison",
    returnToOriginal: "Return to Original Image",
    loveItSaveDesign: "Love it! Save the Design",
    
    // Limits
    creditsFinishedThisMonth: "Credits finished for this month",
    creditsRanOut: "Credits ran out for this month",
    freeLimitReached: "You've reached the free usage limit",
    reachedFreeLimit: "You've reached the free usage limit",
    creditsLimitReached: "You've reached your credits limit. You can upgrade to a larger plan or wait until next month.",
    freeCreditsUsed: "You've used all your free credits. To continue designing without limits and get advanced features, upgrade to a professional plan.",
    currentUsage: "Current Usage",
    limit: "Limit",
    designs: "designs",
    upgradePlan: "Upgrade Plan",
    goToProfessionalPlan: "Go to Professional Plan",
    goPro: "Go Pro",
    notNowThanks: "Not now, thanks",
    
    // Welcome
    welcomeToPlan: "Welcome to {planName} plan!",
    thankYouForJoining: "Thank you for joining our subscribers family. Your account has been upgraded successfully and you now have access to all advanced features and additional credits.",
    creditsAddedToYourAccount: "Credits added to your account",
    unlimitedStyleAccess: "Unlimited access to all styles",
    supportCreators: "Support for creators and designers",
    startDesigning: "Start Designing",
    
    // Secure subscription
    secureYourSubscription: "Secure Your Subscription",
    secureSubscriptionMessage: "To not lose the subscription you purchased, we recommend logging in with email.\n\nThis way you can restore your subscription on a new device or after reinstalling.",
    later: "Later",
    loginNow: "Login Now",
    
    // Onboarding
    onboardingUploadTitle: "Upload Image",
    onboardingUploadDesc: "Start by uploading a photo of the room you want to design. Don't have one? No worries, we'll use a sample image.",
    onboardingStyleTitle: "Choose Redesign Style",
    onboardingStyleDesc: "Select your preferred style from the side menu. Try \"Redesign\" to see different options.",
    onboardingCreateTitle: "Create Design",
    onboardingCreateDesc: "Click \"Create\" and the AI will redesign your room in seconds!",
    onboardingItemTipTitle: "Extra Tip: Add Item",
    onboardingItemTipDesc: "Want to add a specific piece of furniture? Use the \"Add Item\" button to upload an image of an item and incorporate it into the design.",
    skip: "Skip",
    next: "Next",
    finish: "Finish",
    promptAddedToInput: "Prompt added - you can edit it and then tap Create",
    
    // Styles
    styleMediterranean: "Modern Mediterranean",
    styleWarmMinimalism: "Warm Minimalism",
    styleBiophilic: "Biophilic",
    styleModernLuxury: "Modern Luxury",
    styleJapandi: "Japandi",
    styleScandinavian: "Scandinavian",
    styleBohoChic: "Boho Chic",
    styleIndustrial: "Industrial",
    styleEarthyNatural: "Earthy Natural",
    styleJerusalem: "Jerusalem",
    styleMinimalist: "Minimalist",
    styleModernClassic: "Modern Classic",
    
    // Color categories
    colorCategoryReds: "Reds",
    colorCategoryOranges: "Oranges",
    colorCategoryYellows: "Yellows",
    colorCategoryGreens: "Greens",
    colorCategoryBlues: "Blues",
    colorCategoryPurples: "Purples",
    colorCategoryGrays: "Grays",
    colorCategoryWhitesBlacks: "Whites & Blacks",
    
    // Lighting
    lightingRecessed: "Recessed Lighting",
    lightingPendant: "Pendant Light",
    lightingChandelier: "Chandelier",
    lightingTableLamp: "Table Lamp",
    lightingFloorLamp: "Floor Lamp",
    lightingWallSconce: "Wall Sconce",
    lightingTrack: "Track Lighting",
    lightingCeiling: "Ceiling Fixture",
    lightingUnderCabinet: "Under-Cabinet Lighting",
    lightingDecorative: "Decorative Lights",
    lightingDay: "Day",
    lightingNight: "Night",
    lightingSunset: "Sunset",
    lightingSunrise: "Sunrise",
    
    // Furniture
    furnitureSofa: "Sofa",
    furnitureSectional: "Sectional Sofa",
    furnitureArmchair: "Armchair",
    furnitureAccentChair: "Accent Chair",
    furnitureDiningChair: "Dining Chair",
    furnitureBarStool: "Bar Stool",
    furnitureSingleBed: "Single Bed",
    furnitureDoubleBed: "Double Bed",
    furnitureBeanbag: "Beanbag",
    furnitureOttoman: "Ottoman",
    furnitureBench: "Bench",
    furnitureCoffeeTable: "Coffee Table",
    furnitureEndTable: "End Table",
    furnitureNightstand: "Nightstand",
    furnitureDiningTable: "Dining Table",
    furnitureDesk: "Desk",
    furnitureDresser: "Dresser",
    furnitureWardrobe: "Wardrobe",
    furnitureBookcase: "Bookcase",
    furnitureTvStand: "TV Stand",
    furnitureCabinets: "Kitchen Cabinets",
    
    // Repairs
    repairsFixEverything: "Fix everything",
    repairsRepairAll: "Fix and repair everything",
    repairsMessUp: "Mess up everything",
    repairsDestroy: "Destroy and cause damage to everything",
    
    // Windows
    windowPicture: "Picture Window",
    windowSliding: "Sliding Window",
    windowCasement: "Casement Window",
    windowTiltTurn: "Tilt and Turn Window",
    windowAwning: "Awning Window",
    windowSash: "Sash Window",
    windowPocket: "Pocket Window",
    windowArched: "Arched Window",
    
    // Doors
    doorPocket: "Pocket Door",
    doorFrench: "French Doors",
    doorLouvered: "Louvered Door",
    doorBarn: "Barn Door",
    
    // Search
    searchWithLens: "Search",
    selectAreaToSearch: "Draw a rectangle around the item you want to search",
    searchingWithGoogleLens: "Searching with Google Lens...",
    selectAreaWithinImage: "Please select an area within the image",
    googleLensSearchFailed: "Search failed. Please try again.",
    
    // Delete account
    deleteAccount: "Delete Account",
    deleteAccountWarning1Title: "Delete Account",
    deleteAccountWarning1Message: "Are you sure you want to delete your account? This will delete all your information and images and cannot be undone.",
    deleteAccountWarning2Title: "Final Confirmation",
    deleteAccountWarning2Message: "This action is irreversible! All your history and images will be permanently deleted. Are you 100% sure?",
    deleteAccountConfirm: "Yes, Delete Account",
    deletingAccount: "Deleting account...",
    accountDeleted: "Account deleted successfully",
    errorDeletingAccount: "Error deleting account",
    
    // Language
    language: "Language",
    selectLanguage: "Select Language",
    languageChanged: "Language changed",
    
    // Create button
    create: "Create",
    
    // Subscription names
    subscriptionFree: "Free",
    subscriptionStarter: "Starter",
    subscriptionValue: "Value",
    subscriptionPro: "Professional",
    
    // Interior design
    interiorDesign: "Interior & Exterior Design",
    
    // Tool buttons
    repairsDamages: "Repairs & Damages",
    changeColor: "Change Color",
    angle: "Angle",
    addPlants: "Add Plants",
    enhanceLighting: "Enhance Lighting",
    addAccessories: "Add Accessories",
    addDetails: "Add Details",
    addMakeup: "Add Makeup",
    addBackground: "Add Background",
    bathroomShort: "Bathroom",
    
    // UI Labels
    tutorial: "Tutorial",
    designHistory: "Design History",
    activeSubscription: "Active Subscription",
    credits: "credits",
    loggedInAs: "Logged in as",
    promptPlaceholder: "Describe the desired design... (e.g., change the sofa to blue, add plants in the corner)",
    moreTools: "More Tools",
    colors: "Colors",
    aiDesigner: "AI Designer",
    aiDesignerActiveClickToDisable: "Active - Click to disable",
    aiDesignerInactiveClickToEnable: "Inactive - Click to enable",
    yourDesigner: "Your Designer",
    iHaveIdeasForYou: "I have some ideas for you!",
    heyIHaveGreatIdeas: "Hey! I have some great ideas to upgrade this room 🎨",
    noThanks: "No thanks",
    processingNewDesign: "Processing new design...",
    
    // Prompt tips
    promptUpdated: "Prompt updated. Click 'Create' to execute",
    tipClickMore: "💡 Tip: Click \"More\" for shortcuts like colors, furniture, lighting and more!",
    writeRequestAndCreate: "Write your request below and click \"Create\"",
    
    // Login required
    loginRequired: "Login Required",
    loginRequiredMessage: "You need to log in or create an account to purchase a subscription.",
    wantToLogin: "Do you want to go to login?",
    
    // Thanks
    thankYou: "Thank you!",
    messageReceived: "Your message has been received successfully.",
    willGetBack: "We will get back to you as soon as possible.",
    
    // Sending
    sending: "Sending...",
    
    // Additional Limit Reached Modal keys
    creditsDepletedThisMonth: "Credits depleted this month",
    creditsDepletedDesc: "You've reached your credit limit ({limit} credits). You can upgrade to a larger plan or wait until next month.",
    reachedFreeLimitDesc: "You've used all {limit} of your free credits. To continue designing without limits and get advanced features, upgrade to a professional subscription.",
    limitLabel: "Limit",
    goToProfessional: "Go Professional",
    
    // First Upload Tip
    imageUploadedSuccess: "Great! Image uploaded",
    describeWhatToChange: "Now describe what you'd like to change in the image. For example: \"Change the wall color to blue\" or \"Add plants in the corner\".",
    gotItLetsStart: "Got it, let's start!",
    
    // Additional Pricing Modal (new keys only)
    upgradeYourDesignAbilities: "Upgrade your design capabilities with our great subscription plans. Choose the plan that best fits your needs.",
    accessToAllTools: "Access to all design tools",
    emailSupport: "Email support",
    savePerImage: "Save 35% per image",
    prioritySupport: "Priority support",
    earlyAccess: "Early access to new features",
    unlimitedImages: "Unlimited images",
    premiumSupport: "Premium support",
    commercialLicense: "Commercial license",
    unlimitedDesigns: "Unlimited designs!",
    currentPlanBadge: "Current",
    save42PerImage: "Save 42% per image",
    allAdvancedFeatures: "All advanced features",
    forIndustryProfessionals: "For industry professionals",
    subscriptionDisclaimer: "You can cancel your subscription at any time. Billing renews automatically each month.",
    
    // Categories
    categoryInteriorExterior: "Interior & Exterior Design",
    categoryGardensBalconies: "Gardens & Balconies",
    categoryVehicles: "Vehicles & Two-Wheelers",
    categoryTattoos: "Tattoos",
    categoryMakeupBeauty: "Makeup & Beauty",
    categoryAdvertisingProducts: "Advertising & Products",
    
    // Ready Designs Room Categories
    roomKitchens: "Kitchens",
    roomLivingRooms: "Living Rooms",
    roomBathrooms: "Bathrooms",
    roomAdultBedrooms: "Adult Bedrooms",
    roomKidsBedrooms: "Kids Bedrooms",
    roomDiningAreas: "Dining Areas",
    roomOffices: "Home Offices",
    roomBalconies: "Balconies",
    roomGardens: "Gardens",
    roomEntrances: "Entrances",
    categoryProfileImage: "Profile & Image",
  },
  
  he: {
    // App
    appTitle: "מומחה AI",
    appName: "מומחה",
    
    // Auth
    guest: "אורח",
    loginToSaveDesigns: "התחבר כדי לשמור את העיצובים שלך",
    loggedOutSuccess: "התנתקת בהצלחה",
    login: "התחברות",
    logout: "התנתקות",
    createAccount: "יצירת חשבון",
    createNewAccount: "חשבון חדש",
    welcomeBack: "ברוך שובך! התחבר כדי להמשיך",
    joinUs: "הצטרף אלינו כדי לשמור עיצובים ולקבל גישה לכל התכונות",
    email: "אימייל",
    password: "סיסמה",
    confirmPassword: "אישור סיסמה",
    fillAllFields: "אנא מלא את כל השדות",
    passwordsNotMatch: "הסיסמאות אינן תואמות",
    loginButton: "התחבר",
    createAccountButton: "צור חשבון",
    forgotPassword: "שכחת סיסמה?",
    enterEmailFirst: "אנא הזן כתובת אימייל קודם",
    passwordResetEmailSent: "נשלח מייל לאיפוס סיסמה! בדוק את תיבת הדואר ותיקיית הספאם.",
    passwordResetError: "שגיאה בשליחת מייל לאיפוס סיסמה",
    termsAgreement: "בהתחברות אתה מסכים ל",
    termsOfService: "תנאי השירות",
    and: "ו",
    privacyPolicy: "מדיניות הפרטיות",
    privacyPolicyUrl: "https://moomhe.com/privacy.html",
    termsOfServiceUrl: "https://moomhe.com/eula.html",
    loggingIn: "מתחבר...",
    creatingAccount: "יוצר חשבון...",
    loginSuccess: "התחברת בהצלחה! 🎉",
    accountCreated: "החשבון נוצר בהצלחה! 🎉",
    loginError: "שגיאת התחברות",
    userNotFound: "משתמש לא נמצא",
    wrongPassword: "סיסמה שגויה",
    emailInUse: "האימייל כבר בשימוש",
    weakPassword: "הסיסמה חלשה מדי",
    invalidEmail: "כתובת אימייל לא תקינה",
    exitAccount: "יציאה מהחשבון",
    loginWithEmail: "התחבר עם אימייל כדי לשמור את העיצובים שלך",
    
    // Upload
    uploadImage: "העלאת תמונה",
    clickToUploadImage: "לחץ כאן כדי להעלות תמונה מהגלריה",
    gallery: "גלריה",
    camera: "מצלמה",
    uploadItem: "הוספת פריט",
    redesign: "עיצוב מחדש",
    readyDesigns: "גלריית עיצובים",
    // Design Gallery Categories
    categoryKitchen: "מטבח",
    categoryKidsBedroom: "חדר ילדים",
    categoryBathroom: "חדר אמבטיה",
    categoryLivingRoom: "סלון",
    categoryMasterBedroom: "חדר שינה",
    comingSoon: "בקרוב...",
    newDesignsWillBeAdded: "עיצובים חדשים יתווספו כאן",
    more: "עוד",
    moreOptions: "אפשרויות נוספות",
    history: "היסטוריה",
    noHistoryYet: "אין היסטוריה עדיין",
    uploadedImagesWillAppear: "תמונות שתעלה ותערוך יופיעו כאן",
    whatToChange: "מה לשנות?",
    uploadImageFirst: "אנא העלה תמונה קודם",
    uploadingImage: "מעלה תמונה...",
    errorUploadingImage: "שגיאה בהעלאת תמונה",
    
    // Item
    itemImageLoaded: "תמונת הפריט נטענה! תאר בפרומפט איפה להוסיף אותו.",
    addAttachedItem: "הוסף את הפריט המצורף לתמונה",
    
    // Processing
    processingStarting: "מתחיל...",
    processingMagic: "הקסם קורה",
    processing: "מעבד...",
    connectingToCloud: "מתחבר לענן... ☁️",
    sendingToAI: "שולח ל-AI... 🤖",
    analyzingItem: "מנתח פריט... 🔍",
    creatingDesign: "יוצר עיצוב... ✨",
    
    // Fun phrases
    funPhrase1: "שולח את התמונה למימד אחר... 🌀",
    funPhrase2: "מלמד את הבינה המלאכותית להעריך עיצוב טוב... 🎨",
    funPhrase3: "משכנע את הפיקסלים לשתף פעולה... 🤝",
    funPhrase4: "קצת קסם דיגיטלי בדרך... ✨",
    funPhrase5: "שואל את הבינה המלאכותית מה היא חושבת... 🤔",
    funPhrase6: "מערבב צבעים כמו אמן אמיתי... 🖌️",
    funPhrase7: "מחשב את הזווית המושלמת... 📐",
    funPhrase8: "מוסיף קצת סטייל לחיים שלך... 💫",
    funPhrase9: "גורם לחדר להיראות יותר יקר... 💎",
    funPhrase10: "מפעיל את קסם העיצוב... 🪄",
    funPhrase11: "מתייעץ עם מעצבי הפנים הדיגיטליים... 🏠",
    funPhrase12: "מנסה לא להתרגש יותר מדי מהתוצאה... 😍",
    funPhrase13: "עוד רגע תראה משהו מדהים... 🚀",
    funPhrase14: "מוודא שהכל מושלם בשבילך... 👌",
    
    // Tools
    designStyle: "סגנון עיצוב",
    wallColor: "שינוי צבע",
    lighting: "תאורה",
    furniture: "ריהוט",
    doorsWindows: "דלתות וחלונות",
    bathroom: "אמבטיה",
    repairs: "תיקונים",
    general: "כללי",
    
    // Panels
    selectDesignStyle: "בחר סגנון עיצוב",
    colorPalette: "פלטת צבעים",
    
    // Color Categories
    colorReds: "אדומים",
    colorOranges: "כתומים",
    colorYellows: "צהובים",
    colorGreens: "ירוקים",
    colorBlues: "כחולים",
    colorPurples: "סגולים",
    colorGrays: "אפורים",
    colorWhitesAndBlacks: "לבנים ושחורים",
    selectLightingType: "בחר סוג תאורה",
    selectFurnitureType: "בחר סוג ריהוט",
    selectRepairType: "בחר סוג תיקון/נזק",
    bathroomOptions: "אפשרויות אמבטיה",
    pleaseSelectOption: "אנא בחר אפשרות מהרשימה למטה.",
    
    // Repair Options
    repairEverything: "בצע תיקונים להכל",
    fixAndRepairEverything: "תסדר ותקנה את הכל",
    messUpEverything: "תבלגן את הכל",
    destroyAndCauseDamage: "תהרוס ותגרום נזקים להכל",
    
    // Doors/Windows Options
    windowOptions: "אפשרויות חלונות",
    doorOptions: "אפשרויות דלתות",
    fixedWindow: "חלון קבוע",
    slidingWindow: "חלון הזזה",
    casementWindow: "חלון כנף",
    tiltTurnWindow: "חלון דריי-קיפ",
    awningWindow: "חלון ציר עליון",
    doubleHungWindow: "חלון גליוטינה",
    pocketWindow: "חלון כיס",
    archWindow: "חלון קשת",
    pocketDoor: "דלת כיס",
    frenchDoors: "דלתות צרפתיות",
    louverDoor: "דלת לובר",
    barnDoor: "דלת אסם",
    
    // Bathroom Options
    toiletOptions: "אפשרויות אסלה",
    bathtubOptions: "אפשרויות אמבטיה",
    showerOptions: "אפשרויות מקלחת",
    sinkOptions: "אפשרויות כיור",
    jacuzziSpaOptions: "אפשרויות ג'קוזי/ספא",
    poolOptions: "אפשרויות בריכה",
    bidetSeat: "בידה מחומם",
    toiletSeat: "מושב אסלה",
    freestandingTub: "אמבטיה עומדת",
    vintageTub: "אמבטיה וינטג",
    standardTub: "אמבטיה סטנדרטית",
    rainShower: "מקלחת גשם",
    showerEnclosure: "מקלחון",
    slidingShower: "מקלחת דלתות",
    pedestalSink: "כיור עמוד",
    stainlessSink: "כיור נירוסטה",
    undermountSink: "כיור מובנה",
    builtInJacuzzi: "ג'קוזי מובנה",
    portableJacuzzi: "ג'קוזי נייד",
    ingroundPool: "בריכה בתוך הקרקע",
    abovegroundPool: "בריכה מעל הקרקע",
    
    // Actions
    whatToDo: "מה לעשות?",
    describeChange: "תאר את השינוי הרצוי...",
    cancel: "ביטול",
    execute: "בצע",
    confirm: "אישור",
    close: "סגור",
    tryAgain: "נסה שוב",
    
    // Color
    colorChange: "שינוי צבע",
    allWalls: "כל הקירות",
    paintAllWalls: "צבע את כל הקירות בחדר",
    specificObject: "אובייקט ספציפי",
    selectWhatToPaint: "בחר מה אתה רוצה לצבוע",
    exampleObjects: "לדוגמה: ספה, תקרה, ארון...",
    
    // Subscription
    professionalSubscription: "מנוי מקצועי",
    specialLaunchPrices: "מחירי השקה מיוחדים 🚀",
    purchaseFailed: "הרכישה נכשלה",
    yourCurrentPlan: "התוכנית הנוכחית שלך",
    selectPlan: "בחר תוכנית",
    perMonth: "/חודש",
    starterPlan: "מתחיל",
    valuePlan: "משתלם",
    proPlan: "מקצועי",
    imagesPerMonth: "{count} תמונות בחודש",
    whatsappSupport: "תמיכה בווטסאפ",
    historyStorage: "שמירת היסטוריה",
    vipWhatsappSupport: "תמיכת VIP בווטסאפ",
    processingPriority: "עדיפות בעיבוד",
    bestValue: "הכי משתלם: פי 4 יותר תמונות! 🔥",
    forProfessionals: "למקצוענים ⭐",
    allDesignTools: "כל כלי העיצוב",
    fastSupport: "תמיכה מהירה",
    noAds: "ללא פרסומות",
    restorePurchases: "שחזור רכישות",
    
    // Credits
    mySubscription: "המנוי שלי",
    creditsRemaining: "{count} קרדיטים נותרו",
    upgradeToPremium: "שדרג לפרימיום",
    iHaveCoupon: "יש לי קופון",
    enterCouponCode: "הזן קוד קופון כדי לקבל קרדיטים חינם",
    enterCouponCodeTitle: "הזנת קוד קופון",
    enterCouponCodeSubtitle: "הזן את קוד הקופון שקיבלת כדי לקבל קרדיטים חינם",
    couponCode: "קוד קופון",
    mustEnterCoupon: "יש להזין קוד קופון",
    couponActivated: "הקופון הופעל בהצלחה!",
    errorRedeemingCoupon: "שגיאה בהפעלת הקופון",
    redeemCoupon: "הפעל קופון",
    creditsAddedToAccount: "{count} קרדיטים נוספו לחשבונך! 🎉",
    
    // Contact
    contactUs: "צור קשר",
    contactSubtitle: "נשמח לשמוע ממך! מלא את הפרטים ונחזור אליך בהקדם.",
    phone: "טלפון",
    message: "הודעה",
    writeYourMessage: "כתוב את ההודעה שלך כאן...",
    enterPhoneOrEmail: "* אנא הזן לפחות טלפון או אימייל",
    pleaseEnterPhoneOrEmail: "אנא הזן לפחות טלפון או אימייל",
    pleaseEnterMessage: "אנא הזן הודעה",
    errorSendingMessage: "שגיאה בשליחת ההודעה. אנא נסה שוב.",
    sendMessage: "שלח הודעה",
    messageSentSuccess: "ההודעה נשלחה בהצלחה!",
    
    // Errors
    contentNotAllowed: "תוכן לא מורשה",
    requestFailed: "הבקשה נכשלה",
    oopsSomethingWrong: "אופס! משהו השתבש",
    moderationError: "לא ניתן לעבד את התמונה או הבקשה.\n\nייתכן שהתמונה או הבקשה מכילות תוכן שאינו מותר לעיבוד.\n\nנסה עם תמונה אחרת או שנה את הבקשה.",
    timeoutError: "הבקשה לקחה יותר מדי זמן.\n\nנסה שוב מאוחר יותר.",
    genericError: "לא הצלחנו לעבד את הבקשה.\n\nנסה שוב או פנה לתמיכה אם הבעיה נמשכת.",
    errorUnknown: "שגיאה לא ידועה",
    
    // Image actions
    imageSavedToGallery: "התמונה נשמרה בגלריה!",
    errorDownloadingImage: "שגיאה בהורדת התמונה",
    errorSharing: "שגיאה בשיתוף",
    shareText: "🏠 עיצבתי את זה עם מומחה AI!\n📸 רוצים לנסות גם? https://moomhe.com",
    comparison: "השוואה",
    download: "הורד",
    share: "שתף",
    revertToOriginal: "חזור למקור",
    loveItSave: "אהבתי! שמור",
    whatsApp: "וואטסאפ",
    products: "מוצרים",
    cancelSearch: "ביטול חיפוש",
    searchSimilarProducts: "חפשו מוצרים דומים",
    whatDoYouThink: "מה דעתך על העיצוב החדש?",
    dragSliderForComparison: "גרור את הסליידר למעלה להשוואה מלאה",
    returnToOriginal: "חזור לתמונה המקורית",
    loveItSaveDesign: "אהבתי! שמור את העיצוב",
    
    // Limits
    creditsFinishedThisMonth: "הקרדיטים נגמרו החודש",
    creditsRanOut: "הקרדיטים נגמרו החודש",
    freeLimitReached: "הגעת למגבלת השימוש החינמי",
    reachedFreeLimit: "הגעת למגבלת השימוש החינמי",
    creditsLimitReached: "הגעת למגבלת הקרדיטים שלך. תוכל לשדרג לתוכנית גדולה יותר או לחכות עד החודש הבא.",
    freeCreditsUsed: "השתמשת בכל הקרדיטים החינמיים שלך. כדי להמשיך לעצב ללא הגבלות ולקבל תכונות מתקדמות, שדרג לתוכנית מקצועית.",
    currentUsage: "שימוש נוכחי",
    limit: "מגבלה",
    designs: "עיצובים",
    upgradePlan: "שדרג תוכנית",
    goToProfessionalPlan: "עבור לתוכנית מקצועית",
    goPro: "שדרג למקצועי",
    notNowThanks: "לא עכשיו, תודה",
    
    // Welcome
    welcomeToPlan: "ברוך הבא למנוי {planName}!",
    thankYouForJoining: "תודה שהצטרפת למשפחת המנויים שלנו. החשבון שלך שודרג בהצלחה וכעת יש לך גישה לכל התכונות המתקדמות ולקרדיטים נוספים.",
    creditsAddedToYourAccount: "קרדיטים נוספו לחשבונך",
    unlimitedStyleAccess: "גישה ללא הגבלה לכל הסגנונות",
    supportCreators: "תמיכה ביוצרים ומעצבים",
    startDesigning: "התחל לעצב",
    
    // Secure subscription
    secureYourSubscription: "אבטח את המנוי שלך",
    secureSubscriptionMessage: "כדי לא לאבד את המנוי שרכשת, אנחנו ממליצים להתחבר עם אימייל.\n\nכך תוכל לשחזר את המנוי במכשיר חדש או לאחר התקנה מחדש.",
    later: "מאוחר יותר",
    loginNow: "התחבר עכשיו",
    
    // Onboarding
    onboardingUploadTitle: "העלה תמונה",
    onboardingUploadDesc: "התחל בהעלאת תמונה של החדר שתרצה לעצב. אין לך תמונה? אל דאגה, נשתמש בתמונה לדוגמה.",
    onboardingStyleTitle: "בחר עיצוב מחדש",
    onboardingStyleDesc: "בחר את הסגנון המועדף עליך מהתפריט הצדדי. נסה \"עיצוב מחדש\" כדי לראות אפשרויות שונות.",
    onboardingCreateTitle: "צור עיצוב",
    onboardingCreateDesc: "לחץ על \"צור\" וה-AI יעצב מחדש את החדר שלך תוך שניות!",
    onboardingItemTipTitle: "טיפ נוסף: העלה פריט",
    onboardingItemTipDesc: "רוצה להוסיף רהיט ספציפי? השתמש בכפתור \"העלה פריט\" כדי להעלות תמונה של פריט ולשלב אותו בעיצוב.",
    skip: "דלג",
    next: "הבא",
    finish: "סיום",
    promptAddedToInput: "הפרומפט נוסף - ניתן לערוך ואז ללחוץ על צור",
    
    // Styles
    styleMediterranean: "ים תיכוני מודרני",
    styleWarmMinimalism: "מינימליזם חם",
    styleBiophilic: "ביופילי",
    styleModernLuxury: "יוקרה מודרנית",
    styleJapandi: "יפנדי",
    styleScandinavian: "סקנדינבי",
    styleBohoChic: "בוהו שיק",
    styleIndustrial: "תעשייתי",
    styleEarthyNatural: "טבעי אדמתי",
    styleJerusalem: "ירושלמי",
    styleMinimalist: "מינימליסטי",
    styleModernClassic: "קלאסי מודרני",
    
    // Color categories
    colorCategoryReds: "אדומים",
    colorCategoryOranges: "כתומים",
    colorCategoryYellows: "צהובים",
    colorCategoryGreens: "ירוקים",
    colorCategoryBlues: "כחולים",
    colorCategoryPurples: "סגולים",
    colorCategoryGrays: "אפורים",
    colorCategoryWhitesBlacks: "לבנים ושחורים",
    
    // Lighting
    lightingRecessed: "תאורה שקועה",
    lightingPendant: "מנורת תלייה",
    lightingChandelier: "נברשת",
    lightingTableLamp: "מנורת שולחן",
    lightingFloorLamp: "מנורת רצפה",
    lightingWallSconce: "מנורת קיר",
    lightingTrack: "תאורת פס",
    lightingCeiling: "גוף תאורה לתקרה",
    lightingUnderCabinet: "תאורה מתחת לארון",
    lightingDecorative: "תאורה דקורטיבית",
    lightingDay: "יום",
    lightingNight: "לילה",
    lightingSunset: "שקיעה",
    lightingSunrise: "זריחה",
    
    // Furniture
    furnitureSofa: "ספה",
    furnitureSectional: "ספה פינתית",
    furnitureArmchair: "כורסה",
    furnitureAccentChair: "כיסא נוי",
    furnitureDiningChair: "כיסא אוכל",
    furnitureBarStool: "כיסא בר",
    furnitureSingleBed: "מיטת יחיד",
    furnitureDoubleBed: "מיטה זוגית",
    furnitureBeanbag: "פוף",
    furnitureOttoman: "הדום",
    furnitureBench: "ספסל",
    furnitureCoffeeTable: "שולחן קפה",
    furnitureEndTable: "שולחן צד",
    furnitureNightstand: "שידת לילה",
    furnitureDiningTable: "שולחן אוכל",
    furnitureDesk: "שולחן כתיבה",
    furnitureDresser: "שידה",
    furnitureWardrobe: "ארון בגדים",
    furnitureBookcase: "ספריה",
    furnitureTvStand: "מזנון טלוויזיה",
    furnitureCabinets: "ארונות מטבח",
    
    // Repairs
    repairsFixEverything: "תקן הכל",
    repairsRepairAll: "תקן ושפץ הכל",
    repairsMessUp: "הרוס הכל",
    repairsDestroy: "הרס וגרום נזק לכל דבר",
    
    // Windows
    windowPicture: "חלון תמונה",
    windowSliding: "חלון הזזה",
    windowCasement: "חלון ציר",
    windowTiltTurn: "חלון הטיה וסיבוב",
    windowAwning: "חלון סוכך",
    windowSash: "חלון אשנב",
    windowPocket: "חלון כיס",
    windowArched: "חלון קשתי",
    
    // Doors
    doorPocket: "דלת כיס",
    doorFrench: "דלתות צרפתיות",
    doorLouvered: "דלת תריס",
    doorBarn: "דלת אסם",
    
    // Search
    searchWithLens: "חיפוש",
    selectAreaToSearch: "סמן מלבן סביב הפריט שברצונך לחפש",
    searchingWithGoogleLens: "מחפש ב-Google Lens...",
    selectAreaWithinImage: "בחר אזור בתוך התמונה",
    googleLensSearchFailed: "החיפוש נכשל. נסה שוב.",
    
    // Delete account
    deleteAccount: "מחיקת חשבון",
    deleteAccountWarning1Title: "מחיקת חשבון",
    deleteAccountWarning1Message: "האם אתה בטוח שברצונך למחוק את החשבון שלך? פעולה זו תמחק את כל המידע והתמונות שלך ולא ניתן יהיה לשחזר אותם.",
    deleteAccountWarning2Title: "אישור סופי",
    deleteAccountWarning2Message: "זו פעולה בלתי הפיכה! כל ההיסטוריה והתמונות שלך יימחקו לצמיתות. האם אתה בטוח ב-100%?",
    deleteAccountConfirm: "כן, מחק את החשבון",
    deletingAccount: "מוחק חשבון...",
    accountDeleted: "החשבון נמחק בהצלחה",
    errorDeletingAccount: "שגיאה במחיקת החשבון",
    
    // Language
    language: "שפה",
    selectLanguage: "בחר שפה",
    languageChanged: "השפה השתנתה",
    
    // Create button
    create: "צור",
    
    // Subscription names
    subscriptionFree: "חינם",
    subscriptionStarter: "מתחיל",
    subscriptionValue: "משתלם",
    subscriptionPro: "מקצועי",
    
    // Interior design
    interiorDesign: "עיצוב פנים וחוץ",
    
    // Tool buttons
    repairsDamages: "תיקונים ונזקים",
    changeColor: "שנה צבע",
    angle: "זווית",
    addPlants: "הוסף צמחים",
    enhanceLighting: "שיפור תאורה",
    addAccessories: "הוסף אביזרים",
    addDetails: "הוסף פרטים",
    addMakeup: "הוסף איפור",
    addBackground: "הוסף רקע",
    bathroomShort: "רחצה",
    
    // UI Labels
    tutorial: "הדרכה",
    designHistory: "היסטוריית עיצובים",
    activeSubscription: "מנוי פעיל",
    credits: "קרדיטים",
    loggedInAs: "מחובר כ-",
    promptPlaceholder: "תאר את העיצוב המבוקש... (לדוגמה: שנה את הספה לצבע כחול, הוסף צמחייה בפינה)",
    moreTools: "כלים נוספים",
    colors: "צבעים",
    aiDesigner: "מעצבת AI",
    aiDesignerActiveClickToDisable: "פעילה - לחץ לכיבוי",
    aiDesignerInactiveClickToEnable: "כבויה - לחץ להפעלה",
    yourDesigner: "המעצבת שלך",
    iHaveIdeasForYou: "יש לי כמה רעיונות עבורך!",
    heyIHaveGreatIdeas: "היי! יש לי כמה רעיונות מעולים לשדרוג החדר הזה 🎨",
    noThanks: "לא תודה",
    processingNewDesign: "מעבד עיצוב חדש...",
    
    // Prompt tips
    promptUpdated: "שורת פרומפט עודכנה. לחץ על 'צור' כדי לבצע",
    tipClickMore: "💡 טיפ: לחץ על \"עוד\" לקיצורי דרך מוכנים כמו שינוי צבעים, ריהוט, תאורה ועוד!",
    writeRequestAndCreate: "כתוב את הבקשה שלך בשורה למטה ולחץ \"צור\"",
    
    // Login required
    loginRequired: "נדרשת התחברות",
    loginRequiredMessage: "עליך להתחבר או ליצור חשבון כדי לרכוש מנוי.",
    wantToLogin: "האם ברצונך לעבור להתחברות?",
    
    // Thanks
    thankYou: "תודה רבה!",
    messageReceived: "ההודעה שלך התקבלה בהצלחה.",
    willGetBack: "נחזור אליך בהקדם האפשרי.",
    
    // Sending
    sending: "שולח...",
    
    // Additional Limit Reached Modal keys
    creditsDepletedThisMonth: "נגמרו הקרדיטים לחודש זה",
    creditsDepletedDesc: "הגעת למגבלת הקרדיטים שלך ({limit} קרדיטים). ניתן לשדרג לחבילה גדולה יותר או לחכות לחודש הבא.",
    reachedFreeLimitDesc: "ניצלת את כל {limit} הקרדיטים החינמיים שלך. כדי להמשיך לעצב ללא הגבלה ולקבל תכונות מתקדמות, שדרג למנוי מקצועי.",
    limitLabel: "מגבלה",
    goToProfessional: "עבור למנוי מקצועי",
    
    // First Upload Tip
    imageUploadedSuccess: "מעולה! התמונה הועלתה",
    describeWhatToChange: "עכשיו תאר מה תרצה לשנות בתמונה. לדוגמה: \"שנה את צבע הקירות לכחול\" או \"הוסף צמחים בפינה\".",
    gotItLetsStart: "הבנתי, בוא נתחיל!",
    
    // Additional Pricing Modal (new keys only)
    upgradeYourDesignAbilities: "שדרג את יכולות העיצוב שלך עם חבילות המנוי המשתלמות שלנו. בחר את החבילה המתאימה ביותר לצרכים שלך.",
    accessToAllTools: "גישה לכל כלי העיצוב",
    emailSupport: "תמיכה במייל",
    savePerImage: "חסוך 35% למחיר תמונה",
    prioritySupport: "תמיכה בעדיפות",
    earlyAccess: "גישה מוקדמת לתכונות חדשות",
    unlimitedImages: "תמונות ללא הגבלה",
    premiumSupport: "תמיכה פרימיום",
    commercialLicense: "רישיון מסחרי",
    unlimitedDesigns: "עיצובים ללא הגבלה!",
    currentPlanBadge: "נוכחי",
    save42PerImage: "חסוך 42% למחיר תמונה",
    allAdvancedFeatures: "כל הפיצ׳רים המתקדמים",
    forIndustryProfessionals: "לאנשי מקצוע בתחום",
    subscriptionDisclaimer: "ניתן לבטל את המנוי בכל עת. החיוב מתחדש אוטומטית כל חודש. ט.ל.ח",
    
    // Categories
    categoryInteriorExterior: "עיצוב פנים וחוץ",
    categoryGardensBalconies: "גינות ומרפסות",
    categoryVehicles: "רכבים ודו גלגלי",
    categoryTattoos: "קעקועים",
    categoryMakeupBeauty: "איפור וטיפוח",
    categoryAdvertisingProducts: "פרסום ומוצרים",
    
    // Ready Designs Room Categories
    roomKitchens: "מטבחים",
    roomLivingRooms: "סלונים",
    roomBathrooms: "שירותים ורחצה",
    roomAdultBedrooms: "חדרי שינה בוגרים",
    roomKidsBedrooms: "חדרי שינה ילדים",
    roomDiningAreas: "פינות אוכל",
    roomOffices: "חדרי עבודה",
    roomBalconies: "מרפסות",
    roomGardens: "גינות",
    roomEntrances: "מבואות",
    categoryProfileImage: "פרופיל ותדמית",
  },
  
  // Additional languages from translations.js
  ar: additionalTranslations.ar,
  es: additionalTranslations.es,
  de: additionalTranslations.de,
  fr: additionalTranslations.fr,
  it: additionalTranslations.it,
  pt: additionalTranslations.pt,
  nl: additionalTranslations.nl,
  ja: additionalTranslations.ja,
  ko: additionalTranslations.ko,
  zh: additionalTranslations.zh,
  zh_HK: additionalTranslations.zh_HK,
  cs: additionalTranslations.cs,
  da: additionalTranslations.da,
  el: additionalTranslations.el,
  et: additionalTranslations.et,
  fi: additionalTranslations.fi,
  ga: additionalTranslations.ga,
  hr: additionalTranslations.hr,
  hu: additionalTranslations.hu,
  is: additionalTranslations.is,
  ka: additionalTranslations.ka,
  lt: additionalTranslations.lt,
  nb: additionalTranslations.nb,
  pl: additionalTranslations.pl,
  ro: additionalTranslations.ro,
  sl: additionalTranslations.sl,
  sv: additionalTranslations.sv,
};

// Localization context
const LocalizationContext = createContext();

// Get country code by IP
async function getCountryByIP() {
  try {
    const response = await fetch('https://api.country.is/');
    const data = await response.json();
    return data.country;
  } catch (error) {
    console.warn('Could not get country by IP:', error);
    return null;
  }
}

// Get language from country code
function getLanguageFromCountry(countryCode) {
  return COUNTRY_TO_LANGUAGE[countryCode] || 'en';
}

// Get browser language
function getBrowserLanguage() {
  const browserLang = navigator.language || navigator.userLanguage;
  const langCode = browserLang.split('-')[0];
  
  // Check if we support this language
  if (translations[langCode]) {
    return langCode;
  }
  
  // Check for country-specific variants
  if (browserLang === 'zh-HK' || browserLang === 'zh-TW') {
    return 'zh_HK';
  }
  
  return 'en';
}

// Localization Provider
export function LocalizationProvider({ children }) {
  const [language, setLanguageState] = useState(() => {
    // Check localStorage first
    const saved = localStorage.getItem('app_language');
    if (saved && translations[saved]) {
      return saved;
    }
    // Fall back to browser language
    return getBrowserLanguage();
  });
  
  const [isRTL, setIsRTL] = useState(RTL_LANGUAGES.includes(language));
  const [countryCode, setCountryCode] = useState(null);
  const [isInitialized, setIsInitialized] = useState(false);

  // Detect country by IP on mount (only if no saved preference)
  useEffect(() => {
    const savedLanguage = localStorage.getItem('app_language');
    
    if (!savedLanguage) {
      // No saved preference, detect by IP
      getCountryByIP().then(country => {
        if (country) {
          setCountryCode(country);
          const detectedLang = getLanguageFromCountry(country);
          if (translations[detectedLang]) {
            setLanguageState(detectedLang);
            setIsRTL(RTL_LANGUAGES.includes(detectedLang));
          }
        }
        setIsInitialized(true);
      });
    } else {
      // Get country anyway for analytics
      getCountryByIP().then(country => {
        if (country) setCountryCode(country);
        setIsInitialized(true);
      });
    }
  }, []);

  // Update document direction when RTL changes
  useEffect(() => {
    document.documentElement.dir = isRTL ? 'rtl' : 'ltr';
    document.documentElement.lang = language;
  }, [isRTL, language]);

  const setLanguage = (lang) => {
    // Allow any language from SUPPORTED_LANGUAGES, will fall back to English for missing translations
    const isSupported = SUPPORTED_LANGUAGES.some(l => l.code === lang);
    if (isSupported) {
      setLanguageState(lang);
      setIsRTL(RTL_LANGUAGES.includes(lang));
      localStorage.setItem('app_language', lang);
    }
  };

  // Translation function with placeholder support
  const t = (key, params = {}) => {
    let text = translations[language]?.[key] || translations.en?.[key] || key;
    
    // Replace placeholders like {count}, {planName}, etc.
    Object.keys(params).forEach(param => {
      text = text.replace(new RegExp(`\\{${param}\\}`, 'g'), params[param]);
    });
    
    return text;
  };

  const value = {
    language,
    setLanguage,
    t,
    isRTL,
    countryCode,
    isInitialized,
    supportedLanguages: SUPPORTED_LANGUAGES,
  };

  return (
    <LocalizationContext.Provider value={value}>
      {children}
    </LocalizationContext.Provider>
  );
}

// Hook to use localization
export function useLocalization() {
  const context = useContext(LocalizationContext);
  if (!context) {
    throw new Error('useLocalization must be used within a LocalizationProvider');
  }
  return context;
}

// Export for direct use
export { translations, COUNTRY_TO_LANGUAGE, RTL_LANGUAGES };
