import 'dart:async';

/// Base class for fake repositories
///
/// Provides common functionality for in-memory repositories
/// used in testing.
///
/// Usage:
/// ```dart
/// class FakeMedicationRepository extends FakeRepositoryBase
///     implements MedicationRepository {
///   final List<Dose> _doses = [];
///
///   @override
///   Stream<List<Dose>> watchDoses() {
///     return watchData<List<Dose>>(() => List.from(_doses));
///   }
/// }
/// ```
abstract class FakeRepositoryBase {
  final _streamControllers = <String, StreamController>{};
  bool _disposed = false;

  /// Watch data changes with a broadcast stream
  ///
  /// [key] - Unique identifier for the stream
  /// [dataGetter] - Function that returns the current data
  Stream<T> watchData<T>(T Function() dataGetter, {String? key}) {
    final streamKey = key ?? T.toString();

    if (!_streamControllers.containsKey(streamKey)) {
      _streamControllers[streamKey] = StreamController<T>.broadcast();
    }

    final controller = _streamControllers[streamKey] as StreamController<T>;

    // Emit initial data
    if (!controller.isClosed) {
      controller.add(dataGetter());
    }

    return controller.stream;
  }

  /// Notify listeners of data change
  ///
  /// [key] - Unique identifier for the stream
  /// [data] - Updated data to emit
  void notifyListeners<T>(T data, {String? key}) {
    if (_disposed) return;

    final streamKey = key ?? T.toString();

    if (_streamControllers.containsKey(streamKey)) {
      final controller = _streamControllers[streamKey] as StreamController<T>;
      if (!controller.isClosed) {
        controller.add(data);
      }
    }
  }

  /// Clean up resources
  void dispose() {
    _disposed = true;
    for (final controller in _streamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _streamControllers.clear();
  }

  /// Check if repository is disposed
  bool get isDisposed => _disposed;
}
