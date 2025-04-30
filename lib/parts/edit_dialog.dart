import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:simple_grid/simple_grid.dart';
// import 'package:intl/intl.dart';
import '../providers/api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';

class EditDialog extends StatefulWidget {
  final Map<String, dynamic> editRecord;

  const EditDialog({super.key, required this.editRecord});

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final _formKey = GlobalKey<FormState>();
  // final re = '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}';
  Map<String, dynamic> _record = {};
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;

  @override
  void initState() {
    super.initState();
    _record = {...widget.editRecord};
    _pickedDate = DateTime.parse(_record['date']);
    _pickedTime = TimeOfDay.fromDateTime(DateTime.parse(_record['date']));
  }

  @override
  Widget build(BuildContext context) {
    final values = context.watch<ApiProvider>().values;
    // final width = MediaQuery.of(context).size.width;
    final _controllerHeadline = TextEditingController(
      text: _record['headline'],
    );
    var _controllerDate = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm').format(_pickedDate!),
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
                TextFormField(
                  controller: _controllerDate,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // added line
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_month),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _pickedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _pickedDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  _pickedTime!.hour,
                                  _pickedTime!.minute,
                                );
                                print(_pickedDate.toString());
                                _record['date'] = _pickedDate.toString();
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.schedule),
                          onPressed: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: _pickedTime!,
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _pickedTime = pickedTime;
                                _pickedDate = DateTime(
                                  _pickedDate!.year,
                                  _pickedDate!.month,
                                  _pickedDate!.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                print(_pickedDate.toString());
                                _record['date'] = _pickedDate.toString();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  onSaved:
                      (value) => {
                        setState(() {
                          _record['date'] = value!;
                        }),
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
                  initialValues: _record['tags'],
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
