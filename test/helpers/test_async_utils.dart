import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utilities for testing asynchronous code with fake timers
///
/// Example usage:
/// ```dart
/// test('should retry 3 times', () {
///   testWithFakeAsync((async) {
///     var count = 0;
///
///     Future<void> retry() async {
///       for (var i = 0; i < 3; i++) {
///         count++;
///         await Future.delayed(Duration(seconds: 1));
///       }
///     }
///
///     retry();
///     async.elapse(Duration(seconds: 3));
///
///     expect(count, 3);
///   });
/// });
/// ```

/// Test function with fake async wrapper
void testWithFakeAsync(
  void Function(FakeAsync async) testBody, {
  Duration? initialTime,
}) {
  fakeAsync((async) {
    if (initialTime != null) {
      async.elapse(initialTime);
    }
    testBody(async);
  });
}

/// Elapse time and pump frames in widget tests
Future<void> pumpAndElapse(
  WidgetTester tester,
  Duration duration, {
  Duration? pumpDuration,
}) async {
  final pump = pumpDuration ?? const Duration(milliseconds: 100);
  final iterations = duration.inMilliseconds ~/ pump.inMilliseconds;

  for (var i = 0; i < iterations; i++) {
    await tester.pump(pump);
  }
}

/// Wait for a condition with timeout
Future<void> waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration pollInterval = const Duration(milliseconds: 100),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (!condition()) {
    if (DateTime.now().isAfter(endTime)) {
      throw TimeoutException(
        'Condition not met within $timeout',
        timeout,
      );
    }
    await Future.delayed(pollInterval);
  }
}

/// Wait for a stream to emit a specific value
Future<T> waitForStreamValue<T>(
  Stream<T> stream, {
  bool Function(T value)? condition,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<T>();
  late StreamSubscription<T> subscription;

  final timer = Timer(timeout, () {
    if (!completer.isCompleted) {
      subscription.cancel();
      completer.completeError(
        TimeoutException(
          'Stream did not emit expected value within $timeout',
          timeout,
        ),
      );
    }
  });

  subscription = stream.listen((value) {
    if (condition == null || condition(value)) {
      if (!completer.isCompleted) {
        timer.cancel();
        subscription.cancel();
        completer.complete(value);
      }
    }
  });

  return completer.future;
}

/// Retry a future with exponential backoff
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 100),
  double backoffMultiplier = 2.0,
}) async {
  var attempt = 0;
  var delay = initialDelay;

  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts) {
        rethrow;
      }
      await Future.delayed(delay);
      delay *= backoffMultiplier;
    }
  }
}
