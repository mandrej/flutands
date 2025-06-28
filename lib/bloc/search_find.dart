// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../model/find.dart';

Find? fix(find) {
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
  // final Find? find;

  SearchFindChanged(this.key, this.value);
}

class SearchFindState {
  final Find? find;

  SearchFindState({this.find});

  int? get year => find?.year;
  int? get month => find?.month;
  List<String> get tags => find?.tags ?? [];
  String? get model => find?.model;
  String? get lens => find?.lens;
  String? get nick => find?.nick;

  SearchFindState copyWith({Find? find}) {
    return SearchFindState(find: find ?? this.find);
  }
}

class SearchFindBloc extends HydratedBloc<SearchFindEvent, SearchFindState> {
  SearchFindBloc() : super(SearchFindState(find: null)) {
    on<SearchFindChanged>((event, emit) {
      final find = Find.from(state.find ?? {});
      switch (event.key) {
        case 'year':
          find.year = event.value;
        case 'month':
          find.month = event.value;
        case 'tags':
          find.tags = List<String>.from(event.value as List);
        case 'model':
          find.model = event.value;
        case 'lens':
          find.lens = event.value;
        case 'nick':
          find.nick = event.value;
        // Add more cases as needed for other fields
        default:
          throw ArgumentError('Invalid key: ${event.key}');
      }

      emit(state.copyWith(find: fix(find)));
    });
  }

  @override
  SearchFindState? fromJson(Map<String, dynamic> json) {
    try {
      return SearchFindState(find: Find.from(json['find'] ?? {}));
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SearchFindState state) {
    try {
      return {'find': state.find?.toJson()};
    } catch (_) {
      return null;
    }
  }
}
