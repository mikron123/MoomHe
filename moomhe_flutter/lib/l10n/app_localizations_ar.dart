// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'خبير AI';

  @override
  String get appName => 'خبير';

  @override
  String get guest => 'ضيف';

  @override
  String get loginToSaveDesigns => 'سجل الدخول لحفظ تصاميمك';

  @override
  String get loggedOutSuccess => 'تم تسجيل الخروج بنجاح';

  @override
  String get uploadImage => 'رفع صورة';

  @override
  String get clickToUploadImage => 'انقر هنا لرفع صورة من المعرض';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String get uploadItem => 'إضافة عنصر';

  @override
  String get redesign => 'إعادة التصميم';

  @override
  String get more => 'المزيد';

  @override
  String get moreOptions => 'خيارات إضافية';

  @override
  String get history => 'السجل';

  @override
  String get noHistoryYet => 'لا يوجد سجل بعد';

  @override
  String get uploadedImagesWillAppear => 'ستظهر هنا الصور التي ترفعها وتعدلها';

  @override
  String get whatToChange => 'ماذا تريد تغييره؟';

  @override
  String get uploadImageFirst => 'يرجى رفع صورة أولاً';

  @override
  String get uploadingImage => 'جاري رفع الصورة...';

  @override
  String get errorUploadingImage => 'خطأ في رفع الصورة';

  @override
  String get itemImageLoaded =>
      'تم تحميل صورة العنصر! صف في الأمر أين تريد إضافته.';

  @override
  String get addAttachedItem => 'أضف العنصر المرفق إلى الصورة';

  @override
  String get processingStarting => 'جاري البدء...';

  @override
  String get processingMagic => 'السحر يحدث الآن';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get connectingToCloud => 'جاري الاتصال بالسحابة... ☁️';

  @override
  String get sendingToAI => 'جاري الإرسال للذكاء الاصطناعي... 🤖';

  @override
  String get analyzingItem => 'جاري تحليل العنصر... 🔍';

  @override
  String get creatingDesign => 'جاري إنشاء التصميم... ✨';

  @override
  String get funPhrase1 => 'إرسال الصورة عبر بُعد آخر... 🌀';

  @override
  String get funPhrase2 => 'تعليم الذكاء الاصطناعي تقدير التصميم الجيد... 🎨';

  @override
  String get funPhrase3 => 'إقناع البكسلات بالتعاون... 🤝';

  @override
  String get funPhrase4 => 'القليل من السحر الرقمي في الطريق... ✨';

  @override
  String get funPhrase5 => 'نسأل الذكاء الاصطناعي عن رأيه... 🤔';

  @override
  String get funPhrase6 => 'خلط الألوان كفنان حقيقي... 🖌️';

  @override
  String get funPhrase7 => 'حساب الزاوية المثالية... 📐';

  @override
  String get funPhrase8 => 'إضافة بعض الأناقة لحياتك... 💫';

  @override
  String get funPhrase9 => 'جعل الغرفة تبدو أكثر فخامة... 💎';

  @override
  String get funPhrase10 => 'تفعيل سحر التصميم... 🪄';

  @override
  String get funPhrase11 => 'استشارة مصممي الديكور الرقميين... 🏠';

  @override
  String get funPhrase12 => 'محاولة عدم الحماس الزائد للنتيجة... 😍';

  @override
  String get funPhrase13 => 'سترى شيئاً مذهلاً بعد لحظات... 🚀';

  @override
  String get funPhrase14 => 'التأكد من أن كل شيء مثالي لك... 👌';

  @override
  String get designStyle => 'نمط التصميم';

  @override
  String get wallColor => 'تغيير اللون';

  @override
  String get lighting => 'الإضاءة';

  @override
  String get furniture => 'الأثاث';

  @override
  String get doorsWindows => 'الأبواب والنوافذ';

  @override
  String get bathroom => 'الحمام';

  @override
  String get repairs => 'الإصلاحات';

  @override
  String get general => 'عام';

  @override
  String get selectDesignStyle => 'اختر نمط التصميم';

  @override
  String get colorPalette => 'لوحة الألوان';

  @override
  String get selectLightingType => 'اختر نوع الإضاءة';

  @override
  String get selectFurnitureType => 'اختر نوع الأثاث';

  @override
  String get selectRepairType => 'اختر نوع الإصلاح/الضرر';

  @override
  String get bathroomOptions => 'خيارات الحمام';

  @override
  String changeStyleTo(String styleName) {
    return 'تغيير النمط إلى $styleName';
  }

  @override
  String get whatToDo => 'ماذا تريد أن تفعل؟';

  @override
  String get describeChange => 'صف التغيير المطلوب...';

  @override
  String get cancel => 'إلغاء';

  @override
  String get execute => 'تنفيذ';

  @override
  String comingSoon(String feature) {
    return '$feature - قريباً!';
  }

  @override
  String get colorChange => 'تغيير اللون';

  @override
  String get allWalls => 'جميع الجدران';

  @override
  String get paintAllWalls => 'طلاء جميع جدران الغرفة';

  @override
  String get specificObject => 'عنصر محدد';

  @override
  String get selectWhatToPaint => 'اختر ما تريد طلاءه';

  @override
  String get exampleObjects => 'مثال: أريكة، سقف، خزانة...';

  @override
  String get confirm => 'تأكيد';

  @override
  String get windowOptions => 'خيارات النوافذ';

  @override
  String get doorOptions => 'خيارات الأبواب';

  @override
  String get toiletOptions => 'خيارات المرحاض';

  @override
  String get bathtubOptions => 'خيارات حوض الاستحمام';

  @override
  String get showerOptions => 'خيارات الدش';

  @override
  String get sinkOptions => 'خيارات المغسلة';

  @override
  String get jacuzziOptions => 'خيارات الجاكوزي/السبا';

  @override
  String get poolOptions => 'خيارات المسبح';

  @override
  String get professionalSubscription => 'الخطة الاحترافية';

  @override
  String get specialLaunchPrices => 'أسعار إطلاق خاصة 🚀';

  @override
  String get purchaseFailed => 'فشلت عملية الشراء';

  @override
  String get yourCurrentPlan => 'خطتك الحالية';

  @override
  String get selectPlan => 'اختر الخطة';

  @override
  String get perMonth => '/شهر';

  @override
  String get starterPlan => 'المبتدئ';

  @override
  String get valuePlan => 'القيمة';

  @override
  String get proPlan => 'الاحترافي';

  @override
  String imagesPerMonth(int count) {
    return '$count صورة شهرياً';
  }

  @override
  String get whatsappSupport => 'دعم واتساب';

  @override
  String get historyStorage => 'تخزين السجل';

  @override
  String get vipWhatsappSupport => 'دعم واتساب VIP';

  @override
  String get processingPriority => 'أولوية المعالجة';

  @override
  String get bestValue => 'أفضل قيمة: 4 أضعاف الصور! 🔥';

  @override
  String get forProfessionals => 'للمحترفين ⭐';

  @override
  String savePerImage(String percent) {
    return 'وفر $percent% لكل صورة';
  }

  @override
  String get allDesignTools => 'جميع أدوات التصميم';

  @override
  String get fastSupport => 'دعم سريع';

  @override
  String get noAds => 'بدون إعلانات';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get createNewAccount => 'حساب جديد';

  @override
  String get welcomeBack => 'مرحباً بعودتك! سجل الدخول للمتابعة';

  @override
  String get joinUs => 'انضم إلينا لحفظ التصاميم والوصول لجميع الميزات';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get passwordsNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get enterEmailFirst => 'يرجى إدخال عنوان البريد الإلكتروني أولاً';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox and spam folder.';

  @override
  String get passwordResetError => 'Error sending password reset email';

  @override
  String get termsAgreement => 'بتسجيل الدخول فإنك توافق على';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get and => 'و';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-ar.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-ar.html';

  @override
  String get loggingIn => 'جاري تسجيل الدخول...';

  @override
  String get creatingAccount => 'جاري إنشاء الحساب...';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح! 🎉';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح! 🎉';

  @override
  String get loginError => 'خطأ في تسجيل الدخول';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get wrongPassword => 'كلمة مرور خاطئة';

  @override
  String get emailInUse => 'البريد الإلكتروني مستخدم بالفعل';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جداً';

  @override
  String get invalidEmail => 'عنوان بريد إلكتروني غير صالح';

  @override
  String get exitAccount => 'الخروج من الحساب';

  @override
  String get loginWithEmail => 'سجل الدخول بالبريد الإلكتروني لحفظ تصاميمك';

  @override
  String get mySubscription => 'اشتراكي';

  @override
  String creditsRemaining(int count) {
    return '$count رصيد متبقي';
  }

  @override
  String get upgradeToPremium => 'الترقية للمميز';

  @override
  String get iHaveCoupon => 'لدي قسيمة';

  @override
  String get enterCouponCode => 'أدخل رمز القسيمة للحصول على رصيد مجاني';

  @override
  String get enterCouponCodeTitle => 'أدخل رمز القسيمة';

  @override
  String get enterCouponCodeSubtitle =>
      'أدخل رمز القسيمة الذي حصلت عليه للحصول على رصيد مجاني';

  @override
  String get couponCode => 'رمز القسيمة';

  @override
  String get mustEnterCoupon => 'يجب إدخال رمز القسيمة';

  @override
  String get couponActivated => 'تم تفعيل القسيمة بنجاح!';

  @override
  String get errorRedeemingCoupon => 'خطأ في استرداد القسيمة';

  @override
  String get redeemCoupon => 'استرداد القسيمة';

  @override
  String creditsAddedToAccount(int count) {
    return 'تمت إضافة $count رصيد لحسابك! 🎉';
  }

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get contactSubtitle =>
      'نحب أن نسمع منك! املأ التفاصيل وسنرد عليك قريباً.';

  @override
  String get phone => 'الهاتف';

  @override
  String get message => 'الرسالة';

  @override
  String get writeYourMessage => 'اكتب رسالتك هنا...';

  @override
  String get enterPhoneOrEmail =>
      '* يرجى إدخال الهاتف أو البريد الإلكتروني على الأقل';

  @override
  String get pleaseEnterPhoneOrEmail =>
      'يرجى إدخال الهاتف أو البريد الإلكتروني على الأقل';

  @override
  String get pleaseEnterMessage => 'يرجى إدخال رسالة';

  @override
  String get errorSendingMessage =>
      'خطأ في إرسال الرسالة. يرجى المحاولة مرة أخرى.';

  @override
  String get sendMessage => 'إرسال الرسالة';

  @override
  String get messageSentSuccess => 'تم إرسال الرسالة بنجاح!';

  @override
  String get contentNotAllowed => 'المحتوى غير مسموح';

  @override
  String get requestFailed => 'فشل الطلب';

  @override
  String get oopsSomethingWrong => 'عفواً! حدث خطأ ما';

  @override
  String get moderationError =>
      'لا يمكن معالجة هذه الصورة أو الطلب.\n\nقد تحتوي الصورة أو الطلب على محتوى غير مسموح بمعالجته.\n\nجرب صورة مختلفة أو غير الطلب.';

  @override
  String get timeoutError =>
      'استغرق الطلب وقتاً طويلاً.\n\nيرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get genericError =>
      'لم نتمكن من معالجة الطلب.\n\nحاول مرة أخرى أو اتصل بالدعم إذا استمرت المشكلة.';

  @override
  String get close => 'إغلاق';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get imageSavedToGallery => 'تم حفظ الصورة في المعرض!';

  @override
  String get errorDownloadingImage => 'خطأ في تحميل الصورة';

  @override
  String get errorSharing => 'خطأ في المشاركة';

  @override
  String get shareText =>
      '🏠 صممت هذا باستخدام MoomHe AI!\n📸 تريد تجربته أيضاً؟ https://moomhe.com';

  @override
  String get comparison => 'مقارنة';

  @override
  String get download => 'تحميل';

  @override
  String get share => 'مشاركة';

  @override
  String get revertToOriginal => 'العودة للأصلي';

  @override
  String get loveItSave => 'أحببته! حفظ';

  @override
  String get creditsFinishedThisMonth => 'انتهى الرصيد لهذا الشهر';

  @override
  String get creditsRanOut => 'نفد الرصيد لهذا الشهر';

  @override
  String get freeLimitReached => 'لقد وصلت لحد الاستخدام المجاني';

  @override
  String get reachedFreeLimit => 'لقد وصلت لحد الاستخدام المجاني';

  @override
  String creditsLimitReached(int limit) {
    return 'لقد وصلت لحد الرصيد ($limit رصيد). يمكنك الترقية لخطة أكبر أو الانتظار حتى الشهر القادم.';
  }

  @override
  String freeCreditsUsed(int limit) {
    return 'لقد استخدمت كل الـ $limit رصيد المجاني. للمتابعة في التصميم بدون حدود والحصول على ميزات متقدمة، قم بالترقية للخطة الاحترافية.';
  }

  @override
  String get currentUsage => 'الاستخدام الحالي';

  @override
  String get limit => 'الحد';

  @override
  String designs(int count) {
    return '$count تصميم';
  }

  @override
  String designsCount(int count) {
    return '$count تصميم';
  }

  @override
  String get upgradePlan => 'ترقية الخطة';

  @override
  String get goToProfessionalPlan => 'الانتقال للخطة الاحترافية';

  @override
  String get goPro => 'اشترك بالاحترافي';

  @override
  String get notNowThanks => 'ليس الآن، شكراً';

  @override
  String welcomeToPlan(String planName) {
    return 'مرحباً بك في خطة $planName!';
  }

  @override
  String get thankYouForJoining =>
      'شكراً لانضمامك لعائلة المشتركين. تمت ترقية حسابك بنجاح ولديك الآن وصول لجميع الميزات المتقدمة والرصيد الإضافي.';

  @override
  String get creditsAddedToYourAccount => 'تمت إضافة رصيد لحسابك';

  @override
  String get unlimitedStyleAccess => 'وصول غير محدود لجميع الأنماط';

  @override
  String get supportCreators => 'دعم للمبدعين والمصممين';

  @override
  String get startDesigning => 'ابدأ التصميم';

  @override
  String get secureYourSubscription => 'أمّن اشتراكك';

  @override
  String get secureSubscriptionMessage =>
      'لعدم فقدان الاشتراك الذي اشتريته، نوصي بتسجيل الدخول بالبريد الإلكتروني.\n\nبهذه الطريقة يمكنك استعادة اشتراكك على جهاز جديد أو بعد إعادة التثبيت.';

  @override
  String get later => 'لاحقاً';

  @override
  String get loginNow => 'سجل الدخول الآن';

  @override
  String get onboardingUploadTitle => 'رفع صورة';

  @override
  String get onboardingUploadDesc =>
      'ابدأ برفع صورة للغرفة التي تريد تصميمها. ليس لديك صورة؟ لا مشكلة، سنستخدم صورة نموذجية.';

  @override
  String get onboardingStyleTitle => 'اختر نمط إعادة التصميم';

  @override
  String get onboardingStyleDesc =>
      'اختر النمط المفضل لديك من القائمة الجانبية. جرب \"إعادة التصميم\" لرؤية خيارات مختلفة.';

  @override
  String get onboardingCreateTitle => 'إنشاء التصميم';

  @override
  String get onboardingCreateDesc =>
      'انقر \"إنشاء\" وسيعيد الذكاء الاصطناعي تصميم غرفتك في ثوانٍ!';

  @override
  String get onboardingItemTipTitle => 'نصيحة إضافية: إضافة عنصر';

  @override
  String get onboardingItemTipDesc =>
      'تريد إضافة قطعة أثاث محددة؟ استخدم زر \"إضافة عنصر\" لرفع صورة عنصر ودمجه في التصميم.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get finish => 'إنهاء';

  @override
  String get promptAddedToInput =>
      'تمت إضافة الأمر - يمكنك تعديله ثم انقر إنشاء';

  @override
  String get styleMediterranean => 'متوسطي حديث';

  @override
  String get styleWarmMinimalism => 'بساطة دافئة';

  @override
  String get styleBiophilic => 'بيوفيلي';

  @override
  String get styleModernLuxury => 'فخامة حديثة';

  @override
  String get styleJapandi => 'جاباندي';

  @override
  String get styleScandinavian => 'اسكندنافي';

  @override
  String get styleBohoChic => 'بوهو شيك';

  @override
  String get styleIndustrial => 'صناعي';

  @override
  String get styleEarthyNatural => 'طبيعي ترابي';

  @override
  String get styleJerusalem => 'قدسي';

  @override
  String get styleMinimalist => 'بسيط';

  @override
  String get styleModernClassic => 'كلاسيكي حديث';

  @override
  String get colorCategoryReds => 'الأحمر';

  @override
  String get colorCategoryOranges => 'البرتقالي';

  @override
  String get colorCategoryYellows => 'الأصفر';

  @override
  String get colorCategoryGreens => 'الأخضر';

  @override
  String get colorCategoryBlues => 'الأزرق';

  @override
  String get colorCategoryPurples => 'البنفسجي';

  @override
  String get colorCategoryGrays => 'الرمادي';

  @override
  String get colorCategoryWhitesBlacks => 'الأبيض والأسود';

  @override
  String get lightingRecessed => 'إضاءة غائرة';

  @override
  String get lightingPendant => 'مصباح معلق';

  @override
  String get lightingChandelier => 'ثريا';

  @override
  String get lightingTableLamp => 'مصباح طاولة';

  @override
  String get lightingFloorLamp => 'مصباح أرضي';

  @override
  String get lightingWallSconce => 'شمعدان حائط';

  @override
  String get lightingTrack => 'إضاءة مسار';

  @override
  String get lightingCeiling => 'تركيبة سقف';

  @override
  String get lightingUnderCabinet => 'إضاءة أسفل الخزانة';

  @override
  String get lightingDecorative => 'أضواء ديكورية';

  @override
  String get lightingDay => 'نهار';

  @override
  String get lightingNight => 'ليل';

  @override
  String get lightingSunset => 'غروب';

  @override
  String get lightingSunrise => 'شروق';

  @override
  String get lightingAddRecessed => 'إضافة إضاءة غائرة';

  @override
  String get lightingAddPendant => 'إضافة مصباح معلق';

  @override
  String get lightingAddChandelier => 'إضافة ثريا';

  @override
  String get lightingAddTableLamp => 'إضافة مصباح طاولة';

  @override
  String get lightingAddFloorLamp => 'إضافة مصباح أرضي';

  @override
  String get lightingAddWallSconce => 'إضافة شمعدان حائط';

  @override
  String get lightingAddTrack => 'إضافة إضاءة مسار';

  @override
  String get lightingAddCeiling => 'إضافة تركيبة سقف';

  @override
  String get lightingAddUnderCabinet => 'إضافة إضاءة أسفل الخزانة';

  @override
  String get lightingAddDecorative => 'إضافة أضواء ديكورية';

  @override
  String get lightingChangeToDay => 'تغيير الإضاءة لضوء النهار';

  @override
  String get lightingChangeToNight => 'تغيير الإضاءة لضوء الليل';

  @override
  String get lightingChangeToSunset => 'تغيير الإضاءة للغروب';

  @override
  String get lightingChangeToSunrise => 'تغيير الإضاءة للشروق';

  @override
  String get furnitureSofa => 'أريكة';

  @override
  String get furnitureSectional => 'أريكة زاوية';

  @override
  String get furnitureArmchair => 'كرسي بذراعين';

  @override
  String get furnitureAccentChair => 'كرسي مميز';

  @override
  String get furnitureDiningChair => 'كرسي طعام';

  @override
  String get furnitureBarStool => 'كرسي بار';

  @override
  String get furnitureSingleBed => 'سرير مفرد';

  @override
  String get furnitureDoubleBed => 'سرير مزدوج';

  @override
  String get furnitureBeanbag => 'كيس فول';

  @override
  String get furnitureOttoman => 'عثماني';

  @override
  String get furnitureBench => 'مقعد';

  @override
  String get furnitureCoffeeTable => 'طاولة قهوة';

  @override
  String get furnitureEndTable => 'طاولة جانبية';

  @override
  String get furnitureNightstand => 'طاولة سرير';

  @override
  String get furnitureDiningTable => 'طاولة طعام';

  @override
  String get furnitureDesk => 'مكتب';

  @override
  String get furnitureDresser => 'خزانة أدراج';

  @override
  String get furnitureWardrobe => 'خزانة ملابس';

  @override
  String get furnitureBookcase => 'مكتبة';

  @override
  String get furnitureTvStand => 'حامل تلفزيون';

  @override
  String get furnitureCabinets => 'خزائن مطبخ';

  @override
  String get furnitureAddSofa => 'إضافة أريكة';

  @override
  String get furnitureAddSectional => 'إضافة أريكة زاوية';

  @override
  String get furnitureAddArmchair => 'إضافة كرسي بذراعين';

  @override
  String get furnitureAddAccentChair => 'إضافة كرسي مميز';

  @override
  String get furnitureAddDiningChair => 'إضافة كرسي طعام';

  @override
  String get furnitureAddBarStool => 'إضافة كرسي بار';

  @override
  String get furnitureAddSingleBed => 'إضافة سرير مفرد';

  @override
  String get furnitureAddDoubleBed => 'إضافة سرير مزدوج';

  @override
  String get furnitureAddBeanbag => 'إضافة كيس فول';

  @override
  String get furnitureAddOttoman => 'إضافة عثماني';

  @override
  String get furnitureAddBench => 'إضافة مقعد';

  @override
  String get furnitureAddCoffeeTable => 'إضافة طاولة قهوة';

  @override
  String get furnitureAddEndTable => 'إضافة طاولة جانبية';

  @override
  String get furnitureAddNightstand => 'إضافة طاولة سرير';

  @override
  String get furnitureAddDiningTable => 'إضافة طاولة طعام';

  @override
  String get furnitureAddDesk => 'إضافة مكتب';

  @override
  String get furnitureAddDresser => 'إضافة خزانة أدراج';

  @override
  String get furnitureAddWardrobe => 'إضافة خزانة ملابس';

  @override
  String get furnitureAddBookcase => 'إضافة مكتبة';

  @override
  String get furnitureAddTvStand => 'إضافة حامل تلفزيون';

  @override
  String get furnitureAddCabinets => 'إضافة خزائن مطبخ';

  @override
  String get repairsFixEverything => 'إصلاح كل شيء';

  @override
  String get repairsRepairAll => 'إصلاح وترميم كل شيء';

  @override
  String get repairsMessUp => 'إفساد كل شيء';

  @override
  String get repairsDestroy => 'تدمير وإحداث ضرر لكل شيء';

  @override
  String get windowPicture => 'نافذة بانورامية';

  @override
  String get windowSliding => 'نافذة منزلقة';

  @override
  String get windowCasement => 'نافذة مفصلية';

  @override
  String get windowTiltTurn => 'نافذة إمالة ودوران';

  @override
  String get windowAwning => 'نافذة مظلة';

  @override
  String get windowSash => 'نافذة ساش';

  @override
  String get windowPocket => 'نافذة جيب';

  @override
  String get windowArched => 'نافذة مقوسة';

  @override
  String get windowAddPicture => 'إضافة نافذة بانورامية كبيرة';

  @override
  String get windowAddSliding => 'إضافة نافذة منزلقة';

  @override
  String get windowAddCasement => 'إضافة نافذة مفصلية';

  @override
  String get windowAddTiltTurn => 'إضافة نافذة إمالة ودوران';

  @override
  String get windowAddAwning => 'إضافة نافذة مظلة';

  @override
  String get windowAddSash => 'إضافة نافذة ساش';

  @override
  String get windowAddPocket => 'إضافة نافذة جيب';

  @override
  String get windowAddArched => 'إضافة نافذة مقوسة';

  @override
  String get doorPocket => 'باب جيب';

  @override
  String get doorFrench => 'أبواب فرنسية';

  @override
  String get doorLouvered => 'باب مشربية';

  @override
  String get doorBarn => 'باب حظيرة';

  @override
  String get doorAddPocket => 'إضافة باب جيب ينزلق في الحائط';

  @override
  String get doorAddFrench => 'إضافة أبواب فرنسية بزجاج';

  @override
  String get doorAddLouvered => 'إضافة باب مشربية';

  @override
  String get doorAddBarn => 'إضافة باب حظيرة';

  @override
  String get toiletBidet => 'بيديه ساخن';

  @override
  String get toiletSeat => 'مقعد مرحاض';

  @override
  String get tubFreestanding => 'حوض استحمام قائم';

  @override
  String get tubVintage => 'حوض استحمام عتيق';

  @override
  String get tubStandard => 'حوض استحمام قياسي';

  @override
  String get showerRain => 'دش مطري';

  @override
  String get showerEnclosure => 'حجرة دش';

  @override
  String get showerSliding => 'أبواب دش منزلقة';

  @override
  String get sinkPedestal => 'مغسلة عمود';

  @override
  String get sinkStainless => 'مغسلة ستانلس ستيل';

  @override
  String get sinkUndermount => 'مغسلة مدمجة';

  @override
  String get jacuzziBuiltIn => 'جاكوزي مدمج';

  @override
  String get jacuzziPortable => 'جاكوزي متنقل';

  @override
  String get poolInground => 'مسبح أرضي';

  @override
  String get poolAboveGround => 'مسبح فوق الأرض';

  @override
  String get toiletAddBidet => 'إضافة مقعد مرحاض مع بيديه';

  @override
  String get toiletAddSeat => 'إضافة مقعد مرحاض';

  @override
  String get tubAddFreestanding => 'إضافة حوض استحمام قائم';

  @override
  String get tubAddVintage => 'إضافة حوض استحمام عتيق';

  @override
  String get tubAddStandard => 'إضافة حوض استحمام قياسي';

  @override
  String get showerAddRain => 'إضافة دش برأس مطري';

  @override
  String get showerAddEnclosure => 'إضافة حجرة دش';

  @override
  String get showerAddSliding => 'إضافة دش بأبواب منزلقة';

  @override
  String get sinkAddPedestal => 'إضافة مغسلة عمود';

  @override
  String get sinkAddStainless => 'إضافة مغسلة ستانلس ستيل';

  @override
  String get sinkAddUndermount => 'إضافة مغسلة مدمجة';

  @override
  String get jacuzziAddBuiltIn => 'إضافة جاكوزي مدمج';

  @override
  String get jacuzziAddPortable => 'إضافة جاكوزي متنقل';

  @override
  String get poolAddInground => 'إضافة مسبح أرضي';

  @override
  String get poolAddAboveGround => 'إضافة مسبح فوق الأرض';

  @override
  String get errorUnknown => 'خطأ غير معروف';

  @override
  String get searchWithLens => 'بحث';

  @override
  String get cancelSearch => 'إلغاء';

  @override
  String get selectAreaToSearch =>
      'ارسم مستطيلاً حول العنصر الذي تريد البحث عنه';

  @override
  String get searchingWithGoogleLens => 'جاري البحث بـ Google Lens...';

  @override
  String get selectAreaWithinImage => 'يرجى تحديد منطقة داخل الصورة';

  @override
  String get googleLensSearchFailed => 'فشل البحث. يرجى المحاولة مرة أخرى.';

  @override
  String get rateAppTitle => 'هل تستمتع بالتطبيق؟';

  @override
  String get rateAppMessage =>
      'نحب أن نسمع رأيك! ملاحظاتك تساعدنا على التحسين.';

  @override
  String get rateAppYes => 'نعم، أحبه! 😍';

  @override
  String get rateAppNo => 'ليس حقاً';

  @override
  String get rateAppLater => 'اسألني لاحقاً';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountWarning1Title => 'حذف الحساب';

  @override
  String get deleteAccountWarning1Message =>
      'هل أنت متأكد من رغبتك في حذف حسابك؟ سيتم حذف جميع معلوماتك وصورك ولا يمكن التراجع عن ذلك.';

  @override
  String get deleteAccountWarning2Title => 'تأكيد نهائي';

  @override
  String get deleteAccountWarning2Message =>
      'هذا الإجراء لا يمكن التراجع عنه! سيتم حذف كل سجلك وصورك نهائياً. هل أنت متأكد 100%؟';

  @override
  String get deleteAccountConfirm => 'نعم، احذف الحساب';

  @override
  String get deletingAccount => 'جاري حذف الحساب...';

  @override
  String get accountDeleted => 'تم حذف الحساب بنجاح';

  @override
  String get errorDeletingAccount => 'خطأ في حذف الحساب';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get languageChanged => 'تم تغيير اللغة';
}
