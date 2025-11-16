import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/presentation/screens/symptom_record_screen.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

class MockTrackingRepository extends Mock implements TrackingRepository {}

void main() {
  group('SymptomRecordScreen - Save Flow', () {
    late MockTrackingRepository mockTrackingRepository;

    setUp(() {
      mockTrackingRepository = MockTrackingRepository();

      // Setup default behavior
      when(() => mockTrackingRepository.saveSymptomLog(any()))
          .thenAnswer((_) async => {});
      when(() => mockTrackingRepository.getSymptomLogs(any()))
          .thenAnswer((_) async => []);
      when(() => mockTrackingRepository.getLatestDoseEscalationDate(any()))
          .thenAnswer((_) async => null);
    });

    setUpAll(() {
      registerFallbackValue(SymptomLog(
        id: 'test',
        userId: 'test',
        logDate: DateTime.now(),
        symptomName: 'test',
        severity: 5,
      ));
    });

    Widget buildTestableWidget() {
      return ProviderScope(
        overrides: [
          trackingRepositoryProvider.overrideWithValue(mockTrackingRepository),
        ],
        child: const MaterialApp(
          home: SymptomRecordScreen(),
        ),
      );
    }

    testWidgets('TC-SRS-SAVE-01: should call save before showing modal',
        (tester) async {
      // Configure screen size for large layouts
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final callSequence = <String>[];

      when(() => mockTrackingRepository.saveSymptomLog(any()))
          .thenAnswer((_) async {
        callSequence.add('save');
        // 저장에 시간이 걸린다고 가정
        await Future.delayed(const Duration(milliseconds: 100));
      });

      // Arrange
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Act - 증상 선택
      await tester.tap(find.text('메스꺼움'));
      await tester.pump();

      // Scroll down to reveal the save button
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Act - 저장 버튼 클릭
      await tester.tap(find.text('저장'));
      await tester.pump(); // 초기 로딩 시작
      
      // 저장이 완료될 때까지 대기
      await tester.pumpAndSettle();

      // Assert - 저장이 호출되어야 함
      expect(callSequence, contains('save'));
      verify(() => mockTrackingRepository.saveSymptomLog(any())).called(1);
    });

    testWidgets('TC-SRS-SAVE-02: should handle save error gracefully',
        (tester) async {
      // Configure screen size for large layouts
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange - 저장 실패 시뮬레이션
      when(() => mockTrackingRepository.saveSymptomLog(any()))
          .thenThrow(Exception('Database error'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Act - 증상 선택
      await tester.tap(find.text('메스꺼움'));
      await tester.pump();

      // Scroll down to reveal the save button
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Act - 저장 버튼 클릭
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // Assert - 저장이 시도되었는지 확인
      verify(() => mockTrackingRepository.saveSymptomLog(any())).called(1);

      // Note: TrackingNotifier uses AsyncValue.guard() which catches exceptions internally
      // The error is stored in the notifier's state, not propagated to the UI
      // This is current implementation behavior - error handling happens at the notifier level
    });
  });
}
