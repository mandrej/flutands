// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/api_provider.dart';
import 'providers/user_provider.dart';
import 'package:simple_grid/simple_grid.dart';

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
              ? SpGrid(
                width: width,
                children: [
                  SpGridItem(
                    xs: 12,
                    md: 6,
                    child: ElevatedButton(
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
                        height: width < 960 ? height / 2 : height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(lastRecord['url']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SpGridItem(
                    xs: 12,
                    md: 6,
                    child: SizedBox(
                      height: width < 960 ? height / 2 : height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.add),
                            style: IconButton.styleFrom(
                              iconSize: 40.0,
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          SizedBox(height: 30),
                          if (isAuthenticated == false)
                            ElevatedButton(
                              onPressed: () async {
                                await auth.signInWithGoogle();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 4,
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              // foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              // backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text("Sign in with your Google Account"),
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
