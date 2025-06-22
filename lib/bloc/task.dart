import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TaskState {
  final List<UploadTask> tasks;

  TaskState({this.tasks = const []});

  TaskState copyWith({List<UploadTask>? tasks}) {
    return TaskState(tasks: tasks ?? this.tasks);
  }
}

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskState());

  void addTask(UploadTask task) {
    emit(state.copyWith(tasks: List.from(state.tasks)..add(task)));
  }

  void removeTask(UploadTask task) {
    emit(state.copyWith(tasks: List.from(state.tasks)..remove(task)));
  }

  void clearTasks() {
    emit(state.copyWith(tasks: []));
  }
}
