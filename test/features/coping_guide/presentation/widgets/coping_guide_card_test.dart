import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide_state.dart';
import 'package:n06/features/coping_guide/presentation/widgets/coping_guide_card.dart';

void main() {
  group('CopingGuideCard', () {
    testWidgets('증상명과 간단 가이드 표시', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(guide: guide),
          ),
        ),
      );

      // Assert
      expect(find.text('메스꺼움 대처 가이드'), findsOneWidget);
      expect(find.text('소량씩 자주 식사하세요'), findsOneWidget);
    });

    testWidgets('"더 자세한 가이드 보기" 버튼 표시', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(guide: guide),
          ),
        ),
      );

      // Assert
      expect(find.text('더 자세한 가이드 보기'), findsOneWidget);
    });

    testWidgets('피드백 위젯 표시', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(
              guide: guide,
              onFeedback: (helpful) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('도움이 되었나요?'), findsOneWidget);
      expect(find.text('예'), findsOneWidget);
      expect(find.text('아니오'), findsOneWidget);
    });

    testWidgets('"더 자세한 가이드 보기" 탭 시 콜백 호출', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );
      bool navigated = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(
              guide: guide,
              onDetailTap: () => navigated = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('더 자세한 가이드 보기'));
      await tester.pumpAndSettle();

      // Assert
      expect(navigated, isTrue);
    });

    testWidgets('심각도 경고 플래그 활성화 시 경고 배너 표시', (WidgetTester tester) async {
      // Arrange
      final state = CopingGuideState(
        guide: CopingGuide(
          symptomName: '메스꺼움',
          shortGuide: '...',
          reassuranceMessage: '몸이 적응하는 중이에요',
          immediateAction: '물 한 컵 마시기',
        ),
        showSeverityWarning: true,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(
              state: state,
              onCheckSymptom: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('증상이 심각하거나 지속됩니다'), findsOneWidget);
      expect(find.text('증상 체크하기'), findsOneWidget);
    });

    testWidgets('경고 배너 미활성화 시 배너 미표시', (WidgetTester tester) async {
      // Arrange
      final state = CopingGuideState(
        guide: CopingGuide(
          symptomName: '메스꺼움',
          shortGuide: '...',
          reassuranceMessage: '몸이 적응하는 중이에요',
          immediateAction: '물 한 컵 마시기',
        ),
        showSeverityWarning: false,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(state: state),
          ),
        ),
      );

      // Assert
      expect(find.text('증상이 심각하거나 지속됩니다'), findsNothing);
      expect(find.text('증상 체크하기'), findsNothing);
    });

    testWidgets('경고 배너의 "증상 체크하기" 버튼 탭 시 콜백 호출', (WidgetTester tester) async {
      // Arrange
      final state = CopingGuideState(
        guide: CopingGuide(
          symptomName: '메스꺼움',
          shortGuide: '...',
          reassuranceMessage: '몸이 적응하는 중이에요',
          immediateAction: '물 한 컵 마시기',
        ),
        showSeverityWarning: true,
      );
      bool navigatedToF005 = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(
              state: state,
              onCheckSymptom: () => navigatedToF005 = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('증상 체크하기'));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedToF005, isTrue);
    });

    testWidgets('카드가 주요 콘텐츠로 렌더링됨', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '...',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopingGuideCard(guide: guide),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
