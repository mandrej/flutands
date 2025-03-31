import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_provider.dart';
import 'package:simple_grid/simple_grid.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.title});
  final String title;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  void initState() {
    super.initState();
    // Initialize the API provider
    ApiProvider api = Provider.of<ApiProvider>(context, listen: false);
    api.fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    ApiProvider api = Provider.of<ApiProvider>(context);
    final records = api.records;

    return AdminScaffold(
      appBar: AppBar(title: Text(widget.title)),
      sideBar: SideBar(
        backgroundColor: Colors.white,
        items: const [
          AdminMenuItem(title: 'Home', route: '/', icon: Icons.home),
          AdminMenuItem(title: 'Add', route: '/add', icon: Icons.add),
          AdminMenuItem(title: 'Admin', route: '/admin', icon: Icons.settings),
        ],
        selectedRoute: '/',
        onSelected: (item) {
          if (item.route != null) {
            Navigator.of(context).pushNamed(item.route!);
          }
        },
        // header: Container(
        //   height: 50,
        //   width: double.infinity,
        //   color: const Color(0xff444444),
        //   child: const Center(
        //     child: Text('header', style: TextStyle(color: Colors.white)),
        //   ),
        // ),
        header: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text('Search'),
              TextField(
                decoration: InputDecoration(labelText: 'search by text'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'search by tags'),
              ),
            ],
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text('footer', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SpGrid(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var rec in records)
              SpGridItem(
                xs: 12,
                sm: 4,
                md: 3,
                lg: 2,
                // decoration: BoxDecoration(color: Colors.grey[300]),
                child: ContentCard(
                  image: rec['thumb'],
                  title: rec['headline'],
                  subtitle: rec['date'],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.image,
    required this.title,
    this.subtitle = '',
  });

  // final String kTransparentImage = 'assets/image.png';
  final String image;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: [
          FadeInImage.memoryNetwork(
            image: image,
            placeholder: kTransparentImage,
            fit: BoxFit.cover,
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
