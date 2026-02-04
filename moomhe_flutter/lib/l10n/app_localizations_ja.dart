// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Expert AI';

  @override
  String get appName => 'Expert';

  @override
  String get guest => 'ゲスト';

  @override
  String get loginToSaveDesigns => 'デザインを保存するにはログインしてください';

  @override
  String get loggedOutSuccess => 'ログアウトしました';

  @override
  String get uploadImage => '画像をアップロード';

  @override
  String get clickToUploadImage => 'ここをクリックしてギャラリーから画像をアップロード';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get camera => 'カメラ';

  @override
  String get uploadItem => 'アイテム追加';

  @override
  String get redesign => 'リデザイン';

  @override
  String get more => 'もっと';

  @override
  String get moreOptions => 'その他のオプション';

  @override
  String get history => '履歴';

  @override
  String get noHistoryYet => '履歴はまだありません';

  @override
  String get uploadedImagesWillAppear => 'アップロードおよび編集した画像がここに表示されます';

  @override
  String get whatToChange => '何を変更しますか？';

  @override
  String get uploadImageFirst => 'まず画像をアップロードしてください';

  @override
  String get uploadingImage => '画像をアップロード中...';

  @override
  String get errorUploadingImage => '画像のアップロードエラー';

  @override
  String get itemImageLoaded => 'アイテム画像を読み込みました！プロンプトでどこに追加するか説明してください。';

  @override
  String get addAttachedItem => '添付したアイテムを画像に追加';

  @override
  String get processingStarting => '開始中...';

  @override
  String get processingMagic => '魔法が起こっています';

  @override
  String get processing => '処理中...';

  @override
  String get connectingToCloud => 'クラウドに接続中... ☁️';

  @override
  String get sendingToAI => 'AIに送信中... 🤖';

  @override
  String get analyzingItem => 'アイテムを分析中... 🔍';

  @override
  String get creatingDesign => 'デザインを作成中... ✨';

  @override
  String get funPhrase1 => '画像を別次元に送っています... 🌀';

  @override
  String get funPhrase2 => 'AIに良いデザインを教えています... 🎨';

  @override
  String get funPhrase3 => 'ピクセルを説得しています... 🤝';

  @override
  String get funPhrase4 => 'デジタルマジック実行中... ✨';

  @override
  String get funPhrase5 => 'AIに意見を聞いています... 🤔';

  @override
  String get funPhrase6 => '本物のアーティストのように色を混ぜています... 🖌️';

  @override
  String get funPhrase7 => '完璧な角度を計算中... 📐';

  @override
  String get funPhrase8 => 'あなたの生活にスタイルを追加中... 💫';

  @override
  String get funPhrase9 => '部屋をより高級に見せています... 💎';

  @override
  String get funPhrase10 => 'デザインマジックを起動中... 🪄';

  @override
  String get funPhrase11 => 'デジタルインテリアデザイナーと相談中... 🏠';

  @override
  String get funPhrase12 => '結果に興奮しすぎないようにしています... 😍';

  @override
  String get funPhrase13 => 'もうすぐ素晴らしいものが見られます... 🚀';

  @override
  String get funPhrase14 => 'すべてが完璧になるようにしています... 👌';

  @override
  String get designStyle => 'デザインスタイル';

  @override
  String get wallColor => '色を変更';

  @override
  String get lighting => '照明';

  @override
  String get furniture => '家具';

  @override
  String get doorsWindows => 'ドアと窓';

  @override
  String get bathroom => 'バスルーム';

  @override
  String get repairs => '修理';

  @override
  String get general => '一般';

  @override
  String get selectDesignStyle => 'デザインスタイルを選択';

  @override
  String get colorPalette => 'カラーパレット';

  @override
  String get selectLightingType => '照明タイプを選択';

  @override
  String get selectFurnitureType => '家具タイプを選択';

  @override
  String get selectRepairType => '修理/損傷タイプを選択';

  @override
  String get bathroomOptions => 'バスルームオプション';

  @override
  String changeStyleTo(String styleName) {
    return 'スタイルを$styleNameに変更';
  }

  @override
  String get whatToDo => '何をしますか？';

  @override
  String get describeChange => '変更したい内容を説明してください...';

  @override
  String get cancel => 'キャンセル';

  @override
  String get execute => '実行';

  @override
  String comingSoon(String feature) {
    return '$feature - 近日公開！';
  }

  @override
  String get colorChange => '色を変更';

  @override
  String get allWalls => 'すべての壁';

  @override
  String get paintAllWalls => '部屋のすべての壁を塗る';

  @override
  String get specificObject => '特定のオブジェクト';

  @override
  String get selectWhatToPaint => '塗りたいものを選んでください';

  @override
  String get exampleObjects => '例：ソファ、天井、キャビネット...';

  @override
  String get confirm => '確認';

  @override
  String get windowOptions => '窓オプション';

  @override
  String get doorOptions => 'ドアオプション';

  @override
  String get toiletOptions => 'トイレオプション';

  @override
  String get bathtubOptions => 'バスタブオプション';

  @override
  String get showerOptions => 'シャワーオプション';

  @override
  String get sinkOptions => 'シンクオプション';

  @override
  String get jacuzziOptions => 'ジャグジー/スパオプション';

  @override
  String get poolOptions => 'プールオプション';

  @override
  String get professionalSubscription => 'プロフェッショナルプラン';

  @override
  String get specialLaunchPrices => '特別発売価格 🚀';

  @override
  String get purchaseFailed => '購入に失敗しました';

  @override
  String get yourCurrentPlan => '現在のプラン';

  @override
  String get selectPlan => 'プランを選択';

  @override
  String get perMonth => '/月';

  @override
  String get starterPlan => 'スターター';

  @override
  String get valuePlan => 'バリュー';

  @override
  String get proPlan => 'プロフェッショナル';

  @override
  String imagesPerMonth(int count) {
    return '月$count枚の画像';
  }

  @override
  String get whatsappSupport => 'WhatsAppサポート';

  @override
  String get historyStorage => '履歴ストレージ';

  @override
  String get vipWhatsappSupport => 'VIP WhatsAppサポート';

  @override
  String get processingPriority => '処理優先度';

  @override
  String get bestValue => '最もお得：4倍の画像！ 🔥';

  @override
  String get forProfessionals => 'プロフェッショナル向け ⭐';

  @override
  String savePerImage(String percent) {
    return '画像あたり$percent%節約';
  }

  @override
  String get allDesignTools => 'すべてのデザインツール';

  @override
  String get fastSupport => '迅速サポート';

  @override
  String get noAds => '広告なし';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get login => 'ログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get createNewAccount => '新規アカウント';

  @override
  String get welcomeBack => 'おかえりなさい！ログインして続けてください';

  @override
  String get joinUs => '参加してデザインを保存し、すべての機能にアクセスしましょう';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get fillAllFields => 'すべてのフィールドを入力してください';

  @override
  String get passwordsNotMatch => 'パスワードが一致しません';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get loginButton => 'ログイン';

  @override
  String get createAccountButton => 'アカウント作成';

  @override
  String get forgotPassword => 'パスワードを忘れた？';

  @override
  String get enterEmailFirst => 'まずメールアドレスを入力してください';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox and spam folder.';

  @override
  String get passwordResetError => 'Error sending password reset email';

  @override
  String get termsAgreement => 'ログインすると同意したことになります';

  @override
  String get termsOfService => '利用規約';

  @override
  String get and => 'および';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-en.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-en.html';

  @override
  String get loggingIn => 'ログイン中...';

  @override
  String get creatingAccount => 'アカウント作成中...';

  @override
  String get loginSuccess => 'ログインしました！ 🎉';

  @override
  String get accountCreated => 'アカウントが作成されました！ 🎉';

  @override
  String get loginError => 'ログインエラー';

  @override
  String get userNotFound => 'ユーザーが見つかりません';

  @override
  String get wrongPassword => 'パスワードが間違っています';

  @override
  String get emailInUse => 'メールアドレスは既に使用されています';

  @override
  String get weakPassword => 'パスワードが弱すぎます';

  @override
  String get invalidEmail => '無効なメールアドレス';

  @override
  String get exitAccount => 'アカウントを終了';

  @override
  String get loginWithEmail => 'メールでログインしてデザインを保存';

  @override
  String get mySubscription => 'マイサブスクリプション';

  @override
  String creditsRemaining(int count) {
    return '残り$countクレジット';
  }

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get iHaveCoupon => 'クーポンを持っています';

  @override
  String get enterCouponCode => 'クーポンコードを入力して無料クレジットを獲得';

  @override
  String get enterCouponCodeTitle => 'クーポンコードを入力';

  @override
  String get enterCouponCodeSubtitle => '受け取ったクーポンコードを入力して無料クレジットを獲得';

  @override
  String get couponCode => 'クーポンコード';

  @override
  String get mustEnterCoupon => 'クーポンコードを入力してください';

  @override
  String get couponActivated => 'クーポンが有効化されました！';

  @override
  String get errorRedeemingCoupon => 'クーポン引き換えエラー';

  @override
  String get redeemCoupon => 'クーポンを引き換え';

  @override
  String creditsAddedToAccount(int count) {
    return 'アカウントに$countクレジットが追加されました！ 🎉';
  }

  @override
  String get contactUs => 'お問い合わせ';

  @override
  String get contactSubtitle => 'ご連絡をお待ちしております！詳細を入力してください。';

  @override
  String get phone => '電話';

  @override
  String get message => 'メッセージ';

  @override
  String get writeYourMessage => 'ここにメッセージを入力...';

  @override
  String get enterPhoneOrEmail => '* 電話またはメールを入力してください';

  @override
  String get pleaseEnterPhoneOrEmail => '電話またはメールを入力してください';

  @override
  String get pleaseEnterMessage => 'メッセージを入力してください';

  @override
  String get errorSendingMessage => 'メッセージ送信エラー。再試行してください。';

  @override
  String get sendMessage => 'メッセージを送信';

  @override
  String get messageSentSuccess => 'メッセージが送信されました！';

  @override
  String get contentNotAllowed => 'コンテンツが許可されていません';

  @override
  String get requestFailed => 'リクエスト失敗';

  @override
  String get oopsSomethingWrong => 'おっと！何かがうまくいきませんでした';

  @override
  String get moderationError =>
      'この画像またはリクエストを処理できません。\n\n画像またはリクエストに処理が許可されていないコンテンツが含まれている可能性があります。\n\n別の画像で試すか、リクエストを変更してください。';

  @override
  String get timeoutError => 'リクエストに時間がかかりすぎました。\n\n後でもう一度試してください。';

  @override
  String get genericError =>
      'リクエストを処理できませんでした。\n\n再試行するか、問題が続く場合はサポートにお問い合わせください。';

  @override
  String get close => '閉じる';

  @override
  String get tryAgain => '再試行';

  @override
  String get imageSavedToGallery => '画像がギャラリーに保存されました！';

  @override
  String get errorDownloadingImage => '画像のダウンロードエラー';

  @override
  String get errorSharing => '共有エラー';

  @override
  String get shareText =>
      '🏠 MoomHe AIでこれをデザインしました！\n📸 あなたも試してみませんか？ https://moomhe.com';

  @override
  String get comparison => '比較';

  @override
  String get download => 'ダウンロード';

  @override
  String get share => '共有';

  @override
  String get revertToOriginal => '元に戻す';

  @override
  String get loveItSave => '気に入った！保存';

  @override
  String get creditsFinishedThisMonth => '今月のクレジットを使い切りました';

  @override
  String get creditsRanOut => '今月のクレジットがなくなりました';

  @override
  String get freeLimitReached => '無料利用制限に達しました';

  @override
  String get reachedFreeLimit => '無料利用制限に達しました';

  @override
  String creditsLimitReached(int limit) {
    return 'クレジット制限に達しました（$limitクレジット）。より大きなプランにアップグレードするか、来月までお待ちください。';
  }

  @override
  String freeCreditsUsed(int limit) {
    return '無料クレジット$limitクレジットをすべて使用しました。制限なくデザインを続け、高度な機能を利用するには、プロフェッショナルプランにアップグレードしてください。';
  }

  @override
  String get currentUsage => '現在の使用量';

  @override
  String get limit => '制限';

  @override
  String designs(int count) {
    return '$countデザイン';
  }

  @override
  String designsCount(int count) {
    return '$countデザイン';
  }

  @override
  String get upgradePlan => 'プランをアップグレード';

  @override
  String get goToProfessionalPlan => 'プロフェッショナルプランへ';

  @override
  String get goPro => 'プロへ';

  @override
  String get notNowThanks => '今はいいです、ありがとう';

  @override
  String welcomeToPlan(String planName) {
    return '$planNameプランへようこそ！';
  }

  @override
  String get thankYouForJoining =>
      'ご登録いただきありがとうございます。アカウントがアップグレードされ、すべての高度な機能と追加クレジットにアクセスできるようになりました。';

  @override
  String get creditsAddedToYourAccount => 'アカウントにクレジットが追加されました';

  @override
  String get unlimitedStyleAccess => 'すべてのスタイルへの無制限アクセス';

  @override
  String get supportCreators => 'クリエイターとデザイナーのサポート';

  @override
  String get startDesigning => 'デザインを開始';

  @override
  String get secureYourSubscription => 'サブスクリプションを保護';

  @override
  String get secureSubscriptionMessage =>
      '購入したサブスクリプションを失わないために、メールでログインすることをお勧めします。\n\nこれにより、新しいデバイスや再インストール後にサブスクリプションを復元できます。';

  @override
  String get later => '後で';

  @override
  String get loginNow => '今すぐログイン';

  @override
  String get onboardingUploadTitle => '画像をアップロード';

  @override
  String get onboardingUploadDesc =>
      'デザインしたい部屋の写真をアップロードして始めましょう。写真がない場合は、サンプル画像を使用します。';

  @override
  String get onboardingStyleTitle => 'リデザインスタイルを選択';

  @override
  String get onboardingStyleDesc =>
      'サイドメニューからお好みのスタイルを選択してください。「リデザイン」を試して、さまざまなオプションを確認してください。';

  @override
  String get onboardingCreateTitle => 'デザインを作成';

  @override
  String get onboardingCreateDesc => '「作成」をクリックすると、AIが数秒で部屋をリデザインします！';

  @override
  String get onboardingItemTipTitle => 'ヒント：アイテムを追加';

  @override
  String get onboardingItemTipDesc =>
      '特定の家具を追加したいですか？「アイテム追加」ボタンを使用してアイテムの画像をアップロードし、デザインに組み込みましょう。';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get finish => '完了';

  @override
  String get promptAddedToInput => 'プロンプトが追加されました - 編集して「作成」をタップできます';

  @override
  String get styleMediterranean => 'モダン地中海';

  @override
  String get styleWarmMinimalism => 'ウォームミニマリズム';

  @override
  String get styleBiophilic => 'バイオフィリック';

  @override
  String get styleModernLuxury => 'モダンラグジュアリー';

  @override
  String get styleJapandi => 'ジャパンディ';

  @override
  String get styleScandinavian => 'スカンジナビア';

  @override
  String get styleBohoChic => 'ボーホーシック';

  @override
  String get styleIndustrial => 'インダストリアル';

  @override
  String get styleEarthyNatural => 'アースィナチュラル';

  @override
  String get styleJerusalem => 'エルサレム';

  @override
  String get styleMinimalist => 'ミニマリスト';

  @override
  String get styleModernClassic => 'モダンクラシック';

  @override
  String get colorCategoryReds => '赤系';

  @override
  String get colorCategoryOranges => 'オレンジ系';

  @override
  String get colorCategoryYellows => '黄色系';

  @override
  String get colorCategoryGreens => '緑系';

  @override
  String get colorCategoryBlues => '青系';

  @override
  String get colorCategoryPurples => '紫系';

  @override
  String get colorCategoryGrays => 'グレー系';

  @override
  String get colorCategoryWhitesBlacks => '白と黒';

  @override
  String get lightingRecessed => '埋め込み照明';

  @override
  String get lightingPendant => 'ペンダントライト';

  @override
  String get lightingChandelier => 'シャンデリア';

  @override
  String get lightingTableLamp => 'テーブルランプ';

  @override
  String get lightingFloorLamp => 'フロアランプ';

  @override
  String get lightingWallSconce => 'ウォールライト';

  @override
  String get lightingTrack => 'トラック照明';

  @override
  String get lightingCeiling => 'シーリングライト';

  @override
  String get lightingUnderCabinet => 'キャビネット下照明';

  @override
  String get lightingDecorative => 'デコラティブライト';

  @override
  String get lightingDay => '昼間';

  @override
  String get lightingNight => '夜間';

  @override
  String get lightingSunset => '夕日';

  @override
  String get lightingSunrise => '日の出';

  @override
  String get lightingAddRecessed => '埋め込み照明を追加';

  @override
  String get lightingAddPendant => 'ペンダントライトを追加';

  @override
  String get lightingAddChandelier => 'シャンデリアを追加';

  @override
  String get lightingAddTableLamp => 'テーブルランプを追加';

  @override
  String get lightingAddFloorLamp => 'フロアランプを追加';

  @override
  String get lightingAddWallSconce => 'ウォールライトを追加';

  @override
  String get lightingAddTrack => 'トラック照明を追加';

  @override
  String get lightingAddCeiling => 'シーリングライトを追加';

  @override
  String get lightingAddUnderCabinet => 'キャビネット下照明を追加';

  @override
  String get lightingAddDecorative => 'デコラティブライトを追加';

  @override
  String get lightingChangeToDay => '照明を昼光に変更';

  @override
  String get lightingChangeToNight => '照明を夜光に変更';

  @override
  String get lightingChangeToSunset => '照明を夕日に変更';

  @override
  String get lightingChangeToSunrise => '照明を日の出に変更';

  @override
  String get furnitureSofa => 'ソファ';

  @override
  String get furnitureSectional => 'セクショナルソファ';

  @override
  String get furnitureArmchair => 'アームチェア';

  @override
  String get furnitureAccentChair => 'アクセントチェア';

  @override
  String get furnitureDiningChair => 'ダイニングチェア';

  @override
  String get furnitureBarStool => 'バースツール';

  @override
  String get furnitureSingleBed => 'シングルベッド';

  @override
  String get furnitureDoubleBed => 'ダブルベッド';

  @override
  String get furnitureBeanbag => 'ビーズクッション';

  @override
  String get furnitureOttoman => 'オットマン';

  @override
  String get furnitureBench => 'ベンチ';

  @override
  String get furnitureCoffeeTable => 'コーヒーテーブル';

  @override
  String get furnitureEndTable => 'サイドテーブル';

  @override
  String get furnitureNightstand => 'ナイトスタンド';

  @override
  String get furnitureDiningTable => 'ダイニングテーブル';

  @override
  String get furnitureDesk => 'デスク';

  @override
  String get furnitureDresser => 'ドレッサー';

  @override
  String get furnitureWardrobe => 'ワードローブ';

  @override
  String get furnitureBookcase => '本棚';

  @override
  String get furnitureTvStand => 'テレビ台';

  @override
  String get furnitureCabinets => 'キッチンキャビネット';

  @override
  String get furnitureAddSofa => 'ソファを追加';

  @override
  String get furnitureAddSectional => 'セクショナルソファを追加';

  @override
  String get furnitureAddArmchair => 'アームチェアを追加';

  @override
  String get furnitureAddAccentChair => 'アクセントチェアを追加';

  @override
  String get furnitureAddDiningChair => 'ダイニングチェアを追加';

  @override
  String get furnitureAddBarStool => 'バースツールを追加';

  @override
  String get furnitureAddSingleBed => 'シングルベッドを追加';

  @override
  String get furnitureAddDoubleBed => 'ダブルベッドを追加';

  @override
  String get furnitureAddBeanbag => 'ビーズクッションを追加';

  @override
  String get furnitureAddOttoman => 'オットマンを追加';

  @override
  String get furnitureAddBench => 'ベンチを追加';

  @override
  String get furnitureAddCoffeeTable => 'コーヒーテーブルを追加';

  @override
  String get furnitureAddEndTable => 'サイドテーブルを追加';

  @override
  String get furnitureAddNightstand => 'ナイトスタンドを追加';

  @override
  String get furnitureAddDiningTable => 'ダイニングテーブルを追加';

  @override
  String get furnitureAddDesk => 'デスクを追加';

  @override
  String get furnitureAddDresser => 'ドレッサーを追加';

  @override
  String get furnitureAddWardrobe => 'ワードローブを追加';

  @override
  String get furnitureAddBookcase => '本棚を追加';

  @override
  String get furnitureAddTvStand => 'テレビ台を追加';

  @override
  String get furnitureAddCabinets => 'キッチンキャビネットを追加';

  @override
  String get repairsFixEverything => 'すべてを修正';

  @override
  String get repairsRepairAll => 'すべてを修正・修理';

  @override
  String get repairsMessUp => 'すべてを散らかす';

  @override
  String get repairsDestroy => 'すべてを破壊・損傷';

  @override
  String get windowPicture => 'ピクチャーウィンドウ';

  @override
  String get windowSliding => 'スライディングウィンドウ';

  @override
  String get windowCasement => 'ケースメントウィンドウ';

  @override
  String get windowTiltTurn => 'チルト＆ターンウィンドウ';

  @override
  String get windowAwning => 'オーニングウィンドウ';

  @override
  String get windowSash => 'サッシウィンドウ';

  @override
  String get windowPocket => 'ポケットウィンドウ';

  @override
  String get windowArched => 'アーチ型ウィンドウ';

  @override
  String get windowAddPicture => '大きなピクチャーウィンドウを追加';

  @override
  String get windowAddSliding => 'スライディングウィンドウを追加';

  @override
  String get windowAddCasement => 'ケースメントウィンドウを追加';

  @override
  String get windowAddTiltTurn => 'チルト＆ターンウィンドウを追加';

  @override
  String get windowAddAwning => 'オーニングウィンドウを追加';

  @override
  String get windowAddSash => 'サッシウィンドウを追加';

  @override
  String get windowAddPocket => 'ポケットウィンドウを追加';

  @override
  String get windowAddArched => 'アーチ型ウィンドウを追加';

  @override
  String get doorPocket => 'ポケットドア';

  @override
  String get doorFrench => 'フレンチドア';

  @override
  String get doorLouvered => 'ルーバードア';

  @override
  String get doorBarn => 'バーンドア';

  @override
  String get doorAddPocket => '壁に入るポケットドアを追加';

  @override
  String get doorAddFrench => 'ガラス付きフレンチドアを追加';

  @override
  String get doorAddLouvered => 'ルーバードアを追加';

  @override
  String get doorAddBarn => 'バーンドアを追加';

  @override
  String get toiletBidet => '温水ビデ';

  @override
  String get toiletSeat => '便座';

  @override
  String get tubFreestanding => '独立型バスタブ';

  @override
  String get tubVintage => 'ヴィンテージバスタブ';

  @override
  String get tubStandard => '標準バスタブ';

  @override
  String get showerRain => 'レインシャワー';

  @override
  String get showerEnclosure => 'シャワーエンクロージャー';

  @override
  String get showerSliding => 'スライディングシャワードア';

  @override
  String get sinkPedestal => 'ペデスタルシンク';

  @override
  String get sinkStainless => 'ステンレスシンク';

  @override
  String get sinkUndermount => 'アンダーマウントシンク';

  @override
  String get jacuzziBuiltIn => 'ビルトインジャグジー';

  @override
  String get jacuzziPortable => 'ポータブルジャグジー';

  @override
  String get poolInground => '地上プール';

  @override
  String get poolAboveGround => '地上式プール';

  @override
  String get toiletAddBidet => 'ビデ付き便座を追加';

  @override
  String get toiletAddSeat => '便座を追加';

  @override
  String get tubAddFreestanding => '独立型バスタブを追加';

  @override
  String get tubAddVintage => 'ヴィンテージバスタブを追加';

  @override
  String get tubAddStandard => '標準バスタブを追加';

  @override
  String get showerAddRain => 'レインシャワーヘッド付きシャワーを追加';

  @override
  String get showerAddEnclosure => 'シャワーエンクロージャーを追加';

  @override
  String get showerAddSliding => 'スライディングドア付きシャワーを追加';

  @override
  String get sinkAddPedestal => 'ペデスタルシンクを追加';

  @override
  String get sinkAddStainless => 'ステンレスシンクを追加';

  @override
  String get sinkAddUndermount => 'アンダーマウントシンクを追加';

  @override
  String get jacuzziAddBuiltIn => 'ビルトインジャグジーを追加';

  @override
  String get jacuzziAddPortable => 'ポータブルジャグジーを追加';

  @override
  String get poolAddInground => '地上プールを追加';

  @override
  String get poolAddAboveGround => '地上式プールを追加';

  @override
  String get errorUnknown => '不明なエラー';

  @override
  String get searchWithLens => '検索';

  @override
  String get cancelSearch => 'キャンセル';

  @override
  String get selectAreaToSearch => '検索したいアイテムの周りに四角形を描いてください';

  @override
  String get searchingWithGoogleLens => 'Google Lensで検索中...';

  @override
  String get selectAreaWithinImage => '画像内のエリアを選択してください';

  @override
  String get googleLensSearchFailed => '検索に失敗しました。再試行してください。';

  @override
  String get rateAppTitle => 'アプリを楽しんでいますか？';

  @override
  String get rateAppMessage => 'ご感想をお聞かせください！フィードバックは改善に役立ちます。';

  @override
  String get rateAppYes => 'はい、大好きです！ 😍';

  @override
  String get rateAppNo => 'あまり';

  @override
  String get rateAppLater => '後で聞いてください';

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get deleteAccountWarning1Title => 'アカウント削除';

  @override
  String get deleteAccountWarning1Message =>
      'アカウントを削除してもよろしいですか？これによりすべての情報と画像が削除され、元に戻すことはできません。';

  @override
  String get deleteAccountWarning2Title => '最終確認';

  @override
  String get deleteAccountWarning2Message =>
      'この操作は元に戻せません！すべての履歴と画像が永久に削除されます。本当に100%確実ですか？';

  @override
  String get deleteAccountConfirm => 'はい、アカウントを削除';

  @override
  String get deletingAccount => 'アカウントを削除中...';

  @override
  String get accountDeleted => 'アカウントが削除されました';

  @override
  String get errorDeletingAccount => 'アカウント削除エラー';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get languageChanged => '言語が変更されました';

  @override
  String get createAccountPromptTitle => 'アカウントを作成';

  @override
  String get createAccountPromptMessage =>
      '数週間以内に素晴らしいアップデートが届きます！🚀\n\n今すぐアカウントを作成して、作品を失わないようにし、新機能をいち早くお楽しみください。';

  @override
  String get createAccountPromptButton => 'アカウント作成';

  @override
  String get maybeLater => '後で';

  @override
  String get readyDesigns => 'デザインギャラリー';

  @override
  String get noCategories => 'カテゴリーがありません';

  @override
  String get noDesigns => 'デザインがありません';

  @override
  String get noDesignsInCategory => 'このカテゴリーにデザインがありません';

  @override
  String get loadingDesigns => 'デザインを読み込み中...';

  @override
  String get loading => '読み込み中...';

  @override
  String get categoryKitchen => 'キッチン';

  @override
  String get categoryKidsBedroom => '子供部屋';

  @override
  String get categoryBathroom => 'バスルーム';

  @override
  String get categoryLivingRoom => 'リビングルーム';

  @override
  String get categoryMasterBedroom => '主寝室';

  @override
  String get useDesignQuestion => 'このデザインを使用しますか？';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get featureCarouselTitle1 => 'AIパワードデザイン';

  @override
  String get featureCarouselSubtitle1 => '✨ インテリジェントリデザイン';

  @override
  String get featureCarouselDesc1 =>
      '最先端のAIでどんな部屋も変身させましょう。写真をアップロードするだけで、プロ級のデザインで空間が生まれ変わります。';

  @override
  String get featureCarouselTitle2 => '無限の可能性';

  @override
  String get featureCarouselSubtitle2 => '🎨 スタイル＆カラー';

  @override
  String get featureCarouselDesc2 =>
      'モダンミニマリストから居心地の良いボヘミアンまで — あなたの好みに合わせた数十のデザインスタイルとカラーパレットを探索しましょう。';

  @override
  String get featureCarouselTitle3 => '即座の結果';

  @override
  String get featureCarouselSubtitle3 => '⚡ 数時間ではなく数秒';

  @override
  String get featureCarouselDesc3 =>
      '以前はデザイナーに何時間もかかっていたことが、今では数秒で実現。見事なビフォーアフターの変身を即座に手に入れましょう。';

  @override
  String get getStarted => '始める';

  @override
  String freeTrialDays(int days) {
    return '$days Days Free Trial';
  }

  @override
  String thenPrice(Object price) {
    return 'then $price/month';
  }
}
