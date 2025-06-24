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

    return RepositoryProvider(
      create: (context) => AvailableValuesBloc().add(FetchAvailableValues()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AvailableValuesBloc>(
            create: (context) {
              final bloc = AvailableValuesBloc();
              bloc.add(FetchAvailableValues());
              return bloc;
            },
          ),
          BlocProvider<SearchFindBloc>(create: (context) => SearchFindBloc()),
        ],
        child: Container(
          padding: const EdgeInsets.only(left: 16.0),
          color: Theme.of(context).colorScheme.surface,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  (AvailableValuesState().model as Map<String, int>).keys
                      .map<Widget>((model) {
                        return Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            model,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        );
                      })
                      .toList(),
              // children: [
              // AutoSuggestField(
              //   hintText: 'by year',
              //   initialValue: SearchFindState().year.toString(),
              //   options:
              //       AvailableValuesBloc().state.year!.keys
              //           .map((e) => e.toString())
              //           .toList(),
              //   onChanged:
              //       (value) => context.read<SearchFindBloc>().add(
              //         SearchFindChanged('year', int.tryParse(value ?? '')),
              //       ),
              // ),
              // AutoSuggestField(
              //   hintText: 'by month',
              //   initialValue:
              //       AvailableValuesBloc().state.month!.entries
              //           .firstWhere(
              //             (entry) => entry.value == SearchFindState().month,
              //             orElse: () => MapEntry('', 0),
              //           )
              //           .key,
              //   options: AvailableValuesBloc().state.month!.keys.toList(),
              //   onChanged:
              //       (value) => context.read<SearchFindBloc>().add(
              //         SearchFindChanged(
              //           'month',
              //           AvailableValuesBloc().state.month![value ?? ''],
              //         ),
              //       ),
              // ),
              // AutoSuggestMultiSelect(
              //   hintText: 'by tags',
              //   initialValues: SearchFindState().tags,
              //   options: AvailableValuesBloc().state.tags!.keys.toList(),
              //   onChanged:
              //       (value) => context.read<SearchFindBloc>().add(
              //         SearchFindChanged('tags', value),
              //       ),
              // ),
              // AutoSuggestField(
              //   hintText: 'by make',
              //   initialValue: SearchFindState().model,
              //   options: AvailableValuesBloc().state.model!.keys.toList(),
              //   onChanged:
              //       (value) => context.read<SearchFindBloc>().add(
              //         SearchFindChanged('model', value),
              //       ),
              // ),
              // AutoSuggestField(
              //   hintText: 'by lens',
              //   initialValue: SearchFindState().lens,
              //   options: AvailableValuesBloc().state.lens!.keys.toList(),
              //   onChanged:
              //       (value) => context.read<SearchFindBloc>().add(
              //         SearchFindChanged('lens', value),
              //       ),
              // ),
              // AutoSuggestField(
              //   hintText: 'by nick',
              //   initialValue: SearchFindState().nick,
              //   options: AvailableValuesBloc().state.nick!.keys.toList(),
              //   onChanged:
              //       (value) => context.read<SearchFindBloc>().add(
              //         SearchFindChanged('nick', value),
              //       ),
              // ),
              // ],
            ),
          ),
        ),
      ),
    );
  }
}
