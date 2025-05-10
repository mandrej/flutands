import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class FlagProvider extends ChangeNotifier {
  bool _editMode = false;
  late SharedPreferences prefs;

  FlagProvider() {
    _initializePrefs().then((_) {
      _editMode = prefs.getBool('_editMode') ?? false;
      notifyListeners();
    });
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> toggleEditMode() async {
    _editMode = !_editMode;
    await prefs.setBool('_editMode', _editMode);
    notifyListeners();
  }

  bool get editMode => (_editMode || (prefs.getBool('_editMode') ?? false));
}

class ApiProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  Map<String, dynamic>? lastRecord;
  Map<String, dynamic>? firstRecord;
  Map<String, Map<String, int>>? _values;
  Map<String, dynamic>? _find = {};
  List<Map<String, dynamic>> _records = [];

  ApiProvider() {
    initializeStartup();
  }

  List<Map<String, dynamic>> get records => _records;
  Map<String, Map<String, int>>? get values => _values;
  Map<String, dynamic>? get find => _find;

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
    debugPrint('FIND ------------------------------- ${_find.toString()}');
    try {
      Query<Map<String, dynamic>> query = db.collection('Photo');
      query = query.where('year', isEqualTo: _find!['year']);
      query = query.where('month', isEqualTo: _find!['month']);
      query = query.where('tags', arrayContainsAny: _find!['tags']);
      query = query.where('model', isEqualTo: _find!['model']);
      query = query.where('lens', isEqualTo: _find!['lens']);

      final querySnapshot = await query.orderBy('date', descending: true).get();

      if (querySnapshot.docs.isNotEmpty) {
        _records.clear();
        for (var doc in querySnapshot.docs) {
          _records.add(doc.data());
        }
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
      _records.removeWhere((item) => item['filename'] == record['filename']);
      notifyListeners();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> updateRecord(
    Map<String, dynamic> record,
    Map<String, dynamic> newValues,
  ) async {
    try {
      await db.collection('Photo').doc(record['filename']).update(newValues);
      int index = _records.indexWhere(
        (item) => item['filename'] == record['filename'],
      );
      if (index != -1) {
        _records[index].addAll(newValues);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  // Future<void> addRecord(Map<String, dynamic> record) async {
  //   try {
  //     await db.collection('Photo').add(record);
  //     _records.add(record);
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error adding document: $e');
  //   }
  // }
}
