import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/infrastructure/dtos/emergency_symptom_check_dto.dart';
import 'package:n06/features/tracking/infrastructure/repositories/isar_emergency_check_repository.dart';

void main() {
  group('IsarEmergencyCheckRepository Integration', () {
    late Isar isar;
    late IsarEmergencyCheckRepository repository;

    setUp(() async {
      isar = await Isar.open(
        [EmergencySymptomCheckDtoSchema],
        directory: '',
        name: 'test_emergency_check_${DateTime.now().millisecondsSinceEpoch}',
      );
      repository = IsarEmergencyCheckRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('증상 체크 저장 시, DB에 정상 저장', () async {
      // Arrange
      final check = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 1),
        checkedSymptoms: ['증상1'],
      );

      // Act
      await repository.saveEmergencyCheck(check);

      // Assert
      final saved = await isar.emergencySymptomCheckDtos.where().findAll();
      expect(saved.length, 1);
      expect(saved.first.userId, 'user-123');
    });

    test('사용자별 증상 체크 조회 시, 해당 사용자 데이터만 반환', () async {
      // Arrange
      final check1 = EmergencySymptomCheck(
        id: '1',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 1),
        checkedSymptoms: ['증상1'],
      );
      final check2 = EmergencySymptomCheck(
        id: '2',
        userId: 'user-456',
        checkedAt: DateTime(2025, 1, 2),
        checkedSymptoms: ['증상2'],
      );
      await repository.saveEmergencyCheck(check1);
      await repository.saveEmergencyCheck(check2);

      // Act
      final result = await repository.getEmergencyChecks('user-123');

      // Assert
      expect(result.length, 1);
      expect(result.first.userId, 'user-123');
    });

    test('증상 체크 삭제 시, DB에서 제거', () async {
      // Arrange
      final check = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: ['증상1'],
      );
      await repository.saveEmergencyCheck(check);

      // Act
      final saved = await isar.emergencySymptomCheckDtos.where().findAll();
      final dtoId = saved.first.id;
      await repository.deleteEmergencyCheck(dtoId.toString());

      // Assert
      final remaining = await isar.emergencySymptomCheckDtos.where().findAll();
      expect(remaining, isEmpty);
    });

    test('최근 체크 순서로 정렬 조회', () async {
      // Arrange
      final check1 = EmergencySymptomCheck(
        id: '1',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 1),
        checkedSymptoms: ['증상1'],
      );
      final check2 = EmergencySymptomCheck(
        id: '2',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 3),
        checkedSymptoms: ['증상2'],
      );
      final check3 = EmergencySymptomCheck(
        id: '3',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 2),
        checkedSymptoms: ['증상3'],
      );
      await repository.saveEmergencyCheck(check1);
      await repository.saveEmergencyCheck(check2);
      await repository.saveEmergencyCheck(check3);

      // Act
      final result = await repository.getEmergencyChecks('user-123');

      // Assert
      expect(result.length, 3);
      expect(result[0].checkedAt, DateTime(2025, 1, 3)); // 최신순
      expect(result[1].checkedAt, DateTime(2025, 1, 2));
      expect(result[2].checkedAt, DateTime(2025, 1, 1));
    });

    test('존재하지 않는 ID 삭제 시, 예외 발생하지 않음', () async {
      // Act & Assert
      expect(
        () => repository.deleteEmergencyCheck('non-existent'),
        returnsNormally,
      );
    });

    test('증상 체크 수정 시, DB에 업데이트', () async {
      // Arrange
      final check = EmergencySymptomCheck(
        id: 'test-id',
        userId: 'user-123',
        checkedAt: DateTime.now(),
        checkedSymptoms: ['증상1'],
      );
      await repository.saveEmergencyCheck(check);

      // 저장된 DTO의 ID 가져오기
      final saved = await isar.emergencySymptomCheckDtos.where().findAll();
      final dtoId = saved.first.id;

      // Act
      final updated = EmergencySymptomCheck(
        id: dtoId.toString(),
        userId: check.userId,
        checkedAt: check.checkedAt,
        checkedSymptoms: ['새로운 증상'],
      );
      await repository.updateEmergencyCheck(updated);

      // Assert
      final result = await repository.getEmergencyChecks(check.userId);
      expect(result.first.checkedSymptoms, ['새로운 증상']);
    });

    test('같은 증상 반복 체크 시, 별도 기록으로 저장', () async {
      // Arrange
      final check1 = EmergencySymptomCheck(
        id: '1',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 1, 10, 0),
        checkedSymptoms: ['24시간 이상 계속 구토'],
      );
      final check2 = EmergencySymptomCheck(
        id: '2',
        userId: 'user-123',
        checkedAt: DateTime(2025, 1, 1, 14, 0), // 4시간 후
        checkedSymptoms: ['24시간 이상 계속 구토'], // 같은 증상
      );

      // Act
      await repository.saveEmergencyCheck(check1);
      await repository.saveEmergencyCheck(check2);

      // Assert
      final result = await repository.getEmergencyChecks('user-123');
      expect(result.length, 2); // 별도 기록
      expect(result[0].checkedAt, DateTime(2025, 1, 1, 14, 0)); // 최신순
      expect(result[1].checkedAt, DateTime(2025, 1, 1, 10, 0));
    });
  });
}
