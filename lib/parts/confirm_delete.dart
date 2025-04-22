import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class ConfirmDelete extends StatelessWidget {
  const ConfirmDelete({super.key, required this.record});
  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete),
      color: Theme.of(context).colorScheme.surface,
      onPressed:
          () => showDialog(
            context: context,
            builder:
                (BuildContext builder) => AlertDialog(
                  contentPadding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: const Text('Delete'),
                  content: Text(
                    'Are you sure you want to delete ${record['headline']}?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
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
                ),
          ),
    );
  }
}
