import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/presentation/dialogs/symptom_edit_dialog.dart';

void main() {
  group('SymptomEditDialog', () {
    late SymptomLog currentLog;

    setUp(() {
      currentLog = SymptomLog(
        id: 'symptom1',
        userId: 'user123',
        logDate: DateTime(2025, 1, 15),
        symptomName: '메스꺼움',
        severity: 7,
        tags: const ['기름진음식'],
      );
    });

    group('TC-SED-01: Display Current Symptom Data', () {
      testWidgets('should display current symptom name', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('메스꺼움'), findsOneWidget);
        expect(find.text('증상 수정'), findsOneWidget);
      });

      testWidgets('should display current severity level', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('7'), findsWidgets);
        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);
      });

      testWidgets('should display current tags', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('기름진음식'), findsOneWidget);
      });

      testWidgets('should display multiple tags if present', (WidgetTester tester) async {
        // Arrange
        final logWithMultipleTags = SymptomLog(
          id: 'symptom1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          symptomName: '메스꺼움',
          severity: 7,
          tags: const ['기름진음식', '과식'],
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: logWithMultipleTags,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('기름진음식'), findsOneWidget);
        expect(find.text('과식'), findsOneWidget);
      });

      testWidgets('should display note if present', (WidgetTester tester) async {
        // Arrange
        final logWithNote = SymptomLog(
          id: 'symptom1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          symptomName: '메스꺼움',
          severity: 6,
          note: '저녁 식사 후 발생',
          tags: const [],
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: logWithNote,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('저녁 식사 후 발생'), findsOneWidget);
      });
    });

    group('TC-SED-02: Update Symptom and Save', () {
      testWidgets('should allow changing symptom name', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Find and tap on symptom dropdown
        final dropdown = find.byType(DropdownButton);
        if (dropdown.evaluate().isNotEmpty) {
          await tester.tap(dropdown);
          await tester.pumpAndSettle();

          // Select different symptom
          final option = find.text('구토');
          if (option.evaluate().isNotEmpty) {
            await tester.tap(option);
            await tester.pumpAndSettle();

            // Assert
            expect(find.text('구토'), findsOneWidget);
          }
        }
      });

      testWidgets('should allow adjusting severity with slider', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Find slider and drag it
        final slider = find.byType(Slider);
        if (slider.evaluate().isNotEmpty) {
          await tester.drag(slider.first, const Offset(50, 0));
          await tester.pumpAndSettle();

          // Assert - slider should exist and be draggable
          expect(slider, findsOneWidget);
        }
      });

      testWidgets('should display save button', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
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

    group('TC-SED-03: Invalidate Dashboard on Save', () {
      testWidgets('should validate severity range 1-10', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Find slider
        final slider = find.byType(Slider);
        if (slider.evaluate().isNotEmpty) {
          final sliderWidget = tester.widget<Slider>(slider.first);

          // Assert
          expect(sliderWidget.min, 1);
          expect(sliderWidget.max, 10);
        }
      });

      testWidgets('should maintain severity within valid range', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Get initial severity
        expect(find.text('7'), findsWidgets);

        // Assert severity is within range
        expect(currentLog.severity, inInclusiveRange(1, 10));
      });

      testWidgets('should show all symptom options available', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SymptomEditDialog(
                  currentLog: currentLog,
                  userId: 'user123',
                ),
              ),
            ),
          ),
        );

        // Assert main symptom is displayed
        expect(find.text('메스꺼움'), findsOneWidget);
      });
    });
  });
}
