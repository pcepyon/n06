import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:n06/features/coping_guide/domain/entities/guide_feedback.dart';
import 'package:n06/features/coping_guide/infrastructure/dtos/guide_feedback_dto.dart';
import 'package:n06/features/coping_guide/infrastructure/repositories/isar_feedback_repository.dart';

void main() {
  group('IsarFeedbackRepository', () {
    late Isar isar;
    late IsarFeedbackRepository repository;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      final dir = Directory.systemTemp.createTempSync('isar_test_');
      isar = await Isar.open(
        [GuideFeedbackDtoSchema],
        directory: dir.path,
        name: 'test_feedback_${DateTime.now().millisecondsSinceEpoch}',
      );
      repository = IsarFeedbackRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('피드백 저장 성공', () async {
      // Arrange
      final feedback = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: true,
        timestamp: DateTime.now(),
      );

      // Act
      await repository.saveFeedback(feedback);

      // Assert
      final saved = await repository.getFeedbacksBySymptom('메스꺼움');
      expect(saved.length, 1);
      expect(saved.first.symptomName, '메스꺼움');
      expect(saved.first.helpful, isTrue);
    });

    test('증상별 피드백 조회', () async {
      // Arrange
      final feedback1 = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: true,
        timestamp: DateTime.now(),
      );
      final feedback2 = GuideFeedback(
        symptomName: '구토',
        helpful: false,
        timestamp: DateTime.now(),
      );
      await repository.saveFeedback(feedback1);
      await repository.saveFeedback(feedback2);

      // Act
      final result = await repository.getFeedbacksBySymptom('메스꺼움');

      // Assert
      expect(result.length, 1);
      expect(result.first.symptomName, '메스꺼움');
    });

    test('같은 증상 여러 피드백 저장', () async {
      // Arrange
      final feedback1 = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: true,
        timestamp: DateTime.now(),
      );
      final feedback2 = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: false,
        timestamp: DateTime.now().add(Duration(hours: 1)),
      );

      // Act
      await repository.saveFeedback(feedback1);
      await repository.saveFeedback(feedback2);

      // Assert
      final result = await repository.getFeedbacksBySymptom('메스꺼움');
      expect(result.length, 2);
    });

    test('등록되지 않은 증상은 빈 리스트 반환', () async {
      // Act
      final result = await repository.getFeedbacksBySymptom('알 수 없는 증상');

      // Assert
      expect(result, isEmpty);
    });
  });
}
