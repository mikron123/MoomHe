import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
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
        apiKey: 'AIzaSyDexERfe7htllA1aq7vlbnyQAmfgjx6HnI',
        appId: '1:951714207506:ios:YOUR_IOS_APP_ID', // Replace with iOS app ID
        messagingSenderId: '951714207506',
        projectId: 'moomhe-6de30',
        storageBucket: 'moomhe-6de30.firebasestorage.app',
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

class MoomheApp extends StatelessWidget {
  const MoomheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'מומחה AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
