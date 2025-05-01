import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:simple_grid/simple_grid.dart';
import '../providers/api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';
import '../widgets/datetime_widget.dart';

class EditDialog extends StatefulWidget {
  final Map<String, dynamic> editRecord;

  const EditDialog({super.key, required this.editRecord});

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _record = {};

  @override
  void initState() {
    super.initState();
    _record = {...widget.editRecord};
  }

  @override
  Widget build(BuildContext context) {
    final values = context.watch<ApiProvider>().values;
    // final width = MediaQuery.of(context).size.width;
    final _controllerHeadline = TextEditingController(
      text: _record['headline'],
    );

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _formKey.currentState!.save();
                print('Saved: $_record[date]');
                // Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                  initialValues: _record['tags'] != null ? _record['tags'] : [],
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
                  decoration: const InputDecoration(labelText: 'Focal length'),
                  controller: TextEditingController(
                    text: _record['focal_length'].toString(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _record['focal_length'] =
                          value.isEmpty ? null : int.tryParse(value);
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ISO'),
                  controller: TextEditingController(
                    text: _record['iso'].toString(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _record['iso'] =
                          value.isEmpty ? null : int.tryParse(value);
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Shutter'),
                  controller: TextEditingController(text: _record['shutter']),
                  onChanged: (value) {
                    setState(() {
                      _record['shutter'] = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Aperture'),
                  controller: TextEditingController(
                    text: _record['aperture'].toString(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
                  ],
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _record['aperture'] =
                          value.isEmpty ? null : num.tryParse(value);
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Flash'),
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
        ),
      ),
    );
  }
}
