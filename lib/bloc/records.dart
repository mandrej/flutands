import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_find.dart';

// Future<void> fetchRecords() async {
//   final db = FirebaseFirestore.instance;
//   final _find = SearchFindBloc().state;
//     debugPrint('FIND ------------------------------- ${_find.toString()}');
//     try {
//       Query<Map<String, dynamic>> query = db.collection('Photo');
//       query = query.where('year', isEqualTo: _find['year']);
//       query = query.where('month', isEqualTo: _find['month']);
//       query = query.where('tags', arrayContainsAny: _find['tags']);
//       query = query.where('model', isEqualTo: _find['model']);
//       query = query.where('lens', isEqualTo: _find['lens']);
//       query = query.where('nick', isEqualTo: _find['nick']);

//       final querySnapshot =
//           await query.orderBy('date', descending: true).limit(100).get();

//       if (querySnapshot.docs.isNotEmpty) {
//         _records.clear();
//         _records = querySnapshot.docs.map((doc) => doc.data()).toList();
//       } else {
//         _records.clear();
//       }
//     } catch (e) {
//       print('Error completing: $e');
//     }
//   }

// Events
abstract class RecordsEvent {}

class FetchRecords extends RecordsEvent {}

class AddRecord extends RecordsEvent {
  final Map<String, dynamic> record;
  AddRecord(this.record);
}

class UpdateRecord extends RecordsEvent {
  final Map<String, dynamic> updatedData;
  UpdateRecord(this.updatedData);
}

class DeleteRecord extends RecordsEvent {
  final String id;
  DeleteRecord(this.id);
}

// States
abstract class RecordsState {}

class RecordsInitial extends RecordsState {}

class RecordsLoading extends RecordsState {}

class RecordsLoaded extends RecordsState {
  final List<Map<String, dynamic>> records;
  RecordsLoaded(this.records);
}

class RecordsError extends RecordsState {
  final String message;
  RecordsError(this.message);
}

// Bloc
class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  RecordsBloc() : super(RecordsInitial()) {
    on<FetchRecords>(_onFetchRecords);
    on<AddRecord>(_onAddRecord);
    on<UpdateRecord>(_onUpdateRecord);
    on<DeleteRecord>(_onDeleteRecord);
  }

  Future<void> _onFetchRecords(
    FetchRecords event,
    Emitter<RecordsState> emit,
  ) async {
    emit(RecordsLoading());
    try {
      final db = FirebaseFirestore.instance;
      final find = SearchFindBloc().state as Map<String, dynamic>;
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

      final records = querySnapshot.docs.map((doc) => doc.data()).toList();
      emit(RecordsLoaded(records));
    } catch (e) {
      emit(RecordsError('Error fetching records: $e'));
    }
  }

  Future<void> _onAddRecord(AddRecord event, Emitter<RecordsState> emit) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('Photo').add(event.record);
      add(FetchRecords());
    } catch (e) {
      emit(RecordsError('Error adding record: $e'));
    }
  }

  Future<void> _onUpdateRecord(
    UpdateRecord event,
    Emitter<RecordsState> emit,
  ) async {
    try {
      final db = FirebaseFirestore.instance;
      await db
          .collection('Photo')
          .doc(event.updatedData['filename'])
          .update(event.updatedData);
      add(FetchRecords());
    } catch (e) {
      emit(RecordsError('Error updating record: $e'));
    }
  }

  Future<void> _onDeleteRecord(
    DeleteRecord event,
    Emitter<RecordsState> emit,
  ) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('Photo').doc(event.id).delete();
      add(FetchRecords());
    } catch (e) {
      emit(RecordsError('Error deleting record: $e'));
    }
  }
}
