// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Expert AI';

  @override
  String get appName => 'Expert';

  @override
  String get guest => '访客';

  @override
  String get loginToSaveDesigns => '登录以保存您的设计';

  @override
  String get loggedOutSuccess => '已成功登出';

  @override
  String get uploadImage => '上传图片';

  @override
  String get clickToUploadImage => '点击此处从相册上传图片';

  @override
  String get gallery => '相册';

  @override
  String get camera => '相机';

  @override
  String get uploadItem => '添加物品';

  @override
  String get redesign => '重新设计';

  @override
  String get more => '更多';

  @override
  String get moreOptions => '更多选项';

  @override
  String get history => '历史';

  @override
  String get noHistoryYet => '暂无历史';

  @override
  String get uploadedImagesWillAppear => '您上传和编辑的图片将显示在这里';

  @override
  String get whatToChange => '想要改变什么？';

  @override
  String get uploadImageFirst => '请先上传图片';

  @override
  String get uploadingImage => '正在上传图片...';

  @override
  String get errorUploadingImage => '上传图片出错';

  @override
  String get itemImageLoaded => '物品图片已加载！在提示中描述添加位置。';

  @override
  String get addAttachedItem => '将附加的物品添加到图片中';

  @override
  String get processingStarting => '正在开始...';

  @override
  String get processingMagic => '魔法正在发生';

  @override
  String get processing => '处理中...';

  @override
  String get connectingToCloud => '正在连接云端... ☁️';

  @override
  String get sendingToAI => '正在发送到AI... 🤖';

  @override
  String get analyzingItem => '正在分析物品... 🔍';

  @override
  String get creatingDesign => '正在创建设计... ✨';

  @override
  String get funPhrase1 => '正在将图片送往另一个维度... 🌀';

  @override
  String get funPhrase2 => '正在教AI欣赏好设计... 🎨';

  @override
  String get funPhrase3 => '正在说服像素们合作... 🤝';

  @override
  String get funPhrase4 => '一点数字魔法正在进行... ✨';

  @override
  String get funPhrase5 => '正在询问AI的意见... 🤔';

  @override
  String get funPhrase6 => '像真正的艺术家一样混合颜色... 🖌️';

  @override
  String get funPhrase7 => '正在计算完美角度... 📐';

  @override
  String get funPhrase8 => '为您的生活增添一些风格... 💫';

  @override
  String get funPhrase9 => '让房间看起来更高档... 💎';

  @override
  String get funPhrase10 => '正在激活设计魔法... 🪄';

  @override
  String get funPhrase11 => '正在咨询数字室内设计师... 🏠';

  @override
  String get funPhrase12 => '尽量不要对结果太兴奋... 😍';

  @override
  String get funPhrase13 => '您马上就会看到惊人的效果... 🚀';

  @override
  String get funPhrase14 => '确保一切都为您完美呈现... 👌';

  @override
  String get designStyle => '设计风格';

  @override
  String get wallColor => '更改颜色';

  @override
  String get lighting => '照明';

  @override
  String get furniture => '家具';

  @override
  String get doorsWindows => '门窗';

  @override
  String get bathroom => '浴室';

  @override
  String get repairs => '维修';

  @override
  String get general => '通用';

  @override
  String get selectDesignStyle => '选择设计风格';

  @override
  String get colorPalette => '调色板';

  @override
  String get selectLightingType => '选择照明类型';

  @override
  String get selectFurnitureType => '选择家具类型';

  @override
  String get selectRepairType => '选择维修/损坏类型';

  @override
  String get bathroomOptions => '浴室选项';

  @override
  String changeStyleTo(String styleName) {
    return '将风格更改为$styleName';
  }

  @override
  String get whatToDo => '想要做什么？';

  @override
  String get describeChange => '描述您想要的更改...';

  @override
  String get cancel => '取消';

  @override
  String get execute => '执行';

  @override
  String comingSoon(String feature) {
    return '$feature - 即将推出！';
  }

  @override
  String get colorChange => '更改颜色';

  @override
  String get allWalls => '所有墙壁';

  @override
  String get paintAllWalls => '为房间所有墙壁涂漆';

  @override
  String get specificObject => '特定物体';

  @override
  String get selectWhatToPaint => '选择要涂漆的对象';

  @override
  String get exampleObjects => '例如：沙发、天花板、柜子...';

  @override
  String get confirm => '确认';

  @override
  String get windowOptions => '窗户选项';

  @override
  String get doorOptions => '门选项';

  @override
  String get toiletOptions => '马桶选项';

  @override
  String get bathtubOptions => '浴缸选项';

  @override
  String get showerOptions => '淋浴选项';

  @override
  String get sinkOptions => '水槽选项';

  @override
  String get jacuzziOptions => '按摩浴缸/水疗选项';

  @override
  String get poolOptions => '泳池选项';

  @override
  String get professionalSubscription => '专业计划';

  @override
  String get specialLaunchPrices => '特别上市价格 🚀';

  @override
  String get purchaseFailed => '购买失败';

  @override
  String get yourCurrentPlan => '您的当前计划';

  @override
  String get selectPlan => '选择计划';

  @override
  String get perMonth => '/月';

  @override
  String get starterPlan => '入门版';

  @override
  String get valuePlan => '超值版';

  @override
  String get proPlan => '专业版';

  @override
  String imagesPerMonth(int count) {
    return '每月$count张图片';
  }

  @override
  String get whatsappSupport => 'WhatsApp支持';

  @override
  String get historyStorage => '历史存储';

  @override
  String get vipWhatsappSupport => 'VIP WhatsApp支持';

  @override
  String get processingPriority => '处理优先级';

  @override
  String get bestValue => '最佳价值：4倍图片！ 🔥';

  @override
  String get forProfessionals => '专业人士专享 ⭐';

  @override
  String savePerImage(String percent) {
    return '每张图片节省$percent%';
  }

  @override
  String get allDesignTools => '所有设计工具';

  @override
  String get fastSupport => '快速支持';

  @override
  String get noAds => '无广告';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get login => '登录';

  @override
  String get logout => '登出';

  @override
  String get createAccount => '创建账户';

  @override
  String get createNewAccount => '新账户';

  @override
  String get welcomeBack => '欢迎回来！登录以继续';

  @override
  String get joinUs => '加入我们以保存设计并访问所有功能';

  @override
  String get email => '电子邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get fillAllFields => '请填写所有字段';

  @override
  String get passwordsNotMatch => '密码不匹配';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get loginButton => '登录';

  @override
  String get createAccountButton => '创建账户';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get enterEmailFirst => '请先输入电子邮箱地址';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox and spam folder.';

  @override
  String get passwordResetError => 'Error sending password reset email';

  @override
  String get termsAgreement => '登录即表示您同意';

  @override
  String get termsOfService => '服务条款';

  @override
  String get and => '和';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-en.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-en.html';

  @override
  String get loggingIn => '正在登录...';

  @override
  String get creatingAccount => '正在创建账户...';

  @override
  String get loginSuccess => '登录成功！ 🎉';

  @override
  String get accountCreated => '账户创建成功！ 🎉';

  @override
  String get loginError => '登录错误';

  @override
  String get userNotFound => '用户未找到';

  @override
  String get wrongPassword => '密码错误';

  @override
  String get emailInUse => '电子邮箱已被使用';

  @override
  String get weakPassword => '密码太弱';

  @override
  String get invalidEmail => '无效的电子邮箱地址';

  @override
  String get exitAccount => '退出账户';

  @override
  String get loginWithEmail => '使用电子邮箱登录以保存您的设计';

  @override
  String get mySubscription => '我的订阅';

  @override
  String creditsRemaining(int count) {
    return '剩余$count积分';
  }

  @override
  String get upgradeToPremium => '升级到高级版';

  @override
  String get iHaveCoupon => '我有优惠券';

  @override
  String get enterCouponCode => '输入优惠券代码获取免费积分';

  @override
  String get enterCouponCodeTitle => '输入优惠券代码';

  @override
  String get enterCouponCodeSubtitle => '输入您收到的优惠券代码以获取免费积分';

  @override
  String get couponCode => '优惠券代码';

  @override
  String get mustEnterCoupon => '您必须输入优惠券代码';

  @override
  String get couponActivated => '优惠券激活成功！';

  @override
  String get errorRedeemingCoupon => '兑换优惠券出错';

  @override
  String get redeemCoupon => '兑换优惠券';

  @override
  String creditsAddedToAccount(int count) {
    return '已向您的账户添加$count积分！ 🎉';
  }

  @override
  String get contactUs => '联系我们';

  @override
  String get contactSubtitle => '我们很想听到您的声音！请填写详细信息，我们会尽快回复。';

  @override
  String get phone => '电话';

  @override
  String get message => '消息';

  @override
  String get writeYourMessage => '在此输入您的消息...';

  @override
  String get enterPhoneOrEmail => '* 请至少输入电话或电子邮箱';

  @override
  String get pleaseEnterPhoneOrEmail => '请至少输入电话或电子邮箱';

  @override
  String get pleaseEnterMessage => '请输入消息';

  @override
  String get errorSendingMessage => '发送消息出错。请重试。';

  @override
  String get sendMessage => '发送消息';

  @override
  String get messageSentSuccess => '消息发送成功！';

  @override
  String get contentNotAllowed => '内容不允许';

  @override
  String get requestFailed => '请求失败';

  @override
  String get oopsSomethingWrong => '哎呀！出了点问题';

  @override
  String get moderationError =>
      '无法处理此图片或请求。\n\n图片或请求可能包含不允许处理的内容。\n\n请尝试其他图片或更改请求。';

  @override
  String get timeoutError => '请求时间过长。\n\n请稍后重试。';

  @override
  String get genericError => '我们无法处理请求。\n\n请重试，如果问题仍然存在，请联系支持。';

  @override
  String get close => '关闭';

  @override
  String get tryAgain => '重试';

  @override
  String get imageSavedToGallery => '图片已保存到相册！';

  @override
  String get errorDownloadingImage => '下载图片出错';

  @override
  String get errorSharing => '分享出错';

  @override
  String get shareText => '🏠 我用MoomHe AI设计了这个！\n📸 你也想试试吗？ https://moomhe.com';

  @override
  String get comparison => '对比';

  @override
  String get download => '下载';

  @override
  String get share => '分享';

  @override
  String get revertToOriginal => '恢复原图';

  @override
  String get loveItSave => '喜欢！保存';

  @override
  String get creditsFinishedThisMonth => '本月积分已用完';

  @override
  String get creditsRanOut => '本月积分已用完';

  @override
  String get freeLimitReached => '您已达到免费使用限制';

  @override
  String get reachedFreeLimit => '您已达到免费使用限制';

  @override
  String creditsLimitReached(int limit) {
    return '您已达到积分限制（$limit积分）。您可以升级到更大的计划或等到下个月。';
  }

  @override
  String freeCreditsUsed(int limit) {
    return '您已用完所有$limit个免费积分。要继续无限制设计并获得高级功能，请升级到专业计划。';
  }

  @override
  String get currentUsage => '当前使用量';

  @override
  String get limit => '限制';

  @override
  String designs(int count) {
    return '$count个设计';
  }

  @override
  String designsCount(int count) {
    return '$count个设计';
  }

  @override
  String get upgradePlan => '升级计划';

  @override
  String get goToProfessionalPlan => '转到专业计划';

  @override
  String get goPro => '升级专业版';

  @override
  String get notNowThanks => '现在不用，谢谢';

  @override
  String welcomeToPlan(String planName) {
    return '欢迎加入$planName计划！';
  }

  @override
  String get thankYouForJoining =>
      '感谢您加入我们的订阅者大家庭。您的账户已成功升级，现在可以访问所有高级功能和额外积分。';

  @override
  String get creditsAddedToYourAccount => '积分已添加到您的账户';

  @override
  String get unlimitedStyleAccess => '无限访问所有风格';

  @override
  String get supportCreators => '支持创作者和设计师';

  @override
  String get startDesigning => '开始设计';

  @override
  String get secureYourSubscription => '保护您的订阅';

  @override
  String get secureSubscriptionMessage =>
      '为了不丢失您购买的订阅，我们建议使用电子邮箱登录。\n\n这样您可以在新设备或重新安装后恢复订阅。';

  @override
  String get later => '稍后';

  @override
  String get loginNow => '立即登录';

  @override
  String get onboardingUploadTitle => '上传图片';

  @override
  String get onboardingUploadDesc => '首先上传您想要设计的房间照片。没有照片？别担心，我们会使用示例图片。';

  @override
  String get onboardingStyleTitle => '选择重新设计风格';

  @override
  String get onboardingStyleDesc => '从侧边菜单中选择您喜欢的风格。尝试「重新设计」查看不同选项。';

  @override
  String get onboardingCreateTitle => '创建设计';

  @override
  String get onboardingCreateDesc => '点击「创建」，AI将在几秒钟内重新设计您的房间！';

  @override
  String get onboardingItemTipTitle => '额外提示：添加物品';

  @override
  String get onboardingItemTipDesc => '想要添加特定家具？使用「添加物品」按钮上传物品图片并将其融入设计。';

  @override
  String get skip => '跳过';

  @override
  String get next => '下一步';

  @override
  String get finish => '完成';

  @override
  String get promptAddedToInput => '提示已添加 - 您可以编辑后点击创建';

  @override
  String get styleMediterranean => '现代地中海';

  @override
  String get styleWarmMinimalism => '温暖极简';

  @override
  String get styleBiophilic => '生物亲和';

  @override
  String get styleModernLuxury => '现代奢华';

  @override
  String get styleJapandi => '日式北欧';

  @override
  String get styleScandinavian => '北欧风';

  @override
  String get styleBohoChic => '波西米亚风';

  @override
  String get styleIndustrial => '工业风';

  @override
  String get styleEarthyNatural => '自然原野';

  @override
  String get styleJerusalem => '耶路撒冷';

  @override
  String get styleMinimalist => '极简主义';

  @override
  String get styleModernClassic => '现代古典';

  @override
  String get colorCategoryReds => '红色系';

  @override
  String get colorCategoryOranges => '橙色系';

  @override
  String get colorCategoryYellows => '黄色系';

  @override
  String get colorCategoryGreens => '绿色系';

  @override
  String get colorCategoryBlues => '蓝色系';

  @override
  String get colorCategoryPurples => '紫色系';

  @override
  String get colorCategoryGrays => '灰色系';

  @override
  String get colorCategoryWhitesBlacks => '黑白色系';

  @override
  String get lightingRecessed => '嵌入式照明';

  @override
  String get lightingPendant => '吊灯';

  @override
  String get lightingChandelier => '枝形吊灯';

  @override
  String get lightingTableLamp => '台灯';

  @override
  String get lightingFloorLamp => '落地灯';

  @override
  String get lightingWallSconce => '壁灯';

  @override
  String get lightingTrack => '轨道照明';

  @override
  String get lightingCeiling => '天花板灯';

  @override
  String get lightingUnderCabinet => '柜下照明';

  @override
  String get lightingDecorative => '装饰灯';

  @override
  String get lightingDay => '白天';

  @override
  String get lightingNight => '夜晚';

  @override
  String get lightingSunset => '日落';

  @override
  String get lightingSunrise => '日出';

  @override
  String get lightingAddRecessed => '添加嵌入式照明';

  @override
  String get lightingAddPendant => '添加吊灯';

  @override
  String get lightingAddChandelier => '添加枝形吊灯';

  @override
  String get lightingAddTableLamp => '添加台灯';

  @override
  String get lightingAddFloorLamp => '添加落地灯';

  @override
  String get lightingAddWallSconce => '添加壁灯';

  @override
  String get lightingAddTrack => '添加轨道照明';

  @override
  String get lightingAddCeiling => '添加天花板灯';

  @override
  String get lightingAddUnderCabinet => '添加柜下照明';

  @override
  String get lightingAddDecorative => '添加装饰灯';

  @override
  String get lightingChangeToDay => '将照明改为白天';

  @override
  String get lightingChangeToNight => '将照明改为夜晚';

  @override
  String get lightingChangeToSunset => '将照明改为日落';

  @override
  String get lightingChangeToSunrise => '将照明改为日出';

  @override
  String get furnitureSofa => '沙发';

  @override
  String get furnitureSectional => '组合沙发';

  @override
  String get furnitureArmchair => '扶手椅';

  @override
  String get furnitureAccentChair => '装饰椅';

  @override
  String get furnitureDiningChair => '餐椅';

  @override
  String get furnitureBarStool => '吧台凳';

  @override
  String get furnitureSingleBed => '单人床';

  @override
  String get furnitureDoubleBed => '双人床';

  @override
  String get furnitureBeanbag => '豆袋椅';

  @override
  String get furnitureOttoman => '脚凳';

  @override
  String get furnitureBench => '长凳';

  @override
  String get furnitureCoffeeTable => '茶几';

  @override
  String get furnitureEndTable => '边桌';

  @override
  String get furnitureNightstand => '床头柜';

  @override
  String get furnitureDiningTable => '餐桌';

  @override
  String get furnitureDesk => '书桌';

  @override
  String get furnitureDresser => '梳妆台';

  @override
  String get furnitureWardrobe => '衣柜';

  @override
  String get furnitureBookcase => '书架';

  @override
  String get furnitureTvStand => '电视柜';

  @override
  String get furnitureCabinets => '厨柜';

  @override
  String get furnitureAddSofa => '添加沙发';

  @override
  String get furnitureAddSectional => '添加组合沙发';

  @override
  String get furnitureAddArmchair => '添加扶手椅';

  @override
  String get furnitureAddAccentChair => '添加装饰椅';

  @override
  String get furnitureAddDiningChair => '添加餐椅';

  @override
  String get furnitureAddBarStool => '添加吧台凳';

  @override
  String get furnitureAddSingleBed => '添加单人床';

  @override
  String get furnitureAddDoubleBed => '添加双人床';

  @override
  String get furnitureAddBeanbag => '添加豆袋椅';

  @override
  String get furnitureAddOttoman => '添加脚凳';

  @override
  String get furnitureAddBench => '添加长凳';

  @override
  String get furnitureAddCoffeeTable => '添加茶几';

  @override
  String get furnitureAddEndTable => '添加边桌';

  @override
  String get furnitureAddNightstand => '添加床头柜';

  @override
  String get furnitureAddDiningTable => '添加餐桌';

  @override
  String get furnitureAddDesk => '添加书桌';

  @override
  String get furnitureAddDresser => '添加梳妆台';

  @override
  String get furnitureAddWardrobe => '添加衣柜';

  @override
  String get furnitureAddBookcase => '添加书架';

  @override
  String get furnitureAddTvStand => '添加电视柜';

  @override
  String get furnitureAddCabinets => '添加厨柜';

  @override
  String get repairsFixEverything => '修复一切';

  @override
  String get repairsRepairAll => '修复和修理一切';

  @override
  String get repairsMessUp => '弄乱一切';

  @override
  String get repairsDestroy => '破坏和损坏一切';

  @override
  String get windowPicture => '观景窗';

  @override
  String get windowSliding => '推拉窗';

  @override
  String get windowCasement => '平开窗';

  @override
  String get windowTiltTurn => '内倒窗';

  @override
  String get windowAwning => '遮阳窗';

  @override
  String get windowSash => '上下推拉窗';

  @override
  String get windowPocket => '口袋窗';

  @override
  String get windowArched => '拱形窗';

  @override
  String get windowAddPicture => '添加大型观景窗';

  @override
  String get windowAddSliding => '添加推拉窗';

  @override
  String get windowAddCasement => '添加平开窗';

  @override
  String get windowAddTiltTurn => '添加内倒窗';

  @override
  String get windowAddAwning => '添加遮阳窗';

  @override
  String get windowAddSash => '添加上下推拉窗';

  @override
  String get windowAddPocket => '添加口袋窗';

  @override
  String get windowAddArched => '添加拱形窗';

  @override
  String get doorPocket => '口袋门';

  @override
  String get doorFrench => '法式门';

  @override
  String get doorLouvered => '百叶门';

  @override
  String get doorBarn => '谷仓门';

  @override
  String get doorAddPocket => '添加滑入墙内的口袋门';

  @override
  String get doorAddFrench => '添加玻璃法式门';

  @override
  String get doorAddLouvered => '添加百叶门';

  @override
  String get doorAddBarn => '添加谷仓门';

  @override
  String get toiletBidet => '智能马桶';

  @override
  String get toiletSeat => '马桶座';

  @override
  String get tubFreestanding => '独立浴缸';

  @override
  String get tubVintage => '复古浴缸';

  @override
  String get tubStandard => '标准浴缸';

  @override
  String get showerRain => '雨淋花洒';

  @override
  String get showerEnclosure => '淋浴房';

  @override
  String get showerSliding => '推拉淋浴门';

  @override
  String get sinkPedestal => '立柱盆';

  @override
  String get sinkStainless => '不锈钢水槽';

  @override
  String get sinkUndermount => '台下盆';

  @override
  String get jacuzziBuiltIn => '嵌入式按摩浴缸';

  @override
  String get jacuzziPortable => '便携式按摩浴缸';

  @override
  String get poolInground => '地下泳池';

  @override
  String get poolAboveGround => '地上泳池';

  @override
  String get toiletAddBidet => '添加智能马桶';

  @override
  String get toiletAddSeat => '添加马桶座';

  @override
  String get tubAddFreestanding => '添加独立浴缸';

  @override
  String get tubAddVintage => '添加复古浴缸';

  @override
  String get tubAddStandard => '添加标准浴缸';

  @override
  String get showerAddRain => '添加雨淋花洒淋浴';

  @override
  String get showerAddEnclosure => '添加淋浴房';

  @override
  String get showerAddSliding => '添加推拉门淋浴';

  @override
  String get sinkAddPedestal => '添加立柱盆';

  @override
  String get sinkAddStainless => '添加不锈钢水槽';

  @override
  String get sinkAddUndermount => '添加台下盆';

  @override
  String get jacuzziAddBuiltIn => '添加嵌入式按摩浴缸';

  @override
  String get jacuzziAddPortable => '添加便携式按摩浴缸';

  @override
  String get poolAddInground => '添加地下泳池';

  @override
  String get poolAddAboveGround => '添加地上泳池';

  @override
  String get errorUnknown => '未知错误';

  @override
  String get searchWithLens => '搜索';

  @override
  String get cancelSearch => '取消';

  @override
  String get selectAreaToSearch => '在要搜索的物品周围画一个矩形';

  @override
  String get searchingWithGoogleLens => '正在使用Google Lens搜索...';

  @override
  String get selectAreaWithinImage => '请在图片内选择一个区域';

  @override
  String get googleLensSearchFailed => '搜索失败。请重试。';

  @override
  String get rateAppTitle => '喜欢这个应用吗？';

  @override
  String get rateAppMessage => '我们很想听听您的想法！您的反馈帮助我们改进。';

  @override
  String get rateAppYes => '是的，我喜欢！ 😍';

  @override
  String get rateAppNo => '不太喜欢';

  @override
  String get rateAppLater => '稍后问我';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountWarning1Title => '删除账户';

  @override
  String get deleteAccountWarning1Message => '您确定要删除账户吗？这将删除您的所有信息和图片，且无法撤消。';

  @override
  String get deleteAccountWarning2Title => '最终确认';

  @override
  String get deleteAccountWarning2Message =>
      '此操作不可逆！您的所有历史记录和图片将被永久删除。您100%确定吗？';

  @override
  String get deleteAccountConfirm => '是的，删除账户';

  @override
  String get deletingAccount => '正在删除账户...';

  @override
  String get accountDeleted => '账户已成功删除';

  @override
  String get errorDeletingAccount => '删除账户出错';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageChanged => '语言已更改';

  @override
  String get createAccountPromptTitle => '创建您的账户';

  @override
  String get createAccountPromptMessage =>
      '未来几周将有令人惊叹的更新！🚀\n\n立即创建账户，以免丢失您的创作，并成为第一个享受新功能的人。';

  @override
  String get createAccountPromptButton => '创建账户';

  @override
  String get maybeLater => '以后再说';

  @override
  String get readyDesigns => '设计画廊';

  @override
  String get noCategories => '暂无分类';

  @override
  String get noDesigns => '暂无设计';

  @override
  String get noDesignsInCategory => '该分类暂无设计';

  @override
  String get loadingDesigns => '正在加载设计...';

  @override
  String get loading => '加载中...';

  @override
  String get categoryKitchen => '厨房';

  @override
  String get categoryKidsBedroom => '儿童卧室';

  @override
  String get categoryBathroom => '浴室';

  @override
  String get categoryLivingRoom => '客厅';

  @override
  String get categoryMasterBedroom => '主卧室';
}

/// The translations for Chinese, as used in Hong Kong (`zh_HK`).
class AppLocalizationsZhHk extends AppLocalizationsZh {
  AppLocalizationsZhHk() : super('zh_HK');

  @override
  String get appTitle => '專家 AI';

  @override
  String get appName => '專家';

  @override
  String get guest => '訪客';

  @override
  String get loginToSaveDesigns => '登入以儲存你嘅設計';

  @override
  String get loggedOutSuccess => '成功登出';

  @override
  String get uploadImage => '上傳圖片';

  @override
  String get clickToUploadImage => '撳呢度從相簿上傳圖片';

  @override
  String get gallery => '相簿';

  @override
  String get camera => '相機';

  @override
  String get uploadItem => '添加物品';

  @override
  String get redesign => '重新設計';

  @override
  String get more => '更多';

  @override
  String get moreOptions => '更多選項';

  @override
  String get history => '歷史記錄';

  @override
  String get noHistoryYet => '暫無歷史記錄';

  @override
  String get uploadedImagesWillAppear => '你上傳同編輯嘅圖片會喺呢度顯示';

  @override
  String get whatToChange => '想改乜嘢？';

  @override
  String get uploadImageFirst => '請先上傳圖片';

  @override
  String get uploadingImage => '上傳緊圖片...';

  @override
  String get errorUploadingImage => '上傳圖片時出錯';

  @override
  String get itemImageLoaded => '物品圖片已載入！喺提示中描述要將佢加喺邊度。';

  @override
  String get addAttachedItem => '將附加嘅物品加入圖片';

  @override
  String get processingStarting => '開始緊...';

  @override
  String get processingMagic => '魔法進行中';

  @override
  String get processing => '處理緊...';

  @override
  String get connectingToCloud => '連接緊雲端... ☁️';

  @override
  String get sendingToAI => '傳送緊俾AI... 🤖';

  @override
  String get analyzingItem => '分析緊物品... 🔍';

  @override
  String get creatingDesign => '創建緊設計... ✨';

  @override
  String get funPhrase1 => '將圖片送去另一個維度... 🌀';

  @override
  String get funPhrase2 => '教AI欣賞靚嘅設計... 🎨';

  @override
  String get funPhrase3 => '說服像素合作... 🤝';

  @override
  String get funPhrase4 => '少少數碼魔法嚟緊... ✨';

  @override
  String get funPhrase5 => '問緊AI點睇... 🤔';

  @override
  String get funPhrase6 => '好似真正嘅藝術家咁調色... 🖌️';

  @override
  String get funPhrase7 => '計算緊完美角度... 📐';

  @override
  String get funPhrase8 => '為你嘅生活增添風格... 💫';

  @override
  String get funPhrase9 => '令間房睇落更貴氣... 💎';

  @override
  String get funPhrase10 => '啟動緊設計魔法... 🪄';

  @override
  String get funPhrase11 => '諮詢緊數碼室內設計師... 🏠';

  @override
  String get funPhrase12 => '努力唔好對結果太興奮... 😍';

  @override
  String get funPhrase13 => '你好快就會見到啲令人驚嘆嘅嘢... 🚀';

  @override
  String get funPhrase14 => '確保一切都對你嚟講係完美嘅... 👌';

  @override
  String get designStyle => '設計風格';

  @override
  String get wallColor => '改變顏色';

  @override
  String get lighting => '燈光';

  @override
  String get furniture => '傢俬';

  @override
  String get doorsWindows => '門窗';

  @override
  String get bathroom => '浴室';

  @override
  String get repairs => '維修';

  @override
  String get general => '一般';

  @override
  String get selectDesignStyle => '選擇設計風格';

  @override
  String get colorPalette => '色板';

  @override
  String get selectLightingType => '選擇燈光類型';

  @override
  String get selectFurnitureType => '選擇傢俬類型';

  @override
  String get selectRepairType => '選擇維修/損壞類型';

  @override
  String get bathroomOptions => '浴室選項';

  @override
  String changeStyleTo(String styleName) {
    return '將風格改為$styleName';
  }

  @override
  String get whatToDo => '想做乜嘢？';

  @override
  String get describeChange => '描述想要嘅改變...';

  @override
  String get cancel => '取消';

  @override
  String get execute => '執行';

  @override
  String comingSoon(String feature) {
    return '$feature - 即將推出！';
  }

  @override
  String get colorChange => '改變顏色';

  @override
  String get allWalls => '所有牆壁';

  @override
  String get paintAllWalls => '油漆房間內所有牆壁';

  @override
  String get specificObject => '特定物件';

  @override
  String get selectWhatToPaint => '揀你想油漆嘅嘢';

  @override
  String get exampleObjects => '例如：梳化、天花板、櫃...';

  @override
  String get confirm => '確認';

  @override
  String get windowOptions => '窗戶選項';

  @override
  String get doorOptions => '門選項';

  @override
  String get toiletOptions => '馬桶選項';

  @override
  String get bathtubOptions => '浴缸選項';

  @override
  String get showerOptions => '花灑選項';

  @override
  String get sinkOptions => '洗手盆選項';

  @override
  String get jacuzziOptions => '按摩浴缸/水療選項';

  @override
  String get poolOptions => '泳池選項';

  @override
  String get professionalSubscription => '專業計劃';

  @override
  String get specialLaunchPrices => '特別推出價 🚀';

  @override
  String get purchaseFailed => '購買失敗';

  @override
  String get yourCurrentPlan => '你嘅現有計劃';

  @override
  String get selectPlan => '選擇計劃';

  @override
  String get perMonth => '/月';

  @override
  String get starterPlan => '入門';

  @override
  String get valuePlan => '超值';

  @override
  String get proPlan => '專業';

  @override
  String imagesPerMonth(int count) {
    return '每月$count張圖片';
  }

  @override
  String get whatsappSupport => 'WhatsApp支援';

  @override
  String get historyStorage => '歷史儲存';

  @override
  String get vipWhatsappSupport => 'VIP WhatsApp支援';

  @override
  String get processingPriority => '優先處理';

  @override
  String get bestValue => '最抵：4倍圖片！🔥';

  @override
  String get forProfessionals => '專業人士適用 ⭐';

  @override
  String savePerImage(String percent) {
    return '每張圖片慳$percent%';
  }

  @override
  String get allDesignTools => '所有設計工具';

  @override
  String get fastSupport => '快速支援';

  @override
  String get noAds => '無廣告';

  @override
  String get restorePurchases => '恢復購買';

  @override
  String get login => '登入';

  @override
  String get logout => '登出';

  @override
  String get createAccount => '建立帳戶';

  @override
  String get createNewAccount => '新帳戶';

  @override
  String get welcomeBack => '歡迎返嚟！登入以繼續';

  @override
  String get joinUs => '加入我哋以儲存設計同使用所有功能';

  @override
  String get email => '電郵';

  @override
  String get password => '密碼';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get fillAllFields => '請填寫所有欄位';

  @override
  String get passwordsNotMatch => '密碼唔一致';

  @override
  String get passwordsDoNotMatch => '密碼唔一致';

  @override
  String get loginButton => '登入';

  @override
  String get createAccountButton => '建立帳戶';

  @override
  String get forgotPassword => '忘記密碼？';

  @override
  String get enterEmailFirst => '請先輸入電郵地址';

  @override
  String get termsAgreement => '登入即表示你同意';

  @override
  String get termsOfService => '服務條款';

  @override
  String get and => '同';

  @override
  String get privacyPolicy => '私隱政策';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-zh.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-zh.html';

  @override
  String get loggingIn => '登入緊...';

  @override
  String get creatingAccount => '建立緊帳戶...';

  @override
  String get loginSuccess => '登入成功！🎉';

  @override
  String get accountCreated => '帳戶建立成功！🎉';

  @override
  String get loginError => '登入錯誤';

  @override
  String get userNotFound => '搵唔到用戶';

  @override
  String get wrongPassword => '密碼錯誤';

  @override
  String get emailInUse => '電郵已被使用';

  @override
  String get weakPassword => '密碼太弱';

  @override
  String get invalidEmail => '無效嘅電郵地址';

  @override
  String get exitAccount => '退出帳戶';

  @override
  String get loginWithEmail => '用電郵登入以儲存你嘅設計';

  @override
  String get mySubscription => '我嘅訂閱';

  @override
  String creditsRemaining(int count) {
    return '剩餘$count個積分';
  }

  @override
  String get upgradeToPremium => '升級至高級版';

  @override
  String get iHaveCoupon => '我有優惠碼';

  @override
  String get enterCouponCode => '輸入優惠碼以獲取免費積分';

  @override
  String get enterCouponCodeTitle => '輸入優惠碼';

  @override
  String get enterCouponCodeSubtitle => '輸入你收到嘅優惠碼以獲取免費積分';

  @override
  String get couponCode => '優惠碼';

  @override
  String get mustEnterCoupon => '你必須輸入優惠碼';

  @override
  String get couponActivated => '優惠碼啟用成功！';

  @override
  String get errorRedeemingCoupon => '兌換優惠碼時出錯';

  @override
  String get redeemCoupon => '兌換優惠碼';

  @override
  String creditsAddedToAccount(int count) {
    return '已添加$count個積分到你嘅帳戶！🎉';
  }

  @override
  String get contactUs => '聯絡我哋';

  @override
  String get contactSubtitle => '我哋好想聽到你嘅意見！填寫詳情，我哋會盡快回覆你。';

  @override
  String get phone => '電話';

  @override
  String get message => '訊息';

  @override
  String get writeYourMessage => '喺呢度寫你嘅訊息...';

  @override
  String get enterPhoneOrEmail => '* 請至少輸入電話或電郵';

  @override
  String get pleaseEnterPhoneOrEmail => '請至少輸入電話或電郵';

  @override
  String get pleaseEnterMessage => '請輸入訊息';

  @override
  String get errorSendingMessage => '傳送訊息時出錯。請再試一次。';

  @override
  String get sendMessage => '傳送訊息';

  @override
  String get messageSentSuccess => '訊息傳送成功！';

  @override
  String get contentNotAllowed => '內容不被允許';

  @override
  String get requestFailed => '請求失敗';

  @override
  String get oopsSomethingWrong => '哎呀！出咗啲問題';

  @override
  String get moderationError =>
      '無法處理呢張圖片或請求。\n\n圖片或請求可能包含唔允許處理嘅內容。\n\n試下用另一張圖片或改變請求。';

  @override
  String get timeoutError => '請求用咗太長時間。\n\n請稍後再試。';

  @override
  String get genericError => '我哋無法處理請求。\n\n請再試一次或聯絡支援如果問題持續。';

  @override
  String get close => '關閉';

  @override
  String get tryAgain => '再試一次';

  @override
  String get imageSavedToGallery => '圖片已儲存到相簿！';

  @override
  String get errorDownloadingImage => '下載圖片時出錯';

  @override
  String get errorSharing => '分享時出錯';

  @override
  String get shareText => '🏠 我用MoomHe AI設計咗呢個！\n📸 你都想試下？ https://moomhe.com';

  @override
  String get comparison => '對比';

  @override
  String get download => '下載';

  @override
  String get share => '分享';

  @override
  String get revertToOriginal => '還原為原圖';

  @override
  String get loveItSave => '鍾意！儲存';

  @override
  String get creditsFinishedThisMonth => '本月積分已用完';

  @override
  String get creditsRanOut => '本月積分已用完';

  @override
  String get freeLimitReached => '你已達到免費使用限額';

  @override
  String get reachedFreeLimit => '你已達到免費使用限額';

  @override
  String creditsLimitReached(int limit) {
    return '你已達到積分限額（$limit個積分）。你可以升級到更大嘅計劃或等到下個月。';
  }

  @override
  String freeCreditsUsed(int limit) {
    return '你已用完所有$limit個免費積分。要繼續無限制設計同獲得進階功能，請升級到專業計劃。';
  }

  @override
  String get currentUsage => '目前使用量';

  @override
  String get limit => '限額';

  @override
  String designs(int count) {
    return '$count個設計';
  }

  @override
  String designsCount(int count) {
    return '$count個設計';
  }

  @override
  String get upgradePlan => '升級計劃';

  @override
  String get goToProfessionalPlan => '轉到專業計劃';

  @override
  String get goPro => '升級專業版';

  @override
  String get notNowThanks => '暫時唔使，多謝';

  @override
  String welcomeToPlan(String planName) {
    return '歡迎使用$planName計劃！';
  }

  @override
  String get thankYouForJoining =>
      '多謝你加入我哋嘅訂閱者家庭。你嘅帳戶已成功升級，你現在可以使用所有進階功能同額外積分。';

  @override
  String get creditsAddedToYourAccount => '積分已添加到你嘅帳戶';

  @override
  String get unlimitedStyleAccess => '無限使用所有風格';

  @override
  String get supportCreators => '支援創作者同設計師';

  @override
  String get startDesigning => '開始設計';

  @override
  String get secureYourSubscription => '保護你嘅訂閱';

  @override
  String get secureSubscriptionMessage =>
      '為咗唔好失去你購買嘅訂閱，我哋建議用電郵登入。\n\n咁樣你可以喺新裝置或重新安裝後恢復你嘅訂閱。';

  @override
  String get later => '之後';

  @override
  String get loginNow => '立即登入';

  @override
  String get onboardingUploadTitle => '上傳圖片';

  @override
  String get onboardingUploadDesc => '首先上傳你想設計嘅房間相片。冇相？唔緊要，我哋會用示範圖片。';

  @override
  String get onboardingStyleTitle => '揀重新設計風格';

  @override
  String get onboardingStyleDesc => '從側邊選單揀你鍾意嘅風格。試下「重新設計」睇唔同選項。';

  @override
  String get onboardingCreateTitle => '創建設計';

  @override
  String get onboardingCreateDesc => '撳「創建」，AI會喺幾秒內重新設計你嘅房間！';

  @override
  String get onboardingItemTipTitle => '額外貼士：添加物品';

  @override
  String get onboardingItemTipDesc => '想添加特定傢俬？用「添加物品」按鈕上傳物品圖片並將佢融入設計。';

  @override
  String get skip => '跳過';

  @override
  String get next => '下一步';

  @override
  String get finish => '完成';

  @override
  String get promptAddedToInput => '提示已添加 - 你可以編輯然後撳創建';

  @override
  String get styleMediterranean => '現代地中海';

  @override
  String get styleWarmMinimalism => '溫暖極簡';

  @override
  String get styleBiophilic => '親生物';

  @override
  String get styleModernLuxury => '現代奢華';

  @override
  String get styleJapandi => '日式北歐';

  @override
  String get styleScandinavian => '斯堪的納維亞';

  @override
  String get styleBohoChic => '波希米亞風';

  @override
  String get styleIndustrial => '工業風';

  @override
  String get styleEarthyNatural => '大地自然';

  @override
  String get styleJerusalem => '耶路撒冷';

  @override
  String get styleMinimalist => '極簡';

  @override
  String get styleModernClassic => '現代古典';

  @override
  String get colorCategoryReds => '紅色系';

  @override
  String get colorCategoryOranges => '橙色系';

  @override
  String get colorCategoryYellows => '黃色系';

  @override
  String get colorCategoryGreens => '綠色系';

  @override
  String get colorCategoryBlues => '藍色系';

  @override
  String get colorCategoryPurples => '紫色系';

  @override
  String get colorCategoryGrays => '灰色系';

  @override
  String get colorCategoryWhitesBlacks => '黑白色系';

  @override
  String get lightingRecessed => '嵌入式燈';

  @override
  String get lightingPendant => '吊燈';

  @override
  String get lightingChandelier => '水晶燈';

  @override
  String get lightingTableLamp => '檯燈';

  @override
  String get lightingFloorLamp => '落地燈';

  @override
  String get lightingWallSconce => '壁燈';

  @override
  String get lightingTrack => '軌道燈';

  @override
  String get lightingCeiling => '天花燈';

  @override
  String get lightingUnderCabinet => '櫃底燈';

  @override
  String get lightingDecorative => '裝飾燈';

  @override
  String get lightingDay => '日間';

  @override
  String get lightingNight => '夜間';

  @override
  String get lightingSunset => '日落';

  @override
  String get lightingSunrise => '日出';

  @override
  String get lightingAddRecessed => '添加嵌入式燈';

  @override
  String get lightingAddPendant => '添加吊燈';

  @override
  String get lightingAddChandelier => '添加水晶燈';

  @override
  String get lightingAddTableLamp => '添加檯燈';

  @override
  String get lightingAddFloorLamp => '添加落地燈';

  @override
  String get lightingAddWallSconce => '添加壁燈';

  @override
  String get lightingAddTrack => '添加軌道燈';

  @override
  String get lightingAddCeiling => '添加天花燈';

  @override
  String get lightingAddUnderCabinet => '添加櫃底燈';

  @override
  String get lightingAddDecorative => '添加裝飾燈';

  @override
  String get lightingChangeToDay => '改為日間燈光';

  @override
  String get lightingChangeToNight => '改為夜間燈光';

  @override
  String get lightingChangeToSunset => '改為日落燈光';

  @override
  String get lightingChangeToSunrise => '改為日出燈光';

  @override
  String get furnitureSofa => '梳化';

  @override
  String get furnitureSectional => '組合梳化';

  @override
  String get furnitureArmchair => '扶手椅';

  @override
  String get furnitureAccentChair => '特色椅';

  @override
  String get furnitureDiningChair => '餐椅';

  @override
  String get furnitureBarStool => '吧檯凳';

  @override
  String get furnitureSingleBed => '單人床';

  @override
  String get furnitureDoubleBed => '雙人床';

  @override
  String get furnitureBeanbag => '豆袋椅';

  @override
  String get furnitureOttoman => '腳凳';

  @override
  String get furnitureBench => '長凳';

  @override
  String get furnitureCoffeeTable => '茶几';

  @override
  String get furnitureEndTable => '邊桌';

  @override
  String get furnitureNightstand => '床頭櫃';

  @override
  String get furnitureDiningTable => '餐桌';

  @override
  String get furnitureDesk => '書桌';

  @override
  String get furnitureDresser => '梳妝台';

  @override
  String get furnitureWardrobe => '衣櫃';

  @override
  String get furnitureBookcase => '書架';

  @override
  String get furnitureTvStand => '電視櫃';

  @override
  String get furnitureCabinets => '廚櫃';

  @override
  String get furnitureAddSofa => '添加梳化';

  @override
  String get furnitureAddSectional => '添加組合梳化';

  @override
  String get furnitureAddArmchair => '添加扶手椅';

  @override
  String get furnitureAddAccentChair => '添加特色椅';

  @override
  String get furnitureAddDiningChair => '添加餐椅';

  @override
  String get furnitureAddBarStool => '添加吧檯凳';

  @override
  String get furnitureAddSingleBed => '添加單人床';

  @override
  String get furnitureAddDoubleBed => '添加雙人床';

  @override
  String get furnitureAddBeanbag => '添加豆袋椅';

  @override
  String get furnitureAddOttoman => '添加腳凳';

  @override
  String get furnitureAddBench => '添加長凳';

  @override
  String get furnitureAddCoffeeTable => '添加茶几';

  @override
  String get furnitureAddEndTable => '添加邊桌';

  @override
  String get furnitureAddNightstand => '添加床頭櫃';

  @override
  String get furnitureAddDiningTable => '添加餐桌';

  @override
  String get furnitureAddDesk => '添加書桌';

  @override
  String get furnitureAddDresser => '添加梳妝台';

  @override
  String get furnitureAddWardrobe => '添加衣櫃';

  @override
  String get furnitureAddBookcase => '添加書架';

  @override
  String get furnitureAddTvStand => '添加電視櫃';

  @override
  String get furnitureAddCabinets => '添加廚櫃';

  @override
  String get repairsFixEverything => '修復所有嘢';

  @override
  String get repairsRepairAll => '修復同維修所有嘢';

  @override
  String get repairsMessUp => '搞亂所有嘢';

  @override
  String get repairsDestroy => '破壞同損壞所有嘢';

  @override
  String get windowPicture => '觀景窗';

  @override
  String get windowSliding => '趟窗';

  @override
  String get windowCasement => '平開窗';

  @override
  String get windowTiltTurn => '傾斜旋轉窗';

  @override
  String get windowAwning => '遮篷窗';

  @override
  String get windowSash => '上下推窗';

  @override
  String get windowPocket => '隱藏式窗';

  @override
  String get windowArched => '拱形窗';

  @override
  String get windowAddPicture => '添加大型觀景窗';

  @override
  String get windowAddSliding => '添加趟窗';

  @override
  String get windowAddCasement => '添加平開窗';

  @override
  String get windowAddTiltTurn => '添加傾斜旋轉窗';

  @override
  String get windowAddAwning => '添加遮篷窗';

  @override
  String get windowAddSash => '添加上下推窗';

  @override
  String get windowAddPocket => '添加隱藏式窗';

  @override
  String get windowAddArched => '添加拱形窗';

  @override
  String get doorPocket => '隱藏式門';

  @override
  String get doorFrench => '法式門';

  @override
  String get doorLouvered => '百葉門';

  @override
  String get doorBarn => '穀倉門';

  @override
  String get doorAddPocket => '添加滑入牆內嘅隱藏式門';

  @override
  String get doorAddFrench => '添加玻璃法式門';

  @override
  String get doorAddLouvered => '添加百葉門';

  @override
  String get doorAddBarn => '添加穀倉門';

  @override
  String get toiletBidet => '加熱智能廁板';

  @override
  String get toiletSeat => '廁板';

  @override
  String get tubFreestanding => '獨立式浴缸';

  @override
  String get tubVintage => '復古浴缸';

  @override
  String get tubStandard => '標準浴缸';

  @override
  String get showerRain => '花灑淋浴';

  @override
  String get showerEnclosure => '淋浴間';

  @override
  String get showerSliding => '趟門淋浴間';

  @override
  String get sinkPedestal => '立柱式洗手盆';

  @override
  String get sinkStainless => '不銹鋼洗手盆';

  @override
  String get sinkUndermount => '下嵌式洗手盆';

  @override
  String get jacuzziBuiltIn => '內置按摩浴缸';

  @override
  String get jacuzziPortable => '便攜式按摩浴缸';

  @override
  String get poolInground => '地下泳池';

  @override
  String get poolAboveGround => '地上泳池';

  @override
  String get toiletAddBidet => '添加智能廁板';

  @override
  String get toiletAddSeat => '添加廁板';

  @override
  String get tubAddFreestanding => '添加獨立式浴缸';

  @override
  String get tubAddVintage => '添加復古浴缸';

  @override
  String get tubAddStandard => '添加標準浴缸';

  @override
  String get showerAddRain => '添加花灑淋浴';

  @override
  String get showerAddEnclosure => '添加淋浴間';

  @override
  String get showerAddSliding => '添加趟門淋浴間';

  @override
  String get sinkAddPedestal => '添加立柱式洗手盆';

  @override
  String get sinkAddStainless => '添加不銹鋼洗手盆';

  @override
  String get sinkAddUndermount => '添加下嵌式洗手盆';

  @override
  String get jacuzziAddBuiltIn => '添加內置按摩浴缸';

  @override
  String get jacuzziAddPortable => '添加便攜式按摩浴缸';

  @override
  String get poolAddInground => '添加地下泳池';

  @override
  String get poolAddAboveGround => '添加地上泳池';

  @override
  String get errorUnknown => '未知錯誤';

  @override
  String get searchWithLens => '搜尋';

  @override
  String get cancelSearch => '取消';

  @override
  String get selectAreaToSearch => '喺你想搜尋嘅物品周圍畫一個矩形';

  @override
  String get searchingWithGoogleLens => '用Google Lens搜尋緊...';

  @override
  String get selectAreaWithinImage => '請喺圖片內選擇一個區域';

  @override
  String get googleLensSearchFailed => '搜尋失敗。請再試一次。';

  @override
  String get rateAppTitle => '鍾意呢個應用程式？';

  @override
  String get rateAppMessage => '我哋好想聽到你嘅意見！你嘅反饋幫助我哋改進。';

  @override
  String get rateAppYes => '係，我鍾意！😍';

  @override
  String get rateAppNo => '唔係好鍾意';

  @override
  String get rateAppLater => '之後再問我';

  @override
  String get deleteAccount => '刪除帳戶';

  @override
  String get deleteAccountWarning1Title => '刪除帳戶';

  @override
  String get deleteAccountWarning1Message => '你確定要刪除帳戶？呢個會刪除你所有資料同圖片，而且無法復原。';

  @override
  String get deleteAccountWarning2Title => '最終確認';

  @override
  String get deleteAccountWarning2Message =>
      '呢個操作無法復原！你所有歷史記錄同圖片將被永久刪除。你100%確定？';

  @override
  String get deleteAccountConfirm => '係，刪除帳戶';

  @override
  String get deletingAccount => '刪除緊帳戶...';

  @override
  String get accountDeleted => '帳戶刪除成功';

  @override
  String get errorDeletingAccount => '刪除帳戶時出錯';

  @override
  String get language => '語言';

  @override
  String get selectLanguage => '揀語言';

  @override
  String get languageChanged => '語言已更改';

  @override
  String get createAccountPromptTitle => '建立您的帳戶';

  @override
  String get createAccountPromptMessage =>
      '未來幾週將有令人驚嘆的更新！🚀\n\n立即建立帳戶，以免遺失您的創作，並成為第一個享受新功能的人。';

  @override
  String get createAccountPromptButton => '建立帳戶';

  @override
  String get maybeLater => '稍後再說';

  @override
  String get readyDesigns => '設計畫廊';

  @override
  String get noCategories => '暫無分類';

  @override
  String get noDesigns => '暫無設計';

  @override
  String get noDesignsInCategory => '該分類暫無設計';

  @override
  String get loadingDesigns => '正在載入設計...';

  @override
  String get loading => '載入中...';

  @override
  String get categoryKitchen => '廚房';

  @override
  String get categoryKidsBedroom => '兒童睡房';

  @override
  String get categoryBathroom => '浴室';

  @override
  String get categoryLivingRoom => '客廳';

  @override
  String get categoryMasterBedroom => '主人房';
}
