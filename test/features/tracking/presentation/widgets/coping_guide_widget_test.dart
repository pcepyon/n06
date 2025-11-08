import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/presentation/widgets/coping_guide_widget.dart';

void main() {
  group('CopingGuideWidget', () {
    group('Rendering', () {
      testWidgets('should render coping guide widget correctly',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '메스꺼움',
                severity: 5,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('메스꺼움 대처 가이드'), findsOneWidget);
        expect(find.text('심각도: 5/10'), findsOneWidget);
      });

      testWidgets('should display guide content for known symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '메스꺼움',
                severity: 4,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('메스꺼움 대처 가이드'), findsOneWidget);
      });
    });

    group('Feedback', () {
      testWidgets('should allow selecting helpful feedback',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '메스꺼움',
                severity: 5,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('예'));
        await tester.pump();

        // Assert
        expect(find.text('피드백해주셔서 감사합니다!'), findsOneWidget);
      });

      testWidgets('should allow selecting not helpful feedback',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '메스꺼움',
                severity: 5,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('아니오'));
        await tester.pump();

        // Assert
        expect(find.byType(CopingGuideWidget), findsOneWidget);
      });
    });

    group('Symptom Coverage', () {
      testWidgets('should handle nausea symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '메스꺼움',
                severity: 5,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('메스꺼움 대처 가이드'), findsOneWidget);
      });

      testWidgets('should handle vomiting symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '구토',
                severity: 7,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('구토 대처 가이드'), findsOneWidget);
      });

      testWidgets('should handle constipation symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '변비',
                severity: 4,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('변비 대처 가이드'), findsOneWidget);
      });

      testWidgets('should handle diarrhea symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '설사',
                severity: 6,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('설사 대처 가이드'), findsOneWidget);
      });

      testWidgets('should handle abdominal pain symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '복통',
                severity: 5,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('복통 대처 가이드'), findsOneWidget);
      });

      testWidgets('should handle headache symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '두통',
                severity: 4,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('두통 대처 가이드'), findsOneWidget);
      });

      testWidgets('should handle fatigue symptom',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '피로',
                severity: 6,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('피로 대처 가이드'), findsOneWidget);
      });

      testWidgets('should handle unknown symptom gracefully',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '미지의증상',
                severity: 5,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('대처 가이드'), findsOneWidget);
      });
    });

    group('Close Button', () {
      testWidgets('should have close button',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '메스꺼움',
                severity: 5,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('닫기'), findsOneWidget);
      });

      testWidgets('should call onClose callback when close button is tapped',
          (tester) async {
        // Arrange
        bool closed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CopingGuideWidget(
                symptomName: '메스꺼움',
                severity: 5,
                onClose: () => closed = true,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('닫기'));
        await tester.pump();

        // Assert
        expect(closed, true);
      });
    });
  });
}
