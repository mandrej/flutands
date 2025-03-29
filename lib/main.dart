import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:simple_grid/simple_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';
import 'settings_provider.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal.shade500),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(title: 'MDA'),
          '/list': (context) => const ListPage(title: 'List'),
        },
        // home: const HomePage(title: 'MDA'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final lastRecord = settings.lastRecord;
    final firstRecord = settings.firstRecord;
    final values = settings.values;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      //   title: Text(title),
      //   actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body:
          lastRecord != null && firstRecord != null
              ? SpGrid(
                width: width,
                // spacing: 10,
                runSpacing: 10,
                children: [
                  SpGridItem(
                    xs: 12,
                    md: 6,
                    // order: SpOrder(sm: 0, xs: 0),
                    child: GestureDetector(
                      onTap:
                          values != null
                              ? () {
                                settings.fetchRecords();
                                Navigator.pushNamed(context, '/list');
                              }
                              : null,
                      child: Container(
                        height: width < 960 ? height / 2 : height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(lastRecord['url']),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SpGridItem(
                    xs: 12,
                    md: 6,
                    // order: SpOrder(sm: 1, xs: 1),
                    child: SizedBox(
                      height: width < 960 ? height / 2 : height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(fontSize: 40),
                            textAlign: TextAlign.center,
                          ),
                          // SizedBox(height: 10),
                          Text(
                            'Since ${firstRecord['year'].toString()}',
                            style: TextStyle(fontSize: 14),
                          ),
                          if (values != null && values['email'] != null)
                            Column(
                              children:
                                  (values['email'] as Map<String, dynamic>).keys
                                      .map<Widget>((email) {
                                        return Text(
                                          email,
                                          style: TextStyle(fontSize: 14),
                                        );
                                      })
                                      .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : const Center(
                child: Text(
                  'No images yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
    );
  }
}
