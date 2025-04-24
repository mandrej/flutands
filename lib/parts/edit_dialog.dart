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
    final TextEditingController controller = TextEditingController(
      text: editRecord['headline'] ?? '',
    );
    print(values!['tags']!.keys.toList());

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
          elevation: 4,
          shadowColor: Colors.grey,
        ),
        body: SpGrid(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          spacing: 10,
          runSpacing: 10,
          children: [
            SpGridItem(
              xs: 12,
              sm: 6,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Headline'),
              ),
            ),
            SpGridItem(
              xs: 12,
              sm: 6,
              child: AutoSuggestField(
                hintText: 'year',
                initialValue: editRecord['year']?.toString() ?? '',
                options: values['year']!.keys.map((e) => e.toString()).toList(),
                onChanged:
                    (value) => editRecord['year'] = int.tryParse(value ?? ''),
              ),
            ),
            SpGridItem(
              xs: 12,
              sm: 6,
              child: AutoSuggestMultiSelect(
                hintText: 'tags',
                initialValues: List<String>.from(editRecord['tags']),
                options: values['tags']!.keys.toList(),
                onChanged: (value) => editRecord['tags'] = value,
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
    );
  }
}
