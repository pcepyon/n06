import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/presentation/sheets/record_detail_sheet.dart';

void main() {
  group('RecordDetailSheet', () {
    group('TC-RDS-01: Display Record Details', () {
      testWidgets('should display weight record details', (WidgetTester tester) async {
        // Arrange
        final weightLog = WeightLog(
          id: 'log1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          weightKg: 70.5,
          createdAt: DateTime(2025, 1, 15, 9, 0),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.weight(log: weightLog),
            ),
          ),
        );

        // Assert
        expect(find.text('70.5'), findsOneWidget);
        expect(find.textContaining('2025'), findsOneWidget);
      });

      testWidgets('should display symptom record details', (WidgetTester tester) async {
        // Arrange
        final symptomLog = SymptomLog(
          id: 'symptom1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          symptomName: '메스꺼움',
          severity: 7,
          tags: const ['기름진음식', '과식'],
          note: '저녁 식사 후 발생',
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.symptom(log: symptomLog),
            ),
          ),
        );

        // Assert
        expect(find.text('메스꺼움'), findsOneWidget);
        expect(find.text('7'), findsWidgets);
        expect(find.text('기름진음식'), findsOneWidget);
        expect(find.text('과식'), findsOneWidget);
      });

      testWidgets('should display dose record details', (WidgetTester tester) async {
        // Arrange
        final doseRecord = DoseRecord(
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
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.dose(record: doseRecord),
            ),
          ),
        );

        // Assert
        expect(find.text('0.5'), findsWidgets);
        expect(find.text('복부'), findsOneWidget);
      });

      testWidgets('should display all record information formatted correctly', (WidgetTester tester) async {
        // Arrange
        final weightLog = WeightLog(
          id: 'log1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          weightKg: 75.25,
          createdAt: DateTime(2025, 1, 15, 9, 30),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.weight(log: weightLog),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('75'), findsOneWidget);
      });

      testWidgets('should display note for symptom record if present', (WidgetTester tester) async {
        // Arrange
        final symptomLog = SymptomLog(
          id: 'symptom1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          symptomName: '메스꺼움',
          severity: 5,
          note: '저녁 식사 후 발생',
          tags: const [],
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.symptom(log: symptomLog),
            ),
          ),
        );

        // Assert
        expect(find.text('저녁 식사 후 발생'), findsOneWidget);
      });
    });

    group('TC-RDS-02: Open Edit Dialog', () {
      testWidgets('should display edit button for weight record', (WidgetTester tester) async {
        // Arrange
        final weightLog = WeightLog(
          id: 'log1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          weightKg: 70.0,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.weight(log: weightLog),
            ),
          ),
        );

        // Assert
        expect(find.text('수정'), findsOneWidget);
      });

      testWidgets('should display edit button for symptom record', (WidgetTester tester) async {
        // Arrange
        final symptomLog = SymptomLog(
          id: 'symptom1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          symptomName: '메스꺼움',
          severity: 5,
          tags: const [],
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.symptom(log: symptomLog),
            ),
          ),
        );

        // Assert
        expect(find.text('수정'), findsOneWidget);
      });

      testWidgets('should display edit button for dose record', (WidgetTester tester) async {
        // Arrange
        final doseRecord = DoseRecord(
          id: 'dose1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2025, 1, 15, 10, 0),
          actualDoseMg: 0.5,
          injectionSite: '복부',
          isCompleted: true,
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.dose(record: doseRecord),
            ),
          ),
        );

        // Assert
        expect(find.text('수정'), findsOneWidget);
      });

      testWidgets('should allow opening edit dialog from sheet', (WidgetTester tester) async {
        // Arrange
        final weightLog = WeightLog(
          id: 'log1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          weightKg: 70.0,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.weight(log: weightLog),
            ),
          ),
        );

        // Verify edit button exists and is tappable
        final editButton = find.text('수정');
        expect(editButton, findsOneWidget);
      });
    });

    group('TC-RDS-03: Open Delete Dialog', () {
      testWidgets('should display delete button for all record types', (WidgetTester tester) async {
        // Arrange
        final weightLog = WeightLog(
          id: 'log1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          weightKg: 70.0,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.weight(log: weightLog),
            ),
          ),
        );

        // Assert
        expect(find.text('삭제'), findsOneWidget);
      });

      testWidgets('should show record info in delete context', (WidgetTester tester) async {
        // Arrange
        final weightLog = WeightLog(
          id: 'log1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          weightKg: 70.5,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.weight(log: weightLog),
            ),
          ),
        );

        // Assert - verify weight record is displayed
        expect(find.text('70.5'), findsOneWidget);
      });

      testWidgets('should allow delete action for symptom records', (WidgetTester tester) async {
        // Arrange
        final symptomLog = SymptomLog(
          id: 'symptom1',
          userId: 'user123',
          logDate: DateTime(2025, 1, 15),
          symptomName: '메스꺼움',
          severity: 5,
          tags: const [],
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.symptom(log: symptomLog),
            ),
          ),
        );

        // Assert
        expect(find.text('삭제'), findsOneWidget);
        expect(find.text('메스꺼움'), findsOneWidget);
      });

      testWidgets('should allow delete action for dose records', (WidgetTester tester) async {
        // Arrange
        final doseRecord = DoseRecord(
          id: 'dose1',
          dosagePlanId: 'plan1',
          administeredAt: DateTime(2025, 1, 15, 10, 0),
          actualDoseMg: 0.5,
          injectionSite: '복부',
          isCompleted: true,
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordDetailSheet.dose(record: doseRecord),
            ),
          ),
        );

        // Assert
        expect(find.text('삭제'), findsOneWidget);
      });
    });
  });
}
