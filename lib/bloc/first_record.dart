import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

abstract class FirstRecordEvent {}

class FetchFirstRecord extends FirstRecordEvent {
  FetchFirstRecord();
}

class FirstRecordState {
  final Map<String, dynamic>? record;
  final bool loading;
  final String? error;

  FirstRecordState({this.record, this.loading = false, this.error});

  FirstRecordState copyWith({
    Map<String, dynamic>? record,
    bool? loading,
    String? error,
  }) {
    return FirstRecordState(
      record: record ?? this.record,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  Map<String, dynamic> toMap() {
    return {'record': record, 'loading': loading, 'error': error};
  }

  factory FirstRecordState.fromMap(Map<String, dynamic> map) {
    return FirstRecordState(
      record:
          map['record'] != null
              ? Map<String, dynamic>.from(map['record'])
              : null,
      loading: map['loading'] ?? false,
      error: map['error'],
    );
  }
}

class FirstRecordBloc extends HydratedBloc<FirstRecordEvent, FirstRecordState> {
  FirstRecordBloc() : super(FirstRecordState()) {
    on<FetchFirstRecord>(_onFetchFirstRecord);
  }

  Future<void> _onFetchFirstRecord(
    FetchFirstRecord event,
    Emitter<FirstRecordState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final record = await getRecord('Photo', false);
      emit(state.copyWith(record: record, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  @override
  FirstRecordState? fromJson(Map<String, dynamic> json) {
    return FirstRecordState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(FirstRecordState state) {
    return state.toMap();
  }
}
