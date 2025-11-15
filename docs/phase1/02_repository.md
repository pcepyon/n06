# Phase 1.2: Supabase Repository 구현

**목표**: 13개 Repository의 Supabase 구현체 작성 및 DTO 변환

**소요 기간**: 2주

**담당**: Backend 엔지니어 × 2명

---

## 1. 작업 개요

### 1.1 구현 대상

| Feature | Repository | 우선순위 | 예상 공수 | 담당자 |
|---------|-----------|---------|----------|--------|
| **authentication** | `SupabaseAuthRepository` | P0 | 3일 | 엔지니어 A |
| **onboarding** | `SupabaseProfileRepository` | P0 | 1일 | 엔지니어 A |
| **onboarding** | `SupabaseUserRepository` | P0 | 1일 | 엔지니어 A |
| **tracking** | `SupabaseMedicationRepository` | P0 | 2일 | 엔지니어 B |
| **tracking** | `SupabaseDosagePlanRepository` | P0 | 2일 | 엔지니어 B |
| **tracking** | `SupabaseDoseScheduleRepository` | P0 | 1일 | 엔지니어 B |
| **tracking** | `SupabaseTrackingRepository` | P0 | 2일 | 엔지니어 A |
| **tracking** | `SupabaseEmergencyCheckRepository` | P1 | 1일 | 엔지니어 B |
| **tracking** | `SupabaseAuditRepository` | P1 | 1일 | 엔지니어 A |
| **dashboard** | `SupabaseBadgeRepository` | P1 | 1일 | 엔지니어 B |
| **notification** | `SupabaseNotificationRepository` | P1 | 1일 | 엔지니어 A |
| **coping_guide** | `SupabaseFeedbackRepository` | P2 | 1일 | 엔지니어 B |
| **data_sharing** | `SupabaseSharedDataRepository` | P1 | 1일 | 엔지니어 A |

**총 공수**: 18일 (병렬 작업 시 약 9일)

### 1.2 작업 흐름

```
[DTO 변환] (1일)
    ↓
[P0 Repository 구현] (5일) - 병렬
    ↓
[P1 Repository 구현] (3일) - 병렬
    ↓
[Provider DI 수정] (1일)
    ↓
[코드 리뷰 & 테스트] (2일)
```

---

## 2. DTO 변환 (Isar → Supabase)

### 2.1 변환 원칙

**Before (Isar DTO)**:
- `@collection` 어노테이션
- `Id id = Isar.autoIncrement` (int)
- Isar-specific 필드 타입

**After (Supabase DTO)**:
- 일반 Dart 클래스
- `String id` (UUID)
- `fromJson()`, `toJson()` 메서드
- `toEntity()`, `fromEntity()` 메서드 유지

### 2.2 변환 예시: WeightLogDto

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/dtos/weight_log_dto.dart`

**Before (Isar)**:
```dart
import 'package:isar/isar.dart';
import '../../domain/entities/weight_log.dart';

part 'weight_log_dto.g.dart';

@collection
class WeightLogDto {
  Id id = Isar.autoIncrement;
  late String userId;
  late DateTime logDate;
  late double weightKg;
  late DateTime createdAt;

  WeightLog toEntity() {
    return WeightLog(
      id: id.toString(),
      userId: userId,
      logDate: logDate,
      weightKg: weightKg,
      createdAt: createdAt,
    );
  }

  static WeightLogDto fromEntity(WeightLog entity) {
    return WeightLogDto()
      ..id = int.tryParse(entity.id) ?? Isar.autoIncrement
      ..userId = entity.userId
      ..logDate = entity.logDate
      ..weightKg = entity.weightKg
      ..createdAt = entity.createdAt;
  }
}
```

**After (Supabase)**:
```dart
import '../../domain/entities/weight_log.dart';

class WeightLogDto {
  final String id;
  final String userId;
  final DateTime logDate;
  final double weightKg;
  final DateTime createdAt;

  const WeightLogDto({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.weightKg,
    required this.createdAt,
  });

  // Supabase JSON 직렬화
  factory WeightLogDto.fromJson(Map<String, dynamic> json) {
    return WeightLogDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String().split('T')[0], // DATE 형식
      'weight_kg': weightKg,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Entity 변환 (기존 유지)
  WeightLog toEntity() {
    return WeightLog(
      id: id,
      userId: userId,
      logDate: logDate,
      weightKg: weightKg,
      createdAt: createdAt,
    );
  }

  static WeightLogDto fromEntity(WeightLog entity) {
    return WeightLogDto(
      id: entity.id,
      userId: entity.userId,
      logDate: entity.logDate,
      weightKg: entity.weightKg,
      createdAt: entity.createdAt,
    );
  }
}
```

### 2.3 변환 작업 체크리스트 (17개 DTO)

#### Authentication Feature
- [ ] `lib/features/authentication/infrastructure/dtos/user_dto.dart`
- [ ] `lib/features/authentication/infrastructure/dtos/consent_record_dto.dart`

#### Onboarding Feature
- [ ] `lib/features/onboarding/infrastructure/dtos/user_profile_dto.dart`
- [ ] `lib/features/onboarding/infrastructure/dtos/escalation_step_dto.dart` (embedded)

#### Tracking Feature
- [ ] `lib/features/tracking/infrastructure/dtos/dosage_plan_dto.dart`
- [ ] `lib/features/tracking/infrastructure/dtos/plan_change_history_dto.dart`
- [ ] `lib/features/tracking/infrastructure/dtos/dose_schedule_dto.dart`
- [ ] `lib/features/tracking/infrastructure/dtos/dose_record_dto.dart`
- [ ] `lib/features/tracking/infrastructure/dtos/weight_log_dto.dart`
- [ ] `lib/features/tracking/infrastructure/dtos/symptom_log_dto.dart`
- [ ] `lib/features/tracking/infrastructure/dtos/symptom_context_tag_dto.dart`
- [ ] `lib/features/tracking/infrastructure/dtos/emergency_symptom_check_dto.dart`

#### Dashboard Feature
- [ ] `lib/features/dashboard/infrastructure/dtos/badge_definition_dto.dart`
- [ ] `lib/features/dashboard/infrastructure/dtos/user_badge_dto.dart`

#### Notification Feature
- [ ] `lib/features/notification/infrastructure/dtos/notification_settings_dto.dart`

#### Coping Guide Feature
- [ ] `lib/features/coping_guide/infrastructure/dtos/guide_feedback_dto.dart`

#### 신규 추가
- [ ] `lib/features/tracking/infrastructure/dtos/audit_log_dto.dart` (신규)

### 2.4 주의사항

**날짜/시간 변환**:
```dart
// DATE 타입 (날짜만)
'log_date': logDate.toIso8601String().split('T')[0], // "2024-01-15"

// TIMESTAMPTZ 타입 (날짜+시간)
'created_at': createdAt.toIso8601String(), // "2024-01-15T10:30:00.000Z"

// TIME 타입 (시간만)
'notification_time': '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00'
```

**JSONB 필드**:
```dart
// escalation_plan (JSONB)
'escalation_plan': escalationPlan?.map((step) => step.toJson()).toList(),

// checked_symptoms (JSONB)
'checked_symptoms': checkedSymptoms, // List<String>을 그대로 전달
```

**NULL 처리**:
```dart
// Nullable 필드
userId: json['user_id'] as String?, // nullable
doseScheduleId: json['dose_schedule_id'] as String?, // nullable

// toJson에서 null 제외
Map<String, dynamic> toJson() {
  final map = <String, dynamic>{
    'id': id,
    'user_id': userId,
  };
  if (doseScheduleId != null) {
    map['dose_schedule_id'] = doseScheduleId;
  }
  return map;
}
```

---

## 3. Repository 구현

### 3.1 구현 패턴

**파일 위치**: `lib/features/{feature}/infrastructure/repositories/supabase_{feature}_repository.dart`

**기본 구조**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/{feature}_repository.dart';
import '../../domain/entities/{entity}.dart';
import '../dtos/{entity}_dto.dart';

class Supabase{Feature}Repository implements {Feature}Repository {
  final SupabaseClient _supabase;

  Supabase{Feature}Repository(this._supabase);

  // CRUD 메서드 구현
}
```

### 3.2 예시: SupabaseTrackingRepository

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart`

**새 파일 생성**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../../domain/entities/weight_log.dart';
import '../../domain/entities/symptom_log.dart';
import '../dtos/weight_log_dto.dart';
import '../dtos/symptom_log_dto.dart';
import '../dtos/symptom_context_tag_dto.dart';

class SupabaseTrackingRepository implements TrackingRepository {
  final SupabaseClient _supabase;

  SupabaseTrackingRepository(this._supabase);

  // ============================================
  // Weight Logs
  // ============================================

  @override
  Future<List<WeightLog>> getWeightLogs(String userId) async {
    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .order('log_date', ascending: false);

    return (response as List)
        .map((json) => WeightLogDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> saveWeightLog(WeightLog log) async {
    final dto = WeightLogDto.fromEntity(log);

    // UNIQUE (user_id, log_date) 제약 자동 처리
    await _supabase.from('weight_logs').upsert(
      dto.toJson(),
      onConflict: 'user_id,log_date',
    );
  }

  @override
  Future<void> deleteWeightLog(String id) async {
    await _supabase.from('weight_logs').delete().eq('id', id);
  }

  @override
  Future<void> updateWeightLog(String id, double newWeight) async {
    await _supabase
        .from('weight_logs')
        .update({'weight_kg': newWeight})
        .eq('id', id);
  }

  @override
  Future<WeightLog?> getWeightLog(String userId, DateTime date) async {
    final response = await _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', date.toIso8601String().split('T')[0])
        .maybeSingle();

    if (response == null) return null;
    return WeightLogDto.fromJson(response).toEntity();
  }

  @override
  Stream<List<WeightLog>> watchWeightLogs(String userId) {
    return _supabase
        .from('weight_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('log_date', ascending: false)
        .map((data) => data
            .map((json) => WeightLogDto.fromJson(json).toEntity())
            .toList());
  }

  // ============================================
  // Symptom Logs
  // ============================================

  @override
  Future<List<SymptomLog>> getSymptomLogs(String userId) async {
    final response = await _supabase
        .from('symptom_logs')
        .select('*, symptom_context_tags(*)')
        .eq('user_id', userId)
        .order('log_date', ascending: false);

    return (response as List).map((json) {
      final dto = SymptomLogDto.fromJson(json);
      return dto.toEntity();
    }).toList();
  }

  @override
  Future<void> saveSymptomLog(SymptomLog log) async {
    final dto = SymptomLogDto.fromEntity(log);

    // 트랜잭션: symptom_log + context_tags
    await _supabase.rpc('save_symptom_log_with_tags', params: {
      'p_symptom_log': dto.toJson(),
      'p_tags': log.contextTags,
    });

    // 또는 수동 트랜잭션:
    // 1. symptom_log 저장
    final symptomResponse = await _supabase
        .from('symptom_logs')
        .insert(dto.toJson())
        .select()
        .single();

    // 2. context_tags 저장
    if (log.contextTags.isNotEmpty) {
      final tags = log.contextTags.map((tag) => {
        'symptom_log_id': symptomResponse['id'],
        'tag_name': tag,
      }).toList();

      await _supabase.from('symptom_context_tags').insert(tags);
    }
  }

  @override
  Future<void> deleteSymptomLog(String id) async {
    // CASCADE DELETE로 context_tags도 자동 삭제
    await _supabase.from('symptom_logs').delete().eq('id', id);
  }

  @override
  Future<void> updateSymptomLog(String id, SymptomLog updatedLog) async {
    final dto = SymptomLogDto.fromEntity(updatedLog);

    // 1. symptom_log 업데이트
    await _supabase
        .from('symptom_logs')
        .update(dto.toJson())
        .eq('id', id);

    // 2. context_tags 재생성 (기존 삭제 후 새로 추가)
    await _supabase.from('symptom_context_tags').delete().eq('symptom_log_id', id);

    if (updatedLog.contextTags.isNotEmpty) {
      final tags = updatedLog.contextTags.map((tag) => {
        'symptom_log_id': id,
        'tag_name': tag,
      }).toList();

      await _supabase.from('symptom_context_tags').insert(tags);
    }
  }

  @override
  Stream<List<SymptomLog>> watchSymptomLogs(String userId) {
    return _supabase
        .from('symptom_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('log_date', ascending: false)
        .map((data) => data
            .map((json) => SymptomLogDto.fromJson(json).toEntity())
            .toList());
  }

  @override
  Future<DateTime?> getLatestDoseEscalationDate(String userId) async {
    final response = await _supabase
        .from('plan_change_history')
        .select('changed_at, dosage_plans!inner(user_id)')
        .eq('dosage_plans.user_id', userId)
        .order('changed_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return DateTime.parse(response['changed_at'] as String);
  }
}
```

### 3.3 Repository 구현 체크리스트

#### P0 Priority (1주차)

**Authentication**:
- [ ] `/Users/pro16/Desktop/project/n06/lib/features/authentication/infrastructure/repositories/supabase_auth_repository.dart`
  - [ ] `loginWithKakao()` (네이티브 SDK + Supabase `signInWithIdToken` 방식)
  - [ ] `loginWithNaverCallback()` (Edge Function 연동)
  - [ ] `loginWithEmail()`
  - [ ] `logout()`
  - [ ] `getCurrentUser()`

**Onboarding**:
- [ ] `/Users/pro16/Desktop/project/n06/lib/features/onboarding/infrastructure/repositories/supabase_profile_repository.dart`
  - [ ] `getUserProfile()`
  - [ ] `saveUserProfile()`
  - [ ] `updateUserProfile()`

- [ ] `/Users/pro16/Desktop/project/n06/lib/features/onboarding/infrastructure/repositories/supabase_user_repository.dart`
  - [ ] `getUser()`
  - [ ] `updateUser()`

**Tracking**:
- [ ] `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/supabase_medication_repository.dart`
  - [ ] `getActiveDosagePlan()`
  - [ ] `getDoseSchedules()`
  - [ ] `getDoseRecords()`
  - [ ] `saveDoseRecord()`
  - [ ] `deleteDoseRecord()`
  - [ ] `getRecentDoseRecords()`

- [ ] `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/supabase_dosage_plan_repository.dart`
  - [ ] `saveDosagePlan()`
  - [ ] `updateDosagePlan()`
  - [ ] `savePlanChangeHistory()`
  - [ ] `getPlanChangeHistory()`

- [ ] `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/supabase_dose_schedule_repository.dart`
  - [ ] `saveDoseSchedules()`
  - [ ] `deleteDoseSchedulesFrom()`

- [ ] `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart`
  - [ ] Weight Logs (위 예시 참조)
  - [ ] Symptom Logs (위 예시 참조)

#### P1 Priority (2주차)

- [ ] `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/supabase_emergency_check_repository.dart`
- [ ] `/Users/pro16/Desktop/project/n06/lib/features/tracking/infrastructure/repositories/supabase_audit_repository.dart`
- [ ] `/Users/pro16/Desktop/project/n06/lib/features/dashboard/infrastructure/repositories/supabase_badge_repository.dart`
- [ ] `/Users/pro16/Desktop/project/n06/lib/features/notification/infrastructure/repositories/supabase_notification_repository.dart`
- [ ] `/Users/pro16/Desktop/project/n06/lib/features/data_sharing/infrastructure/repositories/supabase_shared_data_repository.dart`

#### P2 Priority (필요 시)

- [ ] `/Users/pro16/Desktop/project/n06/lib/features/coping_guide/infrastructure/repositories/supabase_feedback_repository.dart`

---

## 4. Provider DI 수정

### 4.1 수정할 파일 목록

각 Feature의 `application/providers.dart` 파일을 수정합니다.

#### 수정 1: Authentication

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/authentication/application/providers.dart`

**수정 내용**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../infrastructure/repositories/isar_auth_repository.dart'; // 유지
import '../infrastructure/repositories/supabase_auth_repository.dart'; // 추가
import '../../core/providers.dart';

part 'providers.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  // Phase 0 (제거 예정)
  // final isar = ref.watch(isarProvider);
  // return IsarAuthRepository(isar);

  // Phase 1 (신규)
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAuthRepository(supabase);
}
```

#### 수정 2: Onboarding

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/onboarding/application/providers.dart`

**수정 내용**:
```dart
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseProfileRepository(supabase);
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseUserRepository(supabase);
}
```

#### 수정 3: Tracking

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/tracking/application/providers.dart`

**수정 내용**:
```dart
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseMedicationRepository(supabase);
}

@riverpod
DosagePlanRepository dosagePlanRepository(DosagePlanRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseDosagePlanRepository(supabase);
}

@riverpod
DoseScheduleRepository doseScheduleRepository(DoseScheduleRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseDoseScheduleRepository(supabase);
}

@riverpod
TrackingRepository trackingRepository(TrackingRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseTrackingRepository(supabase);
}

@riverpod
EmergencyCheckRepository emergencyCheckRepository(EmergencyCheckRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseEmergencyCheckRepository(supabase);
}

@riverpod
AuditRepository auditRepository(AuditRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAuditRepository(supabase);
}
```

#### 수정 4: Dashboard

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/dashboard/application/providers.dart`

**수정 내용**:
```dart
@riverpod
BadgeRepository badgeRepository(BadgeRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseBadgeRepository(supabase);
}
```

#### 수정 5: Notification

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/notification/application/providers.dart`

**수정 내용**:
```dart
@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseNotificationRepository(supabase);
}
```

#### 수정 6: Coping Guide

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/coping_guide/application/providers.dart`

**수정 내용**:
```dart
@riverpod
FeedbackRepository feedbackRepository(FeedbackRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseFeedbackRepository(supabase);
}
```

#### 수정 7: Data Sharing

**파일 위치**: `/Users/pro16/Desktop/project/n06/lib/features/data_sharing/application/providers.dart`

**수정 내용**:
```dart
@riverpod
SharedDataRepository sharedDataRepository(SharedDataRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseSharedDataRepository(supabase);
}
```

### 4.2 Code Generation 실행

**명령어**:
```bash
cd /Users/pro16/Desktop/project/n06
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4.3 Provider DI 체크리스트

- [ ] `lib/features/authentication/application/providers.dart` 수정
- [ ] `lib/features/onboarding/application/providers.dart` 수정
- [ ] `lib/features/tracking/application/providers.dart` 수정
- [ ] `lib/features/dashboard/application/providers.dart` 수정
- [ ] `lib/features/notification/application/providers.dart` 수정
- [ ] `lib/features/coping_guide/application/providers.dart` 수정
- [ ] `lib/features/data_sharing/application/providers.dart` 수정
- [ ] `build_runner` 실행 성공

---

## 5. 빌드 및 검증

### 5.1 빌드 테스트

```bash
cd /Users/pro16/Desktop/project/n06

# Clean
flutter clean

# Pub get
flutter pub get

# Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Build (iOS)
flutter build ios --debug

# Build (Android)
flutter build apk --debug
```

### 5.2 컴파일 에러 해결

**자주 발생하는 에러**:

1. **Import 누락**
   ```
   Error: Undefined class 'SupabaseClient'
   ```
   **해결**: `import 'package:supabase_flutter/supabase_flutter.dart';` 추가

2. **DTO 메서드 누락**
   ```
   Error: The method 'fromJson' isn't defined for the class
   ```
   **해결**: DTO에 `fromJson()`, `toJson()` 구현

3. **Repository 인터페이스 불일치**
   ```
   Error: Missing concrete implementation of ...
   ```
   **해결**: Domain Repository 인터페이스의 모든 메서드 구현

### 5.3 빌드 체크리스트

- [ ] `flutter clean` 성공
- [ ] `flutter pub get` 성공
- [ ] `build_runner` 실행 성공
- [ ] `flutter analyze` 에러 0개
- [ ] iOS 빌드 성공
- [ ] Android 빌드 성공

---

## 6. 코드 리뷰 체크리스트

### 6.1 DTO 리뷰

- [ ] `fromJson()`, `toJson()` 구현 완료
- [ ] 날짜/시간 변환 정확
- [ ] Nullable 필드 올바르게 처리
- [ ] JSONB 필드 직렬화 정확

### 6.2 Repository 리뷰

- [ ] 모든 인터페이스 메서드 구현
- [ ] Supabase 쿼리 문법 정확
- [ ] RLS 정책 고려 (user_id 필터링)
- [ ] 에러 핸들링 적절
- [ ] Transaction 처리 (관련 테이블)

### 6.3 Provider 리뷰

- [ ] `supabaseProvider` 의존성 정확
- [ ] Repository 생성자 올바름
- [ ] Code generation 완료

---

## 7. 다음 단계

✅ Phase 1.2 완료 후:
- **[Phase 1.3: 인증 시스템 전환](./03_authentication.md)** 문서로 이동하세요.

---

## 트러블슈팅

### 문제 1: Supabase 쿼리 에러
**증상**: `PostgrestException: ...`
**해결**:
1. 테이블명, 컬럼명 정확한지 확인 (snake_case)
2. RLS 정책 확인 (인증된 사용자만 접근 가능)
3. Supabase Dashboard에서 SQL 직접 실행해보기

### 문제 2: Stream 미작동
**증상**: `watchWeightLogs()` 데이터 업데이트 안됨
**해결**:
1. Realtime 활성화 확인 (Supabase Dashboard > Database > Replication)
2. `stream(primaryKey: ['id'])` 정확한지 확인
3. 테이블에 Primary Key 존재하는지 확인

### 문제 3: Transaction 실패
**증상**: 관련 데이터 일부만 저장됨
**해결**:
1. RPC 함수 사용 (PostgreSQL 함수로 트랜잭션 보장)
2. 또는 수동으로 롤백 처리 (try-catch + 삭제)
