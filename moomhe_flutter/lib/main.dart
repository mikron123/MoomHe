import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // On Android, Firebase config is loaded from google-services.json
  // On iOS, we provide options manually (or from GoogleService-Info.plist)
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBqlgEJ2uBfazqfkv5itV4hVE5jLY8FpIo',
        appId: '1:951714207506:ios:d277c0f4a3a00a4c4345cb',
        messagingSenderId: '951714207506',
        projectId: 'moomhe-6de30',
        storageBucket: 'moomhe-6de30.firebasestorage.app',
        iosBundleId: 'com.kalromsystems.moomhe',
      ),
    );
  }
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, 
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D12),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MoomheApp());
}

/// Supported locales with their display names
class SupportedLocale {
  final Locale locale;
  final String name;
  final String nativeName;

  const SupportedLocale({
    required this.locale,
    required this.name,
    required this.nativeName,
  });
}

/// All supported locales in the app
const List<SupportedLocale> supportedLocales = [
  SupportedLocale(locale: Locale('en'), name: 'English', nativeName: 'English'),
  SupportedLocale(locale: Locale('ar'), name: 'Arabic', nativeName: 'العربية'),
  SupportedLocale(locale: Locale('cs'), name: 'Czech', nativeName: 'Čeština'),
  SupportedLocale(locale: Locale('da'), name: 'Danish', nativeName: 'Dansk'),
  SupportedLocale(locale: Locale('de'), name: 'German', nativeName: 'Deutsch'),
  SupportedLocale(locale: Locale('el'), name: 'Greek', nativeName: 'Ελληνικά'),
  SupportedLocale(locale: Locale('es'), name: 'Spanish', nativeName: 'Español'),
  SupportedLocale(locale: Locale('et'), name: 'Estonian', nativeName: 'Eesti'),
  SupportedLocale(locale: Locale('fi'), name: 'Finnish', nativeName: 'Suomi'),
  SupportedLocale(locale: Locale('fr'), name: 'French', nativeName: 'Français'),
  SupportedLocale(locale: Locale('ga'), name: 'Irish', nativeName: 'Gaeilge'),
  SupportedLocale(locale: Locale('he'), name: 'Hebrew', nativeName: 'עברית'),
  SupportedLocale(locale: Locale('hr'), name: 'Croatian', nativeName: 'Hrvatski'),
  SupportedLocale(locale: Locale('hu'), name: 'Hungarian', nativeName: 'Magyar'),
  SupportedLocale(locale: Locale('is'), name: 'Icelandic', nativeName: 'Íslenska'),
  SupportedLocale(locale: Locale('it'), name: 'Italian', nativeName: 'Italiano'),
  SupportedLocale(locale: Locale('ja'), name: 'Japanese', nativeName: '日本語'),
  SupportedLocale(locale: Locale('ka'), name: 'Georgian', nativeName: 'ქართული'),
  SupportedLocale(locale: Locale('ko'), name: 'Korean', nativeName: '한국어'),
  SupportedLocale(locale: Locale('lt'), name: 'Lithuanian', nativeName: 'Lietuvių'),
  SupportedLocale(locale: Locale('nb'), name: 'Norwegian', nativeName: 'Norsk'),
  SupportedLocale(locale: Locale('nl'), name: 'Dutch', nativeName: 'Nederlands'),
  SupportedLocale(locale: Locale('pl'), name: 'Polish', nativeName: 'Polski'),
  SupportedLocale(locale: Locale('pt'), name: 'Portuguese', nativeName: 'Português'),
  SupportedLocale(locale: Locale('ro'), name: 'Romanian', nativeName: 'Română'),
  SupportedLocale(locale: Locale('sl'), name: 'Slovenian', nativeName: 'Slovenščina'),
  SupportedLocale(locale: Locale('sv'), name: 'Swedish', nativeName: 'Svenska'),
  SupportedLocale(locale: Locale('zh', 'HK'), name: 'Cantonese', nativeName: '廣東話'),
  SupportedLocale(locale: Locale('zh'), name: 'Chinese', nativeName: '中文'),
];

class MoomheApp extends StatefulWidget {
  const MoomheApp({super.key});
  
  /// Access the app state from anywhere
  static _MoomheAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MoomheAppState>();
  }

  @override
  State<MoomheApp> createState() => _MoomheAppState();
}

class _MoomheAppState extends State<MoomheApp> {
  static const String _localeKey = 'selected_locale';
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null && mounted) {
      final parts = savedLocale.split('_');
      setState(() {
        _selectedLocale = parts.length > 1 
            ? Locale(parts[0], parts[1])
            : Locale(parts[0]);
      });
    }
  }

  /// Change the app locale and save preference
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = locale.countryCode != null 
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await prefs.setString(_localeKey, localeString);
    
    if (mounted) {
      setState(() {
        _selectedLocale = locale;
      });
    }
  }

  /// Get current locale
  Locale? get currentLocale => _selectedLocale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoomHe AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Use selected locale if set
      locale: _selectedLocale,
      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales.map((e) => e.locale).toList(),
      // Use device locale if supported, otherwise default to English
      localeResolutionCallback: (locale, supportedLocales) {
        // If user has selected a locale, use it
        if (_selectedLocale != null) {
          return _selectedLocale;
        }
        // Check if the device locale is supported
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Default to English if device locale is not supported
        return const Locale('en');
      },
      // Text direction is determined by the locale (LTR for en/es/fr)
      home: const HomeScreen(),
    );
  }
}
