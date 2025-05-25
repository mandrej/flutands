// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// https://pub.dev/packages/firebase_storage/example

import 'dart:async';
import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'helpers/read_exif.dart';
import 'helpers/common.dart';
import 'package:uuid/uuid.dart';

class TaskManager extends ConsumerStatefulWidget {
  TaskManager({super.key});

  @override
  ConsumerState<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends ConsumerState<TaskManager> {
  List<UploadTask> _uploadTasks = [];

  Future<UploadTask?> uploadFile(XFile? file) async {
    if (file == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file was selected')));
      return null;
    }
    String fileName = file.name;
    var uuid = Uuid();

    UploadTask uploadTask;
    Reference photoRef = FirebaseStorage.instance.ref().child(fileName);

    bool exists = false;
    try {
      await photoRef.getDownloadURL();
      exists = true;
    } catch (e) {
      exists = false;
    }

    if (exists) {
      var [name, ext] = splitFileName(fileName);
      String gen = uuid.v4().split('-').last;
      fileName = '$name-$gen.$ext';
      photoRef = FirebaseStorage.instance.ref().child(fileName);
    }

    final metadata = SettableMetadata(
      contentType: file.mimeType, //'image/jpeg',
      // customMetadata: {'picked-file-path': file.path},
    );

    if (kIsWeb) {
      uploadTask = photoRef.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = photoRef.putFile(io.File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }

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

  // void _removeTaskAtIndex(int index) {
  //   setState(() {
  //     _uploadTasks = _uploadTasks..removeAt(index);
  //   });
  // }

  Future<void> _publish(Reference photoRef) async {
    Reference thumbRef = FirebaseStorage.instance
        .ref()
        .child('/thumbnails')
        .child('/${thumbFileName(photoRef.name)}');

    final db = FirebaseFirestore.instance;
    final auth = ref.read(myUserProvider);
    final email = auth.userEmail;

    var metadata = await photoRef.getMetadata();
    final url = await _downloadUrl(photoRef);
    final thumb = await _downloadUrl(thumbRef);

    var date = DateTime.now();
    final exif = await readExif(photoRef.name);

    final record = <String, dynamic>{
      'filename': photoRef.name,
      'date': DateFormat('yyyy-MM-dd HH:mm').format(date),
      'url': url,
      'thumb': thumb,
      'size': metadata.size,
      'headline': 'No name',
      'email': email,
      ...exif,
    };

    await db.collection('Photo').doc(photoRef.name).set(record);
    print('RECORD $record');
  }

  Future<void> _delete(Reference photoRef) async {
    // print(thumbFileName(photoRef.name));
    Reference thumbRef = FirebaseStorage.instance
        .ref()
        .child('/thumbnails')
        .child('/${thumbFileName(photoRef.name)}');

    try {
      await thumbRef.delete();
    } catch (e) {
      print('Error deleting thumbnail: $e');
    }
    await photoRef.delete();

    setState(() {
      _uploadTasks.removeWhere(
        (task) => task.snapshot.ref.fullPath == photoRef.fullPath,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!\n deleted ${photoRef.name} \n from bucket: ${photoRef.bucket}\n '
          'at path: ${photoRef.fullPath} \n',
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

Future<String> _downloadUrl(Reference photoRef) async {
  return await photoRef.getDownloadURL();
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
