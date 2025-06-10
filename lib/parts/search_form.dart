import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/api_provider.dart';
import '../widgets/auto_suggest_field.dart';
import '../widgets/auto_suggest_multi_select.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    // final api = ref.read(myApiProvider);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    // final values = ref.watch(myApiProvider).values;
    // final find = ref.watch(myApiProvider).find;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchFindBloc>(create: (context) => SearchFindBloc()),
        BlocProvider<AvailableValuesCubit>(
          create: (context) => AvailableValuesCubit()..get('Counter'),
        ),
      ],
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
                initialValue: SearchFindBloc().state['year'].toString(),
                options:
                    (AvailableValuesCubit().state?['year']?.keys ?? [])
                        .map((e) => e.toString())
                        .toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('year', int.tryParse(value ?? '')),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by month',
                initialValue:
                    AvailableValuesCubit().state!['month']!.entries
                        .firstWhere(
                          (entry) =>
                              entry.value == SearchFindBloc().state['month'],
                          orElse: () => MapEntry('', 0),
                        )
                        .key,
                options: AvailableValuesCubit().state!['month']!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged(
                        'month',
                        AvailableValuesCubit().state!['month']![value],
                      ),
                    ),
              ),
              AutoSuggestMultiSelect(
                hintText: 'by tags',
                initialValues: SearchFindBloc().state['tags'],
                options: AvailableValuesCubit().state!['tags']!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('tags', value),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by make',
                initialValue: SearchFindBloc().state['model'],
                options: AvailableValuesCubit().state!['model']!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('model', value),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by lens',
                initialValue: SearchFindBloc().state['lens'],
                options: AvailableValuesCubit().state!['lens']!.keys.toList(),
                onChanged:
                    (value) => context.read<SearchFindBloc>().add(
                      SearchFindChanged('lens', value),
                    ),
              ),
              AutoSuggestField(
                hintText: 'by nick',
                initialValue: SearchFindBloc().state['nick'],
                options: AvailableValuesCubit().state!['nick']!.keys.toList(),
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
