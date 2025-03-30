import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_provider.dart';
import 'package:simple_grid/simple_grid.dart';
import 'package:transparent_image/transparent_image.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
        title: Text(widget.title),
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SpGrid(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var rec in records!)
              SpGridItem(
                xs: 12,
                sm: 4,
                md: 3,
                lg: 2,
                decoration: BoxDecoration(color: Colors.grey[300]),
                child: ContentCard(
                  image: rec['thumb'],
                  title: rec['headline'],
                  subtitle: rec['date'],
                  badge: '30',
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
    this.badge = '',
  });

  // final String kTransparentImage = 'assets/image.png';
  final String image;
  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: FadeInImage.memoryNetwork(
            image: image,
            placeholder: kTransparentImage,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     IconButton(
              //       icon: const Icon(Icons.delete),
              //       tooltip: 'Edit',
              //       onPressed: () {},
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.edit),
              //       tooltip: 'Edit',
              //       onPressed: () {},
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.paste),
              //       tooltip: 'Edit',
              //       onPressed: () {},
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.gps_fixed),
              //       tooltip: 'Edit',
              //       onPressed: () {},
              //     ),
              //   ],
              // ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ),
                  // Container(
                  //   decoration: const BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.all(Radius.circular(5)),
                  //   ),
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 4,
                  //   ),
                  //   child: Text(
                  //     badge,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: textTheme.bodySmall,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
