import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/available_values.dart';
import '../bloc/search_find.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final values = context.watch<AvailableValuesState>();

    return BlocProvider(
      create: (context) => SearchFindBloc(),
      child: Container(
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
                initialValue: SearchFindState().year.toString(),
                options: values.year!.keys.map((e) => e.toString()).toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('year', int.tryParse(value ?? '')),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by month',
                initialValue:
                    values.month!.entries
                        .firstWhere(
                          (entry) => entry.value == SearchFindState().month,
                          orElse: () => MapEntry('', 0),
                        )
                        .key,
                options: values.month!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('month', values.month![value ?? '']),
                    ),
              ),
              AutoSuggestMultiSelect(
                hintText: 'by tags',
                initialValues: SearchFindState().tags,
                options: values.tags!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('tags', value),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by make',
                initialValue: SearchFindState().model,
                options: values.model!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('model', value),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by lens',
                initialValue: SearchFindState().lens,
                options: values.lens!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('lens', value),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by nick',
                initialValue: SearchFindState().nick,
                options: values.nick!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('nick', value),
                    ),
              ),
              Container(color: Colors.yellow, height: 180),
            ],
          ),
        ),
      ),
    );
  }
}
