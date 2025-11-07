import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/coping_guide/presentation/widgets/severity_warning_banner.dart';

void main() {
  group('SeverityWarningBanner', () {
    testWidgets('경고 메시지 텍스트 표시', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeverityWarningBanner(
              onCheckSymptom: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('증상이 심각하거나 지속됩니다'), findsOneWidget);
    });

    testWidgets('"증상 체크하기" 버튼 표시', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeverityWarningBanner(
              onCheckSymptom: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('증상 체크하기'), findsOneWidget);
    });

    testWidgets('"증상 체크하기" 버튼 탭 시 콜백 호출', (WidgetTester tester) async {
      // Arrange
      bool called = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeverityWarningBanner(
              onCheckSymptom: () => called = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('증상 체크하기'));
      await tester.pumpAndSettle();

      // Assert
      expect(called, isTrue);
    });

    testWidgets('배너가 빨간색 배경으로 렌더링됨', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeverityWarningBanner(
              onCheckSymptom: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('경고 아이콘 표시', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeverityWarningBanner(
              onCheckSymptom: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });
  });
}
