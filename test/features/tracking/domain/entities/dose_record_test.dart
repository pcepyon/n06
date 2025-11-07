import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';

void main() {
  group('DoseRecord', () {
    test('should create dose record with required fields', () {
      final record = DoseRecord(
        id: 'record-1',
        dosagePlanId: 'plan-1',
        administeredAt: DateTime(2025, 1, 8, 10, 0),
        actualDoseMg: 0.25,
        isCompleted: true,
      );

      expect(record.id, 'record-1');
      expect(record.dosagePlanId, 'plan-1');
      expect(record.actualDoseMg, 0.25);
      expect(record.isCompleted, true);
    });

    test('should throw exception when administered date is in future', () {
      expect(
        () => DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime.now().add(Duration(hours: 1)),
          actualDoseMg: 0.25,
        ),
        throwsArgumentError,
      );
    });

    test('should throw exception when actual dose is negative', () {
      expect(
        () => DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime.now(),
          actualDoseMg: -0.25,
        ),
        throwsArgumentError,
      );
    });

    test('should throw exception for invalid injection site', () {
      expect(
        () => DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime.now(),
          actualDoseMg: 0.25,
          injectionSite: 'invalid_site',
        ),
        throwsArgumentError,
      );
    });

    test('should validate valid injection sites', () {
      final abdomen = DoseRecord(
        id: 'record-1',
        dosagePlanId: 'plan-1',
        administeredAt: DateTime.now(),
        actualDoseMg: 0.25,
        injectionSite: 'abdomen',
      );
      expect(abdomen.injectionSite, 'abdomen');

      final thigh = DoseRecord(
        id: 'record-2',
        dosagePlanId: 'plan-1',
        administeredAt: DateTime.now(),
        actualDoseMg: 0.25,
        injectionSite: 'thigh',
      );
      expect(thigh.injectionSite, 'thigh');

      final arm = DoseRecord(
        id: 'record-3',
        dosagePlanId: 'plan-1',
        administeredAt: DateTime.now(),
        actualDoseMg: 0.25,
        injectionSite: 'arm',
      );
      expect(arm.injectionSite, 'arm');
    });

    group('state checking', () {
      test('should detect if record is completed', () {
        final record = DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime.now(),
          actualDoseMg: 0.25,
          isCompleted: true,
        );

        expect(record.isCompleted, true);
      });

      test('should calculate days since administration', () {
        final record = DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime.now().subtract(Duration(days: 3)),
          actualDoseMg: 0.25,
        );

        expect(record.daysSinceAdministration(), 3);
      });
    });

    group('copyWith', () {
      test('should copy record with updated fields', () {
        final original = DoseRecord(
          id: 'record-1',
          dosagePlanId: 'plan-1',
          administeredAt: DateTime(2025, 1, 8, 10, 0),
          actualDoseMg: 0.25,
        );

        final updated = original.copyWith(
          injectionSite: 'abdomen',
          note: 'Left abdomen',
        );

        expect(updated.id, original.id);
        expect(updated.actualDoseMg, original.actualDoseMg);
        expect(updated.injectionSite, 'abdomen');
        expect(updated.note, 'Left abdomen');
      });
    });
  });
}
