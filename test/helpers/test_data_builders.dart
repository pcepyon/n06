// Test data builders for creating test entities
//
// Usage:
// ```dart
// final user = UserBuilder()
//   .withId('user123')
//   .withName('Test User')
//   .build();
//
// final dose = DoseBuilder()
//   .withDoseMg(0.5)
//   .withAdministeredAt(DateTime.now())
//   .build();
// ```
library;

/// Base builder class with common functionality
abstract class TestDataBuilder<T> {
  T build();
}

/// Builder for creating test user data
///
/// TODO: Update with actual User entity when domain layer is implemented
class UserBuilder extends TestDataBuilder<Map<String, dynamic>> {
  String id = 'test-user-id';
  String name = 'Test User';
  String email = 'test@example.com';
  String? profileImageUrl;
  String oauthProvider = 'kakao';

  UserBuilder withId(String value) {
    id = value;
    return this;
  }

  UserBuilder withName(String value) {
    name = value;
    return this;
  }

  UserBuilder withEmail(String value) {
    email = value;
    return this;
  }

  UserBuilder withProfileImage(String value) {
    profileImageUrl = value;
    return this;
  }

  UserBuilder withOAuthProvider(String value) {
    oauthProvider = value;
    return this;
  }

  @override
  Map<String, dynamic> build() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'oauthProvider': oauthProvider,
    };
  }
}

/// Builder for creating test dose data
///
/// TODO: Update with actual Dose entity when domain layer is implemented
class DoseBuilder extends TestDataBuilder<Map<String, dynamic>> {
  int id = 1;
  double doseMg = 0.25;
  DateTime administeredAt = DateTime(2024, 1, 1, 9, 0);
  String? injectionSite;
  String? note;

  DoseBuilder withId(int value) {
    id = value;
    return this;
  }

  DoseBuilder withDoseMg(double value) {
    doseMg = value;
    return this;
  }

  DoseBuilder withAdministeredAt(DateTime value) {
    administeredAt = value;
    return this;
  }

  DoseBuilder withInjectionSite(String value) {
    injectionSite = value;
    return this;
  }

  DoseBuilder withNote(String value) {
    note = value;
    return this;
  }

  @override
  Map<String, dynamic> build() {
    return {
      'id': id,
      'doseMg': doseMg,
      'administeredAt': administeredAt.toIso8601String(),
      'injectionSite': injectionSite,
      'note': note,
    };
  }
}

/// Builder for creating test weight log data
class WeightLogBuilder extends TestDataBuilder<Map<String, dynamic>> {
  int id = 1;
  String userId = 'test-user-id';
  DateTime logDate = DateTime(2024, 1, 1);
  double weightKg = 70.0;

  WeightLogBuilder withId(int value) {
    id = value;
    return this;
  }

  WeightLogBuilder withUserId(String value) {
    userId = value;
    return this;
  }

  WeightLogBuilder withLogDate(DateTime value) {
    logDate = value;
    return this;
  }

  WeightLogBuilder withWeightKg(double value) {
    weightKg = value;
    return this;
  }

  @override
  Map<String, dynamic> build() {
    return {
      'id': id,
      'userId': userId,
      'logDate': logDate.toIso8601String(),
      'weightKg': weightKg,
    };
  }
}

/// Builder for creating test symptom log data
class SymptomLogBuilder extends TestDataBuilder<Map<String, dynamic>> {
  int id = 1;
  String userId = 'test-user-id';
  DateTime logDate = DateTime(2024, 1, 1);
  String symptomName = '메스꺼움';
  int severity = 5;
  int? daysSinceEscalation;
  bool? isPersistent24h;
  String? note;
  List<String> contextTags = [];

  SymptomLogBuilder withId(int value) {
    id = value;
    return this;
  }

  SymptomLogBuilder withUserId(String value) {
    userId = value;
    return this;
  }

  SymptomLogBuilder withLogDate(DateTime value) {
    logDate = value;
    return this;
  }

  SymptomLogBuilder withSymptomName(String value) {
    symptomName = value;
    return this;
  }

  SymptomLogBuilder withSeverity(int value) {
    severity = value;
    return this;
  }

  SymptomLogBuilder withDaysSinceEscalation(int value) {
    daysSinceEscalation = value;
    return this;
  }

  SymptomLogBuilder withPersistent24h(bool value) {
    isPersistent24h = value;
    return this;
  }

  SymptomLogBuilder withNote(String value) {
    note = value;
    return this;
  }

  SymptomLogBuilder withContextTags(List<String> value) {
    contextTags = value;
    return this;
  }

  @override
  Map<String, dynamic> build() {
    return {
      'id': id,
      'userId': userId,
      'logDate': logDate.toIso8601String(),
      'symptomName': symptomName,
      'severity': severity,
      'daysSinceEscalation': daysSinceEscalation,
      'isPersistent24h': isPersistent24h,
      'note': note,
      'contextTags': contextTags,
    };
  }
}

/// Builder for creating test dosage plan data
class DosagePlanBuilder extends TestDataBuilder<Map<String, dynamic>> {
  int id = 1;
  String userId = 'test-user-id';
  String medicationName = 'Ozempic';
  DateTime startDate = DateTime(2024, 1, 1);
  int cycleDays = 7;
  double initialDoseMg = 0.25;
  List<Map<String, dynamic>> escalationPlan = [];
  bool isActive = true;

  DosagePlanBuilder withId(int value) {
    id = value;
    return this;
  }

  DosagePlanBuilder withUserId(String value) {
    userId = value;
    return this;
  }

  DosagePlanBuilder withMedicationName(String value) {
    medicationName = value;
    return this;
  }

  DosagePlanBuilder withStartDate(DateTime value) {
    startDate = value;
    return this;
  }

  DosagePlanBuilder withCycleDays(int value) {
    cycleDays = value;
    return this;
  }

  DosagePlanBuilder withInitialDoseMg(double value) {
    initialDoseMg = value;
    return this;
  }

  DosagePlanBuilder withEscalationPlan(List<Map<String, dynamic>> value) {
    escalationPlan = value;
    return this;
  }

  DosagePlanBuilder withIsActive(bool value) {
    isActive = value;
    return this;
  }

  @override
  Map<String, dynamic> build() {
    return {
      'id': id,
      'userId': userId,
      'medicationName': medicationName,
      'startDate': startDate.toIso8601String(),
      'cycleDays': cycleDays,
      'initialDoseMg': initialDoseMg,
      'escalationPlan': escalationPlan,
      'isActive': isActive,
    };
  }
}
