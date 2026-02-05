// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'מומחה AI';

  @override
  String get appName => 'מומחה';

  @override
  String get guest => 'אורח';

  @override
  String get loginToSaveDesigns => 'התחבר כדי לשמור את העיצובים שלך';

  @override
  String get loggedOutSuccess => 'התנתקת בהצלחה';

  @override
  String get uploadImage => 'העלאת תמונה';

  @override
  String get clickToUploadImage => 'לחץ כאן כדי להעלות תמונה מהגלריה';

  @override
  String get gallery => 'גלריה';

  @override
  String get camera => 'מצלמה';

  @override
  String get uploadItem => 'הוספת פריט';

  @override
  String get redesign => 'עיצוב מחדש';

  @override
  String get more => 'עוד';

  @override
  String get moreOptions => 'אפשרויות נוספות';

  @override
  String get history => 'היסטוריה';

  @override
  String get noHistoryYet => 'אין היסטוריה עדיין';

  @override
  String get uploadedImagesWillAppear => 'תמונות שתעלה ותערוך יופיעו כאן';

  @override
  String get whatToChange => 'מה לשנות?';

  @override
  String get uploadImageFirst => 'אנא העלה תמונה קודם';

  @override
  String get uploadingImage => 'מעלה תמונה...';

  @override
  String get errorUploadingImage => 'שגיאה בהעלאת תמונה';

  @override
  String get itemImageLoaded =>
      'תמונת הפריט נטענה! תאר בפרומפט איפה להוסיף אותו.';

  @override
  String get addAttachedItem => 'הוסף את הפריט המצורף לתמונה';

  @override
  String get processingStarting => 'מתחיל...';

  @override
  String get processingMagic => 'הקסם קורה';

  @override
  String get processing => 'מעבד...';

  @override
  String get connectingToCloud => 'מתחבר לענן... ☁️';

  @override
  String get sendingToAI => 'שולח ל-AI... 🤖';

  @override
  String get analyzingItem => 'מנתח פריט... 🔍';

  @override
  String get creatingDesign => 'יוצר עיצוב... ✨';

  @override
  String get funPhrase1 => 'שולח את התמונה למימד אחר... 🌀';

  @override
  String get funPhrase2 => 'מלמד את הבינה המלאכותית להעריך עיצוב טוב... 🎨';

  @override
  String get funPhrase3 => 'משכנע את הפיקסלים לשתף פעולה... 🤝';

  @override
  String get funPhrase4 => 'קצת קסם דיגיטלי בדרך... ✨';

  @override
  String get funPhrase5 => 'שואל את הבינה המלאכותית מה היא חושבת... 🤔';

  @override
  String get funPhrase6 => 'מערבב צבעים כמו אמן אמיתי... 🖌️';

  @override
  String get funPhrase7 => 'מחשב את הזווית המושלמת... 📐';

  @override
  String get funPhrase8 => 'מוסיף קצת סטייל לחיים שלך... 💫';

  @override
  String get funPhrase9 => 'גורם לחדר להיראות יותר יקר... 💎';

  @override
  String get funPhrase10 => 'מפעיל את קסם העיצוב... 🪄';

  @override
  String get funPhrase11 => 'מתייעץ עם מעצבי הפנים הדיגיטליים... 🏠';

  @override
  String get funPhrase12 => 'מנסה לא להתרגש יותר מדי מהתוצאה... 😍';

  @override
  String get funPhrase13 => 'עוד רגע תראה משהו מדהים... 🚀';

  @override
  String get funPhrase14 => 'מוודא שהכל מושלם בשבילך... 👌';

  @override
  String get designStyle => 'סגנון עיצוב';

  @override
  String get wallColor => 'שינוי צבע';

  @override
  String get lighting => 'תאורה';

  @override
  String get furniture => 'ריהוט';

  @override
  String get doorsWindows => 'דלתות וחלונות';

  @override
  String get bathroom => 'אמבטיה';

  @override
  String get repairs => 'תיקונים';

  @override
  String get general => 'כללי';

  @override
  String get selectDesignStyle => 'בחר סגנון עיצוב';

  @override
  String get colorPalette => 'פלטת צבעים';

  @override
  String get selectLightingType => 'בחר סוג תאורה';

  @override
  String get selectFurnitureType => 'בחר סוג ריהוט';

  @override
  String get selectRepairType => 'בחר סוג תיקון/נזק';

  @override
  String get bathroomOptions => 'אפשרויות אמבטיה';

  @override
  String changeStyleTo(String styleName) {
    return 'שנה את הסגנון ל$styleName';
  }

  @override
  String get whatToDo => 'מה לעשות?';

  @override
  String get describeChange => 'תאר את השינוי הרצוי...';

  @override
  String get cancel => 'ביטול';

  @override
  String get execute => 'בצע';

  @override
  String comingSoon(String feature) {
    return '$feature - בקרוב!';
  }

  @override
  String get colorChange => 'שינוי צבע';

  @override
  String get allWalls => 'כל הקירות';

  @override
  String get paintAllWalls => 'צבע את כל הקירות בחדר';

  @override
  String get specificObject => 'אובייקט ספציפי';

  @override
  String get selectWhatToPaint => 'בחר מה אתה רוצה לצבוע';

  @override
  String get exampleObjects => 'לדוגמה: ספה, תקרה, ארון...';

  @override
  String get confirm => 'אישור';

  @override
  String get windowOptions => 'אפשרויות חלונות';

  @override
  String get doorOptions => 'אפשרויות דלתות';

  @override
  String get toiletOptions => 'אפשרויות אסלה';

  @override
  String get bathtubOptions => 'אפשרויות אמבטיה';

  @override
  String get showerOptions => 'אפשרויות מקלחת';

  @override
  String get sinkOptions => 'אפשרויות כיור';

  @override
  String get jacuzziOptions => 'אפשרויות ג\'קוזי/ספא';

  @override
  String get poolOptions => 'אפשרויות בריכה';

  @override
  String get professionalSubscription => 'מנוי מקצועי';

  @override
  String get specialLaunchPrices => 'מחירי השקה מיוחדים 🚀';

  @override
  String get purchaseFailed => 'הרכישה נכשלה';

  @override
  String get yourCurrentPlan => 'התוכנית הנוכחית שלך';

  @override
  String get selectPlan => 'בחר תוכנית';

  @override
  String get perMonth => '/חודש';

  @override
  String get starterPlan => 'מתחיל';

  @override
  String get valuePlan => 'משתלם';

  @override
  String get proPlan => 'מקצועי';

  @override
  String imagesPerMonth(int count) {
    return '$count תמונות בחודש';
  }

  @override
  String get whatsappSupport => 'תמיכה בווטסאפ';

  @override
  String get historyStorage => 'שמירת היסטוריה';

  @override
  String get vipWhatsappSupport => 'תמיכת VIP בווטסאפ';

  @override
  String get processingPriority => 'עדיפות בעיבוד';

  @override
  String get bestValue => 'הכי משתלם: פי 4 יותר תמונות! 🔥';

  @override
  String get forProfessionals => 'למקצוענים ⭐';

  @override
  String savePerImage(String percent) {
    return 'חסכון של $percent% לתמונה';
  }

  @override
  String get allDesignTools => 'כל כלי העיצוב';

  @override
  String get fastSupport => 'תמיכה מהירה';

  @override
  String get noAds => 'ללא פרסומות';

  @override
  String get restorePurchases => 'שחזור רכישות';

  @override
  String get login => 'התחברות';

  @override
  String get logout => 'התנתקות';

  @override
  String get createAccount => 'יצירת חשבון';

  @override
  String get createNewAccount => 'חשבון חדש';

  @override
  String get welcomeBack => 'ברוך שובך! התחבר כדי להמשיך';

  @override
  String get joinUs => 'הצטרף אלינו כדי לשמור עיצובים ולקבל גישה לכל התכונות';

  @override
  String get email => 'אימייל';

  @override
  String get password => 'סיסמה';

  @override
  String get confirmPassword => 'אישור סיסמה';

  @override
  String get fillAllFields => 'אנא מלא את כל השדות';

  @override
  String get passwordsNotMatch => 'הסיסמאות אינן תואמות';

  @override
  String get passwordsDoNotMatch => 'הסיסמאות אינן תואמות';

  @override
  String get loginButton => 'התחבר';

  @override
  String get createAccountButton => 'צור חשבון';

  @override
  String get forgotPassword => 'שכחת סיסמה?';

  @override
  String get enterEmailFirst => 'אנא הזן כתובת אימייל קודם';

  @override
  String get passwordResetEmailSent =>
      'נשלח מייל לאיפוס סיסמה! בדוק את תיבת הדואר ותיקיית הספאם.';

  @override
  String get passwordResetError => 'שגיאה בשליחת מייל לאיפוס סיסמה';

  @override
  String get termsAgreement => 'בהתחברות אתה מסכים ל';

  @override
  String get termsOfService => 'תנאי השירות';

  @override
  String get and => 'ו';

  @override
  String get privacyPolicy => 'מדיניות הפרטיות';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula.html';

  @override
  String get loggingIn => 'מתחבר...';

  @override
  String get creatingAccount => 'יוצר חשבון...';

  @override
  String get loginSuccess => 'התחברת בהצלחה! 🎉';

  @override
  String get accountCreated => 'החשבון נוצר בהצלחה! 🎉';

  @override
  String get loginError => 'שגיאת התחברות';

  @override
  String get userNotFound => 'משתמש לא נמצא';

  @override
  String get wrongPassword => 'סיסמה שגויה';

  @override
  String get emailInUse => 'האימייל כבר בשימוש';

  @override
  String get weakPassword => 'הסיסמה חלשה מדי';

  @override
  String get invalidEmail => 'כתובת אימייל לא תקינה';

  @override
  String get exitAccount => 'יציאה מהחשבון';

  @override
  String get loginWithEmail => 'התחבר עם אימייל כדי לשמור את העיצובים שלך';

  @override
  String get mySubscription => 'המנוי שלי';

  @override
  String creditsRemaining(int count) {
    return '$count קרדיטים נותרו';
  }

  @override
  String get upgradeToPremium => 'שדרג לפרימיום';

  @override
  String get iHaveCoupon => 'יש לי קופון';

  @override
  String get enterCouponCode => 'הזן קוד קופון כדי לקבל קרדיטים חינם';

  @override
  String get enterCouponCodeTitle => 'הזנת קוד קופון';

  @override
  String get enterCouponCodeSubtitle =>
      'הזן את קוד הקופון שקיבלת כדי לקבל קרדיטים חינם';

  @override
  String get couponCode => 'קוד קופון';

  @override
  String get mustEnterCoupon => 'יש להזין קוד קופון';

  @override
  String get couponActivated => 'הקופון הופעל בהצלחה!';

  @override
  String get errorRedeemingCoupon => 'שגיאה בהפעלת הקופון';

  @override
  String get redeemCoupon => 'הפעל קופון';

  @override
  String creditsAddedToAccount(int count) {
    return '$count קרדיטים נוספו לחשבונך! 🎉';
  }

  @override
  String get contactUs => 'צור קשר';

  @override
  String get contactSubtitle =>
      'נשמח לשמוע ממך! מלא את הפרטים ונחזור אליך בהקדם.';

  @override
  String get phone => 'טלפון';

  @override
  String get message => 'הודעה';

  @override
  String get writeYourMessage => 'כתוב את ההודעה שלך כאן...';

  @override
  String get enterPhoneOrEmail => '* אנא הזן לפחות טלפון או אימייל';

  @override
  String get pleaseEnterPhoneOrEmail => 'אנא הזן לפחות טלפון או אימייל';

  @override
  String get pleaseEnterMessage => 'אנא הזן הודעה';

  @override
  String get errorSendingMessage => 'שגיאה בשליחת ההודעה. אנא נסה שוב.';

  @override
  String get sendMessage => 'שלח הודעה';

  @override
  String get messageSentSuccess => 'ההודעה נשלחה בהצלחה!';

  @override
  String get contentNotAllowed => 'תוכן לא מורשה';

  @override
  String get requestFailed => 'הבקשה נכשלה';

  @override
  String get oopsSomethingWrong => 'אופס! משהו השתבש';

  @override
  String get moderationError =>
      'לא ניתן לעבד את התמונה או הבקשה.\n\nייתכן שהתמונה או הבקשה מכילות תוכן שאינו מותר לעיבוד.\n\nנסה עם תמונה אחרת או שנה את הבקשה.';

  @override
  String get timeoutError => 'הבקשה לקחה יותר מדי זמן.\n\nנסה שוב מאוחר יותר.';

  @override
  String get genericError =>
      'לא הצלחנו לעבד את הבקשה.\n\nנסה שוב או פנה לתמיכה אם הבעיה נמשכת.';

  @override
  String get close => 'סגור';

  @override
  String get tryAgain => 'נסה שוב';

  @override
  String get imageSavedToGallery => 'התמונה נשמרה בגלריה!';

  @override
  String get errorDownloadingImage => 'שגיאה בהורדת התמונה';

  @override
  String get errorSharing => 'שגיאה בשיתוף';

  @override
  String get shareText =>
      '🏠 עיצבתי את זה עם מומחה AI!\n📸 רוצים לנסות גם? https://moomhe.com';

  @override
  String get comparison => 'השוואה';

  @override
  String get download => 'הורד';

  @override
  String get share => 'שתף';

  @override
  String get revertToOriginal => 'חזור למקור';

  @override
  String get loveItSave => 'אהבתי! שמור';

  @override
  String get creditsFinishedThisMonth => 'הקרדיטים נגמרו החודש';

  @override
  String get creditsRanOut => 'הקרדיטים נגמרו החודש';

  @override
  String get freeLimitReached => 'הגעת למגבלת השימוש החינמי';

  @override
  String get reachedFreeLimit => 'הגעת למגבלת השימוש החינמי';

  @override
  String creditsLimitReached(int limit) {
    return 'הגעת למגבלת הקרדיטים שלך ($limit קרדיטים). תוכל לשדרג לתוכנית גדולה יותר או לחכות עד החודש הבא.';
  }

  @override
  String freeCreditsUsed(int limit) {
    return 'השתמשת בכל $limit הקרדיטים החינמיים שלך. כדי להמשיך לעצב ללא הגבלות ולקבל תכונות מתקדמות, שדרג לתוכנית מקצועית.';
  }

  @override
  String get currentUsage => 'שימוש נוכחי';

  @override
  String get limit => 'מגבלה';

  @override
  String designs(int count) {
    return '$count עיצובים';
  }

  @override
  String designsCount(int count) {
    return '$count עיצובים';
  }

  @override
  String get upgradePlan => 'שדרג תוכנית';

  @override
  String get goToProfessionalPlan => 'עבור לתוכנית מקצועית';

  @override
  String get goPro => 'שדרג למקצועי';

  @override
  String get notNowThanks => 'לא עכשיו, תודה';

  @override
  String welcomeToPlan(String planName) {
    return 'ברוך הבא למנוי $planName!';
  }

  @override
  String get thankYouForJoining =>
      'תודה שהצטרפת למשפחת המנויים שלנו. החשבון שלך שודרג בהצלחה וכעת יש לך גישה לכל התכונות המתקדמות ולקרדיטים נוספים.';

  @override
  String get creditsAddedToYourAccount => 'קרדיטים נוספו לחשבונך';

  @override
  String get unlimitedStyleAccess => 'גישה ללא הגבלה לכל הסגנונות';

  @override
  String get supportCreators => 'תמיכה ביוצרים ומעצבים';

  @override
  String get startDesigning => 'התחל לעצב';

  @override
  String get secureYourSubscription => 'אבטח את המנוי שלך';

  @override
  String get secureSubscriptionMessage =>
      'כדי לא לאבד את המנוי שרכשת, אנחנו ממליצים להתחבר עם אימייל.\n\nכך תוכל לשחזר את המנוי במכשיר חדש או לאחר התקנה מחדש.';

  @override
  String get later => 'מאוחר יותר';

  @override
  String get loginNow => 'התחבר עכשיו';

  @override
  String get onboardingUploadTitle => 'העלה תמונה';

  @override
  String get onboardingUploadDesc =>
      'התחל בהעלאת תמונה של החדר שתרצה לעצב. אין לך תמונה? אל דאגה, נשתמש בתמונה לדוגמה.';

  @override
  String get onboardingStyleTitle => 'בחר עיצוב מחדש';

  @override
  String get onboardingStyleDesc =>
      'בחר את הסגנון המועדף עליך מהתפריט הצדדי. נסה \"עיצוב מחדש\" כדי לראות אפשרויות שונות.';

  @override
  String get onboardingCreateTitle => 'צור עיצוב';

  @override
  String get onboardingCreateDesc =>
      'לחץ על \"צור\" וה-AI יעצב מחדש את החדר שלך תוך שניות!';

  @override
  String get onboardingItemTipTitle => 'טיפ נוסף: העלה פריט';

  @override
  String get onboardingItemTipDesc =>
      'רוצה להוסיף רהיט ספציפי? השתמש בכפתור \"העלה פריט\" כדי להעלות תמונה של פריט ולשלב אותו בעיצוב.';

  @override
  String get skip => 'דלג';

  @override
  String get next => 'הבא';

  @override
  String get finish => 'סיום';

  @override
  String get promptAddedToInput => 'הפרומפט נוסף - ניתן לערוך ואז ללחוץ על צור';

  @override
  String get styleMediterranean => 'ים תיכוני מודרני';

  @override
  String get styleWarmMinimalism => 'מינימליזם חם';

  @override
  String get styleBiophilic => 'ביופילי';

  @override
  String get styleModernLuxury => 'יוקרה מודרנית';

  @override
  String get styleJapandi => 'יפנדי';

  @override
  String get styleScandinavian => 'סקנדינבי';

  @override
  String get styleBohoChic => 'בוהו שיק';

  @override
  String get styleIndustrial => 'תעשייתי';

  @override
  String get styleEarthyNatural => 'טבעי אדמתי';

  @override
  String get styleJerusalem => 'ירושלמי';

  @override
  String get styleMinimalist => 'מינימליסטי';

  @override
  String get styleModernClassic => 'קלאסי מודרני';

  @override
  String get colorCategoryReds => 'אדומים';

  @override
  String get colorCategoryOranges => 'כתומים';

  @override
  String get colorCategoryYellows => 'צהובים';

  @override
  String get colorCategoryGreens => 'ירוקים';

  @override
  String get colorCategoryBlues => 'כחולים';

  @override
  String get colorCategoryPurples => 'סגולים';

  @override
  String get colorCategoryGrays => 'אפורים';

  @override
  String get colorCategoryWhitesBlacks => 'לבנים ושחורים';

  @override
  String get lightingRecessed => 'תאורה שקועה';

  @override
  String get lightingPendant => 'מנורת תלייה';

  @override
  String get lightingChandelier => 'נברשת';

  @override
  String get lightingTableLamp => 'מנורת שולחן';

  @override
  String get lightingFloorLamp => 'מנורת רצפה';

  @override
  String get lightingWallSconce => 'מנורת קיר';

  @override
  String get lightingTrack => 'תאורת פס';

  @override
  String get lightingCeiling => 'גוף תאורה לתקרה';

  @override
  String get lightingUnderCabinet => 'תאורה מתחת לארון';

  @override
  String get lightingDecorative => 'תאורה דקורטיבית';

  @override
  String get lightingDay => 'יום';

  @override
  String get lightingNight => 'לילה';

  @override
  String get lightingSunset => 'שקיעה';

  @override
  String get lightingSunrise => 'זריחה';

  @override
  String get lightingAddRecessed => 'הוסף תאורה שקועה';

  @override
  String get lightingAddPendant => 'הוסף מנורת תלייה';

  @override
  String get lightingAddChandelier => 'הוסף נברשת';

  @override
  String get lightingAddTableLamp => 'הוסף מנורת שולחן';

  @override
  String get lightingAddFloorLamp => 'הוסף מנורת רצפה';

  @override
  String get lightingAddWallSconce => 'הוסף מנורת קיר';

  @override
  String get lightingAddTrack => 'הוסף תאורת פס';

  @override
  String get lightingAddCeiling => 'הוסף גוף תאורה לתקרה';

  @override
  String get lightingAddUnderCabinet => 'הוסף תאורה מתחת לארון';

  @override
  String get lightingAddDecorative => 'הוסף תאורה דקורטיבית';

  @override
  String get lightingChangeToDay => 'שנה תאורה לאור יום';

  @override
  String get lightingChangeToNight => 'שנה תאורה לאור לילה';

  @override
  String get lightingChangeToSunset => 'שנה תאורה לשקיעה';

  @override
  String get lightingChangeToSunrise => 'שנה תאורה לזריחה';

  @override
  String get furnitureSofa => 'ספה';

  @override
  String get furnitureSectional => 'ספה פינתית';

  @override
  String get furnitureArmchair => 'כורסה';

  @override
  String get furnitureAccentChair => 'כיסא נוי';

  @override
  String get furnitureDiningChair => 'כיסא אוכל';

  @override
  String get furnitureBarStool => 'כיסא בר';

  @override
  String get furnitureSingleBed => 'מיטת יחיד';

  @override
  String get furnitureDoubleBed => 'מיטה זוגית';

  @override
  String get furnitureBeanbag => 'פוף';

  @override
  String get furnitureOttoman => 'הדום';

  @override
  String get furnitureBench => 'ספסל';

  @override
  String get furnitureCoffeeTable => 'שולחן קפה';

  @override
  String get furnitureEndTable => 'שולחן צד';

  @override
  String get furnitureNightstand => 'שידת לילה';

  @override
  String get furnitureDiningTable => 'שולחן אוכל';

  @override
  String get furnitureDesk => 'שולחן כתיבה';

  @override
  String get furnitureDresser => 'שידה';

  @override
  String get furnitureWardrobe => 'ארון בגדים';

  @override
  String get furnitureBookcase => 'ספריה';

  @override
  String get furnitureTvStand => 'מזנון טלוויזיה';

  @override
  String get furnitureCabinets => 'ארונות מטבח';

  @override
  String get furnitureAddSofa => 'הוסף ספה';

  @override
  String get furnitureAddSectional => 'הוסף ספה פינתית';

  @override
  String get furnitureAddArmchair => 'הוסף כורסה';

  @override
  String get furnitureAddAccentChair => 'הוסף כיסא נוי';

  @override
  String get furnitureAddDiningChair => 'הוסף כיסא אוכל';

  @override
  String get furnitureAddBarStool => 'הוסף כיסא בר';

  @override
  String get furnitureAddSingleBed => 'הוסף מיטת יחיד';

  @override
  String get furnitureAddDoubleBed => 'הוסף מיטה זוגית';

  @override
  String get furnitureAddBeanbag => 'הוסף פוף';

  @override
  String get furnitureAddOttoman => 'הוסף הדום';

  @override
  String get furnitureAddBench => 'הוסף ספסל';

  @override
  String get furnitureAddCoffeeTable => 'הוסף שולחן קפה';

  @override
  String get furnitureAddEndTable => 'הוסף שולחן צד';

  @override
  String get furnitureAddNightstand => 'הוסף שידת לילה';

  @override
  String get furnitureAddDiningTable => 'הוסף שולחן אוכל';

  @override
  String get furnitureAddDesk => 'הוסף שולחן כתיבה';

  @override
  String get furnitureAddDresser => 'הוסף שידה';

  @override
  String get furnitureAddWardrobe => 'הוסף ארון בגדים';

  @override
  String get furnitureAddBookcase => 'הוסף ספריה';

  @override
  String get furnitureAddTvStand => 'הוסף מזנון טלוויזיה';

  @override
  String get furnitureAddCabinets => 'הוסף ארונות מטבח';

  @override
  String get repairsFixEverything => 'תקן הכל';

  @override
  String get repairsRepairAll => 'תקן ושפץ הכל';

  @override
  String get repairsMessUp => 'הרוס הכל';

  @override
  String get repairsDestroy => 'הרס וגרום נזק לכל דבר';

  @override
  String get windowPicture => 'חלון תמונה';

  @override
  String get windowSliding => 'חלון הזזה';

  @override
  String get windowCasement => 'חלון ציר';

  @override
  String get windowTiltTurn => 'חלון הטיה וסיבוב';

  @override
  String get windowAwning => 'חלון סוכך';

  @override
  String get windowSash => 'חלון אשנב';

  @override
  String get windowPocket => 'חלון כיס';

  @override
  String get windowArched => 'חלון קשתי';

  @override
  String get windowAddPicture => 'הוסף חלון תמונה גדול';

  @override
  String get windowAddSliding => 'הוסף חלון הזזה';

  @override
  String get windowAddCasement => 'הוסף חלון ציר';

  @override
  String get windowAddTiltTurn => 'הוסף חלון הטיה וסיבוב';

  @override
  String get windowAddAwning => 'הוסף חלון סוכך';

  @override
  String get windowAddSash => 'הוסף חלון אשנב';

  @override
  String get windowAddPocket => 'הוסף חלון כיס';

  @override
  String get windowAddArched => 'הוסף חלון קשתי';

  @override
  String get doorPocket => 'דלת כיס';

  @override
  String get doorFrench => 'דלתות צרפתיות';

  @override
  String get doorLouvered => 'דלת תריס';

  @override
  String get doorBarn => 'דלת אסם';

  @override
  String get doorAddPocket => 'הוסף דלת כיס נשלפת';

  @override
  String get doorAddFrench => 'הוסף דלתות צרפתיות עם זכוכית';

  @override
  String get doorAddLouvered => 'הוסף דלת תריס';

  @override
  String get doorAddBarn => 'הוסף דלת אסם';

  @override
  String get toiletBidet => 'בידה מחומם';

  @override
  String get toiletSeat => 'מושב אסלה';

  @override
  String get tubFreestanding => 'אמבטיה עומדת';

  @override
  String get tubVintage => 'אמבטיה וינטג\'';

  @override
  String get tubStandard => 'אמבטיה רגילה';

  @override
  String get showerRain => 'מקלחת גשם';

  @override
  String get showerEnclosure => 'מקלחון';

  @override
  String get showerSliding => 'דלתות מקלחון הזזה';

  @override
  String get sinkPedestal => 'כיור על עמוד';

  @override
  String get sinkStainless => 'כיור נירוסטה';

  @override
  String get sinkUndermount => 'כיור שקוע';

  @override
  String get jacuzziBuiltIn => 'ג\'קוזי מובנה';

  @override
  String get jacuzziPortable => 'ג\'קוזי נייד';

  @override
  String get poolInground => 'בריכה שקועה';

  @override
  String get poolAboveGround => 'בריכה על הקרקע';

  @override
  String get toiletAddBidet => 'הוסף מושב אסלה עם בידה';

  @override
  String get toiletAddSeat => 'הוסף מושב אסלה';

  @override
  String get tubAddFreestanding => 'הוסף אמבטיה עומדת';

  @override
  String get tubAddVintage => 'הוסף אמבטיה וינטג\'';

  @override
  String get tubAddStandard => 'הוסף אמבטיה רגילה';

  @override
  String get showerAddRain => 'הוסף מקלחת עם ראש גשם';

  @override
  String get showerAddEnclosure => 'הוסף מקלחון';

  @override
  String get showerAddSliding => 'הוסף מקלחון עם דלתות הזזה';

  @override
  String get sinkAddPedestal => 'הוסף כיור על עמוד';

  @override
  String get sinkAddStainless => 'הוסף כיור נירוסטה';

  @override
  String get sinkAddUndermount => 'הוסף כיור שקוע';

  @override
  String get jacuzziAddBuiltIn => 'הוסף ג\'קוזי מובנה';

  @override
  String get jacuzziAddPortable => 'הוסף ג\'קוזי נייד';

  @override
  String get poolAddInground => 'הוסף בריכה שקועה';

  @override
  String get poolAddAboveGround => 'הוסף בריכה על הקרקע';

  @override
  String get errorUnknown => 'שגיאה לא ידועה';

  @override
  String get searchWithLens => 'חיפוש';

  @override
  String get cancelSearch => 'ביטול';

  @override
  String get selectAreaToSearch => 'סמן מלבן סביב הפריט שברצונך לחפש';

  @override
  String get searchingWithGoogleLens => 'מחפש ב-Google Lens...';

  @override
  String get selectAreaWithinImage => 'בחר אזור בתוך התמונה';

  @override
  String get googleLensSearchFailed => 'החיפוש נכשל. נסה שוב.';

  @override
  String get rateAppTitle => 'נהנים מהאפליקציה?';

  @override
  String get rateAppMessage => 'נשמח לשמוע מה דעתך! המשוב שלך עוזר לנו להשתפר.';

  @override
  String get rateAppYes => 'כן, אני אוהב/ת! 😍';

  @override
  String get rateAppNo => 'לא ממש';

  @override
  String get rateAppLater => 'תשאל אותי אחר כך';

  @override
  String get deleteAccount => 'מחיקת חשבון';

  @override
  String get deleteAccountWarning1Title => 'מחיקת חשבון';

  @override
  String get deleteAccountWarning1Message =>
      'האם אתה בטוח שברצונך למחוק את החשבון שלך? פעולה זו תמחק את כל המידע והתמונות שלך ולא ניתן יהיה לשחזר אותם.';

  @override
  String get deleteAccountWarning2Title => 'אישור סופי';

  @override
  String get deleteAccountWarning2Message =>
      'זו פעולה בלתי הפיכה! כל ההיסטוריה והתמונות שלך יימחקו לצמיתות. האם אתה בטוח ב-100%?';

  @override
  String get deleteAccountConfirm => 'כן, מחק את החשבון';

  @override
  String get deletingAccount => 'מוחק חשבון...';

  @override
  String get accountDeleted => 'החשבון נמחק בהצלחה';

  @override
  String get errorDeletingAccount => 'שגיאה במחיקת החשבון';

  @override
  String get language => 'שפה';

  @override
  String get selectLanguage => 'בחר שפה';

  @override
  String get languageChanged => 'השפה השתנתה';

  @override
  String get createAccountPromptTitle => 'צור את החשבון שלך';

  @override
  String get createAccountPromptMessage =>
      'עדכונים מדהימים מגיעים בשבועות הקרובים! 🚀\n\nצור חשבון עכשיו כדי לא לאבד את היצירות שלך ולהיות הראשון ליהנות מהתכונות החדשות.';

  @override
  String get createAccountPromptButton => 'צור חשבון';

  @override
  String get maybeLater => 'אולי מאוחר יותר';

  @override
  String get readyDesigns => 'גלריית עיצובים';

  @override
  String get noCategories => 'אין קטגוריות';

  @override
  String get noDesigns => 'בקרוב...';

  @override
  String get noDesignsInCategory => 'עיצובים חדשים יתווספו כאן';

  @override
  String get loadingDesigns => 'טוען עיצובים...';

  @override
  String get loading => 'טוען...';

  @override
  String get categoryKitchen => 'מטבח';

  @override
  String get categoryKidsBedroom => 'חדר ילדים';

  @override
  String get categoryBathroom => 'חדר אמבטיה';

  @override
  String get categoryLivingRoom => 'סלון';

  @override
  String get categoryMasterBedroom => 'חדר שינה ראשי';

  @override
  String get useDesignQuestion => 'להשתמש בעיצוב הזה?';

  @override
  String get yes => 'כן';

  @override
  String get no => 'לא';

  @override
  String get featureCarouselTitle1 => 'עיצוב מונע בינה מלאכותית';

  @override
  String get featureCarouselSubtitle1 => '✨ עיצוב מחדש חכם';

  @override
  String get featureCarouselDesc1 =>
      'שנו כל חדר עם AI מתקדם. פשוט העלו תמונה וצפו בחלל שלכם מתעורר לחיים עם עיצובים ברמה מקצועית.';

  @override
  String get featureCarouselTitle2 => 'אפשרויות אינסופיות';

  @override
  String get featureCarouselSubtitle2 => '🎨 סגנונות וצבעים';

  @override
  String get featureCarouselDesc2 =>
      'ממינימליזם מודרני ועד בוהמי נעים - גלו עשרות סגנונות עיצוב ופלטות צבעים המותאמות לטעם שלכם.';

  @override
  String get featureCarouselTitle3 => 'תוצאות מיידיות';

  @override
  String get featureCarouselSubtitle3 => '⚡ שניות, לא שעות';

  @override
  String get featureCarouselDesc3 =>
      'מה שנהג לקחת למעצבים שעות קורה עכשיו בשניות. קבלו שינויים מדהימים של לפני ואחרי מיד.';

  @override
  String get getStarted => 'בואו נתחיל';

  @override
  String freeTrialDays(int days) {
    return '$days ימים ניסיון חינם';
  }

  @override
  String thenPrice(Object price) {
    return 'ואז $price/חודש';
  }
}
