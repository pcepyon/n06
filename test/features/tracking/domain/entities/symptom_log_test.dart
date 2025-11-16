import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

void main() {
  group('SymptomLog Entity', () {
    // TC-SL-01: 정상 생성 (경증, 심각도 1-6점)
    test('should create SymptomLog with severity 1-6', () {
      // Arrange & Act
      final symptomLog = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
        daysSinceEscalation: 3,
        tags: const ['기름진음식', '과식'],
      );

      // Assert
      expect(symptomLog.severity, 4);
      expect(symptomLog.isPersistent24h, isNull);
      expect(symptomLog.tags.length, 2);
    });

    // TC-SL-02: 중증 생성 (심각도 7-10점, 24시간 지속)
    test('should create SymptomLog with severity 7-10 and persistent flag', () {
      // Arrange & Act
      final symptomLog = SymptomLog(
        id: 'sl-002',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '구토',
        severity: 9,
        daysSinceEscalation: 5,
        isPersistent24h: true,
      );

      // Assert
      expect(symptomLog.severity, 9);
      expect(symptomLog.isPersistent24h, isTrue);
    });

    // TC-SL-04: 경과일 미계산 (증량 이력 없음)
    test('should allow null daysSinceEscalation', () {
      // Arrange & Act
      final symptomLog = SymptomLog(
        id: 'sl-004',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '복통',
        severity: 3,
        daysSinceEscalation: null,
      );

      // Assert
      expect(symptomLog.daysSinceEscalation, isNull);
    });

    // TC-SL-05: copyWith 정상 동작
    test('should copy SymptomLog with updated severity', () {
      // Arrange
      final original = SymptomLog(
        id: 'sl-005',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
      );

      // Act
      final updated = original.copyWith(severity: 7, isPersistent24h: true);

      // Assert
      expect(updated.severity, 7);
      expect(updated.isPersistent24h, isTrue);
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
    });

    // TC-SL-06: Equality 비교
    test('should compare two SymptomLog entities correctly', () {
      // Arrange
      final now = DateTime.now();
      final log1 = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
        createdAt: now,
      );
      final log2 = SymptomLog(
        id: 'sl-001',
        userId: 'user-001',
        logDate: DateTime(2025, 11, 7),
        symptomName: '메스꺼움',
        severity: 4,
        createdAt: now,
      );

      // Act & Assert
      expect(log1 == log2, isTrue);
    });

    // TC-SL-07: 기본 태그 빈 리스트
    test('should have empty tags by default', () {
      // Arrange & Act
      final symptomLog = SymptomLog(
        id: 'sl-007',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '두통',
        severity: 5,
      );

      // Assert
      expect(symptomLog.tags, isEmpty);
    });

    // TC-SL-08: toString 메서드 존재
    test('should have toString method', () {
      // Arrange
      final log = SymptomLog(
        id: 'sl-008',
        userId: 'user-001',
        logDate: DateTime.now(),
        symptomName: '피로',
        severity: 3,
      );

      // Act
      final str = log.toString();

      // Assert
      expect(str, isNotEmpty);
      expect(str, contains('SymptomLog'));
    });
  });
}
