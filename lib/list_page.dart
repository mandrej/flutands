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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
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
                decoration: BoxDecoration(color: Colors.grey[300]),
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
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
