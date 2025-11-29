import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/main.dart';

void main() {
  group('GabiumToast - Global ScaffoldMessengerKey', () {
    testWidgets('should use rootScaffoldMessengerKey when available', (WidgetTester tester) async {
      // Arrange: 전역 키를 사용하는 앱 구조
      final testKey = GlobalKey<ScaffoldMessengerState>();
      
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: testKey,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    GabiumToast.showSuccess(context, '테스트 메시지');
                  },
                  child: const Text('Show Toast'),
                );
              },
            ),
          ),
        ),
      );

      // Act: 버튼 탭하여 토스트 표시
      await tester.tap(find.text('Show Toast'));
      await tester.pump();

      // Assert: 스낵바가 표시되어야 함
      expect(find.text('테스트 메시지'), findsOneWidget);
    });

    testWidgets('should show toast above Dialog when using global key', (WidgetTester tester) async {
      // Arrange: Dialog 위에서 토스트를 표시하는 시나리오
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('테스트 다이얼로그'),
                        content: Builder(
                          builder: (dialogContext) {
                            return ElevatedButton(
                              onPressed: () {
                                // Dialog 내부에서 토스트 표시
                                GabiumToast.showSuccess(dialogContext, 'Dialog에서 표시');
                              },
                              child: const Text('Show Toast in Dialog'),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Act: 다이얼로그 열기
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Dialog 내부 버튼 탭
      await tester.tap(find.text('Show Toast in Dialog'));
      await tester.pump();

      // Assert: 스낵바가 표시되어야 함
      expect(find.text('Dialog에서 표시'), findsOneWidget);
    });

    testWidgets('should fallback to context ScaffoldMessenger if global key is null', (WidgetTester tester) async {
      // Arrange: 전역 키가 없는 경우
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    GabiumToast.showError(context, '에러 메시지');
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Error'));
      await tester.pump();

      // Assert: fallback으로도 동작해야 함
      expect(find.text('에러 메시지'), findsOneWidget);
    });
  });
}
