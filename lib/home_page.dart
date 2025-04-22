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
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      //   title: Text(title),
      //   actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
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
                              color: Colors.grey.withValues(alpha: 0.5),
                              spreadRadius: 3,
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
                          if (isAuthenticated == false)
                            ElevatedButton(
                              onPressed: () async {
                                await auth.signInWithGoogle();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 4,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                "Sign in with your Google Account",
                                style: const TextStyle(color: Colors.black),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () async {
                                await auth.signOut();
                              },
                              // style: ElevatedButton.styleFrom(
                              //   elevation: 4,
                              //   backgroundColor:
                              //       Theme.of(context).colorScheme.primary,
                              // ),
                              child: Text(
                                'Sign out ${auth.user!['displayName']}',
                                style: const TextStyle(color: Colors.black),
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
