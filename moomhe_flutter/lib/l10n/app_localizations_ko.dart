// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Expert AI';

  @override
  String get appName => 'Expert';

  @override
  String get guest => '게스트';

  @override
  String get loginToSaveDesigns => '디자인을 저장하려면 로그인하세요';

  @override
  String get loggedOutSuccess => '로그아웃되었습니다';

  @override
  String get uploadImage => '이미지 업로드';

  @override
  String get clickToUploadImage => '여기를 클릭하여 갤러리에서 이미지 업로드';

  @override
  String get gallery => '갤러리';

  @override
  String get camera => '카메라';

  @override
  String get uploadItem => '아이템 추가';

  @override
  String get redesign => '리디자인';

  @override
  String get more => '더보기';

  @override
  String get moreOptions => '더 많은 옵션';

  @override
  String get history => '기록';

  @override
  String get noHistoryYet => '아직 기록이 없습니다';

  @override
  String get uploadedImagesWillAppear => '업로드하고 편집한 이미지가 여기에 표시됩니다';

  @override
  String get whatToChange => '무엇을 변경할까요?';

  @override
  String get uploadImageFirst => '먼저 이미지를 업로드해주세요';

  @override
  String get uploadingImage => '이미지 업로드 중...';

  @override
  String get errorUploadingImage => '이미지 업로드 오류';

  @override
  String get itemImageLoaded => '아이템 이미지가 로드되었습니다! 프롬프트에서 어디에 추가할지 설명해주세요.';

  @override
  String get addAttachedItem => '첨부된 아이템을 이미지에 추가';

  @override
  String get processingStarting => '시작 중...';

  @override
  String get processingMagic => '마법이 일어나고 있습니다';

  @override
  String get processing => '처리 중...';

  @override
  String get connectingToCloud => '클라우드에 연결 중... ☁️';

  @override
  String get sendingToAI => 'AI에 전송 중... 🤖';

  @override
  String get analyzingItem => '아이템 분석 중... 🔍';

  @override
  String get creatingDesign => '디자인 생성 중... ✨';

  @override
  String get funPhrase1 => '이미지를 다른 차원으로 보내는 중... 🌀';

  @override
  String get funPhrase2 => 'AI에게 좋은 디자인을 가르치는 중... 🎨';

  @override
  String get funPhrase3 => '픽셀들을 설득하는 중... 🤝';

  @override
  String get funPhrase4 => '디지털 마법 진행 중... ✨';

  @override
  String get funPhrase5 => 'AI에게 의견을 묻는 중... 🤔';

  @override
  String get funPhrase6 => '진짜 아티스트처럼 색을 섞는 중... 🖌️';

  @override
  String get funPhrase7 => '완벽한 각도를 계산 중... 📐';

  @override
  String get funPhrase8 => '당신의 삶에 스타일을 추가하는 중... 💫';

  @override
  String get funPhrase9 => '방을 더 고급스럽게 만드는 중... 💎';

  @override
  String get funPhrase10 => '디자인 마법 활성화 중... 🪄';

  @override
  String get funPhrase11 => '디지털 인테리어 디자이너와 상담 중... 🏠';

  @override
  String get funPhrase12 => '결과에 너무 흥분하지 않으려고 노력 중... 😍';

  @override
  String get funPhrase13 => '곧 놀라운 것을 보게 될 거예요... 🚀';

  @override
  String get funPhrase14 => '모든 것이 완벽하도록 확인 중... 👌';

  @override
  String get designStyle => '디자인 스타일';

  @override
  String get wallColor => '색상 변경';

  @override
  String get lighting => '조명';

  @override
  String get furniture => '가구';

  @override
  String get doorsWindows => '문과 창문';

  @override
  String get bathroom => '욕실';

  @override
  String get repairs => '수리';

  @override
  String get general => '일반';

  @override
  String get selectDesignStyle => '디자인 스타일 선택';

  @override
  String get colorPalette => '색상 팔레트';

  @override
  String get selectLightingType => '조명 유형 선택';

  @override
  String get selectFurnitureType => '가구 유형 선택';

  @override
  String get selectRepairType => '수리/손상 유형 선택';

  @override
  String get bathroomOptions => '욕실 옵션';

  @override
  String changeStyleTo(String styleName) {
    return '스타일을 $styleName(으)로 변경';
  }

  @override
  String get whatToDo => '무엇을 할까요?';

  @override
  String get describeChange => '원하는 변경 사항을 설명하세요...';

  @override
  String get cancel => '취소';

  @override
  String get execute => '실행';

  @override
  String comingSoon(String feature) {
    return '$feature - 곧 출시!';
  }

  @override
  String get colorChange => '색상 변경';

  @override
  String get allWalls => '모든 벽';

  @override
  String get paintAllWalls => '방의 모든 벽 페인트';

  @override
  String get specificObject => '특정 객체';

  @override
  String get selectWhatToPaint => '페인트할 것을 선택하세요';

  @override
  String get exampleObjects => '예: 소파, 천장, 캐비닛...';

  @override
  String get confirm => '확인';

  @override
  String get windowOptions => '창문 옵션';

  @override
  String get doorOptions => '문 옵션';

  @override
  String get toiletOptions => '변기 옵션';

  @override
  String get bathtubOptions => '욕조 옵션';

  @override
  String get showerOptions => '샤워 옵션';

  @override
  String get sinkOptions => '싱크대 옵션';

  @override
  String get jacuzziOptions => '자쿠지/스파 옵션';

  @override
  String get poolOptions => '수영장 옵션';

  @override
  String get professionalSubscription => '프로페셔널 플랜';

  @override
  String get specialLaunchPrices => '특별 출시 가격 🚀';

  @override
  String get purchaseFailed => '구매 실패';

  @override
  String get yourCurrentPlan => '현재 플랜';

  @override
  String get selectPlan => '플랜 선택';

  @override
  String get perMonth => '/월';

  @override
  String get starterPlan => '스타터';

  @override
  String get valuePlan => '밸류';

  @override
  String get proPlan => '프로페셔널';

  @override
  String imagesPerMonth(int count) {
    return '월 $count개 이미지';
  }

  @override
  String get whatsappSupport => 'WhatsApp 지원';

  @override
  String get historyStorage => '기록 저장';

  @override
  String get vipWhatsappSupport => 'VIP WhatsApp 지원';

  @override
  String get processingPriority => '처리 우선순위';

  @override
  String get bestValue => '최고의 가치: 4배 더 많은 이미지! 🔥';

  @override
  String get forProfessionals => '전문가용 ⭐';

  @override
  String savePerImage(String percent) {
    return '이미지당 $percent% 절약';
  }

  @override
  String get allDesignTools => '모든 디자인 도구';

  @override
  String get fastSupport => '빠른 지원';

  @override
  String get noAds => '광고 없음';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get login => '로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get createNewAccount => '새 계정';

  @override
  String get welcomeBack => '다시 오신 것을 환영합니다! 로그인하여 계속하세요';

  @override
  String get joinUs => '가입하여 디자인을 저장하고 모든 기능에 액세스하세요';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get fillAllFields => '모든 필드를 채워주세요';

  @override
  String get passwordsNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get loginButton => '로그인';

  @override
  String get createAccountButton => '계정 만들기';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get enterEmailFirst => '먼저 이메일 주소를 입력해주세요';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox and spam folder.';

  @override
  String get passwordResetError => 'Error sending password reset email';

  @override
  String get termsAgreement => '로그인하면 다음에 동의하게 됩니다';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get and => '및';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-en.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-en.html';

  @override
  String get loggingIn => '로그인 중...';

  @override
  String get creatingAccount => '계정 생성 중...';

  @override
  String get loginSuccess => '로그인되었습니다! 🎉';

  @override
  String get accountCreated => '계정이 생성되었습니다! 🎉';

  @override
  String get loginError => '로그인 오류';

  @override
  String get userNotFound => '사용자를 찾을 수 없습니다';

  @override
  String get wrongPassword => '잘못된 비밀번호';

  @override
  String get emailInUse => '이미 사용 중인 이메일입니다';

  @override
  String get weakPassword => '비밀번호가 너무 약합니다';

  @override
  String get invalidEmail => '유효하지 않은 이메일 주소';

  @override
  String get exitAccount => '계정 나가기';

  @override
  String get loginWithEmail => '이메일로 로그인하여 디자인 저장';

  @override
  String get mySubscription => '내 구독';

  @override
  String creditsRemaining(int count) {
    return '$count 크레딧 남음';
  }

  @override
  String get upgradeToPremium => '프리미엄으로 업그레이드';

  @override
  String get iHaveCoupon => '쿠폰이 있어요';

  @override
  String get enterCouponCode => '쿠폰 코드를 입력하여 무료 크레딧 받기';

  @override
  String get enterCouponCodeTitle => '쿠폰 코드 입력';

  @override
  String get enterCouponCodeSubtitle => '받은 쿠폰 코드를 입력하여 무료 크레딧 받기';

  @override
  String get couponCode => '쿠폰 코드';

  @override
  String get mustEnterCoupon => '쿠폰 코드를 입력해야 합니다';

  @override
  String get couponActivated => '쿠폰이 활성화되었습니다!';

  @override
  String get errorRedeemingCoupon => '쿠폰 사용 오류';

  @override
  String get redeemCoupon => '쿠폰 사용';

  @override
  String creditsAddedToAccount(int count) {
    return '계정에 $count 크레딧이 추가되었습니다! 🎉';
  }

  @override
  String get contactUs => '문의하기';

  @override
  String get contactSubtitle => '연락을 기다리고 있습니다! 세부 정보를 입력해주세요.';

  @override
  String get phone => '전화';

  @override
  String get message => '메시지';

  @override
  String get writeYourMessage => '여기에 메시지를 작성하세요...';

  @override
  String get enterPhoneOrEmail => '* 전화 또는 이메일을 입력해주세요';

  @override
  String get pleaseEnterPhoneOrEmail => '전화 또는 이메일을 입력해주세요';

  @override
  String get pleaseEnterMessage => '메시지를 입력해주세요';

  @override
  String get errorSendingMessage => '메시지 전송 오류. 다시 시도해주세요.';

  @override
  String get sendMessage => '메시지 보내기';

  @override
  String get messageSentSuccess => '메시지가 전송되었습니다!';

  @override
  String get contentNotAllowed => '콘텐츠가 허용되지 않음';

  @override
  String get requestFailed => '요청 실패';

  @override
  String get oopsSomethingWrong => '이런! 무언가 잘못되었습니다';

  @override
  String get moderationError =>
      '이 이미지 또는 요청을 처리할 수 없습니다.\n\n이미지 또는 요청에 처리가 허용되지 않는 콘텐츠가 포함되어 있을 수 있습니다.\n\n다른 이미지로 시도하거나 요청을 변경해주세요.';

  @override
  String get timeoutError => '요청이 너무 오래 걸렸습니다.\n\n나중에 다시 시도해주세요.';

  @override
  String get genericError => '요청을 처리할 수 없습니다.\n\n다시 시도하거나 문제가 지속되면 지원팀에 문의하세요.';

  @override
  String get close => '닫기';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get imageSavedToGallery => '이미지가 갤러리에 저장되었습니다!';

  @override
  String get errorDownloadingImage => '이미지 다운로드 오류';

  @override
  String get errorSharing => '공유 오류';

  @override
  String get shareText =>
      '🏠 MoomHe AI로 이것을 디자인했어요!\n📸 당신도 해보실래요? https://moomhe.com';

  @override
  String get comparison => '비교';

  @override
  String get download => '다운로드';

  @override
  String get share => '공유';

  @override
  String get revertToOriginal => '원본으로 되돌리기';

  @override
  String get loveItSave => '마음에 들어요! 저장';

  @override
  String get creditsFinishedThisMonth => '이번 달 크레딧이 소진되었습니다';

  @override
  String get creditsRanOut => '이번 달 크레딧이 소진되었습니다';

  @override
  String get freeLimitReached => '무료 사용 한도에 도달했습니다';

  @override
  String get reachedFreeLimit => '무료 사용 한도에 도달했습니다';

  @override
  String creditsLimitReached(int limit) {
    return '크레딧 한도에 도달했습니다($limit 크레딧). 더 큰 플랜으로 업그레이드하거나 다음 달까지 기다려주세요.';
  }

  @override
  String freeCreditsUsed(int limit) {
    return '무료 크레딧 $limit개를 모두 사용했습니다. 제한 없이 디자인을 계속하고 고급 기능을 이용하려면 프로페셔널 플랜으로 업그레이드하세요.';
  }

  @override
  String get currentUsage => '현재 사용량';

  @override
  String get limit => '한도';

  @override
  String designs(int count) {
    return '$count개 디자인';
  }

  @override
  String designsCount(int count) {
    return '$count개 디자인';
  }

  @override
  String get upgradePlan => '플랜 업그레이드';

  @override
  String get goToProfessionalPlan => '프로페셔널 플랜으로';

  @override
  String get goPro => '프로로';

  @override
  String get notNowThanks => '지금은 괜찮습니다, 감사합니다';

  @override
  String welcomeToPlan(String planName) {
    return '$planName 플랜에 오신 것을 환영합니다!';
  }

  @override
  String get thankYouForJoining =>
      '구독자 가족에 가입해주셔서 감사합니다. 계정이 업그레이드되었으며 이제 모든 고급 기능과 추가 크레딧에 액세스할 수 있습니다.';

  @override
  String get creditsAddedToYourAccount => '계정에 크레딧이 추가되었습니다';

  @override
  String get unlimitedStyleAccess => '모든 스타일에 무제한 액세스';

  @override
  String get supportCreators => '크리에이터와 디자이너 지원';

  @override
  String get startDesigning => '디자인 시작';

  @override
  String get secureYourSubscription => '구독 보호';

  @override
  String get secureSubscriptionMessage =>
      '구매한 구독을 잃지 않으려면 이메일로 로그인하는 것이 좋습니다.\n\n새 장치나 재설치 후에 구독을 복원할 수 있습니다.';

  @override
  String get later => '나중에';

  @override
  String get loginNow => '지금 로그인';

  @override
  String get onboardingUploadTitle => '이미지 업로드';

  @override
  String get onboardingUploadDesc =>
      '디자인하고 싶은 방의 사진을 업로드하여 시작하세요. 사진이 없으면 샘플 이미지를 사용합니다.';

  @override
  String get onboardingStyleTitle => '리디자인 스타일 선택';

  @override
  String get onboardingStyleDesc =>
      '사이드 메뉴에서 원하는 스타일을 선택하세요. \"리디자인\"을 눌러 다양한 옵션을 확인하세요.';

  @override
  String get onboardingCreateTitle => '디자인 생성';

  @override
  String get onboardingCreateDesc => '\"생성\"을 클릭하면 AI가 몇 초 만에 방을 리디자인합니다!';

  @override
  String get onboardingItemTipTitle => '추가 팁: 아이템 추가';

  @override
  String get onboardingItemTipDesc =>
      '특정 가구를 추가하고 싶으신가요? \"아이템 추가\" 버튼을 사용하여 아이템 이미지를 업로드하고 디자인에 포함시키세요.';

  @override
  String get skip => '건너뛰기';

  @override
  String get next => '다음';

  @override
  String get finish => '완료';

  @override
  String get promptAddedToInput => '프롬프트가 추가되었습니다 - 편집하고 생성을 탭하세요';

  @override
  String get styleMediterranean => '모던 지중해';

  @override
  String get styleWarmMinimalism => '따뜻한 미니멀리즘';

  @override
  String get styleBiophilic => '바이오필릭';

  @override
  String get styleModernLuxury => '모던 럭셔리';

  @override
  String get styleJapandi => '자판디';

  @override
  String get styleScandinavian => '스칸디나비아';

  @override
  String get styleBohoChic => '보호 시크';

  @override
  String get styleIndustrial => '인더스트리얼';

  @override
  String get styleEarthyNatural => '어시 내추럴';

  @override
  String get styleJerusalem => '예루살렘';

  @override
  String get styleMinimalist => '미니멀리스트';

  @override
  String get styleModernClassic => '모던 클래식';

  @override
  String get colorCategoryReds => '빨강';

  @override
  String get colorCategoryOranges => '주황';

  @override
  String get colorCategoryYellows => '노랑';

  @override
  String get colorCategoryGreens => '초록';

  @override
  String get colorCategoryBlues => '파랑';

  @override
  String get colorCategoryPurples => '보라';

  @override
  String get colorCategoryGrays => '회색';

  @override
  String get colorCategoryWhitesBlacks => '흰색과 검정';

  @override
  String get lightingRecessed => '매입 조명';

  @override
  String get lightingPendant => '펜던트 조명';

  @override
  String get lightingChandelier => '샹들리에';

  @override
  String get lightingTableLamp => '테이블 램프';

  @override
  String get lightingFloorLamp => '플로어 램프';

  @override
  String get lightingWallSconce => '벽 조명';

  @override
  String get lightingTrack => '트랙 조명';

  @override
  String get lightingCeiling => '천장 조명';

  @override
  String get lightingUnderCabinet => '캐비닛 하부 조명';

  @override
  String get lightingDecorative => '장식 조명';

  @override
  String get lightingDay => '낮';

  @override
  String get lightingNight => '밤';

  @override
  String get lightingSunset => '일몰';

  @override
  String get lightingSunrise => '일출';

  @override
  String get lightingAddRecessed => '매입 조명 추가';

  @override
  String get lightingAddPendant => '펜던트 조명 추가';

  @override
  String get lightingAddChandelier => '샹들리에 추가';

  @override
  String get lightingAddTableLamp => '테이블 램프 추가';

  @override
  String get lightingAddFloorLamp => '플로어 램프 추가';

  @override
  String get lightingAddWallSconce => '벽 조명 추가';

  @override
  String get lightingAddTrack => '트랙 조명 추가';

  @override
  String get lightingAddCeiling => '천장 조명 추가';

  @override
  String get lightingAddUnderCabinet => '캐비닛 하부 조명 추가';

  @override
  String get lightingAddDecorative => '장식 조명 추가';

  @override
  String get lightingChangeToDay => '조명을 낮으로 변경';

  @override
  String get lightingChangeToNight => '조명을 밤으로 변경';

  @override
  String get lightingChangeToSunset => '조명을 일몰로 변경';

  @override
  String get lightingChangeToSunrise => '조명을 일출로 변경';

  @override
  String get furnitureSofa => '소파';

  @override
  String get furnitureSectional => '섹셔널 소파';

  @override
  String get furnitureArmchair => '안락의자';

  @override
  String get furnitureAccentChair => '악센트 의자';

  @override
  String get furnitureDiningChair => '식탁 의자';

  @override
  String get furnitureBarStool => '바 스툴';

  @override
  String get furnitureSingleBed => '싱글 침대';

  @override
  String get furnitureDoubleBed => '더블 침대';

  @override
  String get furnitureBeanbag => '빈백';

  @override
  String get furnitureOttoman => '오토만';

  @override
  String get furnitureBench => '벤치';

  @override
  String get furnitureCoffeeTable => '커피 테이블';

  @override
  String get furnitureEndTable => '사이드 테이블';

  @override
  String get furnitureNightstand => '협탁';

  @override
  String get furnitureDiningTable => '식탁';

  @override
  String get furnitureDesk => '책상';

  @override
  String get furnitureDresser => '화장대';

  @override
  String get furnitureWardrobe => '옷장';

  @override
  String get furnitureBookcase => '책장';

  @override
  String get furnitureTvStand => 'TV 스탠드';

  @override
  String get furnitureCabinets => '주방 캐비닛';

  @override
  String get furnitureAddSofa => '소파 추가';

  @override
  String get furnitureAddSectional => '섹셔널 소파 추가';

  @override
  String get furnitureAddArmchair => '안락의자 추가';

  @override
  String get furnitureAddAccentChair => '악센트 의자 추가';

  @override
  String get furnitureAddDiningChair => '식탁 의자 추가';

  @override
  String get furnitureAddBarStool => '바 스툴 추가';

  @override
  String get furnitureAddSingleBed => '싱글 침대 추가';

  @override
  String get furnitureAddDoubleBed => '더블 침대 추가';

  @override
  String get furnitureAddBeanbag => '빈백 추가';

  @override
  String get furnitureAddOttoman => '오토만 추가';

  @override
  String get furnitureAddBench => '벤치 추가';

  @override
  String get furnitureAddCoffeeTable => '커피 테이블 추가';

  @override
  String get furnitureAddEndTable => '사이드 테이블 추가';

  @override
  String get furnitureAddNightstand => '협탁 추가';

  @override
  String get furnitureAddDiningTable => '식탁 추가';

  @override
  String get furnitureAddDesk => '책상 추가';

  @override
  String get furnitureAddDresser => '화장대 추가';

  @override
  String get furnitureAddWardrobe => '옷장 추가';

  @override
  String get furnitureAddBookcase => '책장 추가';

  @override
  String get furnitureAddTvStand => 'TV 스탠드 추가';

  @override
  String get furnitureAddCabinets => '주방 캐비닛 추가';

  @override
  String get repairsFixEverything => '모두 수리';

  @override
  String get repairsRepairAll => '모두 수리 및 복구';

  @override
  String get repairsMessUp => '모두 엉망으로';

  @override
  String get repairsDestroy => '모두 파괴 및 손상';

  @override
  String get windowPicture => '픽처 윈도우';

  @override
  String get windowSliding => '슬라이딩 윈도우';

  @override
  String get windowCasement => '케이스먼트 윈도우';

  @override
  String get windowTiltTurn => '틸트 앤 턴 윈도우';

  @override
  String get windowAwning => '어닝 윈도우';

  @override
  String get windowSash => '새시 윈도우';

  @override
  String get windowPocket => '포켓 윈도우';

  @override
  String get windowArched => '아치형 윈도우';

  @override
  String get windowAddPicture => '대형 픽처 윈도우 추가';

  @override
  String get windowAddSliding => '슬라이딩 윈도우 추가';

  @override
  String get windowAddCasement => '케이스먼트 윈도우 추가';

  @override
  String get windowAddTiltTurn => '틸트 앤 턴 윈도우 추가';

  @override
  String get windowAddAwning => '어닝 윈도우 추가';

  @override
  String get windowAddSash => '새시 윈도우 추가';

  @override
  String get windowAddPocket => '포켓 윈도우 추가';

  @override
  String get windowAddArched => '아치형 윈도우 추가';

  @override
  String get doorPocket => '포켓 도어';

  @override
  String get doorFrench => '프렌치 도어';

  @override
  String get doorLouvered => '루버 도어';

  @override
  String get doorBarn => '반 도어';

  @override
  String get doorAddPocket => '벽에 들어가는 포켓 도어 추가';

  @override
  String get doorAddFrench => '유리 프렌치 도어 추가';

  @override
  String get doorAddLouvered => '루버 도어 추가';

  @override
  String get doorAddBarn => '반 도어 추가';

  @override
  String get toiletBidet => '온수 비데';

  @override
  String get toiletSeat => '변기 시트';

  @override
  String get tubFreestanding => '독립형 욕조';

  @override
  String get tubVintage => '빈티지 욕조';

  @override
  String get tubStandard => '표준 욕조';

  @override
  String get showerRain => '레인 샤워';

  @override
  String get showerEnclosure => '샤워 인클로저';

  @override
  String get showerSliding => '슬라이딩 샤워 도어';

  @override
  String get sinkPedestal => '페데스탈 싱크';

  @override
  String get sinkStainless => '스테인리스 싱크';

  @override
  String get sinkUndermount => '언더마운트 싱크';

  @override
  String get jacuzziBuiltIn => '빌트인 자쿠지';

  @override
  String get jacuzziPortable => '휴대용 자쿠지';

  @override
  String get poolInground => '지하 수영장';

  @override
  String get poolAboveGround => '지상 수영장';

  @override
  String get toiletAddBidet => '비데 변기 시트 추가';

  @override
  String get toiletAddSeat => '변기 시트 추가';

  @override
  String get tubAddFreestanding => '독립형 욕조 추가';

  @override
  String get tubAddVintage => '빈티지 욕조 추가';

  @override
  String get tubAddStandard => '표준 욕조 추가';

  @override
  String get showerAddRain => '레인 샤워헤드 샤워 추가';

  @override
  String get showerAddEnclosure => '샤워 인클로저 추가';

  @override
  String get showerAddSliding => '슬라이딩 도어 샤워 추가';

  @override
  String get sinkAddPedestal => '페데스탈 싱크 추가';

  @override
  String get sinkAddStainless => '스테인리스 싱크 추가';

  @override
  String get sinkAddUndermount => '언더마운트 싱크 추가';

  @override
  String get jacuzziAddBuiltIn => '빌트인 자쿠지 추가';

  @override
  String get jacuzziAddPortable => '휴대용 자쿠지 추가';

  @override
  String get poolAddInground => '지하 수영장 추가';

  @override
  String get poolAddAboveGround => '지상 수영장 추가';

  @override
  String get errorUnknown => '알 수 없는 오류';

  @override
  String get searchWithLens => '검색';

  @override
  String get cancelSearch => '취소';

  @override
  String get selectAreaToSearch => '검색하려는 항목 주위에 사각형을 그리세요';

  @override
  String get searchingWithGoogleLens => 'Google 렌즈로 검색 중...';

  @override
  String get selectAreaWithinImage => '이미지 내에서 영역을 선택하세요';

  @override
  String get googleLensSearchFailed => '검색에 실패했습니다. 다시 시도해주세요.';

  @override
  String get rateAppTitle => '앱이 마음에 드시나요?';

  @override
  String get rateAppMessage => '의견을 듣고 싶습니다! 피드백은 개선에 도움이 됩니다.';

  @override
  String get rateAppYes => '네, 좋아요! 😍';

  @override
  String get rateAppNo => '별로요';

  @override
  String get rateAppLater => '나중에 물어봐주세요';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountWarning1Title => '계정 삭제';

  @override
  String get deleteAccountWarning1Message =>
      '계정을 삭제하시겠습니까? 모든 정보와 이미지가 삭제되며 되돌릴 수 없습니다.';

  @override
  String get deleteAccountWarning2Title => '최종 확인';

  @override
  String get deleteAccountWarning2Message =>
      '이 작업은 되돌릴 수 없습니다! 모든 기록과 이미지가 영구 삭제됩니다. 100% 확실하신가요?';

  @override
  String get deleteAccountConfirm => '네, 계정 삭제';

  @override
  String get deletingAccount => '계정 삭제 중...';

  @override
  String get accountDeleted => '계정이 삭제되었습니다';

  @override
  String get errorDeletingAccount => '계정 삭제 오류';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get languageChanged => '언어가 변경되었습니다';

  @override
  String get createAccountPromptTitle => '계정 만들기';

  @override
  String get createAccountPromptMessage =>
      '앞으로 몇 주 안에 놀라운 업데이트가 출시됩니다! 🚀\n\n지금 계정을 만들어 창작물을 잃지 않고 새로운 기능을 가장 먼저 즐기세요.';

  @override
  String get createAccountPromptButton => '계정 만들기';

  @override
  String get maybeLater => '나중에';

  @override
  String get readyDesigns => '디자인 갤러리';

  @override
  String get noCategories => '카테고리 없음';

  @override
  String get noDesigns => '디자인 없음';

  @override
  String get noDesignsInCategory => '이 카테고리에 디자인이 없습니다';

  @override
  String get loadingDesigns => '디자인 로딩 중...';

  @override
  String get loading => '로딩 중...';

  @override
  String get categoryKitchen => '주방';

  @override
  String get categoryKidsBedroom => '어린이 침실';

  @override
  String get categoryBathroom => '욕실';

  @override
  String get categoryLivingRoom => '거실';

  @override
  String get categoryMasterBedroom => '안방';

  @override
  String get useDesignQuestion => '이 디자인을 사용하시겠습니까?';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get featureCarouselTitle1 => 'AI 기반 디자인';

  @override
  String get featureCarouselSubtitle1 => '✨ 지능형 리디자인';

  @override
  String get featureCarouselDesc1 =>
      '최첨단 AI로 모든 공간을 변화시키세요. 사진을 업로드하기만 하면 전문적인 디자인으로 공간이 살아납니다.';

  @override
  String get featureCarouselTitle2 => '무한한 가능성';

  @override
  String get featureCarouselSubtitle2 => '🎨 스타일 & 컬러';

  @override
  String get featureCarouselDesc2 =>
      '모던 미니멀리즘부터 아늑한 보헤미안까지 — 취향에 맞춘 수십 가지 디자인 스타일과 컬러 팔레트를 탐색하세요.';

  @override
  String get featureCarouselTitle3 => '즉각적인 결과';

  @override
  String get featureCarouselSubtitle3 => '⚡ 몇 시간이 아닌 몇 초';

  @override
  String get featureCarouselDesc3 =>
      '이전에는 디자이너에게 몇 시간이 걸렸던 작업이 이제 몇 초 만에 완료됩니다. 놀라운 전후 변신을 즉시 받아보세요.';

  @override
  String get getStarted => '시작하기';

  @override
  String freeTrialDays(int days) {
    return '$days일 무료 체험';
  }

  @override
  String thenPrice(Object price) {
    return '이후 $price/월';
  }

  @override
  String get yearly => 'Yearly';

  @override
  String get monthly => 'Monthly';

  @override
  String get perYear => '/year';

  @override
  String savePercent(int percent) {
    return 'SAVE $percent%';
  }

  @override
  String get billedAnnually => 'billed annually';

  @override
  String justPricePerMonth(String price) {
    return 'Just $price/mo';
  }

  @override
  String wasPrice(String price) {
    return 'Was $price';
  }
}
