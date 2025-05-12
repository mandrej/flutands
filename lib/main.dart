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
import 'add_page.dart';
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

/// Light [ColorScheme] made with FlexColorScheme v8.2.0.
/// Requires Flutter 3.22.0 or later.
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFE65100),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFCC80),
  onPrimaryContainer: Color(0xFF000000),
  primaryFixed: Color(0xFFFFD7C2),
  primaryFixedDim: Color(0xFFFAB38C),
  onPrimaryFixed: Color(0xFF5D2100),
  onPrimaryFixedVariant: Color(0xFF6F2700),
  secondary: Color(0xFF2979FF),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE4EAFF),
  onSecondaryContainer: Color(0xFF000000),
  secondaryFixed: Color(0xFFD6E3F8),
  secondaryFixedDim: Color(0xFFAAC5F1),
  onSecondaryFixed: Color(0xFF00348B),
  onSecondaryFixedVariant: Color(0xFF003B9D),
  tertiary: Color(0xFF2962FF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFCBD6FF),
  onTertiaryContainer: Color(0xFF000000),
  tertiaryFixed: Color(0xFFD6DFF8),
  tertiaryFixedDim: Color(0xFFAABDF1),
  onTertiaryFixed: Color(0xFF00258B),
  onTertiaryFixedVariant: Color(0xFF002A9D),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFCFCFC),
  onSurface: Color(0xFF111111),
  surfaceDim: Color(0xFFE0E0E0),
  surfaceBright: Color(0xFFFDFDFD),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF8F8F8),
  surfaceContainer: Color(0xFFF3F3F3),
  surfaceContainerHigh: Color(0xFFEDEDED),
  surfaceContainerHighest: Color(0xFFE7E7E7),
  onSurfaceVariant: Color(0xFF393939),
  outline: Color(0xFF919191),
  outlineVariant: Color(0xFFD1D1D1),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2A2A2A),
  onInverseSurface: Color(0xFFF1F1F1),
  inversePrimary: Color(0xFFFFCF99),
  surfaceTint: Color(0xFFE65100),
);

/// Dark [ColorScheme] made with FlexColorScheme v8.2.0.
/// Requires Flutter 3.22.0 or later.
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB300),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFFC87200),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFFFFD7C2),
  primaryFixedDim: Color(0xFFFAB38C),
  onPrimaryFixed: Color(0xFF5D2100),
  onPrimaryFixedVariant: Color(0xFF6F2700),
  secondary: Color(0xFF82B1FF),
  onSecondary: Color(0xFF000000),
  secondaryContainer: Color(0xFF3770CF),
  onSecondaryContainer: Color(0xFFFFFFFF),
  secondaryFixed: Color(0xFFD6E3F8),
  secondaryFixedDim: Color(0xFFAAC5F1),
  onSecondaryFixed: Color(0xFF00348B),
  onSecondaryFixedVariant: Color(0xFF003B9D),
  tertiary: Color(0xFF448AFF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF0B429C),
  onTertiaryContainer: Color(0xFFFFFFFF),
  tertiaryFixed: Color(0xFFD6DFF8),
  tertiaryFixedDim: Color(0xFFAABDF1),
  onTertiaryFixed: Color(0xFF00258B),
  onTertiaryFixedVariant: Color(0xFF002A9D),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF080808),
  onSurface: Color(0xFFF1F1F1),
  surfaceDim: Color(0xFF060606),
  surfaceBright: Color(0xFF2C2C2C),
  surfaceContainerLowest: Color(0xFF010101),
  surfaceContainerLow: Color(0xFF0E0E0E),
  surfaceContainer: Color(0xFF151515),
  surfaceContainerHigh: Color(0xFF1D1D1D),
  surfaceContainerHighest: Color(0xFF282828),
  onSurfaceVariant: Color(0xFFCACACA),
  outline: Color(0xFF777777),
  outlineVariant: Color(0xFF414141),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE8E8E8),
  onInverseSurface: Color(0xFF2A2A2A),
  inversePrimary: Color(0xFF6B520A),
  surfaceTint: Color(0xFFFFB300),
);

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
          '/add': (context) => TaskManager(),
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
