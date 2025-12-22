import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/tracking/domain/entities/medication.dart';

void main() {
  late Medication medication;

  setUp(() {
    medication = Medication(
      id: 'mounjaro',
      nameKo: '마운자로',
      nameEn: 'Mounjaro',
      genericName: '티르제파타이드',
      manufacturer: 'Eli Lilly',
      availableDoses: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0],
      recommendedStartDose: 2.5,
      doseUnit: 'mg',
      cycleDays: 7,
      isActive: true,
      displayOrder: 3,
      createdAt: DateTime.now(),
    );
  });

  group('displayName', () {
    test('should return English format for storage', () {
      expect(medication.displayName, 'Mounjaro (티르제파타이드)');
    });

    test('should return nameEn when genericName is empty', () {
      final med = medication.copyWith(genericName: '');
      expect(med.displayName, 'Mounjaro');
    });
  });

  group('localizedDisplayName', () {
    test('should return Korean format for ko languageCode', () {
      expect(
        medication.localizedDisplayName('ko'),
        '마운자로 (티르제파타이드)',
      );
    });

    test('should return English format for en languageCode', () {
      expect(
        medication.localizedDisplayName('en'),
        'Mounjaro (티르제파타이드)',
      );
    });

    test('should return nameKo when genericName is empty (ko)', () {
      final med = medication.copyWith(genericName: '');
      expect(med.localizedDisplayName('ko'), '마운자로');
    });

    test('should return nameEn when genericName is empty (en)', () {
      final med = medication.copyWith(genericName: '');
      expect(med.localizedDisplayName('en'), 'Mounjaro');
    });

    test('should fallback to English for unknown languageCode', () {
      expect(
        medication.localizedDisplayName('ja'),
        'Mounjaro (티르제파타이드)',
      );
    });
  });

  group('findByDisplayName', () {
    late List<Medication> medications;

    setUp(() {
      medications = [medication];
    });

    test('should find by English displayName (1차 매칭)', () {
      final found = Medication.findByDisplayName(
        medications,
        'Mounjaro (티르제파타이드)',
      );
      expect(found?.id, 'mounjaro');
    });

    test('should find by Korean displayName (2차 매칭)', () {
      final found = Medication.findByDisplayName(
        medications,
        '마운자로 (티르제파타이드)',
      );
      expect(found?.id, 'mounjaro');
    });

    test('should find by nameKo only (3차 매칭)', () {
      final found = Medication.findByDisplayName(medications, '마운자로');
      expect(found?.id, 'mounjaro');
    });

    test('should find by nameEn only (4차 매칭)', () {
      final found = Medication.findByDisplayName(medications, 'Mounjaro');
      expect(found?.id, 'mounjaro');
    });

    test('should find by nameEn case-insensitive (4차 매칭)', () {
      final found = Medication.findByDisplayName(medications, 'mounjaro');
      expect(found?.id, 'mounjaro');
    });

    test('should return null when not found', () {
      final found = Medication.findByDisplayName(medications, '존재하지않는약물');
      expect(found, isNull);
    });
  });
}
