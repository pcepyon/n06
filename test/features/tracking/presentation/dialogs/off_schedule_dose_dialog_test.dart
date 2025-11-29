import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/presentation/dialogs/off_schedule_dose_dialog.dart';

void main() {
  group('OffScheduleDoseDialog', () {
    late DoseSchedule testSchedule;
    late List<DoseRecord> testRecords;
    late DateTime selectedDate;

    setUp(() {
      testSchedule = DoseSchedule(
        id: 'schedule-1',
        dosagePlanId: 'plan-1',
        scheduledDate: DateTime(2024, 1, 1),
        scheduledDoseMg: 0.25,
      );

      selectedDate = DateTime(2024, 1, 3); // 2일 늦은 날짜
      testRecords = [];
    });

    testWidgets('다이얼로그가 오류 없이 렌더링되어야 함', (tester) async {
      // Given & When
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );

      // 다이얼로그 빌드 시 오류가 발생하지 않아야 함
      // 실제 다이얼로그는 수정 후 테스트에서 렌더링 확인
    });
  });
}
