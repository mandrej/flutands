import 'package:flutter/material.dart';

class MultiAutoSuggestDropdown extends StatefulWidget {
  final List<String> suggestions;
  final List<String> selected;
  final String hintText;
  final void Function(List<String>) onSelectionChanged;

  const MultiAutoSuggestDropdown({
    super.key,
    required this.suggestions,
    required this.onSelectionChanged,
    this.selected = const [],
    this.hintText = 'Select items',
  });

  @override
  _MultiAutoSuggestDropdownState createState() =>
      _MultiAutoSuggestDropdownState();
}

class _MultiAutoSuggestDropdownState extends State<MultiAutoSuggestDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  late List<String> _selectedItems = widget.selected;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      _filteredSuggestions =
          widget.suggestions
              .where(
                (item) =>
                    item.toLowerCase().contains(query) &&
                    !_selectedItems.contains(item),
              )
              .toList();
    });
  }

  void _addItem(String item) {
    if (!_selectedItems.contains(item)) {
      setState(() {
        _selectedItems.add(item);
        _controller.clear();
        _filteredSuggestions.clear();
      });
      widget.onSelectionChanged(_selectedItems);
    }
  }

  void _removeItem(String item) {
    setState(() {
      _selectedItems.remove(item);
    });
    widget.onSelectionChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              _selectedItems.map((item) {
                return Chip(
                  label: Text(item),
                  onDeleted: () => _removeItem(item),
                );
              }).toList(),
        ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(hintText: widget.hintText),
        ),
        if (_filteredSuggestions.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: 150),
            child: ListView(
              shrinkWrap: true,
              children:
                  _filteredSuggestions.map((item) {
                    return ListTile(
                      title: Text(item),
                      onTap: () => _addItem(item),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
