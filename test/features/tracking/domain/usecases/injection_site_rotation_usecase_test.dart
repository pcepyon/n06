import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/domain/usecases/injection_site_rotation_usecase.dart';

void main() {
  group('InjectionSiteRotationUseCase', () {
    late InjectionSiteRotationUseCase useCase;

    setUp(() {
      useCase = InjectionSiteRotationUseCase();
    });

    group('rotation checking', () {
      test('should return no warning when no recent records', () {
        final result = useCase.checkRotation('abdomen', []);

        expect(result.needsWarning, false);
        expect(result.message, isEmpty);
      });

      test('should return warning when same site used within 7 days', () {
        final now = DateTime.now();
        final recentRecord = DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: now.subtract(Duration(days: 3)),
          actualDoseMg: 0.25,
          injectionSite: 'abdomen',
        );

        final result = useCase.checkRotation('abdomen', [recentRecord]);

        expect(result.needsWarning, true);
        expect(result.message.contains('3'), true);
        expect(result.daysSinceLastUse, 3);
      });

      test('should return no warning when same site used 8 days ago', () {
        final now = DateTime.now();
        final recentRecord = DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: now.subtract(Duration(days: 8)),
          actualDoseMg: 0.25,
          injectionSite: 'abdomen',
        );

        final result = useCase.checkRotation('abdomen', [recentRecord]);

        expect(result.needsWarning, false);
      });

      test('should return no warning when different site used recently', () {
        final now = DateTime.now();
        final recentRecord = DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: now.subtract(Duration(days: 2)),
          actualDoseMg: 0.25,
          injectionSite: 'abdomen',
        );

        final result = useCase.checkRotation('thigh', [recentRecord]);

        expect(result.needsWarning, false);
      });

      test('should handle multiple recent records of same site', () {
        final now = DateTime.now();
        final records = [
          DoseRecord(
            id: 'record-1',
            dosagePlanId: 'plan-1',
            administeredAt: now.subtract(Duration(days: 2)),
            actualDoseMg: 0.25,
            injectionSite: 'arm',
          ),
          DoseRecord(
            id: 'record-2',
            dosagePlanId: 'plan-1',
            administeredAt: now.subtract(Duration(days: 5)),
            actualDoseMg: 0.25,
            injectionSite: 'arm',
          ),
        ];

        final result = useCase.checkRotation('arm', records);

        expect(result.needsWarning, true);
        expect(result.daysSinceLastUse, 2); // Most recent
      });
    });

    group('site history visualization', () {
      test('should visualize site usage for last 30 days', () {
        final now = DateTime.now();
        final records = [
          DoseRecord(
            id: 'record-1',
            dosagePlanId: 'plan-1',
            administeredAt: now.subtract(Duration(days: 1)),
            actualDoseMg: 0.25,
            injectionSite: 'abdomen',
          ),
          DoseRecord(
            id: 'record-2',
            dosagePlanId: 'plan-1',
            administeredAt: now.subtract(Duration(days: 8)),
            actualDoseMg: 0.25,
            injectionSite: 'thigh',
          ),
          DoseRecord(
            id: 'record-3',
            dosagePlanId: 'plan-1',
            administeredAt: now.subtract(Duration(days: 15)),
            actualDoseMg: 0.25,
            injectionSite: 'arm',
          ),
          DoseRecord(
            id: 'record-4',
            dosagePlanId: 'plan-1',
            administeredAt: now.subtract(Duration(days: 35)), // Older than 30 days
            actualDoseMg: 0.25,
            injectionSite: 'abdomen',
          ),
        ];

        final siteHistory = useCase.getSiteHistoryList(records);

        expect(siteHistory.length, 3); // Only last 30 days
        expect(siteHistory.contains('abdomen'), true);
        expect(siteHistory.contains('thigh'), true);
        expect(siteHistory.contains('arm'), true);
      });
    });
  });
}
