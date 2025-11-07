import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utilities for testing Riverpod providers
///
/// Usage:
/// ```dart
/// test('should fetch data from repository', () async {
///   final container = createContainer(
///     overrides: [
///       medicationRepositoryProvider.overrideWithValue(
///         FakeMedicationRepository(),
///       ),
///     ],
///   );
///
///   final state = await container.read(medicationNotifierProvider.future);
///   expect(state, isNotEmpty);
///
///   container.dispose();
/// });
/// ```

/// Create a ProviderContainer with overrides
ProviderContainer createContainer({
  List<Override> overrides = const [],
  ProviderContainer? parent,
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // Register cleanup
  addTearDown(container.dispose);

  return container;
}

/// Create a ProviderScope for widget tests
ProviderScope createProviderScope({
  required Widget child,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  return ProviderScope(
    overrides: overrides,
    observers: observers,
    child: child,
  );
}

/// Test observer for tracking provider state changes
class TestProviderObserver extends ProviderObserver {
  final List<ProviderListenerEvent> events = [];

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    events.add(ProviderListenerEvent.didAdd(provider, value));
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    events.add(ProviderListenerEvent.didUpdate(provider, previousValue, newValue));
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    events.add(ProviderListenerEvent.didDispose(provider));
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    events.add(ProviderListenerEvent.didFail(provider, error, stackTrace));
  }

  /// Get all update events for a specific provider
  List<ProviderListenerEvent> getUpdatesFor(ProviderBase provider) {
    return events.where((e) => e.provider == provider && e.type == EventType.update).toList();
  }

  /// Get the last value for a specific provider
  Object? getLastValueFor(ProviderBase provider) {
    final updates = getUpdatesFor(provider);
    return updates.isEmpty ? null : updates.last.newValue;
  }

  /// Check if provider was disposed
  bool wasDisposed(ProviderBase provider) {
    return events.any((e) => e.provider == provider && e.type == EventType.dispose);
  }

  /// Clear all recorded events
  void clear() {
    events.clear();
  }
}

/// Event types for provider observer
enum EventType {
  add,
  update,
  dispose,
  fail,
}

/// Provider listener event
class ProviderListenerEvent {
  final ProviderBase provider;
  final EventType type;
  final Object? previousValue;
  final Object? newValue;
  final Object? error;
  final StackTrace? stackTrace;

  ProviderListenerEvent.didAdd(this.provider, this.newValue)
      : type = EventType.add,
        previousValue = null,
        error = null,
        stackTrace = null;

  ProviderListenerEvent.didUpdate(this.provider, this.previousValue, this.newValue)
      : type = EventType.update,
        error = null,
        stackTrace = null;

  ProviderListenerEvent.didDispose(this.provider)
      : type = EventType.dispose,
        previousValue = null,
        newValue = null,
        error = null,
        stackTrace = null;

  ProviderListenerEvent.didFail(this.provider, this.error, this.stackTrace)
      : type = EventType.fail,
        previousValue = null,
        newValue = null;

  @override
  String toString() {
    switch (type) {
      case EventType.add:
        return 'ProviderListenerEvent.didAdd(${provider.runtimeType}, $newValue)';
      case EventType.update:
        return 'ProviderListenerEvent.didUpdate(${provider.runtimeType}, $previousValue -> $newValue)';
      case EventType.dispose:
        return 'ProviderListenerEvent.didDispose(${provider.runtimeType})';
      case EventType.fail:
        return 'ProviderListenerEvent.didFail(${provider.runtimeType}, $error)';
    }
  }
}

/// Wait for an AsyncValue to complete with data
Future<T> waitForAsyncValue<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<T>();

  final subscription = container.listen<AsyncValue<T>>(
    provider,
    (previous, next) {
      if (!completer.isCompleted) {
        next.when(
          data: (data) => completer.complete(data),
          loading: () {},
          error: (error, stack) => completer.completeError(error, stack),
        );
      }
    },
  );

  try {
    return await completer.future.timeout(timeout);
  } finally {
    subscription.close();
  }
}

/// Pump widget with ProviderScope
Future<void> pumpWithProviderScope(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) async {
  await tester.pumpWidget(
    createProviderScope(
      overrides: overrides,
      observers: observers,
      child: widget,
    ),
  );
}
