import 'package:hydrated_bloc/hydrated_bloc.dart';

class EditModeCubit extends HydratedCubit<bool> {
  EditModeCubit() : super(false);

  void toggle() => emit(!state);

  @override
  bool fromJson(Map<String, dynamic> json) {
    return json['editMode'] as bool? ?? false;
  }

  @override
  Map<String, dynamic> toJson(bool state) {
    return {'editMode': state};
  }
}
