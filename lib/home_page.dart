// import 'package:flutands/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'parts/alert_box.dart';
import 'providers/api_provider.dart';
import 'providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'helpers/common.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UserProvider auth = Provider.of<UserProvider>(context);
    final auth = ref.read(myUserProvider);
    final isAuthenticated = ref.watch(myUserProvider).isAuthenticated;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final lastRecord = ref.watch(myApiProvider).lastRecord;
    final firstRecord = ref.watch(myApiProvider).firstRecord;

    return Scaffold(
      body:
          lastRecord != null && firstRecord != null
              ? width < 960
                  ? Column(
                    children: [
                      FrontButton(width: width, height: height / 2),
                      FronTitle(title: title, width: width, height: height / 2),
                    ],
                  )
                  : Row(
                    children: [
                      FrontButton(width: width / 2, height: height),
                      FronTitle(title: title, width: width * 2, height: height),
                    ],
                  )
              : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      width: 100,
                      'assets/camera.svg',
                      // colorFilter: const ColorFilter.mode(
                      //   Colors.amber,
                      //   BlendMode.srcIn,
                      // ),
                      semanticsLabel: 'App Logo',
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No images yet\n Sign in with Google\n to add some',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (isAuthenticated == false)
                      FilledButton(
                        onPressed: () async {
                          await auth.signInWithGoogle();
                        },
                        child: Text('Sign in'),
                      )
                    else
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/add'),
                        icon: Icon(Icons.add),
                        style: IconButton.styleFrom(
                          iconSize: 40.0,
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}

class FrontButton extends ConsumerWidget {
  const FrontButton({super.key, required this.width, required this.height});
  final double width, height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastRecord = ref.watch(myApiProvider).lastRecord;
    final values = ref.watch(myApiProvider).values;

    return ElevatedButton(
      onPressed:
          () => values != null ? Navigator.pushNamed(context, '/list') : null,
      style: ElevatedButton.styleFrom(
        elevation: 16,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(lastRecord!['url']),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class FronTitle extends ConsumerWidget {
  const FronTitle({
    super.key,
    required this.title,
    required this.width,
    required this.height,
  });
  final String title;
  final double width, height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UserProvider auth = Provider.of<UserProvider>(context);
    final auth = ref.read(myUserProvider);
    final values = ref.watch(myApiProvider).values;
    final firstRecord = ref.watch(myApiProvider).firstRecord;
    final isAuthenticated = ref.watch(myUserProvider).isAuthenticated;

    return Expanded(
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAuthenticated == true)
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/add'),
                  icon: Icon(Icons.add),
                  style: IconButton.styleFrom(
                    iconSize: 40.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              if (isAuthenticated == true)
                TextButton(
                  onPressed: () async {
                    await auth.signOut();
                  },
                  child: Text('Sign out ${auth.user!['displayName']}'),
                )
              else
                FilledButton(
                  onPressed: () async {
                    await auth.signInWithGoogle();
                  },
                  child: Text('Sign in with Google'),
                ),
              Text(
                title,
                style: TextStyle(fontSize: 40),
                textAlign: TextAlign.center,
              ),
              Text(
                'Since ${firstRecord!['year'].toString()}',
                style: TextStyle(fontSize: 14),
              ),
              if (values != null && values['email'] != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      (values['email'] as Map<String, dynamic>).keys
                          .map<Widget>((email) {
                            return Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                nickEmail(email),
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            );
                          })
                          .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
