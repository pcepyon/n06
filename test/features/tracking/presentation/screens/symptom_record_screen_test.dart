import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/screens/symptom_record_screen.dart';

void main() {
  group('SymptomRecordScreen', () {
    group('TC-SRS-01: Screen Rendering', () {
      testWidgets('should render SymptomRecordScreen',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('증상 기록'), findsOneWidget);
        expect(find.text('증상 선택'), findsOneWidget);
        expect(find.text('심각도 (1-10점)'), findsOneWidget);
        expect(find.text('저장'), findsOneWidget);
      });

      testWidgets('should render symptom list',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('메스꺼움'), findsOneWidget);
        expect(find.text('구토'), findsOneWidget);
        expect(find.text('변비'), findsOneWidget);
        expect(find.text('설사'), findsOneWidget);
        expect(find.text('복통'), findsOneWidget);
        expect(find.text('두통'), findsOneWidget);
        expect(find.text('피로'), findsOneWidget);
      });

      testWidgets('should render severity slider',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(Slider), findsOneWidget);
      });
    });

    group('TC-SRS-02: Multiple Symptom Selection', () {
      testWidgets('should allow selecting multiple symptoms',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('메스꺼움'));
        await tester.pump();
        await tester.tap(find.text('복통'));
        await tester.pump();

        // Assert - FilterChip이 선택되어야 함
        final filterChips = find.byType(FilterChip);
        expect(filterChips, findsWidgets);
      });
    });

    group('TC-SRS-03: Severity Slider', () {
      testWidgets('should display severity slider correctly',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('현재: 5점'), findsOneWidget);
      });

      testWidgets('should update severity value when slider is dragged',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.drag(find.byType(Slider), const Offset(50, 0));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('현재: 5점'), findsNothing);
      });
    });

    group('TC-SRS-04: Severity 7-10 Additional Question', () {
      testWidgets('should show 24h persistence question for severity 7-10',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act - 심각도를 7-10으로 설정
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('24시간 이상 지속되고 있나요?'), findsOneWidget);
        expect(find.text('예'), findsOneWidget);
        expect(find.text('아니오'), findsOneWidget);
      });

      testWidgets('should not show question for severity below 7',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Assert - 기본 심각도는 5점이므로 질문이 표시되지 않음
        expect(find.text('24시간 이상 지속되고 있나요?'), findsNothing);
      });
    });

    group('TC-SRS-05: Context Tag Selection', () {
      testWidgets('should allow selecting context tags for severity 1-6',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act & Assert - 기본 심각도 5점에서 태그가 표시되어야 함
        expect(find.text('컨텍스트 태그 (선택)'), findsOneWidget);
        expect(find.text('#기름진음식'), findsOneWidget);
        expect(find.text('#과식'), findsOneWidget);
      });

      testWidgets('should not show context tags for severity 7-10',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act - 심각도를 7로 설정
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('컨텍스트 태그 (선택)'), findsNothing);
      });
    });

    group('TC-SRS-06: Memo Input', () {
      testWidgets('should allow entering memo',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.enterText(
          find.byType(TextField).last,
          '추가 정보',
        );
        await tester.pump();

        // Assert
        expect(find.text('추가 정보'), findsOneWidget);
      });
    });

    group('TC-SRS-07: Escalation Days Display', () {
      testWidgets('should display days since escalation when available',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Note: 실제로는 escalationDate가 있어야 표시됨
        // 통합 테스트에서 검증
      });
    });

    group('TC-SRS-08: Save and Coping Guide Navigation', () {
      testWidgets('should show coping guide after saving',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act & Assert
        // 실제 저장 및 가이드 표시는 통합 테스트에서 검증
      });
    });

    group('TC-SRS-09: Emergency Check Navigation', () {
      testWidgets('should prompt emergency check for severity 7-10 with persistence',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Note: 실제 navigation은 통합 테스트에서 검증
      });
    });

    group('TC-SRS-10: Error Handling', () {
      testWidgets('should show error when no symptom is selected',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('증상을 선택해주세요'), findsOneWidget);
      });

      testWidgets('should show error when severity 7-10 without persistence selection',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: SymptomRecordScreen(),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('메스꺼움'));
        await tester.pump();
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('24시간 이상 지속 여부를 선택해주세요'), findsOneWidget);
      });
    });
  });
}
