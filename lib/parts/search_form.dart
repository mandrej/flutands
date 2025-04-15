import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_provider.dart';
import 'multi_auto_suggest_dropdown.dart';

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
            MultiAutoSuggestDropdown(
              hintText: 'Select tags',
              selected: api.find?['tags'] ?? [],
              suggestions: api.values!['tags']!.keys.toList(),
              onSelectionChanged: (value) => api.changeFind('tags', value),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
