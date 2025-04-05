import 'package:flutter/material.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'search by year'),
            onChanged: (value) {
              // Handle search by text
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
