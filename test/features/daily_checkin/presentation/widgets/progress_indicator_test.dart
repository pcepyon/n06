import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/daily_checkin/presentation/widgets/progress_indicator.dart';

void main() {
  group('CheckinProgressIndicator', () {
    testWidgets('AppBar.actions에서 레이아웃 예외 없이 렌더링되어야 함 (BUG-20251202-173205)',
        (WidgetTester tester) async {
      // Arrange: AppBar.actions와 동일한 환경에서 수정된 패턴 적용
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                // 수정 후 코드: SizedBox로 감싸서 고정 너비 제공
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 120,
                    child: Center(
                      child: CheckinProgressIndicator(
                        currentStep: 1,
                        totalSteps: 6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Act & Assert: 레이아웃 예외 없이 렌더링되는지 확인
      expect(tester.takeException(), isNull,
          reason: 'AppBar.actions에서 CheckinProgressIndicator가 레이아웃 예외 없이 렌더링되어야 함');

      // 진행 바가 렌더링되었는지 확인
      expect(find.byType(CheckinProgressIndicator), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);
    });

    testWidgets('Step 1-6에서 진행 상태를 올바르게 표시해야 함',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SizedBox(
                  width: 120,
                  child: CheckinProgressIndicator(
                    currentStep: 3,
                    totalSteps: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert: 위젯이 렌더링되었는지 확인
      expect(find.byType(CheckinProgressIndicator), findsOneWidget);
      expect(find.text('3/6'), findsOneWidget);
    });

    testWidgets('고정 너비(120) 환경에서 정상 렌더링되어야 함',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              child: CheckinProgressIndicator(
                currentStep: 2,
                totalSteps: 6,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CheckinProgressIndicator), findsOneWidget);
      expect(find.text('2/6'), findsOneWidget);
    });
  });
}
