import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../helpers/common.dart';

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

class UploadedRecordCubit extends HydratedCubit<List<Map<String, dynamic>>> {
  UploadedRecordCubit() : super([]);

  void add(Map<String, dynamic> record) {
    if (state.any((item) => item['filename'] != record['filename'])) {
      emit([...state, record]);
    }
  }

  void removeUploaded(Map<String, dynamic> record) {
    donePublish(record);
    removeFromStorage(record['filename']);
  }

  void donePublish(Map<String, dynamic> record) {
    emit(
      state.where((item) => item['filename'] != record['filename']).toList(),
    );
  }

  @override
  List<Map<String, dynamic>>? fromJson(Map<String, dynamic> json) {
    final files = json['uploaded'];
    if (files is List) {
      return files
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  @override
  Map<String, dynamic>? toJson(List<Map<String, dynamic>> state) {
    return {'uploaded': state};
  }
}
