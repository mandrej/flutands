import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class AvailableValuesState {
  final Map<String, Map<String, int>>? values;
  final bool loading;
  final String? error;

  AvailableValuesState({this.values, this.loading = false, this.error});

  Map<String, dynamic> toMap() => {
    'values': values,
    'loading': loading,
    'error': error,
  };

  Map<String, int>? get year => values!['year'];
  Map<String, int>? get month => values!['month'];
  Map<String, int>? get tags => values!['tags'];
  Map<String, int>? get email => values!['email'];
  Map<String, int>? get nick => values!['nick'];
  Map<String, int>? get model => values!['model'];
  Map<String, int>? get lens => values!['lens'];

  factory AvailableValuesState.fromMap(Map<String, dynamic> map) {
    return AvailableValuesState(
      values: (map['values'] as Map?)?.map(
        (k, v) => MapEntry(
          k as String,
          (v as Map).map((kk, vv) => MapEntry(kk as String, vv as int)),
        ),
      ),
      loading: map['loading'] ?? false,
      error: map['error'],
    );
  }
}

abstract class AvailableValuesEvent {}

class FetchAvailableValues extends AvailableValuesEvent {
  FetchAvailableValues();
}

class AvailableValuesBloc
    extends HydratedBloc<AvailableValuesEvent, AvailableValuesState> {
  AvailableValuesBloc() : super(AvailableValuesState(loading: false)) {
    on<FetchAvailableValues>(_onFetchAvailableValues);
  }

  Future<void> _onFetchAvailableValues(
    FetchAvailableValues event,
    Emitter<AvailableValuesState> emit,
  ) async {
    emit(AvailableValuesState(loading: true));
    try {
      final values = await getValues('Counter');
      emit(AvailableValuesState(values: values, loading: false));
    } catch (e) {
      emit(
        AvailableValuesState(loading: false, error: e.toString(), values: null),
      );
    }
  }

  @override
  AvailableValuesState? fromJson(Map<String, dynamic> json) {
    return AvailableValuesState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(AvailableValuesState state) {
    return state.toMap();
  }
}
