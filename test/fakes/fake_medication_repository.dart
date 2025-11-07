import 'dart:async';
import 'fake_repository_base.dart';

// TODO: Import actual domain interfaces when they are created
// import 'package:n06/features/tracking/domain/repositories/medication_repository.dart';
// import 'package:n06/features/tracking/domain/entities/dose.dart';

/// Fake implementation of MedicationRepository for testing
///
/// This is a template. Update with actual interface when domain layer is implemented.
///
/// Example usage:
/// ```dart
/// test('should save dose', () async {
///   final repo = FakeMedicationRepository();
///   final dose = Dose(id: 1, doseMg: 0.25, administeredAt: DateTime.now());
///
///   await repo.saveDose(dose);
///
///   expect(await repo.watchDoses().first, contains(dose));
///   repo.dispose();
/// });
/// ```
class FakeMedicationRepository extends FakeRepositoryBase {
  // In-memory storage
  final List<Map<String, dynamic>> _doses = [];
  final List<Map<String, dynamic>> _schedules = [];

  // Simulated errors for testing
  Exception? _nextException;
  bool _shouldDelayOperations = false;
  Duration _operationDelay = const Duration(milliseconds: 100);

  /// Get all doses
  Future<List<Map<String, dynamic>>> getDoses() async {
    _checkException();
    await _simulateDelay();
    return List.from(_doses);
  }

  /// Watch doses as a stream
  Stream<List<Map<String, dynamic>>> watchDoses() {
    return watchData<List<Map<String, dynamic>>>(
      () => List.from(_doses),
      key: 'doses',
    );
  }

  /// Save a new dose
  Future<void> saveDose(Map<String, dynamic> dose) async {
    _checkException();
    await _simulateDelay();

    _doses.add(dose);
    notifyListeners<List<Map<String, dynamic>>>(
      List.from(_doses),
      key: 'doses',
    );
  }

  /// Delete a dose by id
  Future<void> deleteDose(int id) async {
    _checkException();
    await _simulateDelay();

    _doses.removeWhere((dose) => dose['id'] == id);
    notifyListeners<List<Map<String, dynamic>>>(
      List.from(_doses),
      key: 'doses',
    );
  }

  /// Get all schedules
  Future<List<Map<String, dynamic>>> getSchedules() async {
    _checkException();
    await _simulateDelay();
    return List.from(_schedules);
  }

  /// Save schedules
  Future<void> saveSchedules(List<Map<String, dynamic>> schedules) async {
    _checkException();
    await _simulateDelay();

    _schedules.clear();
    _schedules.addAll(schedules);
  }

  /// Clear all data
  void clear() {
    _doses.clear();
    _schedules.clear();
    notifyListeners<List<Map<String, dynamic>>>([], key: 'doses');
  }

  // Test utilities

  /// Simulate an exception on next operation
  void throwOnNextOperation(Exception exception) {
    _nextException = exception;
  }

  /// Enable operation delays (for testing loading states)
  void enableDelays({Duration? delay}) {
    _shouldDelayOperations = true;
    if (delay != null) {
      _operationDelay = delay;
    }
  }

  /// Disable operation delays
  void disableDelays() {
    _shouldDelayOperations = false;
  }

  void _checkException() {
    if (_nextException != null) {
      final exception = _nextException!;
      _nextException = null;
      throw exception;
    }
  }

  Future<void> _simulateDelay() async {
    if (_shouldDelayOperations) {
      await Future.delayed(_operationDelay);
    }
  }
}
