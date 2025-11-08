import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/infrastructure/dtos/weight_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_log_dto.dart';
import 'package:n06/features/tracking/infrastructure/dtos/symptom_context_tag_dto.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_tracking_repository.dart';

void main() {
  group('IsarTrackingRepository', () {
    late Isar isar;
    late IsarTrackingRepository repository;

    setUp(() async {
      final tempDir = await getTemporaryDirectory();
      // In-memory Isar instance for testing
      isar = await Isar.open(
        [
          WeightLogDtoSchema,
          SymptomLogDtoSchema,
          SymptomContextTagDtoSchema,
        ],
        directory: tempDir.path,
      );
      repository = IsarTrackingRepository(isar);
    });

    tearDown(() async {
      await isar.close();
    });

    // TC-ITR-01: 체중 기록 저장
    test('should save WeightLog to Isar', () async {
      // Arrange
      final log = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );

      // Act
      await repository.saveWeightLog(log);

      // Assert
      final saved = await repository.getWeightLog(log.userId, log.logDate);
      expect(saved, isNotNull);
      expect(saved!.weightKg, log.weightKg);
      expect(saved.userId, log.userId);
    });

    // TC-ITR-02: 체중 중복 기록 (덮어쓰기)
    test('should overwrite duplicate WeightLog', () async {
      // Arrange
      final log1 = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );
      final log2 = WeightLog(
        id: 'wl-002',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7), // 같은 날짜
        weightKg: 74.8,
        createdAt: DateTime.now(),
      );

      // Act
      await repository.saveWeightLog(log1);
      await repository.saveWeightLog(log2);

      // Assert
      final saved = await repository.getWeightLog(log1.userId, log1.logDate);
      expect(saved!.weightKg, 74.8); // 덮어쓰기 확인
    });

    // TC-ITR-03: 증상 기록 저장
    test('should save SymptomLog to Isar', () async {
      // Arrange
      final log = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
        tags: const ['기름진음식', '과식'],
      );

      // Act
      await repository.saveSymptomLog(log);

      // Assert
      final saved = await repository.getSymptomLogs(log.userId);
      expect(saved, isNotEmpty);
      expect(saved.first.symptomName, log.symptomName);
      expect(saved.first.tags, log.tags);
    });

    // TC-ITR-04: 증상 기록 조회 (날짜 범위)
    test('should get SymptomLogs in date range', () async {
      // Arrange
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 1),
        symptomName: '메스꺼움',
        severity: 4,
      ));
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-002',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '구토',
        severity: 5,
      ));
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-003',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 15),
        symptomName: '복통',
        severity: 3,
      ));

      // Act
      final logs = await repository.getSymptomLogs(
        'user-001',
        startDate: DateTime(2025, 11, 5),
        endDate: DateTime(2025, 11, 10),
      );

      // Assert
      expect(logs.length, 1); // 11월 7일만 포함
      expect(logs.first.symptomName, '구토');
    });

    // TC-ITR-05: 체중 기록 삭제
    test('should delete WeightLog', () async {
      // Arrange
      final log = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );
      await repository.saveWeightLog(log);

      // Act
      await repository.deleteWeightLog(log.id);

      // Assert
      final deleted = await repository.getWeightLog(log.userId, log.logDate);
      expect(deleted, isNull);
    });

    // TC-ITR-06: 증상 기록 삭제
    test('should delete SymptomLog', () async {
      // Arrange
      final log = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
      );
      await repository.saveSymptomLog(log);

      // Act
      await repository.deleteSymptomLog(log.id);

      // Assert
      final allLogs = await repository.getSymptomLogs('user-001');
      expect(allLogs.isEmpty, isTrue);
    });

    // TC-ITR-07: 체중 기록 업데이트
    test('should update WeightLog', () async {
      // Arrange
      final log = WeightLog(
        id: 'wl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        weightKg: 75.5,
        createdAt: DateTime.now(),
      );
      await repository.saveWeightLog(log);

      // Act
      await repository.updateWeightLog(log.id, 74.8);

      // Assert
      final updated = await repository.getWeightLog(log.userId, log.logDate);
      expect(updated!.weightKg, 74.8);
    });

    // TC-ITR-08: 증상 기록 업데이트
    test('should update SymptomLog', () async {
      // Arrange
      final log = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
      );
      await repository.saveSymptomLog(log);
      final updated = log.copyWith(severity: 7);

      // Act
      await repository.updateSymptomLog(log.id, updated);

      // Assert
      final result = await repository.getSymptomLogs('user-001');
      expect(result.first.severity, 7);
    });

    // TC-ITR-09: 태그 기반 조회
    test('should get symptom logs by tag', () async {
      // Arrange
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '메스꺼움',
        severity: 4,
        tags: const ['기름진음식'],
      ));
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-002',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '메스꺼움',
        severity: 4,
        tags: const ['기름진음식'],
      ));
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-003',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '복통',
        severity: 3,
        tags: const ['과식'],
      ));

      // Act
      final logs = await repository.getSymptomLogsByTag('기름진음식');

      // Assert
      expect(logs.length, 2);
    });

    // TC-ITR-10: 모든 태그 조회
    test('should get all tags for user', () async {
      // Arrange
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '메스꺼움',
        severity: 4,
        tags: const ['기름진음식', '과식'],
      ));
      await repository.saveSymptomLog(SymptomLog(
        id: 'sl-002',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '복통',
        severity: 3,
        tags: const ['스트레스'],
      ));

      // Act
      final tags = await repository.getAllTags('user-001');

      // Assert
      expect(tags, containsAll(['기름진음식', '과식', '스트레스']));
    });
  });
}
