import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/record.dart';

Future<Record?> getRecord(String kind, bool descending) {
  final db = FirebaseFirestore.instance;
  return db
      .collection(kind)
      .orderBy('date', descending: descending)
      .limit(1)
      .get()
      .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data();
          return Record.fromMap(data);
        }
        return null;
      })
      .catchError((e) {
        print('Error completing: $e');
        return null;
      });
}

abstract class FirstRecordEvent {}

class FetchFirstRecord extends FirstRecordEvent {
  FetchFirstRecord();
}

class FirstRecordState {
  final Record? record;
  final bool loading;
  final String? error;

  FirstRecordState({this.record, this.loading = false, this.error});
  // String? get filename => record?.filename;
  // String? get url => record!.url as String?;
  int get year => record!.year;

  FirstRecordState copyWith({Record? record, bool? loading, String? error}) {
    return FirstRecordState(
      record: record ?? this.record,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  Map<String, dynamic> toMap() {
    return {'record': record?.toMap(), 'loading': loading, 'error': error};
  }

  factory FirstRecordState.fromMap(Map<String, dynamic> map) {
    return FirstRecordState(
      record:
          map['record'] != null
              ? Record.fromMap(Map<String, dynamic>.from(map['record']))
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
      final record = await getRecord('Photo', true);
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
