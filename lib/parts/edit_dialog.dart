import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';
import '../widgets/datetime_widget.dart';
import '../helpers/read_exif.dart';

class EditDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> editRecord;

  const EditDialog({super.key, required this.editRecord});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditDialogState();
}

class _EditDialogState extends ConsumerState<EditDialog> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _record = {};

  @override
  void initState() {
    super.initState();
    _record = {...widget.editRecord};
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(myApiProvider).values;
    final width = MediaQuery.of(context).size.width;
    final _controllerHeadline = TextEditingController(
      text: _record['headline'],
    );

    return Dialog(
      child: SizedBox(
        width: 800,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit'),
            actions: [
              ElevatedButton(
                child: const Text('Read Exif'),
                onPressed: () {
                  readExif(_record['filename']);
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: 16),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  _formKey.currentState!.save();
                  print('Saved: $_record[date]');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (width > 600)
                    Expanded(
                      child: Column(
                        children: [
                          Image.network(
                            _record['thumb'],
                            width: 400,
                            // height: 400,
                            fit: BoxFit.cover,
                          ),
                          TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Aperture',
                            ),
                            controller: TextEditingController(
                              text: _record['aperture'].toString(),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Shutter',
                            ),
                            controller: TextEditingController(
                              text: _record['shutter'],
                            ),
                          ),
                          TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(labelText: 'ISO'),
                            controller: TextEditingController(
                              text: _record['iso'].toString(),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  if (width > 600) SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controllerHeadline,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Headline.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Headline',
                            suffixIcon:
                                _controllerHeadline.text.isEmpty
                                    ? null
                                    : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _record['headline'] = '';
                                        });
                                      },
                                    ),
                          ),
                          onSaved:
                              (value) => {
                                setState(() {
                                  _record['headline'] = value!;
                                }),
                              },
                        ),
                        DatetimeWidget(
                          dateAndTime: _record['date'],
                          format: 'yyyy-MM-dd HH:mm',
                          labelText: 'Date',
                          onDone: (value) {
                            setState(() {
                              _record['date'] = value;
                            });
                          },
                        ),
                        AutoSuggestField(
                          hintText: 'email',
                          initialValue: _record['email'],
                          options: values!['email']!.keys.toList(),
                          onChanged: (value) {
                            setState(() {
                              _record['email'] = value!;
                            });
                          },
                        ),
                        AutoSuggestMultiSelect(
                          hintText: 'tags',
                          initialValues: List<String>.from(
                            _record['tags'] as List,
                          ),
                          options: values['tags']!.keys.toList(),
                          onChanged: (value) {
                            setState(() {
                              _record['tags'] = value;
                            });
                          },
                        ),
                        AutoSuggestField(
                          hintText: 'by make',
                          initialValue: _record['model'],
                          options: values['model']!.keys.toList(),
                          onChanged: (value) {
                            setState(() {
                              _record['model'] = value;
                            });
                          },
                        ),
                        AutoSuggestField(
                          hintText: 'lens',
                          initialValue: _record['lens'],
                          options: values['lens']!.keys.toList(),
                          onChanged: (value) {
                            setState(() {
                              _record['lens'] = value;
                            });
                          },
                        ),
                        TextFormField(
                          controller: TextEditingController(
                            text: _record['loc'],
                          ),
                          decoration: InputDecoration(
                            labelText: 'GPS location',
                            hintText: 'latitude, longitude',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _record['loc'] = '';
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _record['loc'] = value;
                            });
                          },
                        ),
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text('Flash fired'),
                          value: _record['flash'],
                          onChanged: (value) {
                            setState(() {
                              _record['flash'] = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
