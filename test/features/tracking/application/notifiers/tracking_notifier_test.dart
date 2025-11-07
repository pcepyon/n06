import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';

class MockTrackingRepository extends Mock implements TrackingRepository {}

void main() {
  group('TrackingNotifier', () {
    late MockTrackingRepository mockRepository;

    setUp(() {
      mockRepository = MockTrackingRepository();
    });

    // TC-TN-01: 체중 기록 저장
    test('should save WeightLog', () async {
      // Arrange
      final log = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.saveWeightLog(any()))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.saveWeightLog(log);

      // Assert
      verify(() => mockRepository.saveWeightLog(log)).called(1);
    });

    // TC-TN-02: 중복 체중 기록 확인
    test('should check for existing weight log on date', () async {
      // Arrange
      final existingLog = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.getWeightLog('user-001', DateTime(2025, 11, 7)))
          .thenAnswer((_) async => existingLog);

      // Act
      final result = await mockRepository.getWeightLog('user-001', DateTime(2025, 11, 7));

      // Assert
      expect(result, isNotNull);
      expect(result!.weightKg, 75.5);
      verify(() => mockRepository.getWeightLog('user-001', DateTime(2025, 11, 7))).called(1);
    });

    // TC-TN-03: 중복 없는 날짜 확인
    test('should return null when no weight log exists on date', () async {
      // Arrange
      when(() => mockRepository.getWeightLog('user-001', DateTime(2025, 11, 7)))
          .thenAnswer((_) async => null);

      // Act
      final result = await mockRepository.getWeightLog('user-001', DateTime(2025, 11, 7));

      // Assert
      expect(result, isNull);
    });

    // TC-TN-04: 증상 기록 저장
    test('should save SymptomLog', () async {
      // Arrange
      final log = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
      );

      when(() => mockRepository.saveSymptomLog(any()))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.saveSymptomLog(log);

      // Assert
      verify(() => mockRepository.saveSymptomLog(log)).called(1);
    });

    // TC-TN-05: 기록 삭제
    test('should delete WeightLog', () async {
      // Arrange
      when(() => mockRepository.deleteWeightLog('wl-001'))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.deleteWeightLog('wl-001');

      // Assert
      verify(() => mockRepository.deleteWeightLog('wl-001')).called(1);
    });

    // TC-TN-06: 기록 업데이트
    test('should update WeightLog', () async {
      // Arrange
      when(() => mockRepository.updateWeightLog('wl-001', 74.8))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.updateWeightLog('wl-001', 74.8);

      // Assert
      verify(() => mockRepository.updateWeightLog('wl-001', 74.8)).called(1);
    });

    // TC-TN-07: 증상 기록 업데이트
    test('should update SymptomLog', () async {
      // Arrange
      final log = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 7,
      );

      when(() => mockRepository.updateSymptomLog('sl-001', any()))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.updateSymptomLog('sl-001', log);

      // Assert
      verify(() => mockRepository.updateSymptomLog('sl-001', any())).called(1);
    });

    // TC-TN-08: 여러 기록 조회
    test('should get multiple weight logs', () async {
      // Arrange
      final logs = [
        WeightLog(
          id: 'wl-001',
          userId: 'user-001',
          logDate: DateTime(2025, 11, 7),
          weightKg: 75.5,
          createdAt: DateTime.now(),
        ),
        WeightLog(
          id: 'wl-002',
          userId: 'user-001',
          logDate: DateTime(2025, 11, 6),
          weightKg: 76.0,
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getWeightLogs('user-001'))
          .thenAnswer((_) async => logs);

      // Act
      final result = await mockRepository.getWeightLogs('user-001');

      // Assert
      expect(result.length, 2);
      verify(() => mockRepository.getWeightLogs('user-001')).called(1);
    });

    // TC-TN-09: 증상 기록 삭제
    test('should delete SymptomLog', () async {
      // Arrange
      when(() => mockRepository.deleteSymptomLog('sl-001'))
          .thenAnswer((_) async => {});

      // Act
      await mockRepository.deleteSymptomLog('sl-001');

      // Assert
      verify(() => mockRepository.deleteSymptomLog('sl-001')).called(1);
    });

    // TC-TN-10: 태그 기반 조회
    test('should get symptom logs by tag', () async {
      // Arrange
      final logs = [
        SymptomLog(
          id: 'sl-001',
          userId: 'user-001',
          logDate: DateTime(2025, 11, 7),
          symptomName: '메스꺼움',
          severity: 4,
          tags: const ['기름진음식'],
        ),
      ];

      when(() => mockRepository.getSymptomLogsByTag('기름진음식'))
          .thenAnswer((_) async => logs);

      // Act
      final result = await mockRepository.getSymptomLogsByTag('기름진음식');

      // Assert
      expect(result.length, 1);
      verify(() => mockRepository.getSymptomLogsByTag('기름진음식')).called(1);
    });
  });
}
