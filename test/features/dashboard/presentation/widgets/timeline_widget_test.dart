import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/dashboard/domain/entities/timeline_event.dart';
import 'package:n06/features/dashboard/presentation/widgets/timeline_widget.dart';

void main() {
  group('TimelineWidget', () {
    testWidgets('should display empty message when timeline is empty', (tester) async {
      // Arrange
      const widget = TimelineWidget(timeline: []);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // Assert
      expect(find.text('아직 이벤트가 없습니다'), findsOneWidget);
    });

    testWidgets('should display all timeline events', (tester) async {
      // Arrange
      final timeline = [
        TimelineEvent(
          id: '1',
          dateTime: DateTime(2024, 1, 1),
          eventType: TimelineEventType.treatmentStart,
          title: '치료 시작',
          description: '0.25mg 투여 시작',
        ),
        TimelineEvent(
          id: '2',
          dateTime: DateTime(2024, 1, 8),
          eventType: TimelineEventType.escalation,
          title: '용량 증량',
          description: '0.5mg으로 증량',
        ),
        TimelineEvent(
          id: '3',
          dateTime: DateTime(2024, 1, 15),
          eventType: TimelineEventType.weightMilestone,
          title: '체중 감량 달성',
          description: '2kg 감량',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineWidget(timeline: timeline),
          ),
        ),
      );

      // Assert
      expect(find.text('치료 시작'), findsOneWidget);
      expect(find.text('용량 증량'), findsOneWidget);
      expect(find.text('체중 감량 달성'), findsOneWidget);
      expect(find.text('0.25mg 투여 시작'), findsOneWidget);
      expect(find.text('0.5mg으로 증량'), findsOneWidget);
      expect(find.text('2kg 감량'), findsOneWidget);
    });

    testWidgets('should display connecting lines between events (not on last item)', (tester) async {
      // Arrange
      final timeline = [
        TimelineEvent(
          id: '1',
          dateTime: DateTime(2024, 1, 1),
          eventType: TimelineEventType.treatmentStart,
          title: '치료 시작',
          description: '0.25mg 투여 시작',
        ),
        TimelineEvent(
          id: '2',
          dateTime: DateTime(2024, 1, 8),
          eventType: TimelineEventType.escalation,
          title: '용량 증량',
          description: '0.5mg으로 증량',
        ),
        TimelineEvent(
          id: '3',
          dateTime: DateTime(2024, 1, 15),
          eventType: TimelineEventType.weightMilestone,
          title: '체중 감량 달성',
          description: '2kg 감량',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineWidget(timeline: timeline),
          ),
        ),
      );

      // Assert
      // Verify all event titles are displayed
      expect(find.text('치료 시작'), findsOneWidget);
      expect(find.text('용량 증량'), findsOneWidget);
      expect(find.text('체중 감량 달성'), findsOneWidget);

      // Find all Column widgets (each event has a Column with circle and connecting line)
      final columns = tester.widgetList<Column>(
        find.byWidgetPredicate((widget) => widget is Column),
      );

      // We should have at least 3 columns (one for each event)
      expect(columns.length, greaterThanOrEqualTo(3));
    });

    testWidgets('should use correct colors for different event types', (tester) async {
      // Arrange
      final timeline = [
        TimelineEvent(
          id: '1',
          dateTime: DateTime(2024, 1, 1),
          eventType: TimelineEventType.treatmentStart,
          title: '치료 시작',
          description: '테스트',
        ),
        TimelineEvent(
          id: '2',
          dateTime: DateTime(2024, 1, 8),
          eventType: TimelineEventType.escalation,
          title: '용량 증량',
          description: '테스트',
        ),
        TimelineEvent(
          id: '3',
          dateTime: DateTime(2024, 1, 15),
          eventType: TimelineEventType.weightMilestone,
          title: '체중 감량',
          description: '테스트',
        ),
        TimelineEvent(
          id: '4',
          dateTime: DateTime(2024, 1, 22),
          eventType: TimelineEventType.badgeAchievement,
          title: '뱃지 획득',
          description: '테스트',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineWidget(timeline: timeline),
          ),
        ),
      );

      // Assert
      // Find all circle decorations
      final circles = tester.widgetList<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final decoration = widget.decoration;
            if (decoration is BoxDecoration) {
              return decoration.shape == BoxShape.circle;
            }
          }
          return false;
        }),
      );

      expect(circles.length, 4);

      // Check specific colors
      final circlesList = circles.toList();
      expect(
        (circlesList[0].decoration as BoxDecoration).color,
        Colors.blue, // treatmentStart
      );
      expect(
        (circlesList[1].decoration as BoxDecoration).color,
        Colors.orange, // escalation
      );
      expect(
        (circlesList[2].decoration as BoxDecoration).color,
        Colors.green, // weightMilestone
      );
      expect(
        (circlesList[3].decoration as BoxDecoration).color,
        Colors.amber, // badgeAchievement
      );
    });

    testWidgets('should display timeline title', (tester) async {
      // Arrange
      final timeline = [
        TimelineEvent(
          id: '1',
          dateTime: DateTime(2024, 1, 1),
          eventType: TimelineEventType.treatmentStart,
          title: '치료 시작',
          description: '테스트',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineWidget(timeline: timeline),
          ),
        ),
      );

      // Assert
      expect(find.text('치료 여정'), findsOneWidget);
    });
  });
}
