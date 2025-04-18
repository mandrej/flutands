import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_provider.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'parts/search_form.dart';
import 'parts/simple_grid_view.dart';

class ListPage extends StatefulWidget {
  ListPage({super.key, required this.title});
  final String title;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late List<Item> galleryItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize the API provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiProvider api = Provider.of<ApiProvider>(context, listen: false);
      api.fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    ApiProvider api = Provider.of<ApiProvider>(context);
    FlagProvider flags = Provider.of<FlagProvider>(context, listen: false);
    var buttonText = context.watch<FlagProvider>().buttonText;

    return AdminScaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
              buttonText,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
        elevation: 5,
        shadowColor: Colors.grey,
      ),
      sideBar: SideBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        activeBackgroundColor: Theme.of(context).colorScheme.primary,
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
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
      body: SimpleGridView(records: api.records),
    );
  }
}
