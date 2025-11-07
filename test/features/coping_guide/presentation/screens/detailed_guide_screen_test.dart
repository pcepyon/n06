import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/coping_guide/domain/entities/guide_section.dart';
import 'package:n06/features/coping_guide/presentation/screens/detailed_guide_screen.dart';

void main() {
  group('DetailedGuideScreen', () {
    testWidgets('증상명을 제목으로 표시', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        detailedSections: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DetailedGuideScreen(guide: guide),
        ),
      );

      // Assert
      expect(find.text('메스꺼움 대처 가이드'), findsOneWidget);
    });

    testWidgets('4가지 섹션을 순서대로 표시', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        detailedSections: [
          GuideSection(title: '즉시 조치', content: '물 마시기'),
          GuideSection(title: '식이 조절', content: '기름진 음식 피하기'),
          GuideSection(title: '생활 습관', content: '충분한 휴식'),
          GuideSection(title: '경과 관찰', content: '3일 후에도 지속 시 상담'),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DetailedGuideScreen(guide: guide),
        ),
      );

      // Assert
      expect(find.text('즉시 조치'), findsOneWidget);
      expect(find.text('식이 조절'), findsOneWidget);
      expect(find.text('생활 습관'), findsOneWidget);
      expect(find.text('경과 관찰'), findsOneWidget);
    });

    testWidgets('섹션 내용 표시', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        detailedSections: [
          GuideSection(title: '즉시 조치', content: '물 마시기'),
          GuideSection(title: '식이 조절', content: '기름진 음식 피하기'),
          GuideSection(title: '생활 습관', content: '충분한 휴식'),
          GuideSection(title: '경과 관찰', content: '3일 후에도 지속 시 상담'),
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DetailedGuideScreen(guide: guide),
        ),
      );

      // Assert
      expect(find.text('물 마시기'), findsOneWidget);
      expect(find.text('기름진 음식 피하기'), findsOneWidget);
      expect(find.text('충분한 휴식'), findsOneWidget);
      expect(find.text('3일 후에도 지속 시 상담'), findsOneWidget);
    });

    testWidgets('빈 섹션 처리', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        detailedSections: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DetailedGuideScreen(guide: guide),
        ),
      );

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Scaffold가 표시됨', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        detailedSections: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DetailedGuideScreen(guide: guide),
        ),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AppBar가 표시됨', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        detailedSections: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DetailedGuideScreen(guide: guide),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('많은 섹션 처리 시 스크롤 가능', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        detailedSections: List.generate(
          10,
          (i) => GuideSection(title: '섹션 $i', content: '내용 ' * 50),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DetailedGuideScreen(guide: guide),
        ),
      );

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
