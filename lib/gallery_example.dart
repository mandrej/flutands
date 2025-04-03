import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:simple_grid/simple_grid.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'api_provider.dart';

class Item {
  Item({
    required this.id,
    required this.thumb,
    required this.url,
    required this.headline,
  });

  final String id;
  final String thumb;
  final String url;
  final String headline;
}

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({
    super.key,
    required this.galleryItem,
    required this.onTap,
  });

  final Item galleryItem;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: galleryItem.id,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            children: [
              Image.network(galleryItem.thumb),
              Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  galleryItem.headline,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryExample extends StatefulWidget {
  const GalleryExample({super.key, required this.title});
  final String title;

  @override
  State<GalleryExample> createState() => _GalleryExampleState();
}

class _GalleryExampleState extends State<GalleryExample> {
  late List<Item> galleryItems = [];

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

    galleryItems =
        records.map((record) {
          return Item(
            id: record['filename'],
            thumb: record['thumb'],
            url: record['url'],
            headline: record['headline'],
          );
        }).toList();

    return AdminScaffold(
      // backgroundColor: Colors.pink.shade100,
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
          children:
              galleryItems.map((item) {
                return SpGridItem(
                  xs: 12,
                  sm: 4,
                  md: 3,
                  lg: 2,
                  child: ItemThumbnail(
                    galleryItem: item,
                    onTap: () {
                      open(context, galleryItems.indexOf(item));
                    },
                  ),
                  // decoration: BoxDecoration(color: Colors.grey[300]),
                );
              }).toList(),
        ),
      ),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GalleryPhotoViewWrapper(
              galleryItems: galleryItems,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              initialIndex: index,
              scrollDirection: Axis.horizontal,
            ),
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<Item> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.amber,
              child: Text(
                widget.galleryItems[currentIndex].headline,
                // "Image ${currentIndex + 1}",
                style: const TextStyle(
                  // color: Colors.white,
                  fontSize: 14.0,
                  decoration: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final Item item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(item.url),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: 1, //PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    );
  }
}
