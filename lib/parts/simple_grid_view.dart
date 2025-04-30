import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import 'confirm_delete.dart';
import 'edit_dialog.dart';

class SimpleGridView extends StatelessWidget {
  SimpleGridView({super.key, required this.records});
  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) {
    final galleryItems =
        records.map((record) {
          return Item(id: record['filename'], record: record);
        }).toList();

    return SingleChildScrollView(
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/ 250,
          // mainAxisExtent: 280,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        children:
            galleryItems.map((item) {
              return ItemThumbnail(
                galleryItem: item,
                onTap: () {
                  open(context, galleryItems.indexOf(item));
                },
              );
            }).toList(),
      ),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GalleryPhotoViewWrapper(
              galleryItems:
                  records.map((record) {
                    return Item(id: record['filename'], record: record);
                  }).toList(),
              // backgroundDecoration: const BoxDecoration(color: Colors.black),
              initialIndex: index,
              scrollDirection: Axis.horizontal,
            ),
      ),
    );
  }
}

class Item {
  Item({required this.id, required this.record});

  final String id;
  final Map<String, dynamic> record;
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
    var editMode = context.watch<FlagProvider>().editMode;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: galleryItem.id,
        child: Card(
          semanticContainer: true,
          // color: Colors.grey.shade200,
          // shadowColor: Colors.transparent,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(8.0),
          // ),
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      galleryItem.record['thumb'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (editMode == true)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 42,
                        // color: Colors.black,
                        alignment: Alignment.topRight,
                        // color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.white70,
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) => DeleteDialog(
                                        record: galleryItem.record,
                                        // onSave: onSave,
                                      ),
                                  barrierDismissible: false,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.white70,
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) => EditDialog(
                                        editRecord: galleryItem.record,
                                        // onSave: onSave,
                                      ),
                                  barrierDismissible: false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Colors.black45),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        galleryItem.record['headline'] ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    return Material(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder:
                        (context) => DeleteDialog(
                          record: widget.galleryItems[currentIndex].record,
                          // onSave: onSave,
                        ),
                    barrierDismissible: false,
                  );
                },
              ),
              Text(
                widget.galleryItems[currentIndex].record['headline'] ?? '',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder:
                        (context) => EditDialog(
                          editRecord: widget.galleryItems[currentIndex].record,
                          // onSave: onSave,
                        ),
                    barrierDismissible: false,
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
          ),
        ],
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final Item item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(item.record['url'] as String),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: 1, //PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    );
  }
}
