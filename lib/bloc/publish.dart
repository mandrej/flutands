import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../helpers/common.dart';
import '../model/record.dart';

void removeFromStorage(String fileName) {
  final photoRef = FirebaseStorage.instance.ref().child(fileName);
  photoRef.delete().catchError((e) {
    print('Error deleting file: $e');
  });
  final thumbRef = FirebaseStorage.instance
      .ref()
      .child('/thumbnails')
      .child('/${thumbFileName(photoRef.name)}');
  thumbRef.delete().catchError((e) {
    print('Error deleting thumbnail: $e');
  });
}

class PublishCubit extends HydratedCubit<List<Record>> {
  PublishCubit() : super([]);

  void add(Record record) {
    if (state.any((item) => item.filename != record.filename)) {
      emit([...state, record]);
    }
  }

  void removeUploaded(Record record) {
    donePublish(record);
    removeFromStorage(record.filename);
  }

  void donePublish(Record record) {
    emit(state.where((item) => item.filename != record.filename).toList());
  }

  @override
  List<Record>? fromJson(Map<String, dynamic> json) {
    final files = json['uploaded'];
    if (files is List) {
      return files.map((item) => Record.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Map<String, dynamic>? toJson(List<Record> state) {
    return {'uploaded': state.map((record) => record.toJson()).toList()};
  }
}
