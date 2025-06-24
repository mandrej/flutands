import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_find.dart';
import '../model/record.dart';
import '../model/find.dart';

// Events
abstract class RecordsEvent {}

class FetchRecords extends RecordsEvent {}

class AddRecord extends RecordsEvent {
  final Record record;
  AddRecord(this.record);
}

class UpdateRecord extends RecordsEvent {
  final Record updatedData;
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
  final List<Record> records;
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
      final find = SearchFindBloc().state as Find;
      Query<Map<String, dynamic>> query = db.collection('Photo');
      query = query.where('year', isEqualTo: find.year);
      query = query.where('month', isEqualTo: find.month);
      query = query.where('tags', arrayContainsAny: find.tags);
      query = query.where('model', isEqualTo: find.model);
      query = query.where('lens', isEqualTo: find.lens);
      query = query.where('nick', isEqualTo: find.nick);

      final querySnapshot =
          await query.orderBy('date', descending: true).limit(100).get();
      final records =
          querySnapshot.docs.map((doc) => Record.fromMap(doc.data())).toList();
      emit(RecordsLoaded(records));
    } catch (e) {
      emit(RecordsError('Error fetching records: $e'));
    }
  }

  Future<void> _onAddRecord(AddRecord event, Emitter<RecordsState> emit) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('Photo').add(event.record.toMap());
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
          .doc(event.updatedData.filename)
          .update(event.updatedData.toMap());
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
