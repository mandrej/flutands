import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../bloc/user.dart';
import '../bloc/edit_mode.dart';

class EditView extends StatelessWidget {
  const EditView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EditModeCubit>(create: (context) => EditModeCubit()),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, auth) {
            final user = auth.user;
            if (user != null && user.isAuthenticated) {
              return BlocBuilder<EditModeCubit, bool>(
                builder: (context, mode) {
                  return TextButton(
                    onPressed: () => context.read<EditModeCubit>().toggle(),
                    child: Text(
                      mode ? 'EDIT MODE' : 'VIEW MODE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
