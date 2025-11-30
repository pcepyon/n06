import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/coping_guide/application/notifiers/coping_guide_notifier.dart';
import 'package:n06/features/coping_guide/application/providers.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/coping_guide/domain/entities/guide_feedback.dart';
import 'package:n06/features/coping_guide/domain/repositories/coping_guide_repository.dart';
import 'package:n06/features/coping_guide/domain/repositories/feedback_repository.dart';

class MockCopingGuideRepository extends Mock implements CopingGuideRepository {}

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

class FakeGuideFeedback extends Fake implements GuideFeedback {
  @override
  final String symptomName = '메스꺼움';

  @override
  final bool helpful = true;

  @override
  final DateTime timestamp = DateTime.now();
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGuideFeedback());
  });
  group('CopingGuideNotifier', () {
    late ProviderContainer container;
    late MockCopingGuideRepository mockGuideRepo;
    late MockFeedbackRepository mockFeedbackRepo;

    setUp(() {
      mockGuideRepo = MockCopingGuideRepository();
      mockFeedbackRepo = MockFeedbackRepository();

      container = ProviderContainer(
        overrides: [
          copingGuideRepositoryProvider.overrideWithValue(mockGuideRepo),
          feedbackRepositoryProvider.overrideWithValue(mockFeedbackRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('증상명으로 가이드 조회 성공', () async {
      // Arrange
      final expectedGuide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );
      when(() => mockGuideRepo.getGuideBySymptom('메스꺼움'))
          .thenAnswer((_) async => expectedGuide);

      // Act
      final notifier = container.read(copingGuideNotifierProvider.notifier);
      await notifier.getGuideBySymptom('메스꺼움');

      // Assert
      final state = container.read(copingGuideNotifierProvider);
      expect(state.value!.guide, expectedGuide);
      verify(() => mockGuideRepo.getGuideBySymptom('메스꺼움')).called(1);
    });

    test('등록되지 않은 증상은 기본 가이드 반환', () async {
      // Arrange
      when(() => mockGuideRepo.getGuideBySymptom('알 수 없는 증상'))
          .thenAnswer((_) async => null);

      // Act
      final notifier = container.read(copingGuideNotifierProvider.notifier);
      await notifier.getGuideBySymptom('알 수 없는 증상');

      // Assert
      final state = container.read(copingGuideNotifierProvider);
      expect(state.value, isNotNull);
      expect(state.value!.guide.symptomName, '일반');
      expect(state.value!.guide.shortGuide, contains('전문가'));
    });

    test('모든 가이드 목록 조회', () async {
      // Arrange
      final expectedGuides = [
        CopingGuide(
          symptomName: '메스꺼움',
          shortGuide: '...',
          reassuranceMessage: '몸이 적응하는 중이에요',
          immediateAction: '물 한 컵 마시기',
        ),
        CopingGuide(
          symptomName: '구토',
          shortGuide: '...',
          reassuranceMessage: '잠시 쉬어가세요',
          immediateAction: '입을 헹구세요',
        ),
      ];
      when(() => mockGuideRepo.getAllGuides())
          .thenAnswer((_) async => expectedGuides);

      // Act
      final notifier = container.read(copingGuideListNotifierProvider.notifier);
      await notifier.loadAllGuides();

      // Assert
      final state = container.read(copingGuideListNotifierProvider);
      expect(state.value, expectedGuides);
      expect(state.value!.length, 2);
    });

    test('심각도 7-10점, 24시간 이상 지속 시 경고 플래그 활성화', () async {
      // Arrange
      final expectedGuide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );
      when(() => mockGuideRepo.getGuideBySymptom('메스꺼움'))
          .thenAnswer((_) async => expectedGuide);

      // Act
      final notifier = container.read(copingGuideNotifierProvider.notifier);
      await notifier.checkSeverityAndGuide('메스꺼움', 8, true);

      // Assert
      final state = container.read(copingGuideNotifierProvider);
      expect(state.value!.guide, expectedGuide);
      expect(state.value!.showSeverityWarning, isTrue);
    });

    test('심각도 6점 이하는 경고 플래그 비활성화', () async {
      // Arrange
      final expectedGuide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );
      when(() => mockGuideRepo.getGuideBySymptom('메스꺼움'))
          .thenAnswer((_) async => expectedGuide);

      // Act
      final notifier = container.read(copingGuideNotifierProvider.notifier);
      await notifier.checkSeverityAndGuide('메스꺼움', 5, true);

      // Assert
      final state = container.read(copingGuideNotifierProvider);
      expect(state.value!.showSeverityWarning, isFalse);
    });

    test('24시간 미만 지속은 경고 플래그 비활성화', () async {
      // Arrange
      final expectedGuide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );
      when(() => mockGuideRepo.getGuideBySymptom('메스꺼움'))
          .thenAnswer((_) async => expectedGuide);

      // Act
      final notifier = container.read(copingGuideNotifierProvider.notifier);
      await notifier.checkSeverityAndGuide('메스꺼움', 8, false);

      // Assert
      final state = container.read(copingGuideNotifierProvider);
      expect(state.value!.showSeverityWarning, isFalse);
    });

    test('피드백 제출 및 저장', () async {
      // Arrange
      when(() => mockFeedbackRepo.saveFeedback(any()))
          .thenAnswer((_) async => {});

      // Act
      final notifier = container.read(copingGuideNotifierProvider.notifier);
      await notifier.submitFeedback('메스꺼움', helpful: true);

      // Assert
      verify(() => mockFeedbackRepo.saveFeedback(any())).called(1);
    });
  });
}
