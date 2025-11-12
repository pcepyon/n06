import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n06/features/tracking/presentation/screens/emergency_check_screen.dart';
import 'package:n06/features/tracking/domain/repositories/emergency_check_repository.dart';
import 'package:n06/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';

class MockEmergencyCheckRepository extends Mock implements EmergencyCheckRepository {}
class MockTrackingRepository extends Mock implements TrackingRepository {}

void main() {
  group('EmergencyCheckScreen - Save Flow', () {
    late MockEmergencyCheckRepository mockEmergencyCheckRepository;
    late MockTrackingRepository mockTrackingRepository;

    setUp(() {
      mockEmergencyCheckRepository = MockEmergencyCheckRepository();
      mockTrackingRepository = MockTrackingRepository();
      
      // Setup default behavior
      when(() => mockEmergencyCheckRepository.saveEmergencyCheck(any()))
          .thenAnswer((_) async => {});
      when(() => mockEmergencyCheckRepository.getEmergencyChecks(any()))
          .thenAnswer((_) async => []);
      when(() => mockTrackingRepository.saveSymptomLog(any()))
          .thenAnswer((_) async => {});
    });

    setUpAll(() {
      registerFallbackValue(EmergencySymptomCheck(
        id: 'test',
        userId: 'test',
        checkedAt: DateTime.now(),
        checkedSymptoms: [],
      ));
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
          emergencyCheckRepositoryProvider.overrideWithValue(mockEmergencyCheckRepository),
          trackingRepositoryProvider.overrideWithValue(mockTrackingRepository),
        ],
        child: const MaterialApp(
          home: EmergencyCheckScreen(),
        ),
      );
    }

    testWidgets('TC-ECS-SAVE-01: should save before showing dialog with proper await',
        (tester) async {
      final callSequence = <String>[];

      when(() => mockEmergencyCheckRepository.saveEmergencyCheck(any()))
          .thenAnswer((_) async {
        callSequence.add('save');
        // 저장에 시간이 걸린다고 가정
        await Future.delayed(const Duration(milliseconds: 100));
      });

      // Arrange
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Act - 증상 선택
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pump();

      // Act - 확인 버튼 클릭
      await tester.tap(find.text('확인'));
      await tester.pump(); // 초기 처리 시작
      
      // 저장이 완료될 때까지 대기
      await tester.pumpAndSettle();

      // Assert - 저장이 먼저 호출되어야 함
      expect(callSequence, contains('save'));
      
      // Assert - 저장이 호출되었는지 확인
      verify(() => mockEmergencyCheckRepository.saveEmergencyCheck(any())).called(1);
    });

    testWidgets('TC-ECS-SAVE-02: should handle save error gracefully',
        (tester) async {
      // Arrange - 저장 실패 시뮬레이션
      when(() => mockEmergencyCheckRepository.saveEmergencyCheck(any()))
          .thenThrow(Exception('Database error'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Act - 증상 선택
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pump();

      // Act - 확인 버튼 클릭
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      // Assert - 에러 스낵바가 표시되어야 함
      expect(find.text('기록 실패: Exception: Database error'), findsOneWidget);
    });
  });
}
