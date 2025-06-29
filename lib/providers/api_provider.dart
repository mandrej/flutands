import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/common.dart';

const months = {
  'January': 1,
  'February': 2,
  'March': 3,
  'April': 4,
  'May': 5,
  'June': 6,
  'July': 7,
  'August': 8,
  'September': 9,
  'October': 10,
  'November': 11,
  'December': 12,
};

final myFlagProvider = ChangeNotifierProvider<FlagProvider>(
  (ref) => FlagProvider(),
);

class FlagProvider extends ChangeNotifier {
  bool _editMode = false;

  void toggleEditMode() {
    _editMode = !_editMode;
    notifyListeners();
  }

  bool get editMode => _editMode;
}

final myApiProvider = ChangeNotifierProvider<ApiProvider>(
  (ref) => ApiProvider(),
);

class ApiProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  Map<String, dynamic>? lastRecord;
  Map<String, dynamic>? firstRecord;
  Map<String, Map<String, int>>? _values;
  Map<String, dynamic>? _find = {};
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _uploaded = [];
  List<UploadTask> _uploadTasks = [];

  ApiProvider() {
    initializeStartup();
  }

  Map<String, dynamic>? get find => _find;
  List<Map<String, dynamic>> get records => _records;
  Map<String, Map<String, int>>? get values => _values;

  List<UploadTask> get uploadTasks => _uploadTasks;
  List<Map<String, dynamic>> get uploaded => _uploaded;

  void initializeStartup() async {
    lastRecord = await getRecord('Photo', true);
    firstRecord = await getRecord('Photo', false);
    _values = await getValues('Counter');
    notifyListeners();
    // print(values!['tags']);
  }

  void changeFind(String field, dynamic value) {
    _find![field] = value;
    fixFind();
    fetchRecords();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getRecord(String kind, bool descending) async {
    try {
      final querySnapshot =
          await db
              .collection(kind)
              .orderBy('date', descending: descending)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error completing: $e');
    }
    return null;
  }

  Future<Map<String, Map<String, int>>?> getValues(String kind) async {
    // {field: email, count: 35, value: milan.andrejevic@gmail.com}
    var result = <String, Map<String, int>>{};

    try {
      final querySnapshot = await db.collection(kind).get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          var d = doc.data();
          if (!result.containsKey(d['field'])) {
            // start filed
            result[d['field']] = {d['value']: d['count']};
          } else {
            result[d['field']]!.addAll({d['value']: d['count']});
          }
          if (result['email'] != null) {
            result['nick'] = {};
            result['email']?.forEach((key, value) {
              result['nick']![nickEmail(key)] = value;
            });
          }
          result['month'] = months;
        }
      }
    } catch (e) {
      print('Error completing: $e');
    }
    return result.isNotEmpty ? result : null;
  }

  Map<String, dynamic>? fixFind() {
    _find?.removeWhere(
      (key, value) =>
          value == null ||
          (value is List && value.isEmpty) ||
          (value is String && value.isEmpty) ||
          (value is int && value == 0),
    );
    return _find;
  }

  Future<void> fetchRecords() async {
    debugPrint('FIND ------------------------------- ${_find.toString()}');
    try {
      Query<Map<String, dynamic>> query = db.collection('Photo');
      query = query.where('year', isEqualTo: _find!['year']);
      query = query.where('month', isEqualTo: _find!['month']);
      query = query.where('tags', arrayContainsAny: _find!['tags']);
      query = query.where('model', isEqualTo: _find!['model']);
      query = query.where('lens', isEqualTo: _find!['lens']);
      query = query.where('nick', isEqualTo: _find!['nick']);

      final querySnapshot =
          await query.orderBy('date', descending: true).limit(100).get();

      if (querySnapshot.docs.isNotEmpty) {
        _records.clear();
        _records = querySnapshot.docs.map((doc) => doc.data()).toList();
        notifyListeners();
      } else {
        _records.clear();
        notifyListeners();
      }
    } catch (e) {
      print('Error completing: $e');
    }
  }

  Future<void> deleteRecord(Map<String, dynamic> record) async {
    try {
      await db.collection('Photo').doc(record['filename']).delete();
      removeFromStorage(record['filename']);
      _records.removeWhere((item) => item['filename'] == record['filename']);
      notifyListeners();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> updateRecord(Map<String, dynamic> record) async {
    try {
      await db.collection('Photo').doc(record['filename']).update(record);
    } catch (e) {
      print('Error updating document: $e');
    } finally {
      int index = _records.indexWhere(
        (item) => item['filename'] == record['filename'],
      );
      if (index != -1) {
        _records[index] = record;
        notifyListeners();
      }
    }
  }

  Future<void> addRecord(Map<String, dynamic> record) async {
    try {
      Reference thumbRef = FirebaseStorage.instance
          .ref()
          .child('/thumbnails')
          .child('/${thumbFileName(record['filename'])}');
      record['thumb'] = await thumbRef.getDownloadURL();
    } catch (e) {
      print('Error processing thumbnail: $e');
    }

    try {
      await db.collection('Photo').doc(record['filename']).set(record);
      _records.add(record);
      notifyListeners();
    } catch (e) {
      print('Error adding document: $e');
    }
  }

  void removeFromStorage(String fileName) {
    final photoRef = FirebaseStorage.instance.ref().child(fileName);
    photoRef.delete().catchError((e) {
      print('Error deleting file: $e');
    });
    final thumbRef = FirebaseStorage.instance
        .ref()
        .child('/thumbnails')
        .child('/${thumbFileName(photoRef.name)}');
    thumbRef.delete().catchError((e) {
      print('Error deleting thumbnail: $e');
    });
  }

  void clearTasks() {
    _uploadTasks = [];
    notifyListeners();
  }

  void addTask(UploadTask task) {
    _uploadTasks = [..._uploadTasks, task];
    notifyListeners();
  }

  void removeTask(Reference photoRef) {
    _uploadTasks.removeWhere((item) => item.snapshot.ref == photoRef);
    notifyListeners();
  }

  void addUploaded(Map<String, dynamic> record) {
    _uploaded.add(record);
    notifyListeners();
  }

  void removeUploaded(Map<String, dynamic> record) {
    _uploaded.removeWhere((item) => item['filename'] == record['filename']);
    removeFromStorage(record['filename']);
    notifyListeners();
  }

  void donePublish(Map<String, dynamic> record) {
    _uploaded.removeWhere((item) => item['filename'] == record['filename']);
    notifyListeners();
  }
}
