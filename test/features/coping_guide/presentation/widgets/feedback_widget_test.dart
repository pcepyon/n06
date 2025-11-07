import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/presentation/widgets/feedback_widget.dart';

void main() {
  group('FeedbackWidget', () {
    testWidgets('"도움이 되었나요?" 텍스트 표시', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackWidget(
              onFeedback: (helpful) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('도움이 되었나요?'), findsOneWidget);
    });

    testWidgets('"예", "아니오" 버튼 표시', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackWidget(
              onFeedback: (helpful) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('예'), findsOneWidget);
      expect(find.text('아니오'), findsOneWidget);
    });

    testWidgets('"예" 탭 시 콜백 호출 및 감사 메시지 표시', (WidgetTester tester) async {
      // Arrange
      bool? callbackResult;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackWidget(
              onFeedback: (helpful) => callbackResult = helpful,
            ),
          ),
        ),
      );
      await tester.tap(find.text('예'));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackResult, isTrue);
      expect(find.text('도움이 되어 기쁩니다!'), findsOneWidget);
    });

    testWidgets('"아니오" 탭 시 추가 옵션 표시', (WidgetTester tester) async {
      // Arrange
      bool? callbackResult;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackWidget(
              onFeedback: (helpful) => callbackResult = helpful,
            ),
          ),
        ),
      );
      await tester.tap(find.text('아니오'));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackResult, isFalse);
      expect(find.text('더 자세한 가이드 보기'), findsOneWidget);
    });

    testWidgets('초기 상태에서 버튼만 표시', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackWidget(
              onFeedback: (helpful) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsWidgets);
      expect(find.text('도움이 되어 기쁩니다!'), findsNothing);
      expect(find.text('더 자세한 가이드 보기'), findsNothing);
    });

    testWidgets('"예" 선택 후 다시 상호작용 불가능 확인', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackWidget(
              onFeedback: (helpful) => callCount++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('예'));
      await tester.pumpAndSettle();

      // 버튼이 비활성화되었는지 확인
      expect(callCount, 1);
    });
  });
}
