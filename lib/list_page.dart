import 'package:flutands/parts/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/api_provider.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'parts/search_form.dart';
import 'parts/simple_grid_view.dart';

class ListPage extends ConsumerStatefulWidget {
  ListPage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  @override
  void initState() {
    super.initState();
    final api = ref.read(myApiProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      api.fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    var records = ref.watch(myApiProvider).records;
    var flags = ref.watch(myFlagProvider);

    return AdminScaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              flags.toggleEditMode();
            },
            child: Text(
              flags.editMode ? 'EDIT MODE' : 'VIEW MODE',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
        // elevation: 4,
        // shadowColor: Colors.grey,
      ),
      sideBar: SideBar(
        width: 240,
        backgroundColor: Theme.of(context).colorScheme.surface,
        // activeBackgroundColor: Theme.of(context).colorScheme.onPrimary,
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
        items: const [
          AdminMenuItem(title: 'Home', route: '/', icon: Icons.home),
          AdminMenuItem(title: 'Add', route: '/add', icon: Icons.add),
          AdminMenuItem(title: 'Admin', route: '/admin', icon: Icons.settings),
        ],
        selectedRoute: '/list',
        onSelected: (item) {
          if (item.route != null) {
            Navigator.of(context).pushNamed(item.route!);
          }
        },
        header: SearchForm(),
      ),
      body:
          (records.isNotEmpty)
              ? SimpleGridView(records: records)
              : AlertBox(
                title: 'No Records',
                content: 'No records found. Please try again later.',
              ),
    );
  }
}
