// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';
import 'providers/api_provider.dart';
import 'providers/user_provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'list_page.dart';
// import 'parts/edit_dialog.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    final emulatorHost =
        (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
            ? '10.0.2.2'
            : 'localhost';
    try {
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
      await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    FlutterError.onError = (details) {
      debugPrint('************************* onErrorDetails');
      debugPrint(details.toString());
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('************************* onError');
      debugPrint(error.toString());
      debugPrint(stack.toString());
      return true;
    };
  }
  runApp(const MyApp());
}

abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: FlexScheme.amber,
    // Input color modifiers.
    useMaterial3ErrorColors: true,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: FlexScheme.amber,
    // Input color modifiers.
    useMaterial3ErrorColors: true,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiProvider()),
        ChangeNotifierProvider(create: (context) => FlagProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        // Disable the banner to make the "+" button more visible.
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(title: 'Andrejeвићи'),
          '/list': (context) => ListPage(title: 'Andrejeвићи'),
          // '/edit':
          //     (context) => EditDialog(
          //       editRecord: {
          //         'date': '2025-04-20 13:49',
          //         'loc': '44.814173, 20.460722',
          //         'focal_length': 25,
          //         'iso': 720,
          //         'thumb':
          //             'http://127.0.0.1:9199/v0/b/andrejevici.appspot.com/o/thumbnails%2F20250420-DSC_8542_400x400.jpeg?alt=media&token=31aee9b4-ad92-4e2b-a328-f5773104eefe',
          //         'year': 2025,
          //         'shutter': '1/200',
          //         'dim': [2560, 3200],
          //         'lens': 'NIKKOR Z 24-70mm f4 S',
          //         'url':
          //             'http://127.0.0.1:9199/v0/b/andrejevici.appspot.com/o/20250420-DSC_8542.jpg?alt=media&token=31aee9b4-ad92-4e2b-a328-f5773104eefe',
          //         'tags': ['flash'],
          //         'nick': 'milan',
          //         'aperture': 4,
          //         'filename': '20250420-DSC_8542.jpg',
          //         'month': 4,
          //         'size': 2444611,
          //         'model': 'NIKON Z 6_2',
          //         'text': ['nam', 'name'],
          //         'day': 20,
          //         'headline': 'No name',
          //         'email': 'milan.andrejevic@gmail.com',
          //         'flash': true,
          //       },
          //     ),
        },
      ),
    );
  }
}
