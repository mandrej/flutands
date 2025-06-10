import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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

Map<String, dynamic>? fix(find) {
  find?.removeWhere(
    (key, value) =>
        value == null ||
        (value is List && value.isEmpty) ||
        (value is String && value.isEmpty) ||
        (value is int && value == 0),
  );
  return find;
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
      emit(fix(updated) ?? {});
    });
  }
}

sealed class RecordsBlocdEvent {}

final class FetchRecords extends RecordsBlocdEvent {
  final BuildContext context;

  FetchRecords(this.context);
}

final class AddRecord extends RecordsBlocdEvent {
  final Map<String, dynamic> record;
  AddRecord(this.record);
}

final class UpdatedRecord extends RecordsBlocdEvent {
  final Map<String, dynamic> record;
  UpdatedRecord(this.record);
}

final class DeleteRecord extends RecordsBlocdEvent {
  final Map<String, dynamic> record;
  DeleteRecord(this.record);
}

class RecordsBloc extends Bloc<RecordsBlocdEvent, List<Map<String, dynamic>>> {
  RecordsBloc() : super([]) {
    on<FetchRecords>((event, emit) async {
      final db = FirebaseFirestore.instance;
      final find = (BlocProvider.of<SearchFindBloc>(event.context).state);
      try {
        Query<Map<String, dynamic>> query = db.collection('Photo');
        if (find['year'] != null) {
          query = query.where('year', isEqualTo: find['year']);
        }
        if (find['month'] != null) {
          query = query.where('month', isEqualTo: find['month']);
        }
        if (find['tags'] != null && (find['tags'] as List).isNotEmpty) {
          query = query.where('tags', arrayContainsAny: find['tags']);
        }
        if (find['model'] != null) {
          query = query.where('model', isEqualTo: find['model']);
        }
        if (find['lens'] != null) {
          query = query.where('lens', isEqualTo: find['lens']);
        }
        if (find['nick'] != null) {
          query = query.where('nick', isEqualTo: find['nick']);
        }
        final querySnapshot =
            await query.orderBy('date', descending: true).limit(100).get();
        emit(querySnapshot.docs.map((doc) => doc.data()).toList());
      } catch (e) {
        print('Error fetching records: $e');
        emit([]);
      }
    });

    on<AddRecord>((event, emit) async {
      final db = FirebaseFirestore.instance;
      final record = event.record;
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
        final updated = List<Map<String, dynamic>>.from(state)..add(record);
        emit(updated);
      } catch (e) {
        print('Error adding document: $e');
      }
    });

    on<UpdatedRecord>((event, emit) async {
      final db = FirebaseFirestore.instance;
      final record = event.record;
      try {
        await db.collection('Photo').doc(record['filename']).update(record);
        final updated = List<Map<String, dynamic>>.from(state);
        int index = updated.indexWhere(
          (item) => item['filename'] == record['filename'],
        );
        if (index != -1) {
          updated[index] = record;
          emit(updated);
        }
      } catch (e) {
        print('Error updating document: $e');
      }
    });

    on<DeleteRecord>((event, emit) async {
      final db = FirebaseFirestore.instance;
      final record = event.record;
      try {
        await db.collection('Photo').doc(record['filename']).delete();
        final photoRef = FirebaseStorage.instance.ref().child(
          record['filename'],
        );
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
        final updated = List<Map<String, dynamic>>.from(state)
          ..removeWhere((item) => item['filename'] == record['filename']);
        emit(updated);
      } catch (e) {
        print('Error deleting document: $e');
      }
    });
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

class TaskCubit extends Cubit<List<UploadTask>> {
  TaskCubit() : super([]);

  void addTask(UploadTask task) {
    emit([...state, task]);
  }

  void removeTask(Reference photoRef) {
    emit(state.where((item) => item.snapshot.ref != photoRef).toList());
  }

  void clearTasks() {
    emit([]);
  }
}

class UploadedCubit extends HydratedCubit<List<Map<String, dynamic>>> {
  UploadedCubit() : super([]);

  void addUploaded(Map<String, dynamic> record) {
    emit([...state, record]);
  }

  void removeUploaded(Map<String, dynamic> record) {
    emit(
      state.where((item) => item['filename'] != record['filename']).toList(),
    );
    removeFromStorage(record['filename']);
  }

  void donePublish(Map<String, dynamic> record) {
    emit(
      state.where((item) => item['filename'] != record['filename']).toList(),
    );
  }

  @override
  List<Map<String, dynamic>>? fromJson(Map<String, dynamic> json) {
    final list = json['uploaded'] as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Map<String, dynamic>? toJson(List<Map<String, dynamic>> state) {
    return {'uploaded': state};
  }
}
