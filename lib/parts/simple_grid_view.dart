import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
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

class ItemThumbnail extends ConsumerWidget {
  const ItemThumbnail({super.key, required this.record, required this.onTap});

  final Map<String, dynamic> record;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var editMode = ref.watch(myFlagProvider).editMode;
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
                            DeleteButton(record: record),
                            EditButton(record: record),
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

class GalleryPhotoViewWrapper extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState
    extends ConsumerState<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final editMode = ref.watch(myFlagProvider).editMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.records[currentIndex]['headline'] ?? ''),

        actions:
            (editMode == true)
                ? [
                  DeleteButton(
                    record: widget.records[currentIndex],
                    color: Colors.black,
                  ),

                  EditButton(
                    record: widget.records[currentIndex],
                    color: Colors.black,
                  ),
                ]
                : null,
      ),
      body: Expanded(
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

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.record,
    this.color = Colors.white,
  });
  final Map<String, dynamic> record;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      color: color,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => DeleteDialog(record: record),
          barrierDismissible: false,
        );
      },
    );
  }
}

class EditButton extends StatelessWidget {
  const EditButton({
    super.key,
    required this.record,
    this.color = Colors.white,
  });
  final Map<String, dynamic> record;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      color: color,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => EditDialog(editRecord: record),
          barrierDismissible: false,
        );
      },
    );
  }
}
