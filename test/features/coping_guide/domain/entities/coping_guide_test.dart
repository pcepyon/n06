import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/coping_guide/domain/entities/guide_section.dart';
import 'package:n06/features/coping_guide/domain/entities/guide_feedback.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide_state.dart';

void main() {
  group('CopingGuide', () {
    test('증상명과 간단 가이드로 생성 가능', () {
      // Arrange & Act
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
      );

      // Assert
      expect(guide.symptomName, '메스꺼움');
      expect(guide.shortGuide, '소량씩 자주 식사하세요');
    });

    test('상세 가이드 섹션 리스트를 포함할 수 있음', () {
      // Arrange
      final sections = [
        GuideSection(title: '즉시 조치', content: '물 마시기'),
        GuideSection(title: '식이 조절', content: '기름진 음식 피하기'),
      ];

      // Act
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        detailedSections: sections,
      );

      // Assert
      expect(guide.detailedSections, sections);
      expect(guide.detailedSections?.length, 2);
    });

    test('equality 비교 가능', () {
      // Arrange
      final guide1 = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
      );
      final guide2 = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
      );

      // Assert
      expect(guide1, guide2);
    });
  });

  group('GuideSection', () {
    test('제목과 내용으로 생성 가능', () {
      // Arrange & Act
      final section = GuideSection(
        title: '즉시 조치',
        content: '물을 천천히 마시세요',
      );

      // Assert
      expect(section.title, '즉시 조치');
      expect(section.content, '물을 천천히 마시세요');
    });

    test('equality 비교 가능', () {
      // Arrange
      final section1 = GuideSection(
        title: '즉시 조치',
        content: '물을 천천히 마시세요',
      );
      final section2 = GuideSection(
        title: '즉시 조치',
        content: '물을 천천히 마시세요',
      );

      // Assert
      expect(section1, section2);
    });
  });

  group('GuideFeedback', () {
    test('증상명, 도움 여부, 타임스탬프로 생성 가능', () {
      // Arrange
      final timestamp = DateTime(2025, 1, 1);

      // Act
      final feedback = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: true,
        timestamp: timestamp,
      );

      // Assert
      expect(feedback.symptomName, '메스꺼움');
      expect(feedback.helpful, isTrue);
      expect(feedback.timestamp, timestamp);
    });

    test('equality 비교 가능', () {
      // Arrange
      final timestamp = DateTime(2025, 1, 1);
      final feedback1 = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: true,
        timestamp: timestamp,
      );
      final feedback2 = GuideFeedback(
        symptomName: '메스꺼움',
        helpful: true,
        timestamp: timestamp,
      );

      // Assert
      expect(feedback1, feedback2);
    });
  });

  group('CopingGuideState', () {
    test('가이드와 심각도 경고 플래그로 생성 가능', () {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
      );

      // Act
      final state = CopingGuideState(
        guide: guide,
        showSeverityWarning: true,
      );

      // Assert
      expect(state.guide, guide);
      expect(state.showSeverityWarning, isTrue);
    });

    test('기본값: showSeverityWarning은 false', () {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
      );

      // Act
      final state = CopingGuideState(guide: guide);

      // Assert
      expect(state.showSeverityWarning, isFalse);
    });

    test('equality 비교 가능', () {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
      );
      final state1 = CopingGuideState(
        guide: guide,
        showSeverityWarning: true,
      );
      final state2 = CopingGuideState(
        guide: guide,
        showSeverityWarning: true,
      );

      // Assert
      expect(state1, state2);
    });
  });
}
