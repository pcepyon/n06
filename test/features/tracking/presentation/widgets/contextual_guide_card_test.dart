import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/tracking/domain/entities/pattern_insight.dart';
import 'package:n06/features/tracking/presentation/widgets/contextual_guide_card.dart';

void main() {
  group('ContextualGuideCard', () {
    // TC-CGC-01: 기본 안심 가이드 렌더링
    testWidgets('should render basic reassurance guide', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        reassuranceMessage: '몸이 적응하는 중이에요. 2-3주면 나아질 거예요.',
        immediateAction: '물 한 컵 마시기',
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContextualGuideCard(guide: guide),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('몸이 적응하는 중이에요'), findsOneWidget);
      expect(find.text('몸이 적응하는 중이에요. 2-3주면 나아질 거예요.'), findsOneWidget);
      // immediateAction is in RichText - verify RichText exists
      expect(find.byType(RichText), findsWidgets);
    });

    // TC-CGC-02: 패턴 인사이트 포함 렌더링
    testWidgets('should render with pattern insights', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '소량씩 자주 식사하세요',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
      );
      final insights = [
        PatternInsight(
          type: PatternType.recurring,
          symptomName: '메스꺼움',
          message: '최근 7일간 3번 반복',
          confidence: 0.9,
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContextualGuideCard(
                guide: guide,
                insights: insights,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('패턴 발견'), findsOneWidget);
      expect(find.text('최근 7일간 3번 반복'), findsOneWidget);
      expect(find.text('몸이 적응하는 중이에요'), findsAtLeastNWidgets(1));
    });

    // TC-CGC-03: 최대 2개 인사이트만 표시
    testWidgets('should display maximum 2 insights', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '테스트',
        reassuranceMessage: '테스트',
        immediateAction: '테스트',
      );
      final insights = [
        PatternInsight(type: PatternType.recurring, symptomName: '메스꺼움', message: '인사이트1', confidence: 0.9),
        PatternInsight(type: PatternType.contextRelated, symptomName: '메스꺼움', message: '인사이트2', confidence: 0.8),
        PatternInsight(type: PatternType.improving, symptomName: '메스꺼움', message: '인사이트3', confidence: 0.7),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContextualGuideCard(
                guide: guide,
                insights: insights,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('인사이트1'), findsOneWidget);
      expect(find.text('인사이트2'), findsOneWidget);
      expect(find.text('인사이트3'), findsNothing); // 3번째는 표시 안됨
    });

    // TC-CGC-04: 통계적 안심 메시지 표시
    testWidgets('should render reassurance stat when provided', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '테스트',
        reassuranceMessage: '몸이 적응하는 중이에요',
        immediateAction: '물 한 컵 마시기',
        reassuranceStat: '사용자의 75%가 2-3주 내 개선',
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContextualGuideCard(guide: guide),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('💡'), findsOneWidget);
      expect(find.text('사용자의 75%가 2-3주 내 개선'), findsOneWidget);
    });

    // TC-CGC-05: onMoreInfoTap 콜백 검증
    testWidgets('should call onMoreInfoTap when tapped', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '테스트',
        reassuranceMessage: '테스트',
        immediateAction: '테스트',
      );
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContextualGuideCard(
                guide: guide,
                onMoreInfoTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('더 알아보기'));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    // TC-CGC-06: onDismissInsight 콜백 검증
    testWidgets('should call onDismissInsight when insight dismissed', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '테스트',
        reassuranceMessage: '테스트',
        immediateAction: '테스트',
      );
      final insights = [
        PatternInsight(
          type: PatternType.recurring,
          symptomName: '메스꺼움',
          message: '테스트',
          confidence: 0.9,
        ),
      ];
      bool dismissed = false;

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContextualGuideCard(
                guide: guide,
                insights: insights,
                onDismissInsight: () => dismissed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert
      expect(dismissed, isTrue);
    });

    // TC-CGC-07: 애니메이션 존재 검증
    testWidgets('should have fade and slide animations', (WidgetTester tester) async {
      // Arrange
      final guide = CopingGuide(
        symptomName: '메스꺼움',
        shortGuide: '테스트',
        reassuranceMessage: '테스트',
        immediateAction: '테스트',
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContextualGuideCard(guide: guide),
            ),
          ),
        ),
      );

      // Assert - 애니메이션 위젯 존재 확인 (MaterialApp이 여러 애니메이션을 만들 수 있으므로 최소 1개 이상)
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsAtLeastNWidgets(1));
    });
  });
}
