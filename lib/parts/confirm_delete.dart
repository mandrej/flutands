import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key, required this.record});
  final Map<String, dynamic> record;
  // final void Function(String) onSave;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16),
      title: const Text('Delete'),
      content: Text('Are you sure you want to delete ${record['headline']}?'),
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
            // Call the delete function here
            Provider.of<ApiProvider>(
              context,
              listen: false,
            ).deleteRecord(record);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
