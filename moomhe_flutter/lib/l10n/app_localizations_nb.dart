// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Expert AI';

  @override
  String get appName => 'Expert';

  @override
  String get guest => 'Gjest';

  @override
  String get loginToSaveDesigns => 'Logg inn for å lagre designene dine';

  @override
  String get loggedOutSuccess => 'Logget ut';

  @override
  String get uploadImage => 'Last opp bilde';

  @override
  String get clickToUploadImage =>
      'Klikk her for å laste opp et bilde fra galleriet';

  @override
  String get gallery => 'Galleri';

  @override
  String get camera => 'Kamera';

  @override
  String get uploadItem => 'Legg til gjenstand';

  @override
  String get redesign => 'Redesign';

  @override
  String get more => 'Mer';

  @override
  String get moreOptions => 'Flere alternativer';

  @override
  String get history => 'Historikk';

  @override
  String get noHistoryYet => 'Ingen historikk ennå';

  @override
  String get uploadedImagesWillAppear =>
      'Bilder du laster opp og redigerer vises her';

  @override
  String get whatToChange => 'Hva vil du endre?';

  @override
  String get uploadImageFirst => 'Vennligst last opp et bilde først';

  @override
  String get uploadingImage => 'Laster opp bilde...';

  @override
  String get errorUploadingImage => 'Feil ved opplasting av bilde';

  @override
  String get itemImageLoaded =>
      'Gjenstandsbilde lastet! Beskriv i prompten hvor du vil legge det til.';

  @override
  String get addAttachedItem => 'Legg til den vedlagte gjenstanden i bildet';

  @override
  String get processingStarting => 'Starter...';

  @override
  String get processingMagic => 'Magien skjer';

  @override
  String get processing => 'Behandler...';

  @override
  String get connectingToCloud => 'Kobler til sky... ☁️';

  @override
  String get sendingToAI => 'Sender til AI... 🤖';

  @override
  String get analyzingItem => 'Analyserer gjenstand... 🔍';

  @override
  String get creatingDesign => 'Lager design... ✨';

  @override
  String get funPhrase1 => 'Sender bildet gjennom en annen dimensjon... 🌀';

  @override
  String get funPhrase2 => 'Lærer AI å sette pris på godt design... 🎨';

  @override
  String get funPhrase3 => 'Overbeviser pikslene om å samarbeide... 🤝';

  @override
  String get funPhrase4 => 'Litt digital magi på vei... ✨';

  @override
  String get funPhrase5 => 'Spør AI hva den synes... 🤔';

  @override
  String get funPhrase6 => 'Blander farger som en ekte kunstner... 🖌️';

  @override
  String get funPhrase7 => 'Beregner den perfekte vinkelen... 📐';

  @override
  String get funPhrase8 => 'Legger til litt stil i livet ditt... 💫';

  @override
  String get funPhrase9 => 'Får rommet til å se dyrere ut... 💎';

  @override
  String get funPhrase10 => 'Aktiverer designmagi... 🪄';

  @override
  String get funPhrase11 =>
      'Konsulterer med de digitale interiørdesignerne... 🏠';

  @override
  String get funPhrase12 =>
      'Prøver å ikke bli for begeistret over resultatet... 😍';

  @override
  String get funPhrase13 => 'Du vil se noe fantastisk snart... 🚀';

  @override
  String get funPhrase14 => 'Sørger for at alt er perfekt for deg... 👌';

  @override
  String get designStyle => 'Designstil';

  @override
  String get wallColor => 'Endre farge';

  @override
  String get lighting => 'Belysning';

  @override
  String get furniture => 'Møbler';

  @override
  String get doorsWindows => 'Dører og vinduer';

  @override
  String get bathroom => 'Bad';

  @override
  String get repairs => 'Reparasjoner';

  @override
  String get general => 'Generelt';

  @override
  String get selectDesignStyle => 'Velg designstil';

  @override
  String get colorPalette => 'Fargepalett';

  @override
  String get selectLightingType => 'Velg belysningstype';

  @override
  String get selectFurnitureType => 'Velg møbeltype';

  @override
  String get selectRepairType => 'Velg reparasjons-/skadetype';

  @override
  String get bathroomOptions => 'Baderomsmuligheter';

  @override
  String changeStyleTo(String styleName) {
    return 'Endre stilen til $styleName';
  }

  @override
  String get whatToDo => 'Hva vil du gjøre?';

  @override
  String get describeChange => 'Beskriv ønsket endring...';

  @override
  String get cancel => 'Avbryt';

  @override
  String get execute => 'Utfør';

  @override
  String comingSoon(String feature) {
    return '$feature - Kommer snart!';
  }

  @override
  String get colorChange => 'Endre farge';

  @override
  String get allWalls => 'Alle vegger';

  @override
  String get paintAllWalls => 'Mal alle veggene i rommet';

  @override
  String get specificObject => 'Spesifikt objekt';

  @override
  String get selectWhatToPaint => 'Velg hva du vil male';

  @override
  String get exampleObjects => 'For eksempel: sofa, tak, skap...';

  @override
  String get confirm => 'Bekreft';

  @override
  String get windowOptions => 'Vindusalternativer';

  @override
  String get doorOptions => 'Døralternativer';

  @override
  String get toiletOptions => 'Toalettalternativer';

  @override
  String get bathtubOptions => 'Badekarsalternativer';

  @override
  String get showerOptions => 'Dusjalternativer';

  @override
  String get sinkOptions => 'Vaskalternativer';

  @override
  String get jacuzziOptions => 'Jacuzzi/spa-alternativer';

  @override
  String get poolOptions => 'Bassengalternativer';

  @override
  String get professionalSubscription => 'Profesjonell plan';

  @override
  String get specialLaunchPrices => 'Spesielle lanseringspriser 🚀';

  @override
  String get purchaseFailed => 'Kjøp mislyktes';

  @override
  String get yourCurrentPlan => 'Din nåværende plan';

  @override
  String get selectPlan => 'Velg plan';

  @override
  String get perMonth => '/måned';

  @override
  String get starterPlan => 'Starter';

  @override
  String get valuePlan => 'Verdi';

  @override
  String get proPlan => 'Profesjonell';

  @override
  String imagesPerMonth(int count) {
    return '$count bilder per måned';
  }

  @override
  String get whatsappSupport => 'WhatsApp-støtte';

  @override
  String get historyStorage => 'Historikklagring';

  @override
  String get vipWhatsappSupport => 'VIP WhatsApp-støtte';

  @override
  String get processingPriority => 'Behandlingsprioritet';

  @override
  String get bestValue => 'Beste verdi: 4x flere bilder! 🔥';

  @override
  String get forProfessionals => 'For profesjonelle ⭐';

  @override
  String savePerImage(String percent) {
    return 'Spar $percent% per bilde';
  }

  @override
  String get allDesignTools => 'Alle designverktøy';

  @override
  String get fastSupport => 'Rask støtte';

  @override
  String get noAds => 'Ingen annonser';

  @override
  String get restorePurchases => 'Gjenopprett kjøp';

  @override
  String get login => 'Logg inn';

  @override
  String get logout => 'Logg ut';

  @override
  String get createAccount => 'Opprett konto';

  @override
  String get createNewAccount => 'Ny konto';

  @override
  String get welcomeBack => 'Velkommen tilbake! Logg inn for å fortsette';

  @override
  String get joinUs =>
      'Bli med for å lagre design og få tilgang til alle funksjoner';

  @override
  String get email => 'E-post';

  @override
  String get password => 'Passord';

  @override
  String get confirmPassword => 'Bekreft passord';

  @override
  String get fillAllFields => 'Vennligst fyll ut alle felt';

  @override
  String get passwordsNotMatch => 'Passordene stemmer ikke';

  @override
  String get passwordsDoNotMatch => 'Passordene stemmer ikke';

  @override
  String get loginButton => 'Logg inn';

  @override
  String get createAccountButton => 'Opprett konto';

  @override
  String get forgotPassword => 'Glemt passord?';

  @override
  String get enterEmailFirst => 'Vennligst skriv inn en e-postadresse først';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox and spam folder.';

  @override
  String get passwordResetError => 'Error sending password reset email';

  @override
  String get termsAgreement => 'Ved å logge inn godtar du';

  @override
  String get termsOfService => 'Tjenestevilkår';

  @override
  String get and => 'og';

  @override
  String get privacyPolicy => 'Personvernregler';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-en.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-en.html';

  @override
  String get loggingIn => 'Logger inn...';

  @override
  String get creatingAccount => 'Oppretter konto...';

  @override
  String get loginSuccess => 'Logget inn! 🎉';

  @override
  String get accountCreated => 'Konto opprettet! 🎉';

  @override
  String get loginError => 'Innloggingsfeil';

  @override
  String get userNotFound => 'Bruker ikke funnet';

  @override
  String get wrongPassword => 'Feil passord';

  @override
  String get emailInUse => 'E-post er allerede i bruk';

  @override
  String get weakPassword => 'Passordet er for svakt';

  @override
  String get invalidEmail => 'Ugyldig e-postadresse';

  @override
  String get exitAccount => 'Logg ut av konto';

  @override
  String get loginWithEmail => 'Logg inn med e-post for å lagre designene dine';

  @override
  String get mySubscription => 'Mitt abonnement';

  @override
  String creditsRemaining(int count) {
    return '$count kreditter igjen';
  }

  @override
  String get upgradeToPremium => 'Oppgrader til Premium';

  @override
  String get iHaveCoupon => 'Jeg har en kupong';

  @override
  String get enterCouponCode =>
      'Skriv inn kupongkode for å få gratis kreditter';

  @override
  String get enterCouponCodeTitle => 'Skriv inn kupongkode';

  @override
  String get enterCouponCodeSubtitle =>
      'Skriv inn kupongkoden du mottok for å få gratis kreditter';

  @override
  String get couponCode => 'Kupongkode';

  @override
  String get mustEnterCoupon => 'Du må skrive inn en kupongkode';

  @override
  String get couponActivated => 'Kupong aktivert!';

  @override
  String get errorRedeemingCoupon => 'Feil ved innløsing av kupong';

  @override
  String get redeemCoupon => 'Løs inn kupong';

  @override
  String creditsAddedToAccount(int count) {
    return '$count kreditter lagt til kontoen din! 🎉';
  }

  @override
  String get contactUs => 'Kontakt oss';

  @override
  String get contactSubtitle =>
      'Vi vil gjerne høre fra deg! Fyll inn detaljene, så tar vi kontakt snart.';

  @override
  String get phone => 'Telefon';

  @override
  String get message => 'Melding';

  @override
  String get writeYourMessage => 'Skriv meldingen din her...';

  @override
  String get enterPhoneOrEmail =>
      '* Vennligst skriv inn minst telefon eller e-post';

  @override
  String get pleaseEnterPhoneOrEmail =>
      'Vennligst skriv inn minst telefon eller e-post';

  @override
  String get pleaseEnterMessage => 'Vennligst skriv inn en melding';

  @override
  String get errorSendingMessage => 'Feil ved sending av melding. Prøv igjen.';

  @override
  String get sendMessage => 'Send melding';

  @override
  String get messageSentSuccess => 'Melding sendt!';

  @override
  String get contentNotAllowed => 'Innhold ikke tillatt';

  @override
  String get requestFailed => 'Forespørsel mislyktes';

  @override
  String get oopsSomethingWrong => 'Oops! Noe gikk galt';

  @override
  String get moderationError =>
      'Kan ikke behandle dette bildet eller forespørselen.\n\nBildet eller forespørselen kan inneholde innhold som ikke er tillatt for behandling.\n\nPrøv med et annet bilde eller endre forespørselen.';

  @override
  String get timeoutError =>
      'Forespørselen tok for lang tid.\n\nVennligst prøv igjen senere.';

  @override
  String get genericError =>
      'Vi kunne ikke behandle forespørselen.\n\nPrøv igjen eller kontakt støtte hvis problemet vedvarer.';

  @override
  String get close => 'Lukk';

  @override
  String get tryAgain => 'Prøv igjen';

  @override
  String get imageSavedToGallery => 'Bilde lagret i galleriet!';

  @override
  String get errorDownloadingImage => 'Feil ved nedlasting av bilde';

  @override
  String get errorSharing => 'Feil ved deling';

  @override
  String get shareText =>
      '🏠 Jeg designet dette med MoomHe AI!\n📸 Vil du prøve det også? https://moomhe.com';

  @override
  String get comparison => 'Sammenligning';

  @override
  String get download => 'Last ned';

  @override
  String get share => 'Del';

  @override
  String get revertToOriginal => 'Tilbake til original';

  @override
  String get loveItSave => 'Elsker det! Lagre';

  @override
  String get creditsFinishedThisMonth => 'Kreditter brukt opp denne måneden';

  @override
  String get creditsRanOut => 'Kreditter brukt opp denne måneden';

  @override
  String get freeLimitReached => 'Du har nådd grensen for gratis bruk';

  @override
  String get reachedFreeLimit => 'Du har nådd grensen for gratis bruk';

  @override
  String creditsLimitReached(int limit) {
    return 'Du har nådd kredittgrensen ($limit kreditter). Du kan oppgradere til en større plan eller vente til neste måned.';
  }

  @override
  String freeCreditsUsed(int limit) {
    return 'Du har brukt alle dine $limit gratis kreditter. For å fortsette å designe uten begrensninger og få avanserte funksjoner, oppgrader til en profesjonell plan.';
  }

  @override
  String get currentUsage => 'Nåværende bruk';

  @override
  String get limit => 'Grense';

  @override
  String designs(int count) {
    return '$count design';
  }

  @override
  String designsCount(int count) {
    return '$count design';
  }

  @override
  String get upgradePlan => 'Oppgrader plan';

  @override
  String get goToProfessionalPlan => 'Gå til profesjonell plan';

  @override
  String get goPro => 'Bli Pro';

  @override
  String get notNowThanks => 'Ikke nå, takk';

  @override
  String welcomeToPlan(String planName) {
    return 'Velkommen til $planName-planen!';
  }

  @override
  String get thankYouForJoining =>
      'Takk for at du ble med i abonnentfamilien vår. Kontoen din er oppgradert, og du har nå tilgang til alle avanserte funksjoner og ekstra kreditter.';

  @override
  String get creditsAddedToYourAccount => 'Kreditter lagt til kontoen din';

  @override
  String get unlimitedStyleAccess => 'Ubegrenset tilgang til alle stiler';

  @override
  String get supportCreators => 'Støtte for skapere og designere';

  @override
  String get startDesigning => 'Start å designe';

  @override
  String get secureYourSubscription => 'Sikre abonnementet ditt';

  @override
  String get secureSubscriptionMessage =>
      'For å ikke miste abonnementet du kjøpte, anbefaler vi å logge inn med e-post.\n\nPå denne måten kan du gjenopprette abonnementet på en ny enhet eller etter reinstallering.';

  @override
  String get later => 'Senere';

  @override
  String get loginNow => 'Logg inn nå';

  @override
  String get onboardingUploadTitle => 'Last opp bilde';

  @override
  String get onboardingUploadDesc =>
      'Start med å laste opp et bilde av rommet du vil designe. Har du ikke et? Ikke bekymre deg, vi bruker et eksempelbilde.';

  @override
  String get onboardingStyleTitle => 'Velg redesignstil';

  @override
  String get onboardingStyleDesc =>
      'Velg din foretrukne stil fra sidemenyen. Prøv \"Redesign\" for å se forskjellige alternativer.';

  @override
  String get onboardingCreateTitle => 'Lag design';

  @override
  String get onboardingCreateDesc =>
      'Klikk \"Lag\", og AI-en vil redesigne rommet ditt på sekunder!';

  @override
  String get onboardingItemTipTitle => 'Ekstra tips: Legg til gjenstand';

  @override
  String get onboardingItemTipDesc =>
      'Vil du legge til et spesifikt møbel? Bruk \"Legg til gjenstand\"-knappen for å laste opp et bilde av en gjenstand og inkludere den i designet.';

  @override
  String get skip => 'Hopp over';

  @override
  String get next => 'Neste';

  @override
  String get finish => 'Fullfør';

  @override
  String get promptAddedToInput =>
      'Prompt lagt til - du kan redigere den og trykke Lag';

  @override
  String get styleMediterranean => 'Moderne middelhavsst';

  @override
  String get styleWarmMinimalism => 'Varm minimalisme';

  @override
  String get styleBiophilic => 'Biofil';

  @override
  String get styleModernLuxury => 'Moderne luksus';

  @override
  String get styleJapandi => 'Japandi';

  @override
  String get styleScandinavian => 'Skandinavisk';

  @override
  String get styleBohoChic => 'Boho Chic';

  @override
  String get styleIndustrial => 'Industriell';

  @override
  String get styleEarthyNatural => 'Jordnær naturlig';

  @override
  String get styleJerusalem => 'Jerusalem';

  @override
  String get styleMinimalist => 'Minimalistisk';

  @override
  String get styleModernClassic => 'Moderne klassisk';

  @override
  String get colorCategoryReds => 'Røde';

  @override
  String get colorCategoryOranges => 'Oransje';

  @override
  String get colorCategoryYellows => 'Gule';

  @override
  String get colorCategoryGreens => 'Grønne';

  @override
  String get colorCategoryBlues => 'Blå';

  @override
  String get colorCategoryPurples => 'Lilla';

  @override
  String get colorCategoryGrays => 'Grå';

  @override
  String get colorCategoryWhitesBlacks => 'Hvite og svarte';

  @override
  String get lightingRecessed => 'Innfelt belysning';

  @override
  String get lightingPendant => 'Pendel';

  @override
  String get lightingChandelier => 'Lysekrone';

  @override
  String get lightingTableLamp => 'Bordlampe';

  @override
  String get lightingFloorLamp => 'Gulvlampe';

  @override
  String get lightingWallSconce => 'Vegglampe';

  @override
  String get lightingTrack => 'Sporbelysning';

  @override
  String get lightingCeiling => 'Taklampe';

  @override
  String get lightingUnderCabinet => 'Benkbelysning';

  @override
  String get lightingDecorative => 'Dekorativ belysning';

  @override
  String get lightingDay => 'Dag';

  @override
  String get lightingNight => 'Natt';

  @override
  String get lightingSunset => 'Solnedgang';

  @override
  String get lightingSunrise => 'Soloppgang';

  @override
  String get lightingAddRecessed => 'Legg til innfelt belysning';

  @override
  String get lightingAddPendant => 'Legg til pendel';

  @override
  String get lightingAddChandelier => 'Legg til lysekrone';

  @override
  String get lightingAddTableLamp => 'Legg til bordlampe';

  @override
  String get lightingAddFloorLamp => 'Legg til gulvlampe';

  @override
  String get lightingAddWallSconce => 'Legg til vegglampe';

  @override
  String get lightingAddTrack => 'Legg til sporbelysning';

  @override
  String get lightingAddCeiling => 'Legg til taklampe';

  @override
  String get lightingAddUnderCabinet => 'Legg til benkbelysning';

  @override
  String get lightingAddDecorative => 'Legg til dekorativ belysning';

  @override
  String get lightingChangeToDay => 'Endre belysning til dag';

  @override
  String get lightingChangeToNight => 'Endre belysning til natt';

  @override
  String get lightingChangeToSunset => 'Endre belysning til solnedgang';

  @override
  String get lightingChangeToSunrise => 'Endre belysning til soloppgang';

  @override
  String get furnitureSofa => 'Sofa';

  @override
  String get furnitureSectional => 'Hjørnesofa';

  @override
  String get furnitureArmchair => 'Lenestol';

  @override
  String get furnitureAccentChair => 'Aksentstol';

  @override
  String get furnitureDiningChair => 'Spisestol';

  @override
  String get furnitureBarStool => 'Barkrakk';

  @override
  String get furnitureSingleBed => 'Enkeltseng';

  @override
  String get furnitureDoubleBed => 'Dobbeltseng';

  @override
  String get furnitureBeanbag => 'Sakkosekk';

  @override
  String get furnitureOttoman => 'Fotskammel';

  @override
  String get furnitureBench => 'Benk';

  @override
  String get furnitureCoffeeTable => 'Sofabord';

  @override
  String get furnitureEndTable => 'Sidebord';

  @override
  String get furnitureNightstand => 'Nattbord';

  @override
  String get furnitureDiningTable => 'Spisebord';

  @override
  String get furnitureDesk => 'Skrivebord';

  @override
  String get furnitureDresser => 'Kommode';

  @override
  String get furnitureWardrobe => 'Garderobe';

  @override
  String get furnitureBookcase => 'Bokhylle';

  @override
  String get furnitureTvStand => 'TV-benk';

  @override
  String get furnitureCabinets => 'Kjøkkenskap';

  @override
  String get furnitureAddSofa => 'Legg til sofa';

  @override
  String get furnitureAddSectional => 'Legg til hjørnesofa';

  @override
  String get furnitureAddArmchair => 'Legg til lenestol';

  @override
  String get furnitureAddAccentChair => 'Legg til aksentstol';

  @override
  String get furnitureAddDiningChair => 'Legg til spisestol';

  @override
  String get furnitureAddBarStool => 'Legg til barkrakk';

  @override
  String get furnitureAddSingleBed => 'Legg til enkeltseng';

  @override
  String get furnitureAddDoubleBed => 'Legg til dobbeltseng';

  @override
  String get furnitureAddBeanbag => 'Legg til sakkosekk';

  @override
  String get furnitureAddOttoman => 'Legg til fotskammel';

  @override
  String get furnitureAddBench => 'Legg til benk';

  @override
  String get furnitureAddCoffeeTable => 'Legg til sofabord';

  @override
  String get furnitureAddEndTable => 'Legg til sidebord';

  @override
  String get furnitureAddNightstand => 'Legg til nattbord';

  @override
  String get furnitureAddDiningTable => 'Legg til spisebord';

  @override
  String get furnitureAddDesk => 'Legg til skrivebord';

  @override
  String get furnitureAddDresser => 'Legg til kommode';

  @override
  String get furnitureAddWardrobe => 'Legg til garderobe';

  @override
  String get furnitureAddBookcase => 'Legg til bokhylle';

  @override
  String get furnitureAddTvStand => 'Legg til TV-benk';

  @override
  String get furnitureAddCabinets => 'Legg til kjøkkenskap';

  @override
  String get repairsFixEverything => 'Fiks alt';

  @override
  String get repairsRepairAll => 'Fiks og reparer alt';

  @override
  String get repairsMessUp => 'Rot til alt';

  @override
  String get repairsDestroy => 'Ødelegg og skad alt';

  @override
  String get windowPicture => 'Panoramavindu';

  @override
  String get windowSliding => 'Skyvevindu';

  @override
  String get windowCasement => 'Sidehengslet vindu';

  @override
  String get windowTiltTurn => 'Vipp-sving vindu';

  @override
  String get windowAwning => 'Markisevindu';

  @override
  String get windowSash => 'Guillotinevindu';

  @override
  String get windowPocket => 'Lommevindu';

  @override
  String get windowArched => 'Buet vindu';

  @override
  String get windowAddPicture => 'Legg til stort panoramavindu';

  @override
  String get windowAddSliding => 'Legg til skyvevindu';

  @override
  String get windowAddCasement => 'Legg til sidehengslet vindu';

  @override
  String get windowAddTiltTurn => 'Legg til vipp-sving vindu';

  @override
  String get windowAddAwning => 'Legg til markisevindu';

  @override
  String get windowAddSash => 'Legg til guillotinevindu';

  @override
  String get windowAddPocket => 'Legg til lommevindu';

  @override
  String get windowAddArched => 'Legg til buet vindu';

  @override
  String get doorPocket => 'Lommedør';

  @override
  String get doorFrench => 'Franske dører';

  @override
  String get doorLouvered => 'Persiennedør';

  @override
  String get doorBarn => 'Låvedør';

  @override
  String get doorAddPocket => 'Legg til lommedør som glir inn i veggen';

  @override
  String get doorAddFrench => 'Legg til franske dører med glass';

  @override
  String get doorAddLouvered => 'Legg til persiennedør';

  @override
  String get doorAddBarn => 'Legg til låvedør';

  @override
  String get toiletBidet => 'Oppvarmet bidet';

  @override
  String get toiletSeat => 'Toalettsete';

  @override
  String get tubFreestanding => 'Frittstående badekar';

  @override
  String get tubVintage => 'Vintage badekar';

  @override
  String get tubStandard => 'Standard badekar';

  @override
  String get showerRain => 'Regndusj';

  @override
  String get showerEnclosure => 'Dusjkabinett';

  @override
  String get showerSliding => 'Skyvedører til dusj';

  @override
  String get sinkPedestal => 'Sokkelservant';

  @override
  String get sinkStainless => 'Rustfri vask';

  @override
  String get sinkUndermount => 'Underlimt vask';

  @override
  String get jacuzziBuiltIn => 'Innebygd boblebad';

  @override
  String get jacuzziPortable => 'Bærbart boblebad';

  @override
  String get poolInground => 'Nedgravd basseng';

  @override
  String get poolAboveGround => 'Oppstilt basseng';

  @override
  String get toiletAddBidet => 'Legg til toalettsete med bidet';

  @override
  String get toiletAddSeat => 'Legg til toalettsete';

  @override
  String get tubAddFreestanding => 'Legg til frittstående badekar';

  @override
  String get tubAddVintage => 'Legg til vintage badekar';

  @override
  String get tubAddStandard => 'Legg til standard badekar';

  @override
  String get showerAddRain => 'Legg til dusj med regndusjhode';

  @override
  String get showerAddEnclosure => 'Legg til dusjkabinett';

  @override
  String get showerAddSliding => 'Legg til dusj med skyvedører';

  @override
  String get sinkAddPedestal => 'Legg til sokkelservant';

  @override
  String get sinkAddStainless => 'Legg til rustfri vask';

  @override
  String get sinkAddUndermount => 'Legg til underlimt vask';

  @override
  String get jacuzziAddBuiltIn => 'Legg til innebygd boblebad';

  @override
  String get jacuzziAddPortable => 'Legg til bærbart boblebad';

  @override
  String get poolAddInground => 'Legg til nedgravd basseng';

  @override
  String get poolAddAboveGround => 'Legg til oppstilt basseng';

  @override
  String get errorUnknown => 'Ukjent feil';

  @override
  String get searchWithLens => 'Søk';

  @override
  String get cancelSearch => 'Avbryt';

  @override
  String get selectAreaToSearch =>
      'Tegn et rektangel rundt gjenstanden du vil søke etter';

  @override
  String get searchingWithGoogleLens => 'Søker med Google Lens...';

  @override
  String get selectAreaWithinImage =>
      'Vennligst velg et område innenfor bildet';

  @override
  String get googleLensSearchFailed => 'Søket mislyktes. Prøv igjen.';

  @override
  String get rateAppTitle => 'Liker du appen?';

  @override
  String get rateAppMessage =>
      'Vi vil gjerne høre hva du synes! Din tilbakemelding hjelper oss å forbedre oss.';

  @override
  String get rateAppYes => 'Ja, jeg elsker den! 😍';

  @override
  String get rateAppNo => 'Ikke egentlig';

  @override
  String get rateAppLater => 'Spør meg senere';

  @override
  String get deleteAccount => 'Slett konto';

  @override
  String get deleteAccountWarning1Title => 'Slett konto';

  @override
  String get deleteAccountWarning1Message =>
      'Er du sikker på at du vil slette kontoen din? Dette vil slette all informasjon og alle bilder og kan ikke angres.';

  @override
  String get deleteAccountWarning2Title => 'Endelig bekreftelse';

  @override
  String get deleteAccountWarning2Message =>
      'Denne handlingen kan ikke angres! All historikk og alle bilder vil bli permanent slettet. Er du 100% sikker?';

  @override
  String get deleteAccountConfirm => 'Ja, slett konto';

  @override
  String get deletingAccount => 'Sletter konto...';

  @override
  String get accountDeleted => 'Konto slettet';

  @override
  String get errorDeletingAccount => 'Feil ved sletting av konto';

  @override
  String get language => 'Språk';

  @override
  String get selectLanguage => 'Velg språk';

  @override
  String get languageChanged => 'Språk endret';

  @override
  String get createAccountPromptTitle => 'Opprett kontoen din';

  @override
  String get createAccountPromptMessage =>
      'Fantastiske oppdateringer kommer de neste ukene! 🚀\n\nOpprett en konto nå for ikke å miste kreasjonene dine og vær den første til å nyte nye funksjoner.';

  @override
  String get createAccountPromptButton => 'Opprett konto';

  @override
  String get maybeLater => 'Kanskje senere';

  @override
  String get readyDesigns => 'Designgalleri';

  @override
  String get noCategories => 'Ingen kategorier';

  @override
  String get noDesigns => 'Ingen design';

  @override
  String get noDesignsInCategory => 'Ingen design i denne kategorien';

  @override
  String get loadingDesigns => 'Laster design...';

  @override
  String get loading => 'Laster...';

  @override
  String get categoryKitchen => 'Kjøkken';

  @override
  String get categoryKidsBedroom => 'Barnerom';

  @override
  String get categoryBathroom => 'Baderom';

  @override
  String get categoryLivingRoom => 'Stue';

  @override
  String get categoryMasterBedroom => 'Hovedsoverom';
}
