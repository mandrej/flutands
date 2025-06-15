import 'package:flutter_bloc/flutter_bloc.dart';

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

abstract class SearchFindEvent {}

class SearchFindChanged extends SearchFindEvent {
  final String key;
  final dynamic value;
  // final Map<String, dynamic>? find;

  SearchFindChanged(this.key, this.value);
}

class SearchFindState {
  final Map<String, dynamic>? find;

  SearchFindState({this.find});

  int? get year => find!['year'];
  int? get month => find!['month'];
  List<String> get tags => find!['tags'];
  String get model => find!['model'];
  String get lens => find!['lens'];
  String get nick => find!['nick'];

  SearchFindState copyWith({Map<String, dynamic>? find}) {
    return SearchFindState(find: find ?? this.find);
  }
}

class SearchFindBloc extends Bloc<SearchFindEvent, SearchFindState> {
  SearchFindBloc() : super(SearchFindState(find: null)) {
    on<SearchFindChanged>((event, emit) {
      final find = Map<String, dynamic>.from(state.find ?? {});
      find[event.key] = event.value;
      emit(state.copyWith(find: fix(find)));
    });
  }
}

// class SearchFindLoaded extends SearchFindState {
//   SearchFindLoaded({super.find});
// }
