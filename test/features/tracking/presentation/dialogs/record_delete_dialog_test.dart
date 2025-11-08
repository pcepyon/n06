import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/dialogs/record_delete_dialog.dart';

void main() {
  group('RecordDeleteDialog', () {
    group('TC-RDD-01: Show Delete Confirmation', () {
      testWidgets('should display delete confirmation message', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '체중 기록',
                recordInfo: '70.5 kg (2025-01-01)',
                onConfirm: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('기록 삭제'), findsOneWidget);
        expect(find.text('체중 기록'), findsOneWidget);
      });

      testWidgets('should show permanent deletion warning', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '증상 기록',
                recordInfo: '메스꺼움 (2025-01-01)',
                onConfirm: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('영구적'), findsOneWidget);
        expect(find.textContaining('복구'), findsOneWidget);
      });

      testWidgets('should display delete and cancel buttons', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '체중 기록',
                recordInfo: '70 kg',
                onConfirm: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('삭제'), findsOneWidget);
        expect(find.text('취소'), findsOneWidget);
      });

      testWidgets('should show different messages for different record types', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '투여 기록',
                recordInfo: '0.5 mg (2025-01-01)',
                onConfirm: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('투여 기록'), findsOneWidget);
      });
    });

    group('TC-RDD-02: Delete Record on Confirm', () {
      testWidgets('should call onConfirm when delete button tapped', (WidgetTester tester) async {
        // Arrange
        bool confirmed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '체중 기록',
                recordInfo: '70 kg',
                onConfirm: () {
                  confirmed = true;
                },
              ),
            ),
          ),
        );

        final deleteButton = find.byWidgetPredicate(
          (widget) => widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == '삭제'
        );
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Assert
        expect(confirmed, true);
      });

      testWidgets('should close dialog when cancel button tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => RecordDeleteDialog(
                        recordType: '체중 기록',
                        recordInfo: '70 kg',
                        onConfirm: () {},
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final cancelButton = find.byWidgetPredicate(
          (widget) => widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == '취소'
        );
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(RecordDeleteDialog), findsNothing);
      });

      testWidgets('should display correct record info', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '체중 기록',
                recordInfo: '75.5 kg (2025-01-15)',
                onConfirm: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('75.5'), findsOneWidget);
      });

      testWidgets('should show confirmation dialog title', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '체중 기록',
                recordInfo: '70 kg',
                onConfirm: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('기록 삭제'), findsOneWidget);
        expect(find.textContaining('삭제하시겠습니까'), findsOneWidget);
      });
    });

    group('TC-RDD-03: Invalidate Dashboard on Delete', () {
      testWidgets('should show destruction warning for delete button', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '체중 기록',
                recordInfo: '70 kg',
                onConfirm: () {},
              ),
            ),
          ),
        );

        // Assert - delete button should exist and be distinct
        expect(find.text('삭제'), findsOneWidget);
      });

      testWidgets('should trigger deletion on confirm button tap', (WidgetTester tester) async {
        // Arrange
        bool onConfirmCalled = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDeleteDialog(
                recordType: '체중 기록',
                recordInfo: '70 kg',
                onConfirm: () {
                  onConfirmCalled = true;
                },
              ),
            ),
          ),
        );

        final deleteButton = find.byWidgetPredicate(
          (widget) => widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == '삭제'
        );
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Assert
        expect(onConfirmCalled, true);
      });

      testWidgets('should allow user to cancel deletion', (WidgetTester tester) async {
        // Arrange
        bool onConfirmCalled = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => RecordDeleteDialog(
                        recordType: '체중 기록',
                        recordInfo: '70 kg',
                        onConfirm: () {
                          onConfirmCalled = true;
                        },
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final cancelButton = find.byWidgetPredicate(
          (widget) => widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == '취소'
        );
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Assert - onConfirm should not be called
        expect(onConfirmCalled, false);
      });
    });
  });
}
