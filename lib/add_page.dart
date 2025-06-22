// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// https://pub.dev/packages/firebase_storage/example

import 'dart:async';
import 'dart:io' as io;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'bloc/task.dart';
import 'bloc/uploaded.dart';
import 'bloc/user.dart';
import 'model/record.dart';
import 'package:intl/intl.dart';
import 'helpers/read_exif.dart';
import 'helpers/common.dart';
import 'package:uuid/uuid.dart';
import 'parts/edit_dialog.dart';

class TaskManager extends StatefulWidget {
  TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
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
    final taskCubit = BlocProvider.of<TaskCubit>(context, listen: false);
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
        taskCubit.addTask(task);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskCubit = BlocProvider.of<TaskCubit>(context);
    final uploadedCubit = BlocProvider.of<UploadedCubit>(context);

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
          if (taskCubit.state.tasks.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: taskCubit.state.tasks.length,
                itemBuilder:
                    (context, index) => UploadTaskListTile(
                      task: taskCubit.state.tasks[index],
                      onDelete: () {
                        taskCubit.removeTask(taskCubit.state.tasks[index]);
                      },
                    ),
              ),
            ),
          if (uploadedCubit.state.isNotEmpty)
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
                  itemCount: uploadedCubit.state.length,
                  itemBuilder:
                      (context, index) => ItemThumbnail(
                        uploadedRecord: uploadedCubit.state[index].toMap(),
                        onDelete: () async {
                          uploadedCubit.removeUploaded(
                            uploadedCubit.state[index],
                          );
                        },
                        onPublish: () async {
                          var editRecord = await _recordPublish(
                            context,
                            uploadedCubit.state[index],
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

Future<Record> _recordPublish(
  BuildContext context,
  Map<String, dynamic> defaultRecord,
) async {
  final auth = BlocProvider.of<UserBloc>(context, listen: false);
  Map<String, dynamic> record;
  final email = auth.state.user!.email;

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

  return record as Record;
}

class UploadTaskListTile extends StatefulWidget {
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
  State<UploadTaskListTile> createState() => _UploadTaskListTileState();
}

class _UploadTaskListTileState extends State<UploadTaskListTile>
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskCubit>(create: (context) => TaskCubit()),
        BlocProvider<UploadedCubit>(create: (context) => UploadedCubit()),
      ],
      child: StreamBuilder<TaskSnapshot>(
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
              TaskCubit().removeTask(snapshot.ref);
              _recordUploaded(snapshot.ref).then((record) {
                UploadedCubit().add(record as Record);
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
      ),
    );
  }
}

class ItemThumbnail extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
