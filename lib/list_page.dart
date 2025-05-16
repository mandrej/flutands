import 'package:flutands/parts/alert_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/api_provider.dart';
import 'providers/user_provider.dart';
import 'parts/search_form.dart';
import 'parts/simple_grid_view.dart';

class ListPage extends ConsumerStatefulWidget {
  ListPage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    final api = ref.read(myApiProvider);
    _fetchFuture = api.fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;
    final records = ref.watch(myApiProvider).records;
    final isAuthenticated = ref.watch(myUserProvider).isAuthenticated;

    return FutureBuilder(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Optionally handle error state
        if (snapshot.hasError) {
          return AlertBox(title: 'Error', content: 'Failed to load records.');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              if (isAuthenticated)
                Consumer(
                  builder: (context, ref, child) {
                    final flags = ref.read(myFlagProvider);
                    final editMode = ref.watch(myFlagProvider).editMode;
                    return TextButton(
                      onPressed: () {
                        flags.toggleEditMode();
                      },
                      child: Text(
                        editMode ? 'EDIT MODE' : 'VIEW MODE',
                        // style: TextStyle(
                        //   color: Theme.of(context).colorScheme.onSurface,
                        // ),
                      ),
                    );
                  },
                ),
            ],
          ),
          drawer: isLargeScreen ? null : const _SidebarDrawer(),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLargeScreen) const _SidebarDrawer(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      (records.isNotEmpty)
                          ? SimpleGridView(records: records)
                          : AlertBox(
                            title: 'No Records',
                            content:
                                'No records found. Please try again later.',
                          ),
                ),
              ),
            ],
          ),
        );
      },
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
