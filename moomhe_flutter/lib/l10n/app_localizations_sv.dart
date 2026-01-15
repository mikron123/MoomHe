// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Expert AI';

  @override
  String get appName => 'Expert';

  @override
  String get guest => 'Gäst';

  @override
  String get loginToSaveDesigns => 'Logga in för att spara dina designs';

  @override
  String get loggedOutSuccess => 'Utloggad';

  @override
  String get uploadImage => 'Ladda upp bild';

  @override
  String get clickToUploadImage =>
      'Klicka här för att ladda upp en bild från galleriet';

  @override
  String get gallery => 'Galleri';

  @override
  String get camera => 'Kamera';

  @override
  String get uploadItem => 'Lägg till objekt';

  @override
  String get redesign => 'Designa om';

  @override
  String get more => 'Mer';

  @override
  String get moreOptions => 'Fler alternativ';

  @override
  String get history => 'Historik';

  @override
  String get noHistoryYet => 'Ingen historik ännu';

  @override
  String get uploadedImagesWillAppear =>
      'Bilder du laddar upp och redigerar visas här';

  @override
  String get whatToChange => 'Vad vill du ändra?';

  @override
  String get uploadImageFirst => 'Ladda upp en bild först';

  @override
  String get uploadingImage => 'Laddar upp bild...';

  @override
  String get errorUploadingImage => 'Fel vid uppladdning av bild';

  @override
  String get itemImageLoaded =>
      'Objektbild laddad! Beskriv i prompten var du vill lägga till det.';

  @override
  String get addAttachedItem => 'Lägg till det bifogade objektet i bilden';

  @override
  String get processingStarting => 'Startar...';

  @override
  String get processingMagic => 'Magin händer';

  @override
  String get processing => 'Bearbetar...';

  @override
  String get connectingToCloud => 'Ansluter till molnet... ☁️';

  @override
  String get sendingToAI => 'Skickar till AI... 🤖';

  @override
  String get analyzingItem => 'Analyserar objekt... 🔍';

  @override
  String get creatingDesign => 'Skapar design... ✨';

  @override
  String get funPhrase1 => 'Skickar bilden genom en annan dimension... 🌀';

  @override
  String get funPhrase2 => 'Lär AI:n att uppskatta bra design... 🎨';

  @override
  String get funPhrase3 => 'Övertygar pixlarna att samarbeta... 🤝';

  @override
  String get funPhrase4 => 'Lite digital magi på väg... ✨';

  @override
  String get funPhrase5 => 'Frågar AI:n vad den tycker... 🤔';

  @override
  String get funPhrase6 => 'Blandar färger som en riktig konstnär... 🖌️';

  @override
  String get funPhrase7 => 'Beräknar den perfekta vinkeln... 📐';

  @override
  String get funPhrase8 => 'Lägger till lite stil i ditt liv... 💫';

  @override
  String get funPhrase9 => 'Får rummet att se dyrare ut... 💎';

  @override
  String get funPhrase10 => 'Aktiverar designmagin... 🪄';

  @override
  String get funPhrase11 =>
      'Konsulterar med digitala inredningsdesigners... 🏠';

  @override
  String get funPhrase12 =>
      'Försöker att inte bli för exalterad över resultatet... 😍';

  @override
  String get funPhrase13 => 'Du kommer snart se något fantastiskt... 🚀';

  @override
  String get funPhrase14 => 'Ser till att allt är perfekt för dig... 👌';

  @override
  String get designStyle => 'Designstil';

  @override
  String get wallColor => 'Ändra färg';

  @override
  String get lighting => 'Belysning';

  @override
  String get furniture => 'Möbler';

  @override
  String get doorsWindows => 'Dörrar och fönster';

  @override
  String get bathroom => 'Badrum';

  @override
  String get repairs => 'Reparationer';

  @override
  String get general => 'Allmänt';

  @override
  String get selectDesignStyle => 'Välj designstil';

  @override
  String get colorPalette => 'Färgpalett';

  @override
  String get selectLightingType => 'Välj belysningstyp';

  @override
  String get selectFurnitureType => 'Välj möbeltyp';

  @override
  String get selectRepairType => 'Välj reparations-/skadetyp';

  @override
  String get bathroomOptions => 'Badrumsalternativ';

  @override
  String changeStyleTo(String styleName) {
    return 'Ändra stilen till $styleName';
  }

  @override
  String get whatToDo => 'Vad ska göras?';

  @override
  String get describeChange => 'Beskriv önskad ändring...';

  @override
  String get cancel => 'Avbryt';

  @override
  String get execute => 'Utför';

  @override
  String comingSoon(String feature) {
    return '$feature - Kommer snart!';
  }

  @override
  String get colorChange => 'Ändra färg';

  @override
  String get allWalls => 'Alla väggar';

  @override
  String get paintAllWalls => 'Måla alla väggar i rummet';

  @override
  String get specificObject => 'Specifikt objekt';

  @override
  String get selectWhatToPaint => 'Välj vad du vill måla';

  @override
  String get exampleObjects => 'Till exempel: soffa, tak, skåp...';

  @override
  String get confirm => 'Bekräfta';

  @override
  String get windowOptions => 'Fönsteralternativ';

  @override
  String get doorOptions => 'Dörralternativ';

  @override
  String get toiletOptions => 'Toalettalternativ';

  @override
  String get bathtubOptions => 'Badkarsalternativ';

  @override
  String get showerOptions => 'Duschalternativ';

  @override
  String get sinkOptions => 'Handfatalternativ';

  @override
  String get jacuzziOptions => 'Jacuzzi/spa-alternativ';

  @override
  String get poolOptions => 'Poolalternativ';

  @override
  String get professionalSubscription => 'Professionell plan';

  @override
  String get specialLaunchPrices => 'Speciella lanseringspriser 🚀';

  @override
  String get purchaseFailed => 'Köpet misslyckades';

  @override
  String get yourCurrentPlan => 'Din nuvarande plan';

  @override
  String get selectPlan => 'Välj plan';

  @override
  String get perMonth => '/månad';

  @override
  String get starterPlan => 'Starter';

  @override
  String get valuePlan => 'Värde';

  @override
  String get proPlan => 'Professionell';

  @override
  String imagesPerMonth(int count) {
    return '$count bilder per månad';
  }

  @override
  String get whatsappSupport => 'WhatsApp-support';

  @override
  String get historyStorage => 'Historiklagring';

  @override
  String get vipWhatsappSupport => 'VIP WhatsApp-support';

  @override
  String get processingPriority => 'Bearbetningsprioritet';

  @override
  String get bestValue => 'Bästa värdet: 4x fler bilder! 🔥';

  @override
  String get forProfessionals => 'För proffs ⭐';

  @override
  String savePerImage(String percent) {
    return 'Spara $percent% per bild';
  }

  @override
  String get allDesignTools => 'Alla designverktyg';

  @override
  String get fastSupport => 'Snabb support';

  @override
  String get noAds => 'Inga annonser';

  @override
  String get restorePurchases => 'Återställ köp';

  @override
  String get login => 'Logga in';

  @override
  String get logout => 'Logga ut';

  @override
  String get createAccount => 'Skapa konto';

  @override
  String get createNewAccount => 'Nytt konto';

  @override
  String get welcomeBack => 'Välkommen tillbaka! Logga in för att fortsätta';

  @override
  String get joinUs =>
      'Gå med för att spara designs och få tillgång till alla funktioner';

  @override
  String get email => 'E-post';

  @override
  String get password => 'Lösenord';

  @override
  String get confirmPassword => 'Bekräfta lösenord';

  @override
  String get fillAllFields => 'Fyll i alla fält';

  @override
  String get passwordsNotMatch => 'Lösenorden matchar inte';

  @override
  String get passwordsDoNotMatch => 'Lösenorden matchar inte';

  @override
  String get loginButton => 'Logga in';

  @override
  String get createAccountButton => 'Skapa konto';

  @override
  String get forgotPassword => 'Glömt lösenord?';

  @override
  String get enterEmailFirst => 'Ange en e-postadress först';

  @override
  String get termsAgreement => 'Genom att logga in godkänner du';

  @override
  String get termsOfService => 'Användarvillkor';

  @override
  String get and => 'och';

  @override
  String get privacyPolicy => 'Integritetspolicy';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-en.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-en.html';

  @override
  String get loggingIn => 'Loggar in...';

  @override
  String get creatingAccount => 'Skapar konto...';

  @override
  String get loginSuccess => 'Inloggad! 🎉';

  @override
  String get accountCreated => 'Konto skapat! 🎉';

  @override
  String get loginError => 'Inloggningsfel';

  @override
  String get userNotFound => 'Användare hittades inte';

  @override
  String get wrongPassword => 'Fel lösenord';

  @override
  String get emailInUse => 'E-post redan i användning';

  @override
  String get weakPassword => 'Lösenordet är för svagt';

  @override
  String get invalidEmail => 'Ogiltig e-postadress';

  @override
  String get exitAccount => 'Logga ut från konto';

  @override
  String get loginWithEmail => 'Logga in med e-post för att spara dina designs';

  @override
  String get mySubscription => 'Min prenumeration';

  @override
  String creditsRemaining(int count) {
    return '$count krediter kvar';
  }

  @override
  String get upgradeToPremium => 'Uppgradera till Premium';

  @override
  String get iHaveCoupon => 'Jag har en kupong';

  @override
  String get enterCouponCode => 'Ange kupongkod för gratis krediter';

  @override
  String get enterCouponCodeTitle => 'Ange kupongkod';

  @override
  String get enterCouponCodeSubtitle =>
      'Ange kupongkoden du fått för gratis krediter';

  @override
  String get couponCode => 'Kupongkod';

  @override
  String get mustEnterCoupon => 'Du måste ange en kupongkod';

  @override
  String get couponActivated => 'Kupong aktiverad!';

  @override
  String get errorRedeemingCoupon => 'Fel vid inlösen av kupong';

  @override
  String get redeemCoupon => 'Lös in kupong';

  @override
  String creditsAddedToAccount(int count) {
    return '$count krediter tillagda på ditt konto! 🎉';
  }

  @override
  String get contactUs => 'Kontakta oss';

  @override
  String get contactSubtitle =>
      'Vi vill gärna höra från dig! Fyll i uppgifterna så hör vi av oss snart.';

  @override
  String get phone => 'Telefon';

  @override
  String get message => 'Meddelande';

  @override
  String get writeYourMessage => 'Skriv ditt meddelande här...';

  @override
  String get enterPhoneOrEmail => '* Ange minst telefon eller e-post';

  @override
  String get pleaseEnterPhoneOrEmail => 'Ange minst telefon eller e-post';

  @override
  String get pleaseEnterMessage => 'Ange ett meddelande';

  @override
  String get errorSendingMessage =>
      'Fel vid sändning av meddelande. Försök igen.';

  @override
  String get sendMessage => 'Skicka meddelande';

  @override
  String get messageSentSuccess => 'Meddelande skickat!';

  @override
  String get contentNotAllowed => 'Innehåll ej tillåtet';

  @override
  String get requestFailed => 'Begäran misslyckades';

  @override
  String get oopsSomethingWrong => 'Oj! Något gick fel';

  @override
  String get moderationError =>
      'Kan inte bearbeta denna bild eller begäran.\n\nBilden eller begäran kan innehålla innehåll som inte är tillåtet för bearbetning.\n\nPröva med en annan bild eller ändra begäran.';

  @override
  String get timeoutError => 'Begäran tog för lång tid.\n\nFörsök igen senare.';

  @override
  String get genericError =>
      'Vi kunde inte bearbeta begäran.\n\nFörsök igen eller kontakta support om problemet kvarstår.';

  @override
  String get close => 'Stäng';

  @override
  String get tryAgain => 'Försök igen';

  @override
  String get imageSavedToGallery => 'Bild sparad i galleriet!';

  @override
  String get errorDownloadingImage => 'Fel vid nedladdning av bild';

  @override
  String get errorSharing => 'Fel vid delning';

  @override
  String get shareText =>
      '🏠 Jag designade detta med MoomHe AI!\n📸 Vill du prova också? https://moomhe.com';

  @override
  String get comparison => 'Jämförelse';

  @override
  String get download => 'Ladda ner';

  @override
  String get share => 'Dela';

  @override
  String get revertToOriginal => 'Återgå till original';

  @override
  String get loveItSave => 'Älskar det! Spara';

  @override
  String get creditsFinishedThisMonth => 'Krediter slut denna månad';

  @override
  String get creditsRanOut => 'Krediter slut denna månad';

  @override
  String get freeLimitReached => 'Du har nått gränsen för gratis användning';

  @override
  String get reachedFreeLimit => 'Du har nått gränsen för gratis användning';

  @override
  String creditsLimitReached(int limit) {
    return 'Du har nått kreditgränsen ($limit krediter). Du kan uppgradera till en större plan eller vänta till nästa månad.';
  }

  @override
  String freeCreditsUsed(int limit) {
    return 'Du har använt alla dina $limit gratis krediter. För att fortsätta designa utan begränsningar och få avancerade funktioner, uppgradera till en professionell plan.';
  }

  @override
  String get currentUsage => 'Nuvarande användning';

  @override
  String get limit => 'Gräns';

  @override
  String designs(int count) {
    return '$count designs';
  }

  @override
  String designsCount(int count) {
    return '$count designs';
  }

  @override
  String get upgradePlan => 'Uppgradera plan';

  @override
  String get goToProfessionalPlan => 'Gå till professionell plan';

  @override
  String get goPro => 'Bli Pro';

  @override
  String get notNowThanks => 'Inte nu, tack';

  @override
  String welcomeToPlan(String planName) {
    return 'Välkommen till $planName-planen!';
  }

  @override
  String get thankYouForJoining =>
      'Tack för att du gick med i vår prenumerantfamilj. Ditt konto har uppgraderats och du har nu tillgång till alla avancerade funktioner och extra krediter.';

  @override
  String get creditsAddedToYourAccount => 'Krediter tillagda på ditt konto';

  @override
  String get unlimitedStyleAccess => 'Obegränsad tillgång till alla stilar';

  @override
  String get supportCreators => 'Support för skapare och designers';

  @override
  String get startDesigning => 'Börja designa';

  @override
  String get secureYourSubscription => 'Säkra din prenumeration';

  @override
  String get secureSubscriptionMessage =>
      'För att inte förlora prenumerationen du köpt rekommenderar vi att logga in med e-post.\n\nPå så sätt kan du återställa din prenumeration på en ny enhet eller efter ominstallation.';

  @override
  String get later => 'Senare';

  @override
  String get loginNow => 'Logga in nu';

  @override
  String get onboardingUploadTitle => 'Ladda upp bild';

  @override
  String get onboardingUploadDesc =>
      'Börja med att ladda upp ett foto av rummet du vill designa. Har du inget? Inga problem, vi använder en exempelbild.';

  @override
  String get onboardingStyleTitle => 'Välj omdesignstil';

  @override
  String get onboardingStyleDesc =>
      'Välj din föredragna stil från sidmenyn. Prova \"Designa om\" för att se olika alternativ.';

  @override
  String get onboardingCreateTitle => 'Skapa design';

  @override
  String get onboardingCreateDesc =>
      'Klicka på \"Skapa\" och AI:n kommer att designa om ditt rum på sekunder!';

  @override
  String get onboardingItemTipTitle => 'Extratips: Lägg till objekt';

  @override
  String get onboardingItemTipDesc =>
      'Vill du lägga till en specifik möbel? Använd knappen \"Lägg till objekt\" för att ladda upp en bild av ett objekt och inkludera det i designen.';

  @override
  String get skip => 'Hoppa över';

  @override
  String get next => 'Nästa';

  @override
  String get finish => 'Slutför';

  @override
  String get promptAddedToInput =>
      'Prompt tillagd - du kan redigera den och sedan trycka Skapa';

  @override
  String get styleMediterranean => 'Modern medelhavsstil';

  @override
  String get styleWarmMinimalism => 'Varm minimalism';

  @override
  String get styleBiophilic => 'Biofilisk';

  @override
  String get styleModernLuxury => 'Modern lyx';

  @override
  String get styleJapandi => 'Japandi';

  @override
  String get styleScandinavian => 'Skandinavisk';

  @override
  String get styleBohoChic => 'Boho Chic';

  @override
  String get styleIndustrial => 'Industriell';

  @override
  String get styleEarthyNatural => 'Jordnära naturlig';

  @override
  String get styleJerusalem => 'Jerusalem';

  @override
  String get styleMinimalist => 'Minimalistisk';

  @override
  String get styleModernClassic => 'Modern klassisk';

  @override
  String get colorCategoryReds => 'Röda';

  @override
  String get colorCategoryOranges => 'Orange';

  @override
  String get colorCategoryYellows => 'Gula';

  @override
  String get colorCategoryGreens => 'Gröna';

  @override
  String get colorCategoryBlues => 'Blåa';

  @override
  String get colorCategoryPurples => 'Lila';

  @override
  String get colorCategoryGrays => 'Grå';

  @override
  String get colorCategoryWhitesBlacks => 'Vita och svarta';

  @override
  String get lightingRecessed => 'Infälld belysning';

  @override
  String get lightingPendant => 'Takpendel';

  @override
  String get lightingChandelier => 'Ljuskrona';

  @override
  String get lightingTableLamp => 'Bordslampa';

  @override
  String get lightingFloorLamp => 'Golvlampa';

  @override
  String get lightingWallSconce => 'Vägglampa';

  @override
  String get lightingTrack => 'Skenabaserad belysning';

  @override
  String get lightingCeiling => 'Taklampa';

  @override
  String get lightingUnderCabinet => 'Underskåpsbelysning';

  @override
  String get lightingDecorative => 'Dekorativ belysning';

  @override
  String get lightingDay => 'Dag';

  @override
  String get lightingNight => 'Natt';

  @override
  String get lightingSunset => 'Solnedgång';

  @override
  String get lightingSunrise => 'Soluppgång';

  @override
  String get lightingAddRecessed => 'Lägg till infälld belysning';

  @override
  String get lightingAddPendant => 'Lägg till takpendel';

  @override
  String get lightingAddChandelier => 'Lägg till ljuskrona';

  @override
  String get lightingAddTableLamp => 'Lägg till bordslampa';

  @override
  String get lightingAddFloorLamp => 'Lägg till golvlampa';

  @override
  String get lightingAddWallSconce => 'Lägg till vägglampa';

  @override
  String get lightingAddTrack => 'Lägg till skenabaserad belysning';

  @override
  String get lightingAddCeiling => 'Lägg till taklampa';

  @override
  String get lightingAddUnderCabinet => 'Lägg till underskåpsbelysning';

  @override
  String get lightingAddDecorative => 'Lägg till dekorativ belysning';

  @override
  String get lightingChangeToDay => 'Ändra belysning till dag';

  @override
  String get lightingChangeToNight => 'Ändra belysning till natt';

  @override
  String get lightingChangeToSunset => 'Ändra belysning till solnedgång';

  @override
  String get lightingChangeToSunrise => 'Ändra belysning till soluppgång';

  @override
  String get furnitureSofa => 'Soffa';

  @override
  String get furnitureSectional => 'Hörnsoffa';

  @override
  String get furnitureArmchair => 'Fåtölj';

  @override
  String get furnitureAccentChair => 'Accentstol';

  @override
  String get furnitureDiningChair => 'Matstol';

  @override
  String get furnitureBarStool => 'Barstol';

  @override
  String get furnitureSingleBed => 'Enkelsäng';

  @override
  String get furnitureDoubleBed => 'Dubbelsäng';

  @override
  String get furnitureBeanbag => 'Sittpuff';

  @override
  String get furnitureOttoman => 'Fotpall';

  @override
  String get furnitureBench => 'Bänk';

  @override
  String get furnitureCoffeeTable => 'Soffbord';

  @override
  String get furnitureEndTable => 'Sidobord';

  @override
  String get furnitureNightstand => 'Nattduksbord';

  @override
  String get furnitureDiningTable => 'Matbord';

  @override
  String get furnitureDesk => 'Skrivbord';

  @override
  String get furnitureDresser => 'Byrå';

  @override
  String get furnitureWardrobe => 'Garderob';

  @override
  String get furnitureBookcase => 'Bokhylla';

  @override
  String get furnitureTvStand => 'TV-bänk';

  @override
  String get furnitureCabinets => 'Köksskåp';

  @override
  String get furnitureAddSofa => 'Lägg till soffa';

  @override
  String get furnitureAddSectional => 'Lägg till hörnsoffa';

  @override
  String get furnitureAddArmchair => 'Lägg till fåtölj';

  @override
  String get furnitureAddAccentChair => 'Lägg till accentstol';

  @override
  String get furnitureAddDiningChair => 'Lägg till matstol';

  @override
  String get furnitureAddBarStool => 'Lägg till barstol';

  @override
  String get furnitureAddSingleBed => 'Lägg till enkelsäng';

  @override
  String get furnitureAddDoubleBed => 'Lägg till dubbelsäng';

  @override
  String get furnitureAddBeanbag => 'Lägg till sittpuff';

  @override
  String get furnitureAddOttoman => 'Lägg till fotpall';

  @override
  String get furnitureAddBench => 'Lägg till bänk';

  @override
  String get furnitureAddCoffeeTable => 'Lägg till soffbord';

  @override
  String get furnitureAddEndTable => 'Lägg till sidobord';

  @override
  String get furnitureAddNightstand => 'Lägg till nattduksbord';

  @override
  String get furnitureAddDiningTable => 'Lägg till matbord';

  @override
  String get furnitureAddDesk => 'Lägg till skrivbord';

  @override
  String get furnitureAddDresser => 'Lägg till byrå';

  @override
  String get furnitureAddWardrobe => 'Lägg till garderob';

  @override
  String get furnitureAddBookcase => 'Lägg till bokhylla';

  @override
  String get furnitureAddTvStand => 'Lägg till TV-bänk';

  @override
  String get furnitureAddCabinets => 'Lägg till köksskåp';

  @override
  String get repairsFixEverything => 'Fixa allt';

  @override
  String get repairsRepairAll => 'Fixa och reparera allt';

  @override
  String get repairsMessUp => 'Stöka till allt';

  @override
  String get repairsDestroy => 'Förstör och skada allt';

  @override
  String get windowPicture => 'Panoramafönster';

  @override
  String get windowSliding => 'Skjutfönster';

  @override
  String get windowCasement => 'Sidohängt fönster';

  @override
  String get windowTiltTurn => 'Dreh-kipp fönster';

  @override
  String get windowAwning => 'Markisfönster';

  @override
  String get windowSash => 'Skjutbart fönster';

  @override
  String get windowPocket => 'Fickfönster';

  @override
  String get windowArched => 'Bågfönster';

  @override
  String get windowAddPicture => 'Lägg till stort panoramafönster';

  @override
  String get windowAddSliding => 'Lägg till skjutfönster';

  @override
  String get windowAddCasement => 'Lägg till sidohängt fönster';

  @override
  String get windowAddTiltTurn => 'Lägg till dreh-kipp fönster';

  @override
  String get windowAddAwning => 'Lägg till markisfönster';

  @override
  String get windowAddSash => 'Lägg till skjutbart fönster';

  @override
  String get windowAddPocket => 'Lägg till fickfönster';

  @override
  String get windowAddArched => 'Lägg till bågfönster';

  @override
  String get doorPocket => 'Skjutdörr i vägg';

  @override
  String get doorFrench => 'Franska dörrar';

  @override
  String get doorLouvered => 'Lamellädörr';

  @override
  String get doorBarn => 'Ladugårdsdörr';

  @override
  String get doorAddPocket => 'Lägg till skjutdörr som glider in i väggen';

  @override
  String get doorAddFrench => 'Lägg till franska dörrar med glas';

  @override
  String get doorAddLouvered => 'Lägg till lamelldörr';

  @override
  String get doorAddBarn => 'Lägg till ladugårdsdörr';

  @override
  String get toiletBidet => 'Uppvärmd bidé';

  @override
  String get toiletSeat => 'Toalettsits';

  @override
  String get tubFreestanding => 'Fristående badkar';

  @override
  String get tubVintage => 'Vintagebadkar';

  @override
  String get tubStandard => 'Standardbadkar';

  @override
  String get showerRain => 'Regndusch';

  @override
  String get showerEnclosure => 'Duschkabin';

  @override
  String get showerSliding => 'Skjutbara duschdörrar';

  @override
  String get sinkPedestal => 'Piedestallhandfat';

  @override
  String get sinkStainless => 'Rostfri diskho';

  @override
  String get sinkUndermount => 'Undermonterat handfat';

  @override
  String get jacuzziBuiltIn => 'Inbyggd jacuzzi';

  @override
  String get jacuzziPortable => 'Portabel jacuzzi';

  @override
  String get poolInground => 'Nedgrävd pool';

  @override
  String get poolAboveGround => 'Ovanmarkspool';

  @override
  String get toiletAddBidet => 'Lägg till toalettsits med bidé';

  @override
  String get toiletAddSeat => 'Lägg till toalettsits';

  @override
  String get tubAddFreestanding => 'Lägg till fristående badkar';

  @override
  String get tubAddVintage => 'Lägg till vintagebadkar';

  @override
  String get tubAddStandard => 'Lägg till standardbadkar';

  @override
  String get showerAddRain => 'Lägg till dusch med regnduschhuvud';

  @override
  String get showerAddEnclosure => 'Lägg till duschkabin';

  @override
  String get showerAddSliding => 'Lägg till dusch med skjutdörrar';

  @override
  String get sinkAddPedestal => 'Lägg till piedestallhandfat';

  @override
  String get sinkAddStainless => 'Lägg till rostfri diskho';

  @override
  String get sinkAddUndermount => 'Lägg till undermonterat handfat';

  @override
  String get jacuzziAddBuiltIn => 'Lägg till inbyggd jacuzzi';

  @override
  String get jacuzziAddPortable => 'Lägg till portabel jacuzzi';

  @override
  String get poolAddInground => 'Lägg till nedgrävd pool';

  @override
  String get poolAddAboveGround => 'Lägg till ovanmarkspool';

  @override
  String get errorUnknown => 'Okänt fel';

  @override
  String get searchWithLens => 'Sök';

  @override
  String get cancelSearch => 'Avbryt';

  @override
  String get selectAreaToSearch =>
      'Rita en rektangel runt objektet du vill söka efter';

  @override
  String get searchingWithGoogleLens => 'Söker med Google Lens...';

  @override
  String get selectAreaWithinImage => 'Välj ett område inom bilden';

  @override
  String get googleLensSearchFailed => 'Sökningen misslyckades. Försök igen.';

  @override
  String get rateAppTitle => 'Gillar du appen?';

  @override
  String get rateAppMessage =>
      'Vi vill gärna höra vad du tycker! Din feedback hjälper oss att förbättras.';

  @override
  String get rateAppYes => 'Ja, jag älskar den! 😍';

  @override
  String get rateAppNo => 'Inte riktigt';

  @override
  String get rateAppLater => 'Fråga mig senare';

  @override
  String get deleteAccount => 'Radera konto';

  @override
  String get deleteAccountWarning1Title => 'Radera konto';

  @override
  String get deleteAccountWarning1Message =>
      'Är du säker på att du vill radera ditt konto? Detta raderar all din information och alla bilder och kan inte ångras.';

  @override
  String get deleteAccountWarning2Title => 'Slutlig bekräftelse';

  @override
  String get deleteAccountWarning2Message =>
      'Denna åtgärd är oåterkallelig! All din historik och alla bilder kommer att raderas permanent. Är du 100% säker?';

  @override
  String get deleteAccountConfirm => 'Ja, radera konto';

  @override
  String get deletingAccount => 'Raderar konto...';

  @override
  String get accountDeleted => 'Konto raderat';

  @override
  String get errorDeletingAccount => 'Fel vid radering av konto';

  @override
  String get language => 'Språk';

  @override
  String get selectLanguage => 'Välj språk';

  @override
  String get languageChanged => 'Språk ändrat';
}
