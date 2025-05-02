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
    return SingleChildScrollView(
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/ 250,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        children:
            records.map((record) {
              return ItemThumbnail(
                record: record,
                onTap: () {
                  open(context, records.indexOf(record));
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
              records: records,
              initialIndex: index,
              scrollDirection: Axis.horizontal,
            ),
      ),
    );
  }
}

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({super.key, required this.record, required this.onTap});

  final Map<String, dynamic> record;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    var editMode = context.watch<FlagProvider>().editMode;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: record['filename'],
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(record['thumb'], fit: BoxFit.cover),
                  ),
                  if (editMode == true)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 42,
                        alignment: Alignment.topRight,
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.white70,
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) => DeleteDialog(record: record),
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
                                      (context) =>
                                          EditDialog(editRecord: record),
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
                        record['headline'] ?? '',
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
    required this.records,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;

  final List<Map<String, dynamic>> records;
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
                        (context) =>
                            DeleteDialog(record: widget.records[currentIndex]),
                    barrierDismissible: false,
                  );
                },
              ),
              Text(
                widget.records[currentIndex]['headline'] ?? '',
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
                          editRecord: widget.records[currentIndex],
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
              itemCount: widget.records.length,
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
    final record = widget.records[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(record['url'] as String),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: 1,
      heroAttributes: PhotoViewHeroAttributes(tag: record['filename']),
    );
  }
}
