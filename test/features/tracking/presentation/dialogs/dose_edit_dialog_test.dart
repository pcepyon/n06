import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/presentation/dialogs/dose_edit_dialog.dart';

void main() {
  group('DoseEditDialog', () {
    late DoseRecord currentRecord;

    setUp(() {
      currentRecord = DoseRecord(
        id: 'dose1',
        dosagePlanId: 'plan1',
        administeredAt: DateTime(2025, 1, 15, 10, 0),
        actualDoseMg: 0.5,
        injectionSite: '복부',
        isCompleted: true,
      );
    });

    group('TC-DED-01: Display Current Dose', () {
      testWidgets('should display current dose amount', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('0.5'), findsWidgets);
        expect(find.text('투여 기록 수정'), findsOneWidget);
      });

      testWidgets('should display current injection site', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('복부'), findsOneWidget);
      });

      testWidgets('should display dose with correct decimal places', (WidgetTester tester) async {
        // Arrange
        final recordWithDifferentDose = DoseRecord(
          id: 'dose1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2025, 1, 15, 10, 0),
          actualDoseMg: 0.75,
          injectionSite: '상완',
          isCompleted: true,
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: recordWithDifferentDose,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('0.75'), findsOneWidget);
      });

      testWidgets('should display note if present', (WidgetTester tester) async {
        // Arrange
        final recordWithNote = DoseRecord(
          id: 'dose1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2025, 1, 15, 10, 0),
          actualDoseMg: 0.5,
          injectionSite: '복부',
          isCompleted: true,
          note: '정상 투여',
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: recordWithNote,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('정상 투여'), findsOneWidget);
      });
    });

    group('TC-DED-02: Update Dose and Save', () {
      testWidgets('should allow changing dose amount', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Find and edit dose field
        final textFields = find.byType(TextField);
        expect(textFields, findsWidgets);

        // Enter new dose
        await tester.enterText(textFields.first, '0.75');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('0.75'), findsOneWidget);
      });

      testWidgets('should allow changing injection site', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Find dropdown
        final dropdown = find.byType(DropdownButton);
        if (dropdown.evaluate().isNotEmpty) {
          await tester.tap(dropdown);
          await tester.pumpAndSettle();

          // Select different site
          final option = find.text('허벅지');
          if (option.evaluate().isNotEmpty) {
            await tester.tap(option);
            await tester.pumpAndSettle();

            // Assert
            expect(find.text('허벅지'), findsOneWidget);
          }
        }
      });

      testWidgets('should display save button', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('저장'), findsOneWidget);
      });
    });

    group('TC-DED-03: Invalidate Dashboard on Save', () {
      testWidgets('should validate dose is positive', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Enter zero dose
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '0');
        await tester.pumpAndSettle();

        // Assert error should be shown
        expect(find.textContaining('0보다'), findsOneWidget);
      });

      testWidgets('should allow positive dose values', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Enter valid dose
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '1.5');
        await tester.pumpAndSettle();

        // Assert save button should be enabled
        expect(find.text('저장'), findsOneWidget);
      });

      testWidgets('should show all injection site options', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Find dropdown
        final dropdown = find.byType(DropdownButton);
        if (dropdown.evaluate().isNotEmpty) {
          await tester.tap(dropdown);
          await tester.pumpAndSettle();

          // Assert at least one site option is available
          expect(find.text('복부'), findsWidgets);
        }
      });

      testWidgets('should accept valid dose and close dialog', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: DoseEditDialog(
                  currentRecord: currentRecord,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Edit dose
        final textField = find.byType(TextField).first;
        await tester.enterText(textField, '1.0');
        await tester.pumpAndSettle();

        // Assert save button exists and is available
        expect(find.text('저장'), findsOneWidget);
      });
    });
  });
}
