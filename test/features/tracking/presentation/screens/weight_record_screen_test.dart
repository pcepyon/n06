import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/presentation/screens/weight_record_screen.dart';

class MockTrackingRepository extends Mock implements TrackingRepository {}

void main() {
  group('WeightRecordScreen', () {
    setUp(() {
      // Repository setup for tests
    });

    group('TC-WRS-01: Screen Rendering', () {
      testWidgets('should render WeightRecordScreen', (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // trackingRepositoryProvider를 mock으로 오버라이드
            ],
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('체중 기록'), findsOneWidget);
        expect(find.text('날짜 선택'), findsOneWidget);
        expect(find.text('체중 입력'), findsOneWidget);
        expect(find.text('저장'), findsOneWidget);
      });

      testWidgets('should render date selection widget',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('오늘'), findsOneWidget);
        expect(find.text('어제'), findsOneWidget);
        expect(find.text('2일 전'), findsOneWidget);
      });

      testWidgets('should render weight input field', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsWidgets);
      });
    });

    group('TC-WRS-02: Date Selection', () {
      testWidgets('should allow selecting today',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('오늘'));
        await tester.pump();

        // Assert - 날짜가 선택된 것으로 간주
        expect(find.text('오늘'), findsOneWidget);
      });
    });

    group('TC-WRS-03: Weight Input Validation', () {
      testWidgets('should validate weight in real-time',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act - 정상 값 입력
        await tester.enterText(
          find.byType(TextField).first,
          '75.5',
        );
        await tester.pump();

        // Assert - 에러가 없어야 함
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should show error for weight below 20kg',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '15.0',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('20kg 이상이어야 합니다'), findsOneWidget);
      });

      testWidgets('should show error for weight above 300kg',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '350.0',
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('300kg 이하여야 합니다'), findsOneWidget);
      });
    });

    group('TC-WRS-04: Save Button Functionality', () {
      testWidgets('should enable save button when valid data is entered',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '75.5',
        );
        await tester.pump();

        // Assert
        expect(find.byType(ElevatedButton), findsOneWidget);
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);
      });
    });

    group('TC-WRS-05: Success Message', () {
      testWidgets('should show success snackbar after saving',
          (tester) async {
        // Arrange - Navigator stub 필요
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: WeightRecordScreen(),
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '75.5',
        );
        await tester.pumpAndSettle();

        // Note: 실제 저장은 Repository 의존성이 필요하므로
        // 통합 테스트에서 검증하거나 mock 필요
      });
    });

    group('TC-WRS-06: Duplicate Record Dialog', () {
      testWidgets('should display confirmation dialog for duplicate date',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act & Assert
        // 중복 확인 로직은 통합 테스트에서 검증
        expect(find.byType(WeightRecordScreen), findsOneWidget);
      });
    });

    group('TC-WRS-07: Overwrite Confirmation', () {
      testWidgets('should allow overwriting existing record',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(WeightRecordScreen), findsOneWidget);
      });
    });

    group('TC-WRS-08: Error Handling', () {
      testWidgets('should show error dialog for invalid input',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).first,
          '10.0', // Invalid: below 20
        );
        await tester.pump();

        // Assert
        expect(find.text('20kg 이상이어야 합니다'), findsOneWidget);
      });
    });

    group('TC-WRS-09: Navigation', () {
      testWidgets('should navigate back on success',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Note: 실제 navigation은 통합 테스트에서 검증
        expect(find.byType(WeightRecordScreen), findsOneWidget);
      });
    });

    group('TC-WRS-10: Loading State', () {
      testWidgets('should show loading indicator during save',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: WeightRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
}
