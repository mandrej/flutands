import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';

class SearchForm extends StatefulWidget {
  SearchForm({super.key});

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
              initialValue: api.find?['year']?.toString() ?? '',
              options:
                  api.values!['year']!.keys.map((e) => e.toString()).toList(),
              onChanged:
                  (value) => api.changeFind('year', int.tryParse(value ?? '')),
            ),
            AutoSuggestMultiSelect(
              hintText: 'filter by tags',
              initialValues: api.find?['tags'] ?? [],
              options: api.values!['tags']!.keys.toList(),
              onChanged: (value) => api.changeFind('tags', value),
            ),
            AutoSuggestField(
              hintText: 'filter by model',
              initialValue: api.find?['model'],
              options: api.values!['model']!.keys.toList(),
              onChanged: (value) => api.changeFind('model', value),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
