import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_grid/simple_grid.dart';
import '../providers/api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';

class EditDialog extends StatelessWidget {
  final Map<String, dynamic> editRecord;
  // final void Function(String) onSave;

  const EditDialog({
    super.key,
    required this.editRecord,
    // required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final values = context.watch<ApiProvider>().values;
    final width = MediaQuery.of(context).size.width;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                // onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16),
            child: SpGrid(
              spacing: 16,
              runSpacing: 16,
              children: [
                width > 600
                    ? SpGridItem(
                      xs: 12,
                      sm: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            // width: 200,
                            child: Image.network(
                              editRecord['thumb'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SpGridItem(child: Container()),
                SpGridItem(
                  xs: 12,
                  sm: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: TextEditingController(
                          text: editRecord['headline'],
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Headline',
                        ),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Date'),
                        controller: TextEditingController(
                          text: editRecord['date']?.toString() ?? '',
                        ),
                        onChanged: (value) => editRecord['date'] = value,
                      ),
                      AutoSuggestMultiSelect(
                        hintText: 'tags',
                        initialValues: List<String>.from(editRecord['tags']),
                        options: values!['tags']!.keys.toList(),
                        onChanged: (value) => editRecord['tags'] = value,
                      ),
                    ],
                  ),
                ),
                SpGridItem(
                  xs: 12,
                  sm: 6,
                  child: AutoSuggestField(
                    hintText: 'by make',
                    initialValue: editRecord['model'],
                    options: values['model']!.keys.toList(),
                    onChanged: (value) => editRecord['model'] = value,
                  ),
                ),
                SpGridItem(
                  xs: 12,
                  sm: 6,
                  child: AutoSuggestField(
                    hintText: 'lens',
                    initialValue: editRecord['lens'],
                    options: values['lens']!.keys.toList(),
                    onChanged: (value) => editRecord['lens'] = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
