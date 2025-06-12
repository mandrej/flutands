import 'package:flutter_bloc/flutter_bloc.dart';

class TaskState {
  final List<String> tasks;

  TaskState({this.tasks = const []});

  TaskState copyWith({List<String>? tasks}) {
    return TaskState(tasks: tasks ?? this.tasks);
  }
}

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskState());

  void addTask(String task) {
    emit(state.copyWith(tasks: List.from(state.tasks)..add(task)));
  }

  void removeTask(String task) {
    emit(state.copyWith(tasks: List.from(state.tasks)..remove(task)));
  }

  void clearTasks() {
    emit(state.copyWith(tasks: []));
  }
}
