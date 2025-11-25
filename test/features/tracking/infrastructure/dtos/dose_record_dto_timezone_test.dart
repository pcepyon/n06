import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/infrastructure/dtos/dose_record_dto.dart';

void main() {
  group('DoseRecordDto - Timezone Handling', () {
    // TC-DRD-TZ-01: UTC timestamp from Supabase should be converted to local time
    test('should convert UTC timestamp to local time when parsing from JSON', () {
      // Arrange - Supabase returns UTC timestamp with Z suffix
      final json = {
        'id': 'test-id',
        'dose_schedule_id': 'schedule-1',
        'dosage_plan_id': 'plan-1',
        'administered_at': '2025-11-25T15:00:00.000Z', // UTC 15:00
        'actual_dose_mg': 0.5,
        'injection_site': 'abdomen_upper_left',
        'is_completed': true,
        'note': 'test note',
        'created_at': '2025-11-25T15:00:00.000Z', // UTC 15:00
      };

      // Act
      final dto = DoseRecordDto.fromJson(json);

      // Assert - Should be converted to local time (KST = UTC+9)
      // UTC 15:00 → KST 00:00 (next day)
      expect(dto.administeredAt.isUtc, false, reason: 'Should be converted to local time');
      expect(dto.administeredAt.hour, isNot(15), reason: 'Should not be 15:00 (UTC time)');
      
      // Verify it's actually local time by checking offset
      final localNow = DateTime.now();
      expect(dto.administeredAt.isUtc, localNow.isUtc, reason: 'Should match local time zone');
    });

    // TC-DRD-TZ-02: UTC timestamp with +00:00 offset should be converted to local time
    test('should convert UTC timestamp with +00:00 offset to local time', () {
      // Arrange - Supabase might return UTC with explicit +00:00
      final json = {
        'id': 'test-id',
        'dose_schedule_id': 'schedule-1',
        'dosage_plan_id': 'plan-1',
        'administered_at': '2025-11-25T15:00:00+00:00', // UTC 15:00
        'actual_dose_mg': 0.5,
        'injection_site': 'abdomen_upper_left',
        'is_completed': true,
        'note': null,
        'created_at': '2025-11-25T15:00:00+00:00',
      };

      // Act
      final dto = DoseRecordDto.fromJson(json);

      // Assert
      expect(dto.administeredAt.isUtc, false, reason: 'Should be local time');
      expect(dto.createdAt.isUtc, false, reason: 'Should be local time');
    });

    // TC-DRD-TZ-03: Prevent "future date" validation error due to timezone confusion
    test('should not throw "future date" error when UTC timestamp is properly converted', () {
      // Arrange - Create a timestamp that is in the past in UTC but might appear future in local time
      final now = DateTime.now();
      final pastUtc = now.subtract(const Duration(hours: 2)).toUtc();
      
      final json = {
        'id': 'test-id',
        'dose_schedule_id': 'schedule-1',
        'dosage_plan_id': 'plan-1',
        'administered_at': pastUtc.toIso8601String(), // Past in UTC
        'actual_dose_mg': 0.5,
        'injection_site': 'abdomen_upper_left',
        'is_completed': true,
        'note': null,
        'created_at': pastUtc.toIso8601String(),
      };

      // Act
      final dto = DoseRecordDto.fromJson(json);

      // Assert - Should not throw when converting to entity
      expect(() => dto.toEntity(), returnsNormally, 
        reason: 'Should not throw "Administered date cannot be in the future" error');
      
      // Verify the timestamp is in the past
      final entity = dto.toEntity();
      expect(entity.administeredAt.isBefore(DateTime.now()), true,
        reason: 'Administered time should be in the past');
    });

    // TC-DRD-TZ-04: Round-trip conversion should preserve time correctly
    test('should preserve time correctly in round-trip conversion', () {
      // Arrange - Start with a local time
      final localTime = DateTime.now().subtract(const Duration(hours: 1));
      
      final originalDto = DoseRecordDto(
        id: 'test-id',
        doseScheduleId: 'schedule-1',
        dosagePlanId: 'plan-1',
        administeredAt: localTime,
        actualDoseMg: 0.5,
        injectionSite: 'abdomen',
        isCompleted: true,
        note: null,
        createdAt: localTime,
      );

      // Act - Convert to JSON (simulating save to Supabase)
      final json = originalDto.toJson();
      
      // Simulate Supabase storing as UTC and returning UTC
      // (In real scenario, Supabase would do this conversion)
      final utcString = DateTime.parse(json['administered_at'] as String)
          .toUtc()
          .toIso8601String();
      
      final retrievedJson = {...json, 'administered_at': utcString, 'created_at': utcString};
      
      // Convert back from JSON (simulating retrieval from Supabase)
      final retrievedDto = DoseRecordDto.fromJson(retrievedJson);

      // Assert - Times should be equivalent (within 1 second due to precision)
      final timeDiff = retrievedDto.administeredAt.difference(localTime).inSeconds.abs();
      expect(timeDiff, lessThan(2), 
        reason: 'Round-trip conversion should preserve time within 1 second');
    });
  });
}
