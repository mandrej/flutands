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
  final Map<String, dynamic>? find;

  SearchFindChanged(this.find);
}

// class SearchFindState {
//   final int year;
//   final int month;
//   final List<String> tags;
//   final String model;
//   final String lens;
//   final String nick;

//   SearchFindState({
//     this.year = 2025,
//     this.month = 6,
//     this.tags = const [],
//     this.model = '',
//     this.lens = '',
//     this.nick = '',
//   });

//   dynamic operator [](String key) {
//     switch (key) {
//       case 'year':
//         return year;
//       case 'month':
//         return month;
//       case 'tags':
//         return tags;
//       case 'model':
//         return model;
//       case 'lens':
//         return lens;
//       case 'nick':
//         return nick;
//       default:
//         throw ArgumentError('Invalid key: $key');
//     }
//   }

//   SearchFindState copyWith({Map<String, dynamic>? find}) {
//     return SearchFindState(find: find ?? this.find);
//   }
// }

class SearchFindState {
  final Map<String, dynamic>? find;

  SearchFindState({this.find});

  SearchFindState copyWith({Map<String, dynamic>? find}) {
    return SearchFindState(find: find ?? this.find);
  }
}

class SearchFindBloc extends Bloc<SearchFindEvent, SearchFindState> {
  SearchFindBloc() : super(SearchFindState(find: null)) {
    on<SearchFindChanged>((event, emit) {
      emit(state.copyWith(find: fix(event.find)));
    });
  }
}

// class SearchFindLoaded extends SearchFindState {
//   SearchFindLoaded({super.find});
// }
