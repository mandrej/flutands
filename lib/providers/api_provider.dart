import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class FlagProvider extends ChangeNotifier {
  bool _editMode = false;

  FlagProvider();

  void toggleEditMode() {
    _editMode = !_editMode;
    notifyListeners();
  }

  bool get editMode => _editMode;
}

class ApiProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  Map<String, dynamic>? lastRecord;
  Map<String, dynamic>? firstRecord;
  Map<String, Map<String, int>>? _values;
  Map<String, dynamic>? _find = {};
  List<Map<String, dynamic>> _records = [];

  ApiProvider() {
    initializeRecords();
  }

  List<Map<String, dynamic>> get records => _records;
  Map<String, Map<String, int>>? get values => _values;
  Map<String, dynamic>? get find => _find;

  void initializeRecords() async {
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
            result[d['field']] = {d['value']: d['count']};
          } else {
            result[d['field']]!.addAll({d['value']: d['count']});
          }
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
    debugPrint('FIND ${_find.toString()}');
    try {
      Query<Map<String, dynamic>> query = db.collection('Photo');

      if (_find!['year'] != null) {
        query = query.where('year', isEqualTo: _find!['year']);
      }
      if (_find!['month'] != null) {
        query = query.where('month', isEqualTo: _find!['month']);
      }
      if (_find!['tags'] != null &&
          _find!['tags'] is List &&
          _find!['tags'].isNotEmpty) {
        query = query.where('tags', arrayContainsAny: _find!['tags']);
      }
      if (_find!['model'] != null) {
        query = query.where('model', isEqualTo: _find!['model']);
      }

      final querySnapshot = await query.orderBy('date', descending: true).get();

      if (querySnapshot.docs.isNotEmpty) {
        _records.clear();
        for (var doc in querySnapshot.docs) {
          _records.add(doc.data());
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error completing: $e');
    }
  }

  Future<void> deleteRecord(Map<String, dynamic> rec) async {
    try {
      await db.collection('Photo').doc(rec['filename']).delete();
      _records.removeWhere((item) => item['filename'] == rec['filename']);
      notifyListeners();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
