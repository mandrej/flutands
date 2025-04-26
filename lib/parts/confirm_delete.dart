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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      // backgroundColor: Theme.of(context).colorScheme.surface,
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
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
