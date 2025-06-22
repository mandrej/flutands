import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/records.dart';
import '../model/record.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key, required this.record});
  final Record record;

  @override
  Widget build(BuildContext context) {
    // final api = ref.read(myApiProvider);

    return BlocProvider<RecordsBloc>(
      create: (context) => RecordsBloc(),
      child: AlertDialog(
        contentPadding: EdgeInsets.all(16),
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete ${record.headline}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () {
              RecordsBloc().add(DeleteRecord(record.filename));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
