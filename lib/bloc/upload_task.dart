import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadTaskCubit extends Cubit<List<UploadTask>> {
  UploadTaskCubit() : super([]);

  void add(UploadTask task) {
    emit(List.from(state)..add(task));
  }

  void remove(UploadTask task) {
    emit(List.from(state)..remove(task));
  }

  void clear() {
    emit([]);
  }
}
