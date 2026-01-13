import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Expert AI'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get appName;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @loginToSaveDesigns.
  ///
  /// In en, this message translates to:
  /// **'Log in to save your designs'**
  String get loginToSaveDesigns;

  /// No description provided for @loggedOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccess;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @clickToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Click here to upload an image from gallery'**
  String get clickToUploadImage;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @uploadItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get uploadItem;

  /// No description provided for @redesign.
  ///
  /// In en, this message translates to:
  /// **'Redesign'**
  String get redesign;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @uploadedImagesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Images you upload and edit will appear here'**
  String get uploadedImagesWillAppear;

  /// No description provided for @whatToChange.
  ///
  /// In en, this message translates to:
  /// **'What to change?'**
  String get whatToChange;

  /// No description provided for @uploadImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please upload an image first'**
  String get uploadImageFirst;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get uploadingImage;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get errorUploadingImage;

  /// No description provided for @itemImageLoaded.
  ///
  /// In en, this message translates to:
  /// **'Item image loaded! Describe in the prompt where to add it.'**
  String get itemImageLoaded;

  /// No description provided for @addAttachedItem.
  ///
  /// In en, this message translates to:
  /// **'Add the attached item to the image'**
  String get addAttachedItem;

  /// No description provided for @processingStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get processingStarting;

  /// No description provided for @processingMagic.
  ///
  /// In en, this message translates to:
  /// **'The magic is happening'**
  String get processingMagic;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @funPhrase1.
  ///
  /// In en, this message translates to:
  /// **'Sending the image through another dimension... 🌀'**
  String get funPhrase1;

  /// No description provided for @funPhrase2.
  ///
  /// In en, this message translates to:
  /// **'Teaching the AI to appreciate good design... 🎨'**
  String get funPhrase2;

  /// No description provided for @funPhrase3.
  ///
  /// In en, this message translates to:
  /// **'Convincing the pixels to cooperate... 🤝'**
  String get funPhrase3;

  /// No description provided for @funPhrase4.
  ///
  /// In en, this message translates to:
  /// **'A little digital magic on the way... ✨'**
  String get funPhrase4;

  /// No description provided for @funPhrase5.
  ///
  /// In en, this message translates to:
  /// **'Asking the AI what it thinks... 🤔'**
  String get funPhrase5;

  /// No description provided for @funPhrase6.
  ///
  /// In en, this message translates to:
  /// **'Mixing colors like a real artist... 🖌️'**
  String get funPhrase6;

  /// No description provided for @funPhrase7.
  ///
  /// In en, this message translates to:
  /// **'Calculating the perfect angle... 📐'**
  String get funPhrase7;

  /// No description provided for @funPhrase8.
  ///
  /// In en, this message translates to:
  /// **'Adding some style to your life... 💫'**
  String get funPhrase8;

  /// No description provided for @funPhrase9.
  ///
  /// In en, this message translates to:
  /// **'Making the room look more expensive... 💎'**
  String get funPhrase9;

  /// No description provided for @funPhrase10.
  ///
  /// In en, this message translates to:
  /// **'Activating the design magic... 🪄'**
  String get funPhrase10;

  /// No description provided for @funPhrase11.
  ///
  /// In en, this message translates to:
  /// **'Consulting with the digital interior designers... 🏠'**
  String get funPhrase11;

  /// No description provided for @funPhrase12.
  ///
  /// In en, this message translates to:
  /// **'Trying not to get too excited about the result... 😍'**
  String get funPhrase12;

  /// No description provided for @funPhrase13.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see something amazing in a moment... 🚀'**
  String get funPhrase13;

  /// No description provided for @funPhrase14.
  ///
  /// In en, this message translates to:
  /// **'Making sure everything is perfect for you... 👌'**
  String get funPhrase14;

  /// No description provided for @designStyle.
  ///
  /// In en, this message translates to:
  /// **'Design Style'**
  String get designStyle;

  /// No description provided for @wallColor.
  ///
  /// In en, this message translates to:
  /// **'Change Color'**
  String get wallColor;

  /// No description provided for @lighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get lighting;

  /// No description provided for @furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// No description provided for @doorsWindows.
  ///
  /// In en, this message translates to:
  /// **'Doors & Windows'**
  String get doorsWindows;

  /// No description provided for @bathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get bathroom;

  /// No description provided for @repairs.
  ///
  /// In en, this message translates to:
  /// **'Repairs'**
  String get repairs;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @selectDesignStyle.
  ///
  /// In en, this message translates to:
  /// **'Select Design Style'**
  String get selectDesignStyle;

  /// No description provided for @colorPalette.
  ///
  /// In en, this message translates to:
  /// **'Color Palette'**
  String get colorPalette;

  /// No description provided for @selectLightingType.
  ///
  /// In en, this message translates to:
  /// **'Select Lighting Type'**
  String get selectLightingType;

  /// No description provided for @selectFurnitureType.
  ///
  /// In en, this message translates to:
  /// **'Select Furniture Type'**
  String get selectFurnitureType;

  /// No description provided for @selectRepairType.
  ///
  /// In en, this message translates to:
  /// **'Select Repair/Damage Type'**
  String get selectRepairType;

  /// No description provided for @bathroomOptions.
  ///
  /// In en, this message translates to:
  /// **'Bathroom Options'**
  String get bathroomOptions;

  /// No description provided for @changeStyleTo.
  ///
  /// In en, this message translates to:
  /// **'Change the style to {styleName}'**
  String changeStyleTo(String styleName);

  /// No description provided for @whatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do?'**
  String get whatToDo;

  /// No description provided for @describeChange.
  ///
  /// In en, this message translates to:
  /// **'Describe the desired change...'**
  String get describeChange;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @execute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get execute;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} - Coming soon!'**
  String comingSoon(String feature);

  /// No description provided for @colorChange.
  ///
  /// In en, this message translates to:
  /// **'Change Color'**
  String get colorChange;

  /// No description provided for @allWalls.
  ///
  /// In en, this message translates to:
  /// **'All Walls'**
  String get allWalls;

  /// No description provided for @paintAllWalls.
  ///
  /// In en, this message translates to:
  /// **'Paint all walls in the room'**
  String get paintAllWalls;

  /// No description provided for @specificObject.
  ///
  /// In en, this message translates to:
  /// **'Specific Object'**
  String get specificObject;

  /// No description provided for @selectWhatToPaint.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to paint'**
  String get selectWhatToPaint;

  /// No description provided for @exampleObjects.
  ///
  /// In en, this message translates to:
  /// **'For example: sofa, ceiling, cabinet...'**
  String get exampleObjects;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @windowOptions.
  ///
  /// In en, this message translates to:
  /// **'Window Options'**
  String get windowOptions;

  /// No description provided for @doorOptions.
  ///
  /// In en, this message translates to:
  /// **'Door Options'**
  String get doorOptions;

  /// No description provided for @toiletOptions.
  ///
  /// In en, this message translates to:
  /// **'Toilet Options'**
  String get toiletOptions;

  /// No description provided for @bathtubOptions.
  ///
  /// In en, this message translates to:
  /// **'Bathtub Options'**
  String get bathtubOptions;

  /// No description provided for @showerOptions.
  ///
  /// In en, this message translates to:
  /// **'Shower Options'**
  String get showerOptions;

  /// No description provided for @sinkOptions.
  ///
  /// In en, this message translates to:
  /// **'Sink Options'**
  String get sinkOptions;

  /// No description provided for @jacuzziOptions.
  ///
  /// In en, this message translates to:
  /// **'Jacuzzi/Spa Options'**
  String get jacuzziOptions;

  /// No description provided for @poolOptions.
  ///
  /// In en, this message translates to:
  /// **'Pool Options'**
  String get poolOptions;

  /// No description provided for @professionalSubscription.
  ///
  /// In en, this message translates to:
  /// **'Professional Plan'**
  String get professionalSubscription;

  /// No description provided for @specialLaunchPrices.
  ///
  /// In en, this message translates to:
  /// **'Special launch prices 🚀'**
  String get specialLaunchPrices;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseFailed;

  /// No description provided for @yourCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Your current plan'**
  String get yourCurrentPlan;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get selectPlan;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @starterPlan.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get starterPlan;

  /// No description provided for @valuePlan.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valuePlan;

  /// No description provided for @proPlan.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get proPlan;

  /// No description provided for @imagesPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} images per month'**
  String imagesPerMonth(int count);

  /// No description provided for @whatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupport;

  /// No description provided for @historyStorage.
  ///
  /// In en, this message translates to:
  /// **'History Storage'**
  String get historyStorage;

  /// No description provided for @vipWhatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'VIP WhatsApp Support'**
  String get vipWhatsappSupport;

  /// No description provided for @processingPriority.
  ///
  /// In en, this message translates to:
  /// **'Processing Priority'**
  String get processingPriority;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value: 4x more images! 🔥'**
  String get bestValue;

  /// No description provided for @forProfessionals.
  ///
  /// In en, this message translates to:
  /// **'For professionals ⭐'**
  String get forProfessionals;

  /// No description provided for @savePerImage.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}% per image'**
  String savePerImage(String percent);

  /// No description provided for @allDesignTools.
  ///
  /// In en, this message translates to:
  /// **'All design tools'**
  String get allDesignTools;

  /// No description provided for @fastSupport.
  ///
  /// In en, this message translates to:
  /// **'Fast support'**
  String get fastSupport;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get noAds;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get createNewAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Log in to continue'**
  String get welcomeBack;

  /// No description provided for @joinUs.
  ///
  /// In en, this message translates to:
  /// **'Join us to save designs and access all features'**
  String get joinUs;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address first'**
  String get enterEmailFirst;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By logging in you agree to the'**
  String get termsAgreement;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyUrl.
  ///
  /// In en, this message translates to:
  /// **'https://moomhe.com/privacy-en.html'**
  String get privacyPolicyUrl;

  /// No description provided for @termsOfServiceUrl.
  ///
  /// In en, this message translates to:
  /// **'https://moomhe.com/eula-en.html'**
  String get termsOfServiceUrl;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully! 🎉'**
  String get loginSuccess;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! 🎉'**
  String get accountCreated;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @exitAccount.
  ///
  /// In en, this message translates to:
  /// **'Exit account'**
  String get exitAccount;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Log in with email to save your designs'**
  String get loginWithEmail;

  /// No description provided for @mySubscription.
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get mySubscription;

  /// No description provided for @creditsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} credits remaining'**
  String creditsRemaining(int count);

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @iHaveCoupon.
  ///
  /// In en, this message translates to:
  /// **'I have a coupon'**
  String get iHaveCoupon;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code to get free credits'**
  String get enterCouponCode;

  /// No description provided for @enterCouponCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Coupon Code'**
  String get enterCouponCodeTitle;

  /// No description provided for @enterCouponCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the coupon code you received to get free credits'**
  String get enterCouponCodeSubtitle;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponCode;

  /// No description provided for @mustEnterCoupon.
  ///
  /// In en, this message translates to:
  /// **'You must enter a coupon code'**
  String get mustEnterCoupon;

  /// No description provided for @couponActivated.
  ///
  /// In en, this message translates to:
  /// **'Coupon activated successfully!'**
  String get couponActivated;

  /// No description provided for @errorRedeemingCoupon.
  ///
  /// In en, this message translates to:
  /// **'Error redeeming coupon'**
  String get errorRedeemingCoupon;

  /// No description provided for @redeemCoupon.
  ///
  /// In en, this message translates to:
  /// **'Redeem Coupon'**
  String get redeemCoupon;

  /// No description provided for @creditsAddedToAccount.
  ///
  /// In en, this message translates to:
  /// **'{count} credits added to your account! 🎉'**
  String creditsAddedToAccount(int count);

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you! Fill in the details and we\'ll get back to you soon.'**
  String get contactSubtitle;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @writeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get writeYourMessage;

  /// No description provided for @enterPhoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'* Please enter at least phone or email'**
  String get enterPhoneOrEmail;

  /// No description provided for @pleaseEnterPhoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least phone or email'**
  String get pleaseEnterPhoneOrEmail;

  /// No description provided for @pleaseEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get pleaseEnterMessage;

  /// No description provided for @errorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending message. Please try again.'**
  String get errorSendingMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @messageSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully!'**
  String get messageSentSuccess;

  /// No description provided for @contentNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Content Not Allowed'**
  String get contentNotAllowed;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request Failed'**
  String get requestFailed;

  /// No description provided for @oopsSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWrong;

  /// No description provided for @moderationError.
  ///
  /// In en, this message translates to:
  /// **'Cannot process this image or request.\n\nThe image or request may contain content that is not allowed for processing.\n\nTry with a different image or change the request.'**
  String get moderationError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'The request took too long.\n\nPlease try again later.'**
  String get timeoutError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t process the request.\n\nTry again or contact support if the issue persists.'**
  String get genericError;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery!'**
  String get imageSavedToGallery;

  /// No description provided for @errorDownloadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error downloading image'**
  String get errorDownloadingImage;

  /// No description provided for @errorSharing.
  ///
  /// In en, this message translates to:
  /// **'Error sharing'**
  String get errorSharing;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'🏠 I designed this with MoomHe AI!\n📸 Want to try it too? https://moomhe.com'**
  String get shareText;

  /// No description provided for @comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparison;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @revertToOriginal.
  ///
  /// In en, this message translates to:
  /// **'Revert to Original'**
  String get revertToOriginal;

  /// No description provided for @loveItSave.
  ///
  /// In en, this message translates to:
  /// **'Love it! Save'**
  String get loveItSave;

  /// No description provided for @creditsFinishedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Credits finished for this month'**
  String get creditsFinishedThisMonth;

  /// No description provided for @creditsRanOut.
  ///
  /// In en, this message translates to:
  /// **'Credits ran out for this month'**
  String get creditsRanOut;

  /// No description provided for @freeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the free usage limit'**
  String get freeLimitReached;

  /// No description provided for @reachedFreeLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the free usage limit'**
  String get reachedFreeLimit;

  /// No description provided for @creditsLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your credits limit ({limit} credits). You can upgrade to a larger plan or wait until next month.'**
  String creditsLimitReached(int limit);

  /// No description provided for @freeCreditsUsed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your {limit} free credits. To continue designing without limits and get advanced features, upgrade to a professional plan.'**
  String freeCreditsUsed(int limit);

  /// No description provided for @currentUsage.
  ///
  /// In en, this message translates to:
  /// **'Current Usage'**
  String get currentUsage;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @designs.
  ///
  /// In en, this message translates to:
  /// **'{count} designs'**
  String designs(int count);

  /// No description provided for @designsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} designs'**
  String designsCount(int count);

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// No description provided for @goToProfessionalPlan.
  ///
  /// In en, this message translates to:
  /// **'Go to Professional Plan'**
  String get goToProfessionalPlan;

  /// No description provided for @goPro.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get goPro;

  /// No description provided for @notNowThanks.
  ///
  /// In en, this message translates to:
  /// **'Not now, thanks'**
  String get notNowThanks;

  /// No description provided for @welcomeToPlan.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {planName} plan!'**
  String welcomeToPlan(String planName);

  /// No description provided for @thankYouForJoining.
  ///
  /// In en, this message translates to:
  /// **'Thank you for joining our subscribers family. Your account has been upgraded successfully and you now have access to all advanced features and additional credits.'**
  String get thankYouForJoining;

  /// No description provided for @creditsAddedToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Credits added to your account'**
  String get creditsAddedToYourAccount;

  /// No description provided for @unlimitedStyleAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to all styles'**
  String get unlimitedStyleAccess;

  /// No description provided for @supportCreators.
  ///
  /// In en, this message translates to:
  /// **'Support for creators and designers'**
  String get supportCreators;

  /// No description provided for @startDesigning.
  ///
  /// In en, this message translates to:
  /// **'Start Designing'**
  String get startDesigning;

  /// No description provided for @secureYourSubscription.
  ///
  /// In en, this message translates to:
  /// **'Secure Your Subscription'**
  String get secureYourSubscription;

  /// No description provided for @secureSubscriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'To not lose the subscription you purchased, we recommend logging in with email.\n\nThis way you can restore your subscription on a new device or after reinstalling.'**
  String get secureSubscriptionMessage;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @onboardingUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get onboardingUploadTitle;

  /// No description provided for @onboardingUploadDesc.
  ///
  /// In en, this message translates to:
  /// **'Start by uploading a photo of the room you want to design. Don\'t have one? No worries, we\'ll use a sample image.'**
  String get onboardingUploadDesc;

  /// No description provided for @onboardingStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Redesign Style'**
  String get onboardingStyleTitle;

  /// No description provided for @onboardingStyleDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred style from the side menu. Try \"Redesign\" to see different options.'**
  String get onboardingStyleDesc;

  /// No description provided for @onboardingCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Design'**
  String get onboardingCreateTitle;

  /// No description provided for @onboardingCreateDesc.
  ///
  /// In en, this message translates to:
  /// **'Click \"Create\" and the AI will redesign your room in seconds!'**
  String get onboardingCreateDesc;

  /// No description provided for @onboardingItemTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra Tip: Add Item'**
  String get onboardingItemTipTitle;

  /// No description provided for @onboardingItemTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Want to add a specific piece of furniture? Use the \"Add Item\" button to upload an image of an item and incorporate it into the design.'**
  String get onboardingItemTipDesc;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @promptAddedToInput.
  ///
  /// In en, this message translates to:
  /// **'Prompt added - you can edit it and then tap Create'**
  String get promptAddedToInput;

  /// No description provided for @styleMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Modern Mediterranean'**
  String get styleMediterranean;

  /// No description provided for @styleWarmMinimalism.
  ///
  /// In en, this message translates to:
  /// **'Warm Minimalism'**
  String get styleWarmMinimalism;

  /// No description provided for @styleBiophilic.
  ///
  /// In en, this message translates to:
  /// **'Biophilic'**
  String get styleBiophilic;

  /// No description provided for @styleModernLuxury.
  ///
  /// In en, this message translates to:
  /// **'Modern Luxury'**
  String get styleModernLuxury;

  /// No description provided for @styleJapandi.
  ///
  /// In en, this message translates to:
  /// **'Japandi'**
  String get styleJapandi;

  /// No description provided for @styleScandinavian.
  ///
  /// In en, this message translates to:
  /// **'Scandinavian'**
  String get styleScandinavian;

  /// No description provided for @styleBohoChic.
  ///
  /// In en, this message translates to:
  /// **'Boho Chic'**
  String get styleBohoChic;

  /// No description provided for @styleIndustrial.
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get styleIndustrial;

  /// No description provided for @styleEarthyNatural.
  ///
  /// In en, this message translates to:
  /// **'Earthy Natural'**
  String get styleEarthyNatural;

  /// No description provided for @styleJerusalem.
  ///
  /// In en, this message translates to:
  /// **'Jerusalem'**
  String get styleJerusalem;

  /// No description provided for @styleMinimalist.
  ///
  /// In en, this message translates to:
  /// **'Minimalist'**
  String get styleMinimalist;

  /// No description provided for @styleModernClassic.
  ///
  /// In en, this message translates to:
  /// **'Modern Classic'**
  String get styleModernClassic;

  /// No description provided for @colorCategoryReds.
  ///
  /// In en, this message translates to:
  /// **'Reds'**
  String get colorCategoryReds;

  /// No description provided for @colorCategoryOranges.
  ///
  /// In en, this message translates to:
  /// **'Oranges'**
  String get colorCategoryOranges;

  /// No description provided for @colorCategoryYellows.
  ///
  /// In en, this message translates to:
  /// **'Yellows'**
  String get colorCategoryYellows;

  /// No description provided for @colorCategoryGreens.
  ///
  /// In en, this message translates to:
  /// **'Greens'**
  String get colorCategoryGreens;

  /// No description provided for @colorCategoryBlues.
  ///
  /// In en, this message translates to:
  /// **'Blues'**
  String get colorCategoryBlues;

  /// No description provided for @colorCategoryPurples.
  ///
  /// In en, this message translates to:
  /// **'Purples'**
  String get colorCategoryPurples;

  /// No description provided for @colorCategoryGrays.
  ///
  /// In en, this message translates to:
  /// **'Grays'**
  String get colorCategoryGrays;

  /// No description provided for @colorCategoryWhitesBlacks.
  ///
  /// In en, this message translates to:
  /// **'Whites & Blacks'**
  String get colorCategoryWhitesBlacks;

  /// No description provided for @lightingRecessed.
  ///
  /// In en, this message translates to:
  /// **'Recessed Lighting'**
  String get lightingRecessed;

  /// No description provided for @lightingPendant.
  ///
  /// In en, this message translates to:
  /// **'Pendant Light'**
  String get lightingPendant;

  /// No description provided for @lightingChandelier.
  ///
  /// In en, this message translates to:
  /// **'Chandelier'**
  String get lightingChandelier;

  /// No description provided for @lightingTableLamp.
  ///
  /// In en, this message translates to:
  /// **'Table Lamp'**
  String get lightingTableLamp;

  /// No description provided for @lightingFloorLamp.
  ///
  /// In en, this message translates to:
  /// **'Floor Lamp'**
  String get lightingFloorLamp;

  /// No description provided for @lightingWallSconce.
  ///
  /// In en, this message translates to:
  /// **'Wall Sconce'**
  String get lightingWallSconce;

  /// No description provided for @lightingTrack.
  ///
  /// In en, this message translates to:
  /// **'Track Lighting'**
  String get lightingTrack;

  /// No description provided for @lightingCeiling.
  ///
  /// In en, this message translates to:
  /// **'Ceiling Fixture'**
  String get lightingCeiling;

  /// No description provided for @lightingUnderCabinet.
  ///
  /// In en, this message translates to:
  /// **'Under-Cabinet Lighting'**
  String get lightingUnderCabinet;

  /// No description provided for @lightingDecorative.
  ///
  /// In en, this message translates to:
  /// **'Decorative Lights'**
  String get lightingDecorative;

  /// No description provided for @lightingDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get lightingDay;

  /// No description provided for @lightingNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get lightingNight;

  /// No description provided for @lightingSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get lightingSunset;

  /// No description provided for @lightingSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get lightingSunrise;

  /// No description provided for @lightingAddRecessed.
  ///
  /// In en, this message translates to:
  /// **'Add recessed lighting'**
  String get lightingAddRecessed;

  /// No description provided for @lightingAddPendant.
  ///
  /// In en, this message translates to:
  /// **'Add pendant light'**
  String get lightingAddPendant;

  /// No description provided for @lightingAddChandelier.
  ///
  /// In en, this message translates to:
  /// **'Add chandelier'**
  String get lightingAddChandelier;

  /// No description provided for @lightingAddTableLamp.
  ///
  /// In en, this message translates to:
  /// **'Add table lamp'**
  String get lightingAddTableLamp;

  /// No description provided for @lightingAddFloorLamp.
  ///
  /// In en, this message translates to:
  /// **'Add floor lamp'**
  String get lightingAddFloorLamp;

  /// No description provided for @lightingAddWallSconce.
  ///
  /// In en, this message translates to:
  /// **'Add wall sconce'**
  String get lightingAddWallSconce;

  /// No description provided for @lightingAddTrack.
  ///
  /// In en, this message translates to:
  /// **'Add track lighting'**
  String get lightingAddTrack;

  /// No description provided for @lightingAddCeiling.
  ///
  /// In en, this message translates to:
  /// **'Add ceiling fixture'**
  String get lightingAddCeiling;

  /// No description provided for @lightingAddUnderCabinet.
  ///
  /// In en, this message translates to:
  /// **'Add under-cabinet lighting'**
  String get lightingAddUnderCabinet;

  /// No description provided for @lightingAddDecorative.
  ///
  /// In en, this message translates to:
  /// **'Add decorative lights'**
  String get lightingAddDecorative;

  /// No description provided for @lightingChangeToDay.
  ///
  /// In en, this message translates to:
  /// **'Change lighting to daylight'**
  String get lightingChangeToDay;

  /// No description provided for @lightingChangeToNight.
  ///
  /// In en, this message translates to:
  /// **'Change lighting to nightlight'**
  String get lightingChangeToNight;

  /// No description provided for @lightingChangeToSunset.
  ///
  /// In en, this message translates to:
  /// **'Change lighting to sunset'**
  String get lightingChangeToSunset;

  /// No description provided for @lightingChangeToSunrise.
  ///
  /// In en, this message translates to:
  /// **'Change lighting to sunrise'**
  String get lightingChangeToSunrise;

  /// No description provided for @furnitureSofa.
  ///
  /// In en, this message translates to:
  /// **'Sofa'**
  String get furnitureSofa;

  /// No description provided for @furnitureSectional.
  ///
  /// In en, this message translates to:
  /// **'Sectional Sofa'**
  String get furnitureSectional;

  /// No description provided for @furnitureArmchair.
  ///
  /// In en, this message translates to:
  /// **'Armchair'**
  String get furnitureArmchair;

  /// No description provided for @furnitureAccentChair.
  ///
  /// In en, this message translates to:
  /// **'Accent Chair'**
  String get furnitureAccentChair;

  /// No description provided for @furnitureDiningChair.
  ///
  /// In en, this message translates to:
  /// **'Dining Chair'**
  String get furnitureDiningChair;

  /// No description provided for @furnitureBarStool.
  ///
  /// In en, this message translates to:
  /// **'Bar Stool'**
  String get furnitureBarStool;

  /// No description provided for @furnitureSingleBed.
  ///
  /// In en, this message translates to:
  /// **'Single Bed'**
  String get furnitureSingleBed;

  /// No description provided for @furnitureDoubleBed.
  ///
  /// In en, this message translates to:
  /// **'Double Bed'**
  String get furnitureDoubleBed;

  /// No description provided for @furnitureBeanbag.
  ///
  /// In en, this message translates to:
  /// **'Beanbag'**
  String get furnitureBeanbag;

  /// No description provided for @furnitureOttoman.
  ///
  /// In en, this message translates to:
  /// **'Ottoman'**
  String get furnitureOttoman;

  /// No description provided for @furnitureBench.
  ///
  /// In en, this message translates to:
  /// **'Bench'**
  String get furnitureBench;

  /// No description provided for @furnitureCoffeeTable.
  ///
  /// In en, this message translates to:
  /// **'Coffee Table'**
  String get furnitureCoffeeTable;

  /// No description provided for @furnitureEndTable.
  ///
  /// In en, this message translates to:
  /// **'End Table'**
  String get furnitureEndTable;

  /// No description provided for @furnitureNightstand.
  ///
  /// In en, this message translates to:
  /// **'Nightstand'**
  String get furnitureNightstand;

  /// No description provided for @furnitureDiningTable.
  ///
  /// In en, this message translates to:
  /// **'Dining Table'**
  String get furnitureDiningTable;

  /// No description provided for @furnitureDesk.
  ///
  /// In en, this message translates to:
  /// **'Desk'**
  String get furnitureDesk;

  /// No description provided for @furnitureDresser.
  ///
  /// In en, this message translates to:
  /// **'Dresser'**
  String get furnitureDresser;

  /// No description provided for @furnitureWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get furnitureWardrobe;

  /// No description provided for @furnitureBookcase.
  ///
  /// In en, this message translates to:
  /// **'Bookcase'**
  String get furnitureBookcase;

  /// No description provided for @furnitureTvStand.
  ///
  /// In en, this message translates to:
  /// **'TV Stand'**
  String get furnitureTvStand;

  /// No description provided for @furnitureCabinets.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Cabinets'**
  String get furnitureCabinets;

  /// No description provided for @furnitureAddSofa.
  ///
  /// In en, this message translates to:
  /// **'Add sofa'**
  String get furnitureAddSofa;

  /// No description provided for @furnitureAddSectional.
  ///
  /// In en, this message translates to:
  /// **'Add sectional sofa'**
  String get furnitureAddSectional;

  /// No description provided for @furnitureAddArmchair.
  ///
  /// In en, this message translates to:
  /// **'Add armchair'**
  String get furnitureAddArmchair;

  /// No description provided for @furnitureAddAccentChair.
  ///
  /// In en, this message translates to:
  /// **'Add accent chair'**
  String get furnitureAddAccentChair;

  /// No description provided for @furnitureAddDiningChair.
  ///
  /// In en, this message translates to:
  /// **'Add dining chair'**
  String get furnitureAddDiningChair;

  /// No description provided for @furnitureAddBarStool.
  ///
  /// In en, this message translates to:
  /// **'Add bar stool'**
  String get furnitureAddBarStool;

  /// No description provided for @furnitureAddSingleBed.
  ///
  /// In en, this message translates to:
  /// **'Add single bed'**
  String get furnitureAddSingleBed;

  /// No description provided for @furnitureAddDoubleBed.
  ///
  /// In en, this message translates to:
  /// **'Add double bed'**
  String get furnitureAddDoubleBed;

  /// No description provided for @furnitureAddBeanbag.
  ///
  /// In en, this message translates to:
  /// **'Add beanbag'**
  String get furnitureAddBeanbag;

  /// No description provided for @furnitureAddOttoman.
  ///
  /// In en, this message translates to:
  /// **'Add ottoman'**
  String get furnitureAddOttoman;

  /// No description provided for @furnitureAddBench.
  ///
  /// In en, this message translates to:
  /// **'Add bench'**
  String get furnitureAddBench;

  /// No description provided for @furnitureAddCoffeeTable.
  ///
  /// In en, this message translates to:
  /// **'Add coffee table'**
  String get furnitureAddCoffeeTable;

  /// No description provided for @furnitureAddEndTable.
  ///
  /// In en, this message translates to:
  /// **'Add end table'**
  String get furnitureAddEndTable;

  /// No description provided for @furnitureAddNightstand.
  ///
  /// In en, this message translates to:
  /// **'Add nightstand'**
  String get furnitureAddNightstand;

  /// No description provided for @furnitureAddDiningTable.
  ///
  /// In en, this message translates to:
  /// **'Add dining table'**
  String get furnitureAddDiningTable;

  /// No description provided for @furnitureAddDesk.
  ///
  /// In en, this message translates to:
  /// **'Add desk'**
  String get furnitureAddDesk;

  /// No description provided for @furnitureAddDresser.
  ///
  /// In en, this message translates to:
  /// **'Add dresser'**
  String get furnitureAddDresser;

  /// No description provided for @furnitureAddWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Add wardrobe'**
  String get furnitureAddWardrobe;

  /// No description provided for @furnitureAddBookcase.
  ///
  /// In en, this message translates to:
  /// **'Add bookcase'**
  String get furnitureAddBookcase;

  /// No description provided for @furnitureAddTvStand.
  ///
  /// In en, this message translates to:
  /// **'Add TV stand'**
  String get furnitureAddTvStand;

  /// No description provided for @furnitureAddCabinets.
  ///
  /// In en, this message translates to:
  /// **'Add kitchen cabinets'**
  String get furnitureAddCabinets;

  /// No description provided for @repairsFixEverything.
  ///
  /// In en, this message translates to:
  /// **'Fix everything'**
  String get repairsFixEverything;

  /// No description provided for @repairsRepairAll.
  ///
  /// In en, this message translates to:
  /// **'Fix and repair everything'**
  String get repairsRepairAll;

  /// No description provided for @repairsMessUp.
  ///
  /// In en, this message translates to:
  /// **'Mess up everything'**
  String get repairsMessUp;

  /// No description provided for @repairsDestroy.
  ///
  /// In en, this message translates to:
  /// **'Destroy and cause damage to everything'**
  String get repairsDestroy;

  /// No description provided for @windowPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture Window'**
  String get windowPicture;

  /// No description provided for @windowSliding.
  ///
  /// In en, this message translates to:
  /// **'Sliding Window'**
  String get windowSliding;

  /// No description provided for @windowCasement.
  ///
  /// In en, this message translates to:
  /// **'Casement Window'**
  String get windowCasement;

  /// No description provided for @windowTiltTurn.
  ///
  /// In en, this message translates to:
  /// **'Tilt and Turn Window'**
  String get windowTiltTurn;

  /// No description provided for @windowAwning.
  ///
  /// In en, this message translates to:
  /// **'Awning Window'**
  String get windowAwning;

  /// No description provided for @windowSash.
  ///
  /// In en, this message translates to:
  /// **'Sash Window'**
  String get windowSash;

  /// No description provided for @windowPocket.
  ///
  /// In en, this message translates to:
  /// **'Pocket Window'**
  String get windowPocket;

  /// No description provided for @windowArched.
  ///
  /// In en, this message translates to:
  /// **'Arched Window'**
  String get windowArched;

  /// No description provided for @windowAddPicture.
  ///
  /// In en, this message translates to:
  /// **'Add a large picture window'**
  String get windowAddPicture;

  /// No description provided for @windowAddSliding.
  ///
  /// In en, this message translates to:
  /// **'Add sliding window'**
  String get windowAddSliding;

  /// No description provided for @windowAddCasement.
  ///
  /// In en, this message translates to:
  /// **'Add casement window'**
  String get windowAddCasement;

  /// No description provided for @windowAddTiltTurn.
  ///
  /// In en, this message translates to:
  /// **'Add tilt and turn window'**
  String get windowAddTiltTurn;

  /// No description provided for @windowAddAwning.
  ///
  /// In en, this message translates to:
  /// **'Add awning window'**
  String get windowAddAwning;

  /// No description provided for @windowAddSash.
  ///
  /// In en, this message translates to:
  /// **'Add sash window'**
  String get windowAddSash;

  /// No description provided for @windowAddPocket.
  ///
  /// In en, this message translates to:
  /// **'Add pocket window'**
  String get windowAddPocket;

  /// No description provided for @windowAddArched.
  ///
  /// In en, this message translates to:
  /// **'Add arched window'**
  String get windowAddArched;

  /// No description provided for @doorPocket.
  ///
  /// In en, this message translates to:
  /// **'Pocket Door'**
  String get doorPocket;

  /// No description provided for @doorFrench.
  ///
  /// In en, this message translates to:
  /// **'French Doors'**
  String get doorFrench;

  /// No description provided for @doorLouvered.
  ///
  /// In en, this message translates to:
  /// **'Louvered Door'**
  String get doorLouvered;

  /// No description provided for @doorBarn.
  ///
  /// In en, this message translates to:
  /// **'Barn Door'**
  String get doorBarn;

  /// No description provided for @doorAddPocket.
  ///
  /// In en, this message translates to:
  /// **'Add pocket door that slides into wall'**
  String get doorAddPocket;

  /// No description provided for @doorAddFrench.
  ///
  /// In en, this message translates to:
  /// **'Add French doors with glass'**
  String get doorAddFrench;

  /// No description provided for @doorAddLouvered.
  ///
  /// In en, this message translates to:
  /// **'Add louvered door'**
  String get doorAddLouvered;

  /// No description provided for @doorAddBarn.
  ///
  /// In en, this message translates to:
  /// **'Add barn door'**
  String get doorAddBarn;

  /// No description provided for @toiletBidet.
  ///
  /// In en, this message translates to:
  /// **'Heated Bidet'**
  String get toiletBidet;

  /// No description provided for @toiletSeat.
  ///
  /// In en, this message translates to:
  /// **'Toilet Seat'**
  String get toiletSeat;

  /// No description provided for @tubFreestanding.
  ///
  /// In en, this message translates to:
  /// **'Freestanding Tub'**
  String get tubFreestanding;

  /// No description provided for @tubVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage Tub'**
  String get tubVintage;

  /// No description provided for @tubStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard Tub'**
  String get tubStandard;

  /// No description provided for @showerRain.
  ///
  /// In en, this message translates to:
  /// **'Rain Shower'**
  String get showerRain;

  /// No description provided for @showerEnclosure.
  ///
  /// In en, this message translates to:
  /// **'Shower Enclosure'**
  String get showerEnclosure;

  /// No description provided for @showerSliding.
  ///
  /// In en, this message translates to:
  /// **'Sliding Shower Doors'**
  String get showerSliding;

  /// No description provided for @sinkPedestal.
  ///
  /// In en, this message translates to:
  /// **'Pedestal Sink'**
  String get sinkPedestal;

  /// No description provided for @sinkStainless.
  ///
  /// In en, this message translates to:
  /// **'Stainless Steel Sink'**
  String get sinkStainless;

  /// No description provided for @sinkUndermount.
  ///
  /// In en, this message translates to:
  /// **'Undermount Sink'**
  String get sinkUndermount;

  /// No description provided for @jacuzziBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in Jacuzzi'**
  String get jacuzziBuiltIn;

  /// No description provided for @jacuzziPortable.
  ///
  /// In en, this message translates to:
  /// **'Portable Jacuzzi'**
  String get jacuzziPortable;

  /// No description provided for @poolInground.
  ///
  /// In en, this message translates to:
  /// **'Inground Pool'**
  String get poolInground;

  /// No description provided for @poolAboveGround.
  ///
  /// In en, this message translates to:
  /// **'Above Ground Pool'**
  String get poolAboveGround;

  /// No description provided for @toiletAddBidet.
  ///
  /// In en, this message translates to:
  /// **'Add toilet seat with bidet'**
  String get toiletAddBidet;

  /// No description provided for @toiletAddSeat.
  ///
  /// In en, this message translates to:
  /// **'Add toilet seat'**
  String get toiletAddSeat;

  /// No description provided for @tubAddFreestanding.
  ///
  /// In en, this message translates to:
  /// **'Add freestanding tub'**
  String get tubAddFreestanding;

  /// No description provided for @tubAddVintage.
  ///
  /// In en, this message translates to:
  /// **'Add vintage tub'**
  String get tubAddVintage;

  /// No description provided for @tubAddStandard.
  ///
  /// In en, this message translates to:
  /// **'Add standard tub'**
  String get tubAddStandard;

  /// No description provided for @showerAddRain.
  ///
  /// In en, this message translates to:
  /// **'Add shower with rain shower head'**
  String get showerAddRain;

  /// No description provided for @showerAddEnclosure.
  ///
  /// In en, this message translates to:
  /// **'Add shower enclosure'**
  String get showerAddEnclosure;

  /// No description provided for @showerAddSliding.
  ///
  /// In en, this message translates to:
  /// **'Add shower with sliding doors'**
  String get showerAddSliding;

  /// No description provided for @sinkAddPedestal.
  ///
  /// In en, this message translates to:
  /// **'Add pedestal sink'**
  String get sinkAddPedestal;

  /// No description provided for @sinkAddStainless.
  ///
  /// In en, this message translates to:
  /// **'Add stainless steel sink'**
  String get sinkAddStainless;

  /// No description provided for @sinkAddUndermount.
  ///
  /// In en, this message translates to:
  /// **'Add undermount sink'**
  String get sinkAddUndermount;

  /// No description provided for @jacuzziAddBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Add built-in jacuzzi'**
  String get jacuzziAddBuiltIn;

  /// No description provided for @jacuzziAddPortable.
  ///
  /// In en, this message translates to:
  /// **'Add portable jacuzzi'**
  String get jacuzziAddPortable;

  /// No description provided for @poolAddInground.
  ///
  /// In en, this message translates to:
  /// **'Add inground pool'**
  String get poolAddInground;

  /// No description provided for @poolAddAboveGround.
  ///
  /// In en, this message translates to:
  /// **'Add above ground pool'**
  String get poolAddAboveGround;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get errorUnknown;

  /// No description provided for @searchWithLens.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchWithLens;

  /// No description provided for @cancelSearch.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelSearch;

  /// No description provided for @selectAreaToSearch.
  ///
  /// In en, this message translates to:
  /// **'Draw a rectangle around the item you want to search'**
  String get selectAreaToSearch;

  /// No description provided for @searchingWithGoogleLens.
  ///
  /// In en, this message translates to:
  /// **'Searching with Google Lens...'**
  String get searchingWithGoogleLens;

  /// No description provided for @selectAreaWithinImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an area within the image'**
  String get selectAreaWithinImage;

  /// No description provided for @googleLensSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get googleLensSearchFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
