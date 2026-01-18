// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Expert AI';

  @override
  String get appName => 'Expert';

  @override
  String get guest => 'Vieras';

  @override
  String get loginToSaveDesigns =>
      'Kirjaudu sisään tallentaaksesi suunnitelmasi';

  @override
  String get loggedOutSuccess => 'Kirjauduttu ulos onnistuneesti';

  @override
  String get uploadImage => 'Lataa kuva';

  @override
  String get clickToUploadImage =>
      'Klikkaa tästä ladataksesi kuvan galleriasta';

  @override
  String get gallery => 'Galleria';

  @override
  String get camera => 'Kamera';

  @override
  String get uploadItem => 'Lisää esine';

  @override
  String get redesign => 'Suunnittele uudelleen';

  @override
  String get more => 'Lisää';

  @override
  String get moreOptions => 'Lisää vaihtoehtoja';

  @override
  String get history => 'Historia';

  @override
  String get noHistoryYet => 'Ei vielä historiaa';

  @override
  String get uploadedImagesWillAppear =>
      'Lataamasi ja muokkaamasi kuvat näkyvät täällä';

  @override
  String get whatToChange => 'Mitä haluat muuttaa?';

  @override
  String get uploadImageFirst => 'Lataa ensin kuva';

  @override
  String get uploadingImage => 'Ladataan kuvaa...';

  @override
  String get errorUploadingImage => 'Virhe kuvan lataamisessa';

  @override
  String get itemImageLoaded =>
      'Esineen kuva ladattu! Kuvaile kehotteessa, minne haluat lisätä sen.';

  @override
  String get addAttachedItem => 'Lisää liitetty esine kuvaan';

  @override
  String get processingStarting => 'Aloitetaan...';

  @override
  String get processingMagic => 'Taikuus tapahtuu';

  @override
  String get processing => 'Käsitellään...';

  @override
  String get connectingToCloud => 'Yhdistetään pilveen... ☁️';

  @override
  String get sendingToAI => 'Lähetetään tekoälylle... 🤖';

  @override
  String get analyzingItem => 'Analysoidaan esinettä... 🔍';

  @override
  String get creatingDesign => 'Luodaan suunnitelmaa... ✨';

  @override
  String get funPhrase1 => 'Lähetetään kuvaa toisen ulottuvuuden läpi... 🌀';

  @override
  String get funPhrase2 =>
      'Opetetaan tekoälyä arvostamaan hyvää suunnittelua... 🎨';

  @override
  String get funPhrase3 => 'Vakuutetaan pikselit yhteistyöhön... 🤝';

  @override
  String get funPhrase4 => 'Pieni digitaalinen taikuus matkalla... ✨';

  @override
  String get funPhrase5 => 'Kysytään tekoälyn mielipidettä... 🤔';

  @override
  String get funPhrase6 => 'Sekoitetaan värejä kuin oikea taiteilija... 🖌️';

  @override
  String get funPhrase7 => 'Lasketaan täydellistä kulmaa... 📐';

  @override
  String get funPhrase8 => 'Lisätään tyyliä elämääsi... 💫';

  @override
  String get funPhrase9 => 'Tehdään huoneesta kalliimman näköinen... 💎';

  @override
  String get funPhrase10 => 'Aktivoidaan suunnittelutaikuutta... 🪄';

  @override
  String get funPhrase11 =>
      'Konsultoidaan digitaalisia sisustussuunnittelijoita... 🏠';

  @override
  String get funPhrase12 =>
      'Yritetään olla innostumatta liikaa tuloksesta... 😍';

  @override
  String get funPhrase13 => 'Näet kohta jotain hämmästyttävää... 🚀';

  @override
  String get funPhrase14 =>
      'Varmistetaan, että kaikki on täydellistä sinulle... 👌';

  @override
  String get designStyle => 'Suunnittelutyyli';

  @override
  String get wallColor => 'Vaihda väri';

  @override
  String get lighting => 'Valaistus';

  @override
  String get furniture => 'Huonekalut';

  @override
  String get doorsWindows => 'Ovet ja ikkunat';

  @override
  String get bathroom => 'Kylpyhuone';

  @override
  String get repairs => 'Korjaukset';

  @override
  String get general => 'Yleinen';

  @override
  String get selectDesignStyle => 'Valitse suunnittelutyyli';

  @override
  String get colorPalette => 'Väripaletti';

  @override
  String get selectLightingType => 'Valitse valaistustyyppi';

  @override
  String get selectFurnitureType => 'Valitse huonekalutyyppi';

  @override
  String get selectRepairType => 'Valitse korjaus-/vahinkotyyppi';

  @override
  String get bathroomOptions => 'Kylpyhuonevaihtoehdot';

  @override
  String changeStyleTo(String styleName) {
    return 'Vaihda tyyli muotoon $styleName';
  }

  @override
  String get whatToDo => 'Mitä haluat tehdä?';

  @override
  String get describeChange => 'Kuvaile haluttu muutos...';

  @override
  String get cancel => 'Peruuta';

  @override
  String get execute => 'Suorita';

  @override
  String comingSoon(String feature) {
    return '$feature - Tulossa pian!';
  }

  @override
  String get colorChange => 'Värin vaihto';

  @override
  String get allWalls => 'Kaikki seinät';

  @override
  String get paintAllWalls => 'Maalaa kaikki huoneen seinät';

  @override
  String get specificObject => 'Tietty esine';

  @override
  String get selectWhatToPaint => 'Valitse mitä haluat maalata';

  @override
  String get exampleObjects => 'Esimerkiksi: sohva, katto, kaappi...';

  @override
  String get confirm => 'Vahvista';

  @override
  String get windowOptions => 'Ikkunavaihtoehdot';

  @override
  String get doorOptions => 'Ovivaihtoehdot';

  @override
  String get toiletOptions => 'WC-vaihtoehdot';

  @override
  String get bathtubOptions => 'Kylpyammevaihtoehdot';

  @override
  String get showerOptions => 'Suihkuvaihtoehdot';

  @override
  String get sinkOptions => 'Pesualtaan vaihtoehdot';

  @override
  String get jacuzziOptions => 'Poreallas/spa-vaihtoehdot';

  @override
  String get poolOptions => 'Uima-allasvaihtoehdot';

  @override
  String get professionalSubscription => 'Ammattilaispaketti';

  @override
  String get specialLaunchPrices => 'Erikoiset lanseeraushinnat 🚀';

  @override
  String get purchaseFailed => 'Osto epäonnistui';

  @override
  String get yourCurrentPlan => 'Nykyinen pakettisi';

  @override
  String get selectPlan => 'Valitse paketti';

  @override
  String get perMonth => '/kuukausi';

  @override
  String get starterPlan => 'Aloittelija';

  @override
  String get valuePlan => 'Arvo';

  @override
  String get proPlan => 'Ammattilainen';

  @override
  String imagesPerMonth(int count) {
    return '$count kuvaa kuukaudessa';
  }

  @override
  String get whatsappSupport => 'WhatsApp-tuki';

  @override
  String get historyStorage => 'Historian tallennus';

  @override
  String get vipWhatsappSupport => 'VIP WhatsApp-tuki';

  @override
  String get processingPriority => 'Käsittelyprioriteetti';

  @override
  String get bestValue => 'Paras arvo: 4x enemmän kuvia! 🔥';

  @override
  String get forProfessionals => 'Ammattilaisille ⭐';

  @override
  String savePerImage(String percent) {
    return 'Säästä $percent% per kuva';
  }

  @override
  String get allDesignTools => 'Kaikki suunnittelutyökalut';

  @override
  String get fastSupport => 'Nopea tuki';

  @override
  String get noAds => 'Ei mainoksia';

  @override
  String get restorePurchases => 'Palauta ostot';

  @override
  String get login => 'Kirjaudu sisään';

  @override
  String get logout => 'Kirjaudu ulos';

  @override
  String get createAccount => 'Luo tili';

  @override
  String get createNewAccount => 'Uusi tili';

  @override
  String get welcomeBack => 'Tervetuloa takaisin! Kirjaudu jatkaaksesi';

  @override
  String get joinUs =>
      'Liity mukaan tallentaaksesi suunnitelmat ja käyttääksesi kaikkia ominaisuuksia';

  @override
  String get email => 'Sähköposti';

  @override
  String get password => 'Salasana';

  @override
  String get confirmPassword => 'Vahvista salasana';

  @override
  String get fillAllFields => 'Täytä kaikki kentät';

  @override
  String get passwordsNotMatch => 'Salasanat eivät täsmää';

  @override
  String get passwordsDoNotMatch => 'Salasanat eivät täsmää';

  @override
  String get loginButton => 'Kirjaudu sisään';

  @override
  String get createAccountButton => 'Luo tili';

  @override
  String get forgotPassword => 'Unohditko salasanan?';

  @override
  String get enterEmailFirst => 'Anna ensin sähköpostiosoite';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox and spam folder.';

  @override
  String get passwordResetError => 'Error sending password reset email';

  @override
  String get termsAgreement => 'Kirjautumalla hyväksyt';

  @override
  String get termsOfService => 'Käyttöehdot';

  @override
  String get and => 'ja';

  @override
  String get privacyPolicy => 'Tietosuojakäytännön';

  @override
  String get privacyPolicyUrl => 'https://moomhe.com/privacy-fi.html';

  @override
  String get termsOfServiceUrl => 'https://moomhe.com/eula-fi.html';

  @override
  String get loggingIn => 'Kirjaudutaan...';

  @override
  String get creatingAccount => 'Luodaan tiliä...';

  @override
  String get loginSuccess => 'Kirjautuminen onnistui! 🎉';

  @override
  String get accountCreated => 'Tili luotu onnistuneesti! 🎉';

  @override
  String get loginError => 'Kirjautumisvirhe';

  @override
  String get userNotFound => 'Käyttäjää ei löytynyt';

  @override
  String get wrongPassword => 'Väärä salasana';

  @override
  String get emailInUse => 'Sähköposti on jo käytössä';

  @override
  String get weakPassword => 'Salasana on liian heikko';

  @override
  String get invalidEmail => 'Virheellinen sähköpostiosoite';

  @override
  String get exitAccount => 'Poistu tililtä';

  @override
  String get loginWithEmail =>
      'Kirjaudu sähköpostilla tallentaaksesi suunnitelmasi';

  @override
  String get mySubscription => 'Tilaukseni';

  @override
  String creditsRemaining(int count) {
    return '$count krediittiä jäljellä';
  }

  @override
  String get upgradeToPremium => 'Päivitä Premiumiin';

  @override
  String get iHaveCoupon => 'Minulla on kuponki';

  @override
  String get enterCouponCode =>
      'Anna kuponkikoodi saadaksesi ilmaisia krediittejä';

  @override
  String get enterCouponCodeTitle => 'Anna kuponkikoodi';

  @override
  String get enterCouponCodeSubtitle =>
      'Anna saamasi kuponkikoodi saadaksesi ilmaisia krediittejä';

  @override
  String get couponCode => 'Kuponkikoodi';

  @override
  String get mustEnterCoupon => 'Sinun on annettava kuponkikoodi';

  @override
  String get couponActivated => 'Kuponki aktivoitu onnistuneesti!';

  @override
  String get errorRedeemingCoupon => 'Virhe kupongin lunastuksessa';

  @override
  String get redeemCoupon => 'Lunasta kuponki';

  @override
  String creditsAddedToAccount(int count) {
    return '$count krediittiä lisätty tilillesi! 🎉';
  }

  @override
  String get contactUs => 'Ota yhteyttä';

  @override
  String get contactSubtitle =>
      'Haluaisimme kuulla sinusta! Täytä tiedot, niin otamme pian yhteyttä.';

  @override
  String get phone => 'Puhelin';

  @override
  String get message => 'Viesti';

  @override
  String get writeYourMessage => 'Kirjoita viestisi tähän...';

  @override
  String get enterPhoneOrEmail => '* Anna vähintään puhelin tai sähköposti';

  @override
  String get pleaseEnterPhoneOrEmail => 'Anna vähintään puhelin tai sähköposti';

  @override
  String get pleaseEnterMessage => 'Anna viesti';

  @override
  String get errorSendingMessage =>
      'Virhe viestin lähettämisessä. Yritä uudelleen.';

  @override
  String get sendMessage => 'Lähetä viesti';

  @override
  String get messageSentSuccess => 'Viesti lähetetty onnistuneesti!';

  @override
  String get contentNotAllowed => 'Sisältö ei sallittu';

  @override
  String get requestFailed => 'Pyyntö epäonnistui';

  @override
  String get oopsSomethingWrong => 'Hups! Jotain meni pieleen';

  @override
  String get moderationError =>
      'Tätä kuvaa tai pyyntöä ei voi käsitellä.\n\nKuva tai pyyntö saattaa sisältää sisältöä, jota ei ole sallittu käsitellä.\n\nKokeile toisella kuvalla tai muuta pyyntöä.';

  @override
  String get timeoutError =>
      'Pyyntö kesti liian kauan.\n\nYritä myöhemmin uudelleen.';

  @override
  String get genericError =>
      'Pyyntöä ei voitu käsitellä.\n\nYritä uudelleen tai ota yhteyttä tukeen, jos ongelma jatkuu.';

  @override
  String get close => 'Sulje';

  @override
  String get tryAgain => 'Yritä uudelleen';

  @override
  String get imageSavedToGallery => 'Kuva tallennettu galleriaan!';

  @override
  String get errorDownloadingImage => 'Virhe kuvan lataamisessa';

  @override
  String get errorSharing => 'Virhe jakamisessa';

  @override
  String get shareText =>
      '🏠 Suunnittelin tämän MoomHe AI:lla!\n📸 Haluatko kokeilla? https://moomhe.com';

  @override
  String get comparison => 'Vertailu';

  @override
  String get download => 'Lataa';

  @override
  String get share => 'Jaa';

  @override
  String get revertToOriginal => 'Palauta alkuperäiseen';

  @override
  String get loveItSave => 'Rakastan! Tallenna';

  @override
  String get creditsFinishedThisMonth => 'Krediitit lopussa tässä kuussa';

  @override
  String get creditsRanOut => 'Krediitit lopussa tässä kuussa';

  @override
  String get freeLimitReached => 'Olet saavuttanut ilmaisen käytön rajan';

  @override
  String get reachedFreeLimit => 'Olet saavuttanut ilmaisen käytön rajan';

  @override
  String creditsLimitReached(int limit) {
    return 'Olet saavuttanut krediittirajan ($limit krediittiä). Voit päivittää suurempaan pakettiin tai odottaa seuraavaan kuukauteen.';
  }

  @override
  String freeCreditsUsed(int limit) {
    return 'Olet käyttänyt kaikki $limit ilmaista krediittiäsi. Jatkaaksesi suunnittelua rajoituksetta ja saadaksesi edistyneet ominaisuudet, päivitä ammattilaispaketiksi.';
  }

  @override
  String get currentUsage => 'Nykyinen käyttö';

  @override
  String get limit => 'Raja';

  @override
  String designs(int count) {
    return '$count suunnitelmaa';
  }

  @override
  String designsCount(int count) {
    return '$count suunnitelmaa';
  }

  @override
  String get upgradePlan => 'Päivitä paketti';

  @override
  String get goToProfessionalPlan => 'Siirry ammattilaispaketiksi';

  @override
  String get goPro => 'Siirry Pro:hon';

  @override
  String get notNowThanks => 'Ei nyt, kiitos';

  @override
  String welcomeToPlan(String planName) {
    return 'Tervetuloa $planName-pakettiin!';
  }

  @override
  String get thankYouForJoining =>
      'Kiitos liittymisestäsi tilaajaperheeseemme. Tilisi on päivitetty onnistuneesti ja sinulla on nyt pääsy kaikkiin edistyneisiin ominaisuuksiin ja lisäkrediitteihin.';

  @override
  String get creditsAddedToYourAccount => 'Krediitit lisätty tilillesi';

  @override
  String get unlimitedStyleAccess => 'Rajoittamaton pääsy kaikkiin tyyleihin';

  @override
  String get supportCreators => 'Tuki luojille ja suunnittelijoille';

  @override
  String get startDesigning => 'Aloita suunnittelu';

  @override
  String get secureYourSubscription => 'Suojaa tilauksesi';

  @override
  String get secureSubscriptionMessage =>
      'Jotta et menetä ostamaasi tilausta, suosittelemme kirjautumaan sähköpostilla.\n\nNäin voit palauttaa tilauksesi uudella laitteella tai uudelleenasennuksen jälkeen.';

  @override
  String get later => 'Myöhemmin';

  @override
  String get loginNow => 'Kirjaudu nyt';

  @override
  String get onboardingUploadTitle => 'Lataa kuva';

  @override
  String get onboardingUploadDesc =>
      'Aloita lataamalla kuva huoneesta, jonka haluat suunnitella. Eikö ole? Ei huolta, käytämme esimerkkikuvaa.';

  @override
  String get onboardingStyleTitle => 'Valitse uudelleensuunnittelutyyli';

  @override
  String get onboardingStyleDesc =>
      'Valitse suosikkityylisi sivuvalikosta. Kokeile \"Suunnittele uudelleen\" nähdäksesi eri vaihtoehdot.';

  @override
  String get onboardingCreateTitle => 'Luo suunnitelma';

  @override
  String get onboardingCreateDesc =>
      'Klikkaa \"Luo\" ja tekoäly suunnittelee huoneesi uudelleen sekunneissa!';

  @override
  String get onboardingItemTipTitle => 'Lisävinkki: Lisää esine';

  @override
  String get onboardingItemTipDesc =>
      'Haluatko lisätä tietyn huonekalun? Käytä \"Lisää esine\" -painiketta ladataksesi esineen kuvan ja sisällyttääksesi sen suunnitelmaan.';

  @override
  String get skip => 'Ohita';

  @override
  String get next => 'Seuraava';

  @override
  String get finish => 'Valmis';

  @override
  String get promptAddedToInput =>
      'Kehote lisätty - voit muokata sitä ja klikata sitten Luo';

  @override
  String get styleMediterranean => 'Moderni välimerellinen';

  @override
  String get styleWarmMinimalism => 'Lämmin minimalismi';

  @override
  String get styleBiophilic => 'Biofiilinen';

  @override
  String get styleModernLuxury => 'Moderni luksus';

  @override
  String get styleJapandi => 'Japandi';

  @override
  String get styleScandinavian => 'Skandinaavinen';

  @override
  String get styleBohoChic => 'Boho chic';

  @override
  String get styleIndustrial => 'Teollinen';

  @override
  String get styleEarthyNatural => 'Maanläheinen luonnollinen';

  @override
  String get styleJerusalem => 'Jerusalem';

  @override
  String get styleMinimalist => 'Minimalistinen';

  @override
  String get styleModernClassic => 'Moderni klassinen';

  @override
  String get colorCategoryReds => 'Punaiset';

  @override
  String get colorCategoryOranges => 'Oranssit';

  @override
  String get colorCategoryYellows => 'Keltaiset';

  @override
  String get colorCategoryGreens => 'Vihreät';

  @override
  String get colorCategoryBlues => 'Siniset';

  @override
  String get colorCategoryPurples => 'Violetit';

  @override
  String get colorCategoryGrays => 'Harmaat';

  @override
  String get colorCategoryWhitesBlacks => 'Valkoiset ja mustat';

  @override
  String get lightingRecessed => 'Upotettava valaistus';

  @override
  String get lightingPendant => 'Riippuvalaisin';

  @override
  String get lightingChandelier => 'Kattokruunu';

  @override
  String get lightingTableLamp => 'Pöytävalaisin';

  @override
  String get lightingFloorLamp => 'Jalkavalaisin';

  @override
  String get lightingWallSconce => 'Seinävalaisin';

  @override
  String get lightingTrack => 'Kiskovalaisin';

  @override
  String get lightingCeiling => 'Kattovalaisin';

  @override
  String get lightingUnderCabinet => 'Alakaappivalaisin';

  @override
  String get lightingDecorative => 'Koristevalaistus';

  @override
  String get lightingDay => 'Päivä';

  @override
  String get lightingNight => 'Yö';

  @override
  String get lightingSunset => 'Auringonlasku';

  @override
  String get lightingSunrise => 'Auringonnousu';

  @override
  String get lightingAddRecessed => 'Lisää upotettava valaistus';

  @override
  String get lightingAddPendant => 'Lisää riippuvalaisin';

  @override
  String get lightingAddChandelier => 'Lisää kattokruunu';

  @override
  String get lightingAddTableLamp => 'Lisää pöytävalaisin';

  @override
  String get lightingAddFloorLamp => 'Lisää jalkavalaisin';

  @override
  String get lightingAddWallSconce => 'Lisää seinävalaisin';

  @override
  String get lightingAddTrack => 'Lisää kiskovalaisin';

  @override
  String get lightingAddCeiling => 'Lisää kattovalaisin';

  @override
  String get lightingAddUnderCabinet => 'Lisää alakaappivalaisin';

  @override
  String get lightingAddDecorative => 'Lisää koristevalaistus';

  @override
  String get lightingChangeToDay => 'Vaihda valaistus päivävaloksi';

  @override
  String get lightingChangeToNight => 'Vaihda valaistus yövaloksi';

  @override
  String get lightingChangeToSunset => 'Vaihda valaistus auringonlaskuun';

  @override
  String get lightingChangeToSunrise => 'Vaihda valaistus auringonnousuun';

  @override
  String get furnitureSofa => 'Sohva';

  @override
  String get furnitureSectional => 'Kulmasohva';

  @override
  String get furnitureArmchair => 'Nojatuoli';

  @override
  String get furnitureAccentChair => 'Korostetuoli';

  @override
  String get furnitureDiningChair => 'Ruokatuoli';

  @override
  String get furnitureBarStool => 'Baarituoli';

  @override
  String get furnitureSingleBed => 'Yhden hengen sänky';

  @override
  String get furnitureDoubleBed => 'Parisänky';

  @override
  String get furnitureBeanbag => 'Säkkituoli';

  @override
  String get furnitureOttoman => 'Rahi';

  @override
  String get furnitureBench => 'Penkki';

  @override
  String get furnitureCoffeeTable => 'Sohvapöytä';

  @override
  String get furnitureEndTable => 'Sivupöytä';

  @override
  String get furnitureNightstand => 'Yöpöytä';

  @override
  String get furnitureDiningTable => 'Ruokapöytä';

  @override
  String get furnitureDesk => 'Työpöytä';

  @override
  String get furnitureDresser => 'Lipasto';

  @override
  String get furnitureWardrobe => 'Vaatekaappi';

  @override
  String get furnitureBookcase => 'Kirjahylly';

  @override
  String get furnitureTvStand => 'TV-taso';

  @override
  String get furnitureCabinets => 'Keittiökaapit';

  @override
  String get furnitureAddSofa => 'Lisää sohva';

  @override
  String get furnitureAddSectional => 'Lisää kulmasohva';

  @override
  String get furnitureAddArmchair => 'Lisää nojatuoli';

  @override
  String get furnitureAddAccentChair => 'Lisää korostetuoli';

  @override
  String get furnitureAddDiningChair => 'Lisää ruokatuoli';

  @override
  String get furnitureAddBarStool => 'Lisää baarituoli';

  @override
  String get furnitureAddSingleBed => 'Lisää yhden hengen sänky';

  @override
  String get furnitureAddDoubleBed => 'Lisää parisänky';

  @override
  String get furnitureAddBeanbag => 'Lisää säkkituoli';

  @override
  String get furnitureAddOttoman => 'Lisää rahi';

  @override
  String get furnitureAddBench => 'Lisää penkki';

  @override
  String get furnitureAddCoffeeTable => 'Lisää sohvapöytä';

  @override
  String get furnitureAddEndTable => 'Lisää sivupöytä';

  @override
  String get furnitureAddNightstand => 'Lisää yöpöytä';

  @override
  String get furnitureAddDiningTable => 'Lisää ruokapöytä';

  @override
  String get furnitureAddDesk => 'Lisää työpöytä';

  @override
  String get furnitureAddDresser => 'Lisää lipasto';

  @override
  String get furnitureAddWardrobe => 'Lisää vaatekaappi';

  @override
  String get furnitureAddBookcase => 'Lisää kirjahylly';

  @override
  String get furnitureAddTvStand => 'Lisää TV-taso';

  @override
  String get furnitureAddCabinets => 'Lisää keittiökaapit';

  @override
  String get repairsFixEverything => 'Korjaa kaikki';

  @override
  String get repairsRepairAll => 'Korjaa ja kunnostaa kaikki';

  @override
  String get repairsMessUp => 'Sotke kaikki';

  @override
  String get repairsDestroy => 'Tuhoa ja vahingoita kaikki';

  @override
  String get windowPicture => 'Maisemaikkuna';

  @override
  String get windowSliding => 'Liukuikkuna';

  @override
  String get windowCasement => 'Saranaikkuna';

  @override
  String get windowTiltTurn => 'Kääntö-kallistusikkuna';

  @override
  String get windowAwning => 'Ylösaukeava ikkuna';

  @override
  String get windowSash => 'Nostoikkuna';

  @override
  String get windowPocket => 'Taskuikkuna';

  @override
  String get windowArched => 'Kaareva ikkuna';

  @override
  String get windowAddPicture => 'Lisää suuri maisemaikkuna';

  @override
  String get windowAddSliding => 'Lisää liukuikkuna';

  @override
  String get windowAddCasement => 'Lisää saranaikkuna';

  @override
  String get windowAddTiltTurn => 'Lisää kääntö-kallistusikkuna';

  @override
  String get windowAddAwning => 'Lisää ylösaukeava ikkuna';

  @override
  String get windowAddSash => 'Lisää nostoikkuna';

  @override
  String get windowAddPocket => 'Lisää taskuikkuna';

  @override
  String get windowAddArched => 'Lisää kaareva ikkuna';

  @override
  String get doorPocket => 'Taskuovi';

  @override
  String get doorFrench => 'Ranskalaiset ovet';

  @override
  String get doorLouvered => 'Säleovi';

  @override
  String get doorBarn => 'Ladun ovi';

  @override
  String get doorAddPocket => 'Lisää seinään liukuva taskuovi';

  @override
  String get doorAddFrench => 'Lisää ranskalaiset ovet lasilla';

  @override
  String get doorAddLouvered => 'Lisää säleovi';

  @override
  String get doorAddBarn => 'Lisää ladun ovi';

  @override
  String get toiletBidet => 'Lämmitetty bidee';

  @override
  String get toiletSeat => 'WC-istuin';

  @override
  String get tubFreestanding => 'Vapaasti seisova amme';

  @override
  String get tubVintage => 'Vintage-amme';

  @override
  String get tubStandard => 'Standardiamme';

  @override
  String get showerRain => 'Sadesuihku';

  @override
  String get showerEnclosure => 'Suihkukaappi';

  @override
  String get showerSliding => 'Liukuovisuihku';

  @override
  String get sinkPedestal => 'Jalallinen pesuallas';

  @override
  String get sinkStainless => 'Ruostumaton pesuallas';

  @override
  String get sinkUndermount => 'Alakiinnitettävä pesuallas';

  @override
  String get jacuzziBuiltIn => 'Kiinteä poreallas';

  @override
  String get jacuzziPortable => 'Siirrettävä poreallas';

  @override
  String get poolInground => 'Maahan upotettu allas';

  @override
  String get poolAboveGround => 'Maanpäällinen allas';

  @override
  String get toiletAddBidet => 'Lisää WC-istuin bideellä';

  @override
  String get toiletAddSeat => 'Lisää WC-istuin';

  @override
  String get tubAddFreestanding => 'Lisää vapaasti seisova amme';

  @override
  String get tubAddVintage => 'Lisää vintage-amme';

  @override
  String get tubAddStandard => 'Lisää standardiamme';

  @override
  String get showerAddRain => 'Lisää suihku sadesuihkupäällä';

  @override
  String get showerAddEnclosure => 'Lisää suihkukaappi';

  @override
  String get showerAddSliding => 'Lisää suihku liukuovilla';

  @override
  String get sinkAddPedestal => 'Lisää jalallinen pesuallas';

  @override
  String get sinkAddStainless => 'Lisää ruostumaton pesuallas';

  @override
  String get sinkAddUndermount => 'Lisää alakiinnitettävä pesuallas';

  @override
  String get jacuzziAddBuiltIn => 'Lisää kiinteä poreallas';

  @override
  String get jacuzziAddPortable => 'Lisää siirrettävä poreallas';

  @override
  String get poolAddInground => 'Lisää maahan upotettu allas';

  @override
  String get poolAddAboveGround => 'Lisää maanpäällinen allas';

  @override
  String get errorUnknown => 'Tuntematon virhe';

  @override
  String get searchWithLens => 'Hae';

  @override
  String get cancelSearch => 'Peruuta';

  @override
  String get selectAreaToSearch =>
      'Piirrä suorakaide haettavan esineen ympärille';

  @override
  String get searchingWithGoogleLens => 'Haetaan Google Lensillä...';

  @override
  String get selectAreaWithinImage => 'Valitse alue kuvan sisällä';

  @override
  String get googleLensSearchFailed => 'Haku epäonnistui. Yritä uudelleen.';

  @override
  String get rateAppTitle => 'Pidätkö sovelluksesta?';

  @override
  String get rateAppMessage =>
      'Haluaisimme kuulla mielipiteesi! Palautteesi auttaa meitä parantamaan.';

  @override
  String get rateAppYes => 'Kyllä, rakastan sitä! 😍';

  @override
  String get rateAppNo => 'En oikeastaan';

  @override
  String get rateAppLater => 'Kysy myöhemmin';

  @override
  String get deleteAccount => 'Poista tili';

  @override
  String get deleteAccountWarning1Title => 'Poista tili';

  @override
  String get deleteAccountWarning1Message =>
      'Haluatko varmasti poistaa tilisi? Tämä poistaa kaikki tietosi ja kuvasi, eikä sitä voi peruuttaa.';

  @override
  String get deleteAccountWarning2Title => 'Lopullinen vahvistus';

  @override
  String get deleteAccountWarning2Message =>
      'Tätä toimintoa ei voi peruuttaa! Kaikki historiasi ja kuvasi poistetaan pysyvästi. Oletko 100% varma?';

  @override
  String get deleteAccountConfirm => 'Kyllä, poista tili';

  @override
  String get deletingAccount => 'Poistetaan tiliä...';

  @override
  String get accountDeleted => 'Tili poistettu onnistuneesti';

  @override
  String get errorDeletingAccount => 'Virhe tilin poistamisessa';

  @override
  String get language => 'Kieli';

  @override
  String get selectLanguage => 'Valitse kieli';

  @override
  String get languageChanged => 'Kieli vaihdettu';
}
