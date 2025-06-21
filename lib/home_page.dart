import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/available_values.dart';
import 'bloc/last_record.dart';
import 'bloc/first_record.dart';
import 'bloc/user.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'helpers/common.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AvailableValuesBloc>(
          create:
              (context) => AvailableValuesBloc()..add(FetchAvailableValues()),
        ),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
      ],
      child: BlocBuilder<AvailableValuesBloc, AvailableValuesState>(
        builder: (context, values) {
          return Scaffold(
            body:
                values.email != null
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
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (UserBloc().state.user == null)
                            FilledButton(
                              onPressed: () async {
                                UserBloc().add(UserSignInRequested());
                              },
                              child: Text('Sign in'),
                            )
                          else
                            IconButton(
                              onPressed:
                                  () => Navigator.pushNamed(context, '/add'),
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
        },
      ),
    );
  }
}

class FrontButton extends StatelessWidget {
  const FrontButton({super.key, required this.width, required this.height});
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = LastRecordBloc();
        bloc.add(FetchLastRecord());
        return bloc;
      },
      child: BlocBuilder<LastRecordBloc, LastRecordState>(
        builder: (context, record) {
          return ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/list'),
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
                  image: NetworkImage(record.url ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
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
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
        BlocProvider<AvailableValuesBloc>(
          create:
              (context) => AvailableValuesBloc()..add(FetchAvailableValues()),
        ),
        BlocProvider<FirstRecordBloc>(
          create: (context) {
            final bloc = FirstRecordBloc();
            bloc.add(FetchFirstRecord());
            return bloc;
          },
        ),
      ],
      child: Expanded(
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontSize: 40)),
                  BlocBuilder<FirstRecordBloc, FirstRecordState>(
                    builder: (context, record) {
                      return Text(
                        'Since ${record.year.toString()}',
                        style: TextStyle(fontSize: 14),
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, auth) {
                      if (auth.user != null) {
                        return Column(
                          children: [
                            IconButton(
                              onPressed:
                                  () => Navigator.pushNamed(context, '/add'),
                              icon: Icon(Icons.add),
                              style: IconButton.styleFrom(
                                iconSize: 40.0,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            if (AvailableValuesBloc().state.email != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    (AvailableValuesBloc().state.email
                                            as Map<String, int>)
                                        .keys
                                        .map<Widget>((email) {
                                          return Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Text(
                                              nickEmail(email),
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.headlineSmall,
                                            ),
                                          );
                                        })
                                        .toList(),
                              ),
                            TextButton(
                              onPressed: () {
                                UserBloc().add(UserSignOutRequested());
                              },
                              child: Text('Sign out ${auth.user!.displayName}'),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () {
                                UserBloc().add(UserSignInRequested());
                              },
                              child: Text('Sign in with Google'),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
