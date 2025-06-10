// import 'package:flutands/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'providers/api_provider.dart';
import 'providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'helpers/common.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => AvailableValuesCubit()..get('Counter'),
      child: Scaffold(
        body:
        // You may need to update how 'values' is accessed, e.g. via context.watch<AvailableValuesCubit>().state
        // For now, replace 'values' with a placeholder or proper BlocBuilder/Selector as needed.
        // Example placeholder:
        Builder(
          builder: (context) {
            final values = context.watch<AvailableValuesCubit>().state;
            return values != null && values.isNotEmpty
                ? width < 960
                    ? Column(
                      children: [
                        FrontButton(width: width, height: height / 2),
                        FronTitle(
                          title: title,
                          width: width,
                          height: height / 2,
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        FrontButton(width: width / 2, height: height),
                        FronTitle(
                          title: title,
                          width: width * 2,
                          height: height,
                        ),
                      ],
                    )
                : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        width: 100,
                        'assets/camera.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor,
                          BlendMode.srcIn,
                        ),
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
                      if (UserCubit().state!['isAuthenticated'] == false)
                        FilledButton(
                          onPressed: () async {
                            // await auth.signInWithGoogle();
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
                );
          },
        ),
      ),
    );
  }
}

class FrontButton extends StatelessWidget {
  const FrontButton({super.key, required this.width, required this.height});
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LastRecordCubit>(
          create:
              (context) => LastRecordCubit()..get('Photo', descending: true),
        ),
        BlocProvider<AvailableValuesCubit>(
          create: (context) => AvailableValuesCubit()..get('Counter'),
        ),
      ],
      child: ElevatedButton(
        onPressed:
            () =>
                AvailableValuesCubit().state != null
                    ? Navigator.pushNamed(context, '/list')
                    : null,
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
              image: NetworkImage(LastRecordCubit().state!['url']),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class FronTitle extends StatelessWidget {
  const FronTitle({
    super.key,
    required this.title,
    required this.width,
    required this.height,
  });
  final String title;
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FirstRecordCubit>(
          create:
              (context) => FirstRecordCubit()..get('Photo', descending: false),
        ),
        BlocProvider<AvailableValuesCubit>(
          create: (context) => AvailableValuesCubit()..get('Counter'),
        ),
        BlocProvider<UserCubit>(create: (context) => UserCubit()..login()),
      ],
      child: Expanded(
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (UserCubit().state!['isFamily'])
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/add'),
                    icon: Icon(Icons.add),
                    style: IconButton.styleFrom(
                      iconSize: 40.0,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                if (UserCubit().state!['isAuthenticated'])
                  TextButton(
                    onPressed: () {
                      UserCubit().logout();
                    },
                    child: Text(
                      'Sign out ${UserCubit().state!['displayName']}',
                    ),
                  )
                else
                  FilledButton(
                    onPressed: () {
                      UserCubit().login();
                    },
                    child: Text('Sign in with Google'),
                  ),
                Text(
                  title,
                  style: TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Since ${FirstRecordCubit().state!['year'].toString()}',
                  style: TextStyle(fontSize: 14),
                ),
                if (AvailableValuesCubit().state != null &&
                    AvailableValuesCubit().state!['email'] != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        (AvailableValuesCubit().state!['email']
                                as Map<String, dynamic>)
                            .keys
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
      ),
    );
  }
}
