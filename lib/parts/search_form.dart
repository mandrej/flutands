import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_provider.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    ApiProvider api = Provider.of<ApiProvider>(context, listen: false);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CompleteAuto(
            label: 'search_by_year',
            options: api.values!['year']!.keys.map((i) => i.toString()),
            initialValue: api.find!['year']?.toString() ?? '',
            action: (String value) {
              api.changeFind('year', int.tryParse(value));
            },
          ),
          CompleteAuto(
            label: 'search by month',
            options: [
              1,
              2,
              3,
              4,
              5,
              6,
              7,
              8,
              9,
              10,
              11,
              12,
            ].map((i) => i.toString()),
            initialValue: api.find?['month']?.toString() ?? '',
            action: (String value) {
              api.changeFind('month', int.tryParse(value));
            },
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

class CompleteAuto extends StatelessWidget {
  const CompleteAuto({
    super.key,
    required this.label,
    required this.options,
    required this.initialValue,
    required this.action,
  });
  final String label;
  final Iterable<String> options;
  final String initialValue;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      key: Key(label),
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(labelText: label),
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
            action(value);
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(title: Text(option)),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
