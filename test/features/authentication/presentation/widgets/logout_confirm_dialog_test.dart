import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/presentation/widgets/logout_confirm_dialog.dart';

void main() {
  group('LogoutConfirmDialog', () {
    testWidgets('should display confirmation message', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LogoutConfirmDialog(
                onConfirm: () {},
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('로그아웃하시겠습니까?'), findsOneWidget);
    });

    testWidgets('should display title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LogoutConfirmDialog(
                onConfirm: () {},
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('로그아웃'), findsOneWidget);
    });

    testWidgets('should display confirm button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LogoutConfirmDialog(
                onConfirm: () {},
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('should display cancel button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LogoutConfirmDialog(
                onConfirm: () {},
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('should call onConfirm when confirm button tapped',
        (WidgetTester tester) async {
      // Arrange
      bool confirmCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LogoutConfirmDialog(
                onConfirm: () {
                  confirmCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      // Assert
      expect(confirmCalled, true);
    });

    testWidgets('should pop dialog when cancel button tapped',
        (WidgetTester tester) async {
      // Arrange
      bool cancelCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LogoutConfirmDialog(
                onConfirm: () {},
                onCancel: () {
                  cancelCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // Assert
      expect(cancelCalled, true);
    });

    testWidgets('should not call onConfirm when cancel is tapped',
        (WidgetTester tester) async {
      // Arrange
      bool confirmCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LogoutConfirmDialog(
                onConfirm: () {
                  confirmCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // Assert
      expect(confirmCalled, false);
    });
  });
}
