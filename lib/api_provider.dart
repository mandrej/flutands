import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class FlagProvider extends ChangeNotifier {
  bool editMode = false;

  FlagProvider();

  void toggleEditMode() {
    editMode = !editMode;
    notifyListeners();
  }

  String get buttonText => editMode ? 'EDIT MODE' : 'VIEW MODE';
  bool get editModeValue => editMode;
}

class ApiProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  Map<String, dynamic>? lastRecord;
  Map<String, dynamic>? firstRecord;
  Map<String, Map<String, int>>? values;
  Map<String, dynamic>? find = {};
  List<Map<String, dynamic>> records = [];

  ApiProvider() {
    initializeRecords();
  }

  void initializeRecords() async {
    lastRecord = await getRecord('Photo', true);
    firstRecord = await getRecord('Photo', false);
    values = await getValues('Counter');
    notifyListeners();
    // print(values!['tags']);
  }

  void changeFind(String field, dynamic value) {
    find![field] = value;
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
      print("Error completing: $e");
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
      print("Error completing: $e");
    }
    return result.isNotEmpty ? result : null;
  }

  Map<String, dynamic>? fixFind() {
    find?.removeWhere(
      (key, value) =>
          value == null ||
          (value is List && value.isEmpty) ||
          (value is String && value.isEmpty) ||
          (value is int && value == 0),
    );
    return find;
  }

  fetchRecords() async {
    debugPrint('FIND $find.toString()');
    try {
      final querySnapshot =
          await db
              .collection('Photo')
              .where('year', isEqualTo: find!['year'])
              .where('month', isEqualTo: find!['month'])
              // .where('day', isEqualTo: find!['day'])
              .where('tags', arrayContainsAny: find!['tags'])
              .where('model', isEqualTo: find!['model'])
              // .where('lens', isEqualTo: find!['lens'])
              // .where('email', isEqualTo: find!['email'])
              .orderBy('date', descending: true)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        records.clear();
        for (var doc in querySnapshot.docs) {
          records.add(doc.data());
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error completing: $e");
    }
  }
}
