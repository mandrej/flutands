// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// https://pub.dev/packages/firebase_storage/example

import 'dart:async';
import 'dart:io' as io;
// import 'dart:js_interop';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/user_provider.dart'
import 'helpers/common.dart';
import 'package:uuid/uuid.dart';

class TaskManager extends StatefulWidget {
  TaskManager({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TaskManager();
  }
}

class _TaskManager extends State<TaskManager> {
  List<UploadTask> _uploadTasks = [];

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> uploadFile(XFile? file) async {
    if (file == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file was selected')));
      return null;
    }
    var fileName = file.name;
    var uuid = Uuid();

    UploadTask uploadTask;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('test')
        .child('/$fileName');

    bool exists = false;
    try {
      await ref.getDownloadURL();
      exists = true;
    } catch (e) {
      exists = false;
    }

    if (exists) {
      var [name, ext] = splitFileName(fileName);
      String gen = uuid.v4().split('-').last;
      fileName = '$name-$gen.$ext';
      ref = FirebaseStorage.instance.ref().child('test').child('/$fileName');
    }

    final metadata = SettableMetadata(
      contentType: file.mimeType, //'image/jpeg',
      // customMetadata: {'picked-file-path': file.path},
    );

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(io.File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }

  /// Handles the user pressing the PopupMenuItem item.
  Future<void> handleUploads() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file was selected')));
      return;
    }
    for (var file in images) {
      UploadTask? task = await uploadFile(file);
      if (task != null) {
        setState(() {
          _uploadTasks = [..._uploadTasks, task];
        });
      }
    }
  }

  void _removeTaskAtIndex(int index) {
    setState(() {
      _uploadTasks = _uploadTasks..removeAt(index);
    });
  }

  Future<void> _publish(Reference ref) async {
    print('Publishing ${ref.name}');
    final email = ref.watch(myUserProvider).email;
    var metadata = await ref.getMetadata();
    Map<String, dynamic> record = {
      'filename': ref.name,
      'url': _downloadUrl(ref),
      'size': metadata.size,
      'headline': 'No name',
      'email': email,
    };
    print(record);
  }

  Future<void> _delete(Reference ref) async {
    // print(thumbFileName(ref.name));
    Reference thumbRef = FirebaseStorage.instance
        .ref()
        .child('test')
        .child('/thumbnails')
        .child('/${thumbFileName(ref.name)}');

    print(thumbRef.fullPath);
    try {
      await thumbRef.delete();
    } catch (e) {
      print('Error deleting thumbnail: $e');
    }
    await ref.delete();

    setState(() {
      _uploadTasks.removeWhere(
        (task) => task.snapshot.ref.fullPath == ref.fullPath,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!\n deleted ${ref.name} \n from bucket: ${ref.bucket}\n '
          'at path: ${ref.fullPath} \n',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        actions: [
          SizedBox(width: 16.0),
          if (_uploadTasks.isNotEmpty)
            FilledButton(
              onPressed: () {
                setState(() {
                  _uploadTasks = [];
                });
              },
              child: Text('Clear list'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: FilledButton(
                onPressed: () {
                  handleUploads();
                },
                child: Text('Upload local files'),
              ),
            ),
            if (_uploadTasks.isNotEmpty)
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 200,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 1,
                ),
                shrinkWrap: true,
                itemCount: _uploadTasks.length,
                itemBuilder:
                    (context, index) => ItemThumbnail(
                      task: _uploadTasks[index],
                      onDelete: () async {
                        return _delete(_uploadTasks[index].snapshot.ref);
                      },
                      onPublish: () async {
                        return _publish(_uploadTasks[index].snapshot.ref);
                      },
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<String> _downloadUrl(Reference ref) async {
  return await ref.getDownloadURL();
}

class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onPublish,
  });

  final UploadTask /*!*/ task;

  /// Triggered when the user presses the "delete" button on a completed upload task.
  final VoidCallback /*!*/ onDelete;
  final VoidCallback /*!*/ onPublish;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (
        BuildContext context,
        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
      ) {
        if (asyncSnapshot.hasError) {
          if (asyncSnapshot.error is FirebaseException &&
              // ignore: cast_nullable_to_non_nullable
              (asyncSnapshot.error as FirebaseException).code == 'canceled') {
          } else {
            print(asyncSnapshot.error);
          }
        }
        return Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: FutureBuilder<String>(
                      future: _downloadUrl(task.snapshot.ref),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Icon(Icons.error));
                        } else if (snapshot.hasData) {
                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.publish),
                            onPressed: onPublish,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
