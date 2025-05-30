import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';

class SearchForm extends ConsumerWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(myApiProvider);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final values = ref.watch(myApiProvider).values;
    final find = ref.watch(myApiProvider).find;

    return Container(
      padding: const EdgeInsets.only(left: 16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSuggestField(
              hintText: 'by year',
              initialValue: find?['year']?.toString() ?? '',
              options: values!['year']!.keys.map((e) => e.toString()).toList(),
              onChanged:
                  (value) => api.changeFind('year', int.tryParse(value ?? '')),
            ),
            AutoSuggestField(
              hintText: 'by month',
              initialValue:
                  values['month']!.entries
                      .firstWhere(
                        (entry) => entry.value == find?['month'],
                        orElse: () => MapEntry('', 0),
                      )
                      .key,
              options: values['month']!.keys.toList(),
              onChanged:
                  (value) => api.changeFind('month', values['month']![value]),
            ),
            AutoSuggestMultiSelect(
              hintText: 'by tags',
              initialValues: find?['tags'] ?? [],
              options: values['tags']!.keys.toList(),
              onChanged: (value) => api.changeFind('tags', value),
            ),
            AutoSuggestField(
              hintText: 'by make',
              initialValue: find?['model'],
              options: values['model']!.keys.toList(),
              onChanged: (value) => api.changeFind('model', value),
            ),
            AutoSuggestField(
              hintText: 'by lens',
              initialValue: find?['lens'],
              options: values['lens']!.keys.toList(),
              onChanged: (value) => api.changeFind('lens', value),
            ),
            AutoSuggestField(
              hintText: 'by nick',
              initialValue: find?['nick'],
              options: values['nick']!.keys.toList(),
              onChanged: (value) => api.changeFind('nick', value),
            ),
            // Container(color: Colors.yellow, height: 180),
          ],
        ),
      ),
    );
  }
}
