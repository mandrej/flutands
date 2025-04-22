import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ApiProvider api = Provider.of<ApiProvider>(context, listen: false);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final values = context.watch<ApiProvider>().values;
    final find = context.watch<ApiProvider>().find;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSuggestField(
              hintText: 'filter by year',
              initialValue: find?['year']?.toString() ?? '',
              options: values!['year']!.keys.map((e) => e.toString()).toList(),
              onChanged:
                  (value) => api.changeFind('year', int.tryParse(value ?? '')),
            ),
            AutoSuggestMultiSelect(
              hintText: 'by tags',
              initialValues: find?['tags'] ?? [],
              options: values!['tags']!.keys.toList(),
              onChanged: (value) => api.changeFind('tags', value),
            ),
            AutoSuggestField(
              hintText: 'by make',
              initialValue: find?['model'],
              options: values!['model']!.keys.toList(),
              onChanged: (value) => api.changeFind('model', value),
            ),
            AutoSuggestField(
              hintText: 'by lens',
              initialValue: find?['lens'],
              options: values!['lens']!.keys.toList(),
              onChanged: (value) => api.changeFind('lens', value),
            ),
            // Container(color: Colors.yellow, height: 180),
          ],
        ),
      ),
    );
  }
}
