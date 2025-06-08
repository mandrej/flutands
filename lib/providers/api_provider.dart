import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

Future<Map<String, dynamic>?> getRecord(String kind, bool descending) async {
  final db = FirebaseFirestore.instance;
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
  final db = FirebaseFirestore.instance;
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

class EditModeCubit extends HydratedCubit<bool> {
  EditModeCubit() : super(false);

  void toggleEditMode() => emit(!state);

  @override
  bool fromJson(Map<String, dynamic> json) => json['editMode'] as bool;

  @override
  Map<String, dynamic> toJson(bool state) => {'editMode': state};
}

class LastRecordCubit extends HydratedCubit<Map<String, dynamic>?> {
  LastRecordCubit() : super(null);

  // void setLastRecord(Map<String, dynamic>? record) => emit(record);
  // void getRecord() => emit(state);
  Future<void> get(String kind, {bool descending = true}) async {
    final record = await getRecord(kind = 'Photo', descending = true);
    emit(record);
  }

  @override
  Map<String, dynamic>? fromJson(Map<String, dynamic> json) =>
      json['lastRecord'] as Map<String, dynamic>?;

  @override
  Map<String, dynamic> toJson(Map<String, dynamic>? state) => {
    'lastRecord': state,
  };
}

class FirstRecordCubit extends HydratedCubit<Map<String, dynamic>?> {
  FirstRecordCubit() : super(null);

  // void setLastRecord(Map<String, dynamic>? record) => emit(record);
  // void getRecord() => emit(state);
  Future<void> get(String kind, {bool descending = false}) async {
    final record = await getRecord(kind = 'Photo', descending = true);
    emit(record);
  }

  @override
  Map<String, dynamic>? fromJson(Map<String, dynamic> json) =>
      json['firstRecord'] as Map<String, dynamic>?;

  @override
  Map<String, dynamic> toJson(Map<String, dynamic>? state) => {
    'firstRecord': state,
  };
}

class AvailableValuesCubit
    extends HydratedCubit<Map<String, Map<String, int>>?> {
  AvailableValuesCubit() : super(null);

  Future<void> get(String kind) async {
    final values = await getValues(kind = 'Counter');
    emit(values);
  }

  @override
  Map<String, Map<String, int>>? fromJson(Map<String, dynamic> json) =>
      json['availableValues'] as Map<String, Map<String, int>>?;

  @override
  Map<String, dynamic> toJson(Map<String, Map<String, int>>? state) => {
    'availableValues': state,
  };
}

sealed class SearchFindEvent {}

final class SearchFindChanged extends SearchFindEvent {
  final String field;
  final dynamic value;

  SearchFindChanged(this.field, this.value);
}

class SearchFindBloc extends Bloc<SearchFindEvent, Map<String, dynamic>> {
  SearchFindBloc() : super({}) {
    on<SearchFindChanged>((event, emit) {
      final updated = Map<String, dynamic>.from(state);
      updated[event.field] = event.value;
      emit(updated);
    });
  }
}

Future<void> fetchRecords() async {
  final db = FirebaseFirestore.instance;
  final _find = SearchFindBloc().state;
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
      } else {
        _records.clear();
      }
    } catch (e) {
      print('Error completing: $e');
    }
  }
class FetchRecordsCubit extends Cubit<List<Map<String, dynamic>>> {
  FetchRecordsCubit() : super([]);

  void fetch() {
    fetchRecords().then((_) {
      emit(records);
    });
  }

  void deleteRecord(Map<String, dynamic> record) {
    apiProvider.deleteRecord(record).then((_) {
      emit(apiProvider.records);
    });
  }

  void updateRecord(Map<String, dynamic> record) {
    apiProvider.updateRecord(record).then((_) {
      emit(apiProvider.records);
    });
  }

  void addRecord(Map<String, dynamic> record) {
    apiProvider.addRecord(record).then((_) {
      emit(apiProvider.records);
    });
// class SearchCriteriaBloc extends Bloc<SearchFindEvent, Map<String, dynamic>?> {
//   HydratedBloc() : super({});

//   Map<String, dynamic>? fix(_find) {
//     _find?.removeWhere(
//       (key, value) =>
//           value == null ||
//           (value is List && value.isEmpty) ||
//           (value is String && value.isEmpty) ||
//           (value is int && value == 0),
//     );
//     return _find;
//   }

//   void setCriteria(Map<String, dynamic> criteria) => emit(fix(criteria));
//   Map<String, dynamic>? getCriteria() => fix(state);

//   @override
//   Map<String, dynamic>? fromJson(Map<String, dynamic> json) =>
//       json['searchCriteria'] as Map<String, dynamic>?;

//   @override
//   Map<String, dynamic> toJson(Map<String, dynamic>? state) => {
//     'searchCriteria': state,
//   };
// }

class ApiProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _uploaded = [];
  List<UploadTask> _uploadTasks = [];

  List<Map<String, dynamic>> get records => _records;

  List<UploadTask> get uploadTasks => _uploadTasks;
  List<Map<String, dynamic>> get uploaded => _uploaded;

  void changeFind(String field, dynamic value) {
    _find![field] = value;
    fetchRecords();
    notifyListeners();
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
