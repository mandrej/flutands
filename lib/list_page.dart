import 'package:flutands/parts/alert_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'bloc/edit_mode.dart';
import 'bloc/records.dart';
import 'bloc/user.dart';
import 'bloc/search_find.dart';
import 'parts/search_form.dart';
import 'parts/simple_grid_view.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.title});
  final String title;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return MultiBlocProvider(
      providers: [
        BlocProvider<EditModeCubit>(create: (context) => EditModeCubit()),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
        BlocProvider<SearchFindBloc>(create: (context) => SearchFindBloc()),
        BlocProvider<RecordsBloc>(
          create: (context) {
            final bloc = RecordsBloc();
            bloc.add(FetchRecords());
            return bloc;
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, auth) {
                  final user = auth.user;
                  if (user != null && user.isAuthenticated) {
                    return BlocBuilder<EditModeCubit, bool>(
                      builder: (context, mode) {
                        return TextButton(
                          onPressed:
                              () => context.read<EditModeCubit>().toggle(),
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
          ],
        ),
        drawer: isLargeScreen ? null : const _SidebarDrawer(),
        body: BlocBuilder<RecordsBloc, RecordsState>(
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLargeScreen) const _SidebarDrawer(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        (state is RecordsLoaded && state.records.isNotEmpty)
                            ? SimpleGridView(records: state.records)
                            : AlertBox(
                              title: 'No Records',
                              content:
                                  'No records found. Please try again later.',
                            ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SidebarDrawer extends StatelessWidget {
  const _SidebarDrawer();

  @override
  Widget build(BuildContext context) {
    final width = 240.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SearchForm(),
          Spacer(),
          _SidebarItem(
            icon: Icons.home,
            label: 'Home',
            onTap: () => Navigator.pushNamed(context, '/'),
          ),
          _SidebarItem(
            icon: Icons.add,
            label: 'Add',
            onTap: () => Navigator.pushNamed(context, '/add'),
          ),
          _SidebarItem(
            icon: Icons.settings,
            label: 'Admin',
            onTap: () => Navigator.pushNamed(context, '/admin'),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: onTap,
      // dense: true,
    );
  }
}
