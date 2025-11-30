import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/pattern_insight.dart';
import 'package:n06/features/tracking/presentation/widgets/pattern_insight_card.dart';

void main() {
  group('PatternInsightCard', () {
    // TC-PIC-01: recurring 패턴 렌더링
    testWidgets('should render recurring pattern insight', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '메스꺼움이(가) 최근 7일간 5번 반복되었어요',
        confidence: 0.9,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('패턴 발견'), findsOneWidget);
      expect(find.text('메스꺼움이(가) 최근 7일간 5번 반복되었어요'), findsOneWidget);
      expect(find.text('🔄'), findsOneWidget); // recurring icon
    });

    // TC-PIC-02: contextRelated 패턴 렌더링
    testWidgets('should render context related pattern insight', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.contextRelated,
        symptomName: '메스꺼움',
        message: '메스꺼움이(가) #기름진음식와(과) 함께 3번 기록되었어요',
        confidence: 0.7,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('💡'), findsOneWidget); // contextRelated icon
      expect(find.text('메스꺼움이(가) #기름진음식와(과) 함께 3번 기록되었어요'), findsOneWidget);
    });

    // TC-PIC-03: improving 패턴 렌더링
    testWidgets('should render improving pattern insight', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.improving,
        symptomName: '피로',
        message: '좋은 소식! 지난주보다 25% 나아졌어요',
        confidence: 0.8,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('📈'), findsOneWidget); // improving icon
      expect(find.text('좋은 소식! 지난주보다 25% 나아졌어요'), findsOneWidget);
    });

    // TC-PIC-04: worsening 패턴 렌더링
    testWidgets('should render worsening pattern insight', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.worsening,
        symptomName: '구토',
        message: '지난주보다 30% 증가했어요',
        confidence: 0.8,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('📉'), findsOneWidget); // worsening icon
      expect(find.text('지난주보다 30% 증가했어요'), findsOneWidget);
    });

    // TC-PIC-05: 제안 메시지 렌더링
    testWidgets('should render suggestion when provided', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.worsening,
        symptomName: '구토',
        message: '지난주보다 30% 증가했어요',
        suggestion: '증상이 지속되면 담당 의료진과 상담해보세요',
        confidence: 0.8,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('💬'), findsOneWidget);
      expect(find.text('증상이 지속되면 담당 의료진과 상담해보세요'), findsOneWidget);
    });

    // TC-PIC-06: 제안 없을 때 미표시
    testWidgets('should not render suggestion when not provided', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '최근 반복되고 있어요',
        confidence: 0.9,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('💬'), findsNothing);
    });

    // TC-PIC-07: 신뢰도 표시 (showConfidence: true)
    testWidgets('should show confidence when showConfidence is true', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트',
        confidence: 0.85,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(
              insight: insight,
              showConfidence: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('신뢰도 85%'), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    // TC-PIC-08: 신뢰도 미표시 (showConfidence: false, default)
    testWidgets('should not show confidence by default', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트',
        confidence: 0.85,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('신뢰도 85%'), findsNothing);
      expect(find.byIcon(Icons.verified_outlined), findsNothing);
    });

    // TC-PIC-09: onDismiss 콜백 검증
    testWidgets('should call onDismiss when dismiss button tapped', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트',
        confidence: 0.9,
      );
      bool dismissed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(
              insight: insight,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert
      expect(dismissed, isTrue);
    });

    // TC-PIC-10: onDismiss 없을 때 닫기 버튼 미표시
    testWidgets('should not show dismiss button when onDismiss is null', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트',
        confidence: 0.9,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.close), findsNothing);
    });

    // TC-PIC-11: onLearnMore 콜백 검증
    testWidgets('should call onLearnMore when learn more tapped', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트',
        confidence: 0.9,
      );
      bool learnMoreTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(
              insight: insight,
              onLearnMore: () => learnMoreTapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('더 알아보기'));
      await tester.pumpAndSettle();

      // Assert
      expect(learnMoreTapped, isTrue);
    });

    // TC-PIC-12: onLearnMore 없을 때 버튼 미표시
    testWidgets('should not show learn more button when onLearnMore is null', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.recurring,
        symptomName: '메스꺼움',
        message: '테스트',
        confidence: 0.9,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      expect(find.text('더 알아보기'), findsNothing);
    });

    // TC-PIC-13: 패턴 유형별 색상 구분 검증
    testWidgets('should render with proper container decoration', (WidgetTester tester) async {
      // Arrange
      final insight = PatternInsight(
        type: PatternType.improving,
        symptomName: '피로',
        message: '테스트',
        confidence: 0.8,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternInsightCard(insight: insight),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PatternInsightCard),
          matching: find.byType(Container).first,
        ),
      );
      expect(container.decoration, isA<BoxDecoration>());
    });
  });
}
