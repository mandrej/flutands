import 'package:flutands/parts/alert_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
// import 'bloc/edit_mode.dart';
import 'bloc/records.dart';
// import 'bloc/user.dart';
import 'bloc/search_find.dart';
import 'parts/search_form.dart';
import 'parts/simple_grid_view.dart';
import 'parts/edit_view.dart';

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
        BlocProvider<SearchFindBloc>(create: (context) => SearchFindBloc()),
        BlocProvider<RecordsBloc>(create: (context) => RecordsBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [EditView()]),
        drawer: isLargeScreen ? null : const _SidebarDrawer(),
        body: BlocListener<SearchFindBloc, SearchFindState>(
          listener: (context, state) {
            if (state.find != null) {
              // Trigger a fetch of records based on the current search criteria
              context.read<RecordsBloc>().add(FetchRecords(find: state.find));
            }
          },
          child: BlocListener<RecordsBloc, RecordsState>(
            listener: (context, state) {
              if (state is RecordsError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }

              // TODO: implement listener
            },
            child: BlocBuilder<RecordsBloc, RecordsState>(
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
                                      'No records found. Please try again.',
                                ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
