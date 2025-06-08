// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// https://pub.dev/packages/firebase_storage/example

import 'dart:async';
import 'dart:io' as io;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'providers/api_provider.dart';
import 'providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'helpers/read_exif.dart';
import 'helpers/common.dart';
import 'package:uuid/uuid.dart';
import 'parts/edit_dialog.dart';

class TaskManager extends ConsumerStatefulWidget {
  TaskManager({super.key});

  @override
  ConsumerState<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends ConsumerState<TaskManager> {
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
    var api = ref.read(myApiProvider);
    final ImagePicker _picker = ImagePicker();
    final List<XFile> images = await _picker.pickMultiImage();
    if (!mounted) return;
    if (images.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file was selected')));
      return;
    }
    for (var file in images) {
      UploadTask? task = await uploadFile(file);
      if (task != null) {
        api.addTask(task);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.read(myApiProvider);
    final _uploaded = ref.watch(myApiProvider).uploaded;
    List<UploadTask> _uploadTasks = ref.watch(myApiProvider).uploadTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilledButton(
                  onPressed: () {
                    handleUploads();
                  },
                  child: Text('Upload local files'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_uploadTasks.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _uploadTasks.length,
                itemBuilder:
                    (context, index) => UploadTaskListTile(
                      task: _uploadTasks[index],
                      onDelete: () {
                        api.removeTask(_uploadTasks[index].snapshot.ref);
                      },
                    ),
              ),
            ),
          if (_uploaded.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width ~/ 200,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  shrinkWrap: true,
                  itemCount: _uploaded.length,
                  itemBuilder:
                      (context, index) => ItemThumbnail(
                        uploadedRecord: _uploaded[index],
                        onDelete: () async {
                          api.removeUploaded(_uploaded[index]);
                          // return _delete(_uploadTasks[index].snapshot.ref);
                        },
                        onPublish: () async {
                          var editRecord = await _recordPublish(
                            _uploaded[index],
                            ref,
                          );
                          await showDialog(
                            context: context,
                            builder:
                                (context) => EditDialog(editRecord: editRecord),
                            barrierDismissible: false,
                          );
                        },
                      ),
                ),
              ),
            )
          else
            SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>> _recordUploaded(Reference photoRef) async {
  final url = await photoRef.getDownloadURL();
  var metadata = await photoRef.getMetadata();

  final record = <String, dynamic>{
    'filename': photoRef.name,
    'url': url,
    'size': metadata.size,
    'headline': 'No name',
  };
  return record;
}

Future<Map<String, dynamic>> _recordPublish(
  Map<String, dynamic> defaultRecord,
  WidgetRef ref,
) async {
  final auth = ref.read(myUserProvider);
  Map<String, dynamic> record;
  final email = auth.userEmail;

  var exif = await readExif(defaultRecord['filename']);
  if (exif.isEmpty) {
    var date = DateTime.now();
    exif = {
      'model': 'UNKNOWN',
      'date': DateFormat(formatDate).format(date),
      'year': date.year,
      'month': date.month,
      'day': date.day,
    };
  }
  record = <String, dynamic>{
    ...defaultRecord,
    ...exif,
    'email': email,
    'nick': nickEmail(email!),
    'tags': [],
  };

  return record;
}

class UploadTaskListTile extends ConsumerStatefulWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile({
    super.key,
    required this.task,
    required this.onDelete,
  });

  final UploadTask task;
  final VoidCallback onDelete;

  // num _bytesTransferred(TaskSnapshot snapshot) {
  //   return snapshot.bytesTransferred / snapshot.totalBytes;
  // }

  @override
  ConsumerState<UploadTaskListTile> createState() => _UploadTaskListTileState();
}

class _UploadTaskListTileState extends ConsumerState<UploadTaskListTile>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, value: 0.0)..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var api = ref.read(myApiProvider);
    return StreamBuilder<TaskSnapshot>(
      stream: widget.task.snapshotEvents,
      builder: (
        BuildContext context,
        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
      ) {
        var info = '';
        TaskSnapshot? snapshot = asyncSnapshot.data;
        TaskState? state = snapshot?.state;

        if (asyncSnapshot.hasError) {
          if (asyncSnapshot.error is FirebaseException &&
              // ignore: cast_nullable_to_non_nullable
              (asyncSnapshot.error as FirebaseException).code == 'canceled') {
            info = 'Upload canceled.';
          } else {
            // ignore: avoid_print
            info = 'Something went wrong.';
          }
        } else if (snapshot != null) {
          if (state == TaskState.success) {
            // controller.stop();
            api.removeTask(snapshot.ref);
            _recordUploaded(snapshot.ref).then((record) {
              api.addUploaded(record);
            });
          }
        }

        return ListTile(
          title: Text('${widget.task.snapshot.ref.name} $info'),
          subtitle: LinearProgressIndicator(
            value:
                widget.task.snapshot.bytesTransferred /
                widget.task.snapshot.totalBytes,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ItemThumbnail extends ConsumerWidget {
  const ItemThumbnail({
    super.key,
    required this.uploadedRecord,
    required this.onDelete,
    required this.onPublish,
  });

  final Map<String, dynamic> uploadedRecord;
  final VoidCallback onDelete;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final api = ref.read(myApiProvider);
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Image.network(
              uploadedRecord['url'] as String,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(color: Colors.white70),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
                  IconButton(
                    icon: const Icon(Icons.publish),
                    onPressed: onPublish,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
