import 'package:flutter_riverpod/flutter_riverpod.dart';

class Logger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    print(
      'Provider ${provider.name ?? provider.runtimeType} was initialized with $value',
    );
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    print('Provider ${provider.name ?? provider.runtimeType} was disposed');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print(
      'Provider ${provider.name ?? provider.runtimeType} updated from $previousValue to $newValue',
    );
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    print(
      'Provider ${provider.name ?? provider.runtimeType} threw $error at $stackTrace',
    );
  }
}
