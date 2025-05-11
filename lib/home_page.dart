// import 'package:flutands/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/api_provider.dart';
import 'providers/user_provider.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    UserProvider auth = Provider.of<UserProvider>(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final lastRecord = context.watch<ApiProvider>().lastRecord;
    final firstRecord = context.watch<ApiProvider>().firstRecord;
    final values = context.watch<ApiProvider>().values;
    final isAuthenticated = context.watch<UserProvider>().isAuthenticated;

    return Scaffold(
      body:
          lastRecord != null && firstRecord != null
              ? width < 960
                  ? Column(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () =>
                                values != null
                                    ? Navigator.pushNamed(context, '/list')
                                    : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Container(
                          height: height / 2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(lastRecord['url']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        height: height / 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.add),
                                  style: IconButton.styleFrom(
                                    iconSize: 40.0,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              if (isAuthenticated == false)
                                ElevatedButton(
                                  onPressed: () async {
                                    await auth.signInWithGoogle();
                                  },
                                  child: Text(
                                    "Sign in with your Google Account",
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () async {
                                    await auth.signOut();
                                  },
                                  child: Text(
                                    'Sign out ${auth.user!['displayName']}',
                                  ),
                                ),
                              Text(
                                title,
                                style: TextStyle(fontSize: 40),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Since ${firstRecord['year'].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                              if (values != null && values['email'] != null)
                                Column(
                                  children:
                                      (values['email'] as Map<String, dynamic>)
                                          .keys
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
                  : Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () =>
                                values != null
                                    ? Navigator.pushNamed(context, '/list')
                                    : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Container(
                          width: width / 2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(lastRecord['url']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width / 2,
                        height: height,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.add),
                                  style: IconButton.styleFrom(
                                    iconSize: 40.0,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              if (isAuthenticated == false)
                                ElevatedButton(
                                  onPressed: () async {
                                    await auth.signInWithGoogle();
                                  },
                                  child: Text(
                                    "Sign in with your Google Account",
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () async {
                                    await auth.signOut();
                                  },
                                  child: Text(
                                    'Sign out ${auth.user!['displayName']}',
                                  ),
                                ),
                              Text(
                                title,
                                style: TextStyle(fontSize: 40),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Since ${firstRecord['year'].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                              if (values != null && values['email'] != null)
                                Column(
                                  children:
                                      (values['email'] as Map<String, dynamic>)
                                          .keys
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
