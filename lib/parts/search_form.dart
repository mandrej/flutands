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
          TextField(
            decoration: InputDecoration(labelText: 'search by year'),
            controller: TextEditingController(
              text: api.find!['year'].toString(),
            ),
            onChanged: (value) {
              api.changeFind('year', int.tryParse(value) ?? 0);
              // print(api.find?['year']);
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'search by tags'),
            onChanged: (value) {
              // Handle search by tags
            },
          ),
        ],
      ),
    );
  }
}
