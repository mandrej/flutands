import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';
import 'api_provider.dart';
import 'home_page.dart';
import 'list_page.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
  runApp(const MyApp());
}

ThemeData theme = ThemeData(
  primaryColor: Colors.amber,
  scaffoldBackgroundColor: Colors.white10,
  // fontFamily: 'PTSans',
  useMaterial3: true,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ApiProvider())],
      child: MaterialApp(
        theme: theme,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(title: 'Andrejeвићи'),
          '/list': (context) => ListPage(title: 'List Page'),
        },
        // home: const HomePage(title: 'MDA'),
      ),
    );
  }
}
