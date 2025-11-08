# DTO Constructor Fix - Detailed Code Examples

## File: test/features/data_sharing/infrastructure/repositories/isar_shared_data_repository_test.dart

### Transformation 1: DoseRecordDto in "fetch dose records" test (Lines 48-57)

**Original Code (BROKEN):**
```dart
await isar.doseRecordDtos.putAll([
  DoseRecordDto(
    id: '1',
    dosagePlanId: 'plan1',
    administeredAt: startDate.add(const Duration(days: 5)),
    actualDoseMg: 0.25,
    isCompleted: true,
  ),
  DoseRecordDto(
    id: '2',
    dosagePlanId: 'plan1',
    administeredAt: endDate.add(const Duration(days: 10)), // Outside range
    actualDoseMg: 0.25,
    isCompleted: true,
  ),
]);
```

**Fixed Code (CORRECT):**
```dart
await isar.doseRecordDtos.putAll([
  DoseRecordDto()
    ..dosagePlanId = 'plan1'
    ..administeredAt = startDate.add(const Duration(days: 5))
    ..actualDoseMg = 0.25
    ..isCompleted = true,
  DoseRecordDto()
    ..dosagePlanId = 'plan1'
    ..administeredAt = endDate.add(const Duration(days: 10)) // Outside range
    ..actualDoseMg = 0.25
    ..isCompleted = true,
]);
```

**Changes:**
- Changed `DoseRecordDto(...)` to `DoseRecordDto()`
- Removed `id: '1',` and `id: '2',` parameters
- Converted all named parameters to cascade assignments with `..fieldName = value`
- Preserved all field values and test logic

---

### Transformation 2: WeightLogDto in "fetch weight logs" test (Lines 75-82)

**Original Code (BROKEN):**
```dart
await isar.weightLogDtos.putAll([
  WeightLogDto(
    id: '1',
    userId: userId,
    logDate: startDate.add(const Duration(days: 5)),
    weightKg: 75.5,
  ),
  WeightLogDto(
    id: '2',
    userId: userId,
    logDate: startDate.subtract(const Duration(days: 40)), // Outside 30-day range
    weightKg: 76.0,
  ),
]);
```

**Fixed Code (CORRECT):**
```dart
await isar.weightLogDtos.putAll([
  WeightLogDto()
    ..userId = userId
    ..logDate = startDate.add(const Duration(days: 5))
    ..weightKg = 75.5,
  WeightLogDto()
    ..userId = userId
    ..logDate = startDate.subtract(const Duration(days: 40)) // Outside 30-day range
    ..weightKg = 76.0,
]);
```

**Changes:**
- Changed `WeightLogDto(...)` to `WeightLogDto()`
- Removed `id: '1',` and `id: '2',` parameters
- Converted to cascade notation for remaining fields
- Note: WeightLogDto has `Id id = Isar.autoIncrement;` so id is auto-managed

---

### Transformation 3: SymptomLogDto in "fetch symptom logs" test (Lines 100-109)

**Original Code (BROKEN):**
```dart
await isar.symptomLogDtos.putAll([
  SymptomLogDto(
    id: '1',
    userId: userId,
    logDate: startDate.add(const Duration(days: 5)),
    symptomName: '메스꺼움',
    severity: 5,
  ),
  SymptomLogDto(
    id: '2',
    userId: userId,
    logDate: startDate.subtract(const Duration(days: 40)),
    symptomName: '두통',
    severity: 3,
  ),
]);
```

**Fixed Code (CORRECT):**
```dart
await isar.symptomLogDtos.putAll([
  SymptomLogDto()
    ..userId = userId
    ..logDate = startDate.add(const Duration(days: 5))
    ..symptomName = '메스꺼움'
    ..severity = 5,
  SymptomLogDto()
    ..userId = userId
    ..logDate = startDate.subtract(const Duration(days: 40))
    ..symptomName = '두통'
    ..severity = 3,
]);
```

**Changes:**
- Changed `SymptomLogDto(...)` to `SymptomLogDto()`
- Removed `id:` parameters
- All field assignments now use cascade notation
- Korean characters (메스꺼움, 두통) preserved

---

### Transformation 4: DoseScheduleDto in "fetch schedules" test (Lines 161-168)

**Original Code (BROKEN):**
```dart
await isar.doseScheduleDtos.putAll([
  DoseScheduleDto(
    id: '1',
    dosagePlanId: 'plan1',
    scheduledDate: startDate.add(const Duration(days: 0)),
    scheduledDoseMg: 0.25,
  ),
  DoseScheduleDto(
    id: '2',
    dosagePlanId: 'plan1',
    scheduledDate: startDate.add(const Duration(days: 7)),
    scheduledDoseMg: 0.25,
  ),
]);
```

**Fixed Code (CORRECT):**
```dart
await isar.doseScheduleDtos.putAll([
  DoseScheduleDto()
    ..dosagePlanId = 'plan1'
    ..scheduledDate = startDate.add(const Duration(days: 0))
    ..scheduledDoseMg = 0.25,
  DoseScheduleDto()
    ..dosagePlanId = 'plan1'
    ..scheduledDate = startDate.add(const Duration(days: 7))
    ..scheduledDoseMg = 0.25,
]);
```

**Changes:**
- Changed `DoseScheduleDto(...)` to `DoseScheduleDto()`
- Removed `id:` parameters
- Converted to cascade notation
- This DTO has `Id? id = Isar.autoIncrement;` (nullable)

---

### Transformation 5: Single Instance in "partial data" test (Lines 138-142)

**Original Code (BROKEN):**
```dart
await isar.doseRecordDtos.put(
  DoseRecordDto(
    id: '1',
    dosagePlanId: 'plan1',
    administeredAt: startDate.add(const Duration(days: 5)),
    actualDoseMg: 0.25,
    isCompleted: true,
  ),
);
```

**Fixed Code (CORRECT):**
```dart
await isar.doseRecordDtos.put(
  DoseRecordDto()
    ..dosagePlanId = 'plan1'
    ..administeredAt = startDate.add(const Duration(days: 5))
    ..actualDoseMg = 0.25
    ..isCompleted = true,
);
```

**Changes:**
- Same pattern but using `.put()` instead of `.putAll()`
- Single instance instead of array
- All cascade notation applied

---

## Why These Changes Were Necessary

### The Problem

The DTO classes are defined like this:
```dart
@collection
class DoseRecordDto {
  Id? id = Isar.autoIncrement;  // Field with default value, NOT a constructor parameter
  late String dosagePlanId;
  // ...
  
  DoseRecordDto();  // Empty constructor with no parameters
}
```

The empty constructor `DoseRecordDto()` has NO parameters, so trying to pass named arguments like `id:`, `dosagePlanId:`, etc. causes a compilation error: "The named parameter X isn't defined"

### The Solution

Use cascade notation to set fields after object creation:
```dart
DoseRecordDto()          // Create instance with empty constructor
  ..dosagePlanId = 'plan1'  // Assign fields using cascade operator (..)
  ..administeredAt = now
```

### Why the id field is not set

1. The `id` field has `Isar.autoIncrement` as default value
2. Isar manages the id field automatically when the object is persisted
3. Setting it manually would interfere with Isar's auto-increment mechanism
4. Therefore, id is intentionally left unset - Isar will assign it

---

## Verification Results

### Compilation Check
- No "undefined_named_parameter" errors
- No "missing_required_argument" errors
- Dart syntax validation: PASSED

### Code Inspection
- 14 DTO instantiations verified
- 0 remaining `id:` parameters
- All 14 cascade notations correctly formatted
- All field values preserved

### Test Logic
- No changes to test assertions
- No changes to test flow
- Only syntax of DTO instantiation changed

