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
///   // For AsyncNotifier providers, use .future to get the value
///   final data = await container.read(someAsyncNotifierProvider.future);
///   expect(data, isNotNull);
///
///   container.dispose();
/// });
/// ```

/// Create a ProviderContainer with overrides
ProviderContainer createContainer({
  dynamic overrides,
  ProviderContainer? parent,
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides ?? [],
    observers: observers,
  );

  // Register cleanup
  addTearDown(container.dispose);

  return container;
}

/// Create a ProviderScope for widget tests
ProviderScope createProviderScope({
  required Widget child,
  dynamic overrides,
  List<ProviderObserver>? observers,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    observers: observers,
    child: child,
  );
}

/// Test observer for tracking provider state changes
final class TestProviderObserver extends ProviderObserver {
  final List<ProviderListenerEvent> events = [];

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    events.add(ProviderListenerEvent.didAdd(context, value));
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    events.add(ProviderListenerEvent.didUpdate(context, previousValue, newValue));
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    events.add(ProviderListenerEvent.didDispose(context));
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    events.add(ProviderListenerEvent.didFail(context, error, stackTrace));
  }

  /// Get all update events for a specific provider name
  List<ProviderListenerEvent> getUpdatesFor(String providerName) {
    return events.where((e) => e.providerName == providerName && e.type == EventType.update).toList();
  }

  /// Get the last value for a specific provider name
  Object? getLastValueFor(String providerName) {
    final updates = getUpdatesFor(providerName);
    return updates.isEmpty ? null : updates.last.newValue;
  }

  /// Check if provider was disposed
  bool wasDisposed(String providerName) {
    return events.any((e) => e.providerName == providerName && e.type == EventType.dispose);
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
  final String providerName;
  final EventType type;
  final Object? previousValue;
  final Object? newValue;
  final Object? error;
  final StackTrace? stackTrace;

  ProviderListenerEvent.didAdd(ProviderObserverContext context, this.newValue)
      : providerName = context.provider.toString(),
        type = EventType.add,
        previousValue = null,
        error = null,
        stackTrace = null;

  ProviderListenerEvent.didUpdate(ProviderObserverContext context, this.previousValue, this.newValue)
      : providerName = context.provider.toString(),
        type = EventType.update,
        error = null,
        stackTrace = null;

  ProviderListenerEvent.didDispose(ProviderObserverContext context)
      : providerName = context.provider.toString(),
        type = EventType.dispose,
        previousValue = null,
        newValue = null,
        error = null,
        stackTrace = null;

  ProviderListenerEvent.didFail(ProviderObserverContext context, this.error, this.stackTrace)
      : providerName = context.provider.toString(),
        type = EventType.fail,
        previousValue = null,
        newValue = null;

  @override
  String toString() {
    switch (type) {
      case EventType.add:
        return 'ProviderListenerEvent.didAdd($providerName, $newValue)';
      case EventType.update:
        return 'ProviderListenerEvent.didUpdate($providerName, $previousValue -> $newValue)';
      case EventType.dispose:
        return 'ProviderListenerEvent.didDispose($providerName)';
      case EventType.fail:
        return 'ProviderListenerEvent.didFail($providerName, $error)';
    }
  }
}

/// Wait for an AsyncValue to complete with data
Future<T> waitForAsyncValue<T>(
  ProviderContainer container,
  dynamic provider, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<T>();

  final subscription = container.listen(
    provider,
    (previous, next) {
      if (!completer.isCompleted && next is AsyncValue<T>) {
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
  dynamic overrides,
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
