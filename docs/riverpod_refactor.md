# Riverpod 아키텍처 리팩토링 가이드

## 문서 정보
- **작성일**: 2025-11-11
- **검토 기준**: `docs/external/riverpod_설정가이드.md`
- **검토 범위**: 전체 코드베이스
- **목적**: Riverpod 가이드 준수 및 4-Layer Architecture 강화

---

## 검토 결과 요약

### ✅ 잘 지켜지고 있는 사항

| 항목 | 상태 | 세부 내용 |
|------|------|-----------|
| Domain Layer 순수성 | 완벽 | Riverpod 의존성 없음 (1개 예외 제외) |
| Infrastructure Layer 순수성 | 완벽 | Riverpod 의존성 없음 |
| Code Generation 설정 | 완벽 | 13개 파일, 28개 .g.dart 파일 정상 |
| Provider 정의 위치 | 양호 | Application Layer에만 정의됨 |
| Consumer 패턴 사용 | 완벽 | 18개 파일에서 정상 사용 |

### ⚠️ 개선 필요 사항 (3건)

| 순서 | 문제 | 파일 | 심각도 |
|------|------|------|--------|
| 1 | Domain에서 Flutter import | notification/domain/services/notification_scheduler.dart | 높음 |
| 2 | Provider 정의 분산 | notification/application/notifiers/notification_notifier.dart | 중간 |
| 3 | Core Provider 중복 정의 | coping_guide/application/providers.dart | 낮음 |

---

## Issue #1: Domain Layer의 Flutter 의존성 제거

### 문제 상황

**파일**: `lib/features/notification/domain/services/notification_scheduler.dart`

**현재 코드**:
```dart
import 'package:flutter/material.dart';  // ← 아키텍처 위반

abstract class NotificationScheduler {
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required TimeOfDay time,  // ← Flutter 타입
  });
}
```

**문제점**:
- Domain Layer가 Flutter 프레임워크에 의존
- `TimeOfDay`는 Flutter UI 타입 (material.dart)
- Domain은 UI 프레임워크와 독립적이어야 함
- 4-Layer Architecture 원칙 위반

**영향 범위**:
- Domain Layer: notification/domain/services/notification_scheduler.dart
- Infrastructure Layer: notification/infrastructure/services/local_notification_scheduler.dart
- Application Layer: notification/application/notifiers/notification_notifier.dart
- Presentation Layer: notification/presentation/screens/notification_settings_screen.dart

---

### 해결 방안

#### Step 1: 순수 Dart 타입 생성

**파일**: `lib/features/notification/domain/value_objects/notification_time.dart` (새로 생성)

```dart
/// 순수 Dart 시간 Value Object (Flutter 의존성 없음)
class NotificationTime {
  final int hour;   // 0-23
  final int minute; // 0-59

  const NotificationTime({
    required this.hour,
    required this.minute,
  }) : assert(hour >= 0 && hour < 24, 'Hour must be 0-23'),
       assert(minute >= 0 && minute < 60, 'Minute must be 0-59');

  /// TimeOfDay로 변환 (Presentation Layer에서만 사용)
  factory NotificationTime.fromTimeOfDay(TimeOfDay timeOfDay) {
    return NotificationTime(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );
  }

  /// TimeOfDay로 변환
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// DateTime으로 변환 (오늘 날짜 기준)
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
```

#### Step 2: Domain Interface 수정

**파일**: `lib/features/notification/domain/services/notification_scheduler.dart`

```dart
// ❌ 수정 전
import 'package:flutter/material.dart';

abstract class NotificationScheduler {
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required TimeOfDay time,
  });
}

// ✅ 수정 후
import '../value_objects/notification_time.dart';

abstract class NotificationScheduler {
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required NotificationTime time,  // ← 순수 Dart 타입
  });

  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
}
```

#### Step 3: Infrastructure 구현체 수정

**파일**: `lib/features/notification/infrastructure/services/local_notification_scheduler.dart`

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../domain/services/notification_scheduler.dart';
import '../../domain/value_objects/notification_time.dart';

class LocalNotificationScheduler implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationScheduler(this._plugin);

  @override
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required NotificationTime time,  // ← NotificationTime 사용
  }) async {
    final now = tz.TZ.local.now();
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,     // ← NotificationTime에서 직접 접근
      time.minute,
    );

    // 시간이 이미 지났으면 다음 날로 예약
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel',
          'Daily Notifications',
          channelDescription: 'Daily reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelNotification(String id) async {
    await _plugin.cancel(id.hashCode);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
```

#### Step 4: Entity 수정

**파일**: `lib/features/notification/domain/entities/notification_settings.dart`

```dart
// ❌ 수정 전
import 'package:flutter/material.dart';

class NotificationSettings {
  final bool isEnabled;
  final TimeOfDay reminderTime;  // ← Flutter 타입
  // ...
}

// ✅ 수정 후
import '../value_objects/notification_time.dart';

class NotificationSettings {
  final bool isEnabled;
  final NotificationTime reminderTime;  // ← 순수 Dart 타입
  final bool beforeMealReminder;
  final bool afterMealReminder;

  const NotificationSettings({
    required this.isEnabled,
    required this.reminderTime,
    this.beforeMealReminder = false,
    this.afterMealReminder = false,
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    NotificationTime? reminderTime,
    bool? beforeMealReminder,
    bool? afterMealReminder,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      beforeMealReminder: beforeMealReminder ?? this.beforeMealReminder,
      afterMealReminder: afterMealReminder ?? this.afterMealReminder,
    );
  }
}
```

#### Step 5: DTO 수정

**파일**: `lib/features/notification/infrastructure/dtos/notification_settings_dto.dart`

```dart
import 'package:isar/isar.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/value_objects/notification_time.dart';

part 'notification_settings_dto.g.dart';

@collection
class NotificationSettingsDto {
  Id id = Isar.autoIncrement;

  late bool isEnabled;
  late int reminderHour;     // ← TimeOfDay 대신 hour/minute 분리
  late int reminderMinute;
  late bool beforeMealReminder;
  late bool afterMealReminder;

  // Entity → DTO
  factory NotificationSettingsDto.fromEntity(NotificationSettings entity) {
    return NotificationSettingsDto()
      ..isEnabled = entity.isEnabled
      ..reminderHour = entity.reminderTime.hour
      ..reminderMinute = entity.reminderTime.minute
      ..beforeMealReminder = entity.beforeMealReminder
      ..afterMealReminder = entity.afterMealReminder;
  }

  // DTO → Entity
  NotificationSettings toEntity() {
    return NotificationSettings(
      isEnabled: isEnabled,
      reminderTime: NotificationTime(
        hour: reminderHour,
        minute: reminderMinute,
      ),
      beforeMealReminder: beforeMealReminder,
      afterMealReminder: afterMealReminder,
    );
  }
}
```

#### Step 6: Presentation Layer 수정

**파일**: `lib/features/notification/presentation/screens/notification_settings_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/notifiers/notification_notifier.dart';
import '../../domain/value_objects/notification_time.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('에러: $error')),
        data: (settings) {
          // NotificationTime → TimeOfDay 변환 (Presentation Layer에서만)
          final timeOfDay = settings.reminderTime.toTimeOfDay();

          return ListView(
            children: [
              SwitchListTile(
                title: const Text('알림 활성화'),
                value: settings.isEnabled,
                onChanged: (value) {
                  ref.read(notificationNotifierProvider.notifier)
                      .updateEnabled(value);
                },
              ),
              ListTile(
                title: const Text('알림 시간'),
                subtitle: Text(settings.reminderTime.toString()),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: timeOfDay,
                  );

                  if (pickedTime != null) {
                    // TimeOfDay → NotificationTime 변환
                    final notificationTime = NotificationTime.fromTimeOfDay(pickedTime);

                    ref.read(notificationNotifierProvider.notifier)
                        .updateTime(notificationTime);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
```

#### Step 7: Notifier 수정

**파일**: `lib/features/notification/application/notifiers/notification_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/services/notification_scheduler.dart';
import '../../domain/value_objects/notification_time.dart';
import '../providers.dart';  // Repository Provider는 별도 파일에

part 'notification_notifier.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<NotificationSettings> build() async {
    final repository = ref.watch(notificationRepositoryProvider);
    return await repository.getSettings();
  }

  Future<void> updateEnabled(bool isEnabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryProvider);
      final scheduler = ref.read(notificationSchedulerProvider);
      final currentSettings = await repository.getSettings();

      final newSettings = currentSettings.copyWith(isEnabled: isEnabled);
      await repository.saveSettings(newSettings);

      if (isEnabled) {
        await scheduler.scheduleNotification(
          id: 'daily_reminder',
          title: 'GLP-1 투여 알림',
          body: '오늘의 투여 시간입니다',
          time: newSettings.reminderTime,  // ← NotificationTime 직접 전달
        );
      } else {
        await scheduler.cancelAllNotifications();
      }

      return newSettings;
    });
  }

  Future<void> updateTime(NotificationTime time) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryProvider);
      final scheduler = ref.read(notificationSchedulerProvider);
      final currentSettings = await repository.getSettings();

      final newSettings = currentSettings.copyWith(reminderTime: time);
      await repository.saveSettings(newSettings);

      if (currentSettings.isEnabled) {
        await scheduler.scheduleNotification(
          id: 'daily_reminder',
          title: 'GLP-1 투여 알림',
          body: '오늘의 투여 시간입니다',
          time: time,  // ← NotificationTime 직접 전달
        );
      }

      return newSettings;
    });
  }
}
```

---

## Issue #2: Provider 정의 분리

### 문제 상황

**파일**: `lib/features/notification/application/notifiers/notification_notifier.dart`

**현재 구조**:
```dart
// notification_notifier.dart에 Repository Provider와 Notifier가 섞여 있음
@riverpod
NotificationRepository notificationRepository(ref) { }  // ← Repository Provider

@riverpod
NotificationScheduler notificationScheduler(ref) { }   // ← Service Provider

@riverpod
class NotificationNotifier extends _$NotificationNotifier { }  // ← Notifier
```

**문제점**:
- Provider 정의와 Notifier 로직이 한 파일에 혼재
- 다른 Feature에서 `notificationRepositoryProvider`만 import하려 해도 전체 notifier 로직 포함
- Application Layer의 `providers.dart` 컨벤션 위반

**참고**: 다른 Feature들은 모두 올바르게 분리되어 있음:
- `tracking/application/providers.dart` (Repository Provider만)
- `tracking/application/notifiers/medication_notifier.dart` (Notifier만)

---

### 해결 방안

#### Step 1: providers.dart 파일 생성

**파일**: `lib/features/notification/application/providers.dart` (새로 생성)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/services/permission_service.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/services/notification_scheduler.dart';
import '../infrastructure/repositories/isar_notification_repository.dart';
import '../infrastructure/services/local_notification_scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'providers.g.dart';

// Repository Provider
@riverpod
NotificationRepository notificationRepository(
  NotificationRepositoryRef ref,
) {
  final isar = ref.watch(isarProvider);
  return IsarNotificationRepository(isar);
}

// Service Provider
@riverpod
NotificationScheduler notificationScheduler(
  NotificationSchedulerRef ref,
) {
  final plugin = FlutterLocalNotificationsPlugin();
  return LocalNotificationScheduler(plugin);
}
```

#### Step 2: notification_notifier.dart 정리

**파일**: `lib/features/notification/application/notifiers/notification_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/value_objects/notification_time.dart';
import '../providers.dart';  // ← Repository Provider import

part 'notification_notifier.g.dart';

// Notifier만 정의
@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<NotificationSettings> build() async {
    final repository = ref.watch(notificationRepositoryProvider);
    return await repository.getSettings();
  }

  Future<void> updateEnabled(bool isEnabled) async {
    // ... (기존 로직 유지)
  }

  Future<void> updateTime(NotificationTime time) async {
    // ... (기존 로직 유지)
  }
}
```

#### Step 3: Build Runner 실행

```bash
# providers.g.dart 생성
dart run build_runner build --delete-conflicting-outputs

# 또는 watch 모드
dart run build_runner watch -d
```

#### Step 4: Import 경로 수정

**영향받는 파일**: Notification feature 내 다른 파일들

```dart
// ❌ 수정 전
import '../notifiers/notification_notifier.dart';  // Repository Provider 접근 시

// ✅ 수정 후
import '../providers.dart';  // Repository Provider
import '../notifiers/notification_notifier.dart';  // Notifier
```

---

## Issue #3: Core Provider 중복 정의 제거

### 문제 상황

**파일**: `lib/features/coping_guide/application/providers.dart`

**현재 코드**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
// ...

part 'providers.g.dart';

// ❌ Core에 이미 있는 Provider를 Feature에서 재정의
@riverpod
Isar isar(IsarRef ref) {
  throw UnimplementedError('isarProvider must be implemented in core');
}

@riverpod
CopingGuideRepository copingGuideRepository(
  CopingGuideRepositoryRef ref,
) {
  final isar = ref.watch(isarProvider);  // ← 위의 로컬 정의 참조
  return IsarCopingGuideRepository(isar);
}
```

**문제점**:
- `isarProvider`는 `lib/core/database/isar_provider.dart`에 이미 정의됨
- Feature에서 같은 이름으로 shadowing 발생
- UnimplementedError throw는 실제 구현이 아님
- 다른 Feature들은 core의 `isarProvider`를 직접 import하여 사용

**정상 예시** (tracking feature):
```dart
// tracking/application/providers.dart
import '../../../core/database/isar_provider.dart';  // ← core import

@riverpod
MedicationRepository medicationRepository(ref) {
  final isar = ref.watch(isarProvider);  // ← core의 Provider 사용
  return IsarMedicationRepository(isar);
}
```

---

### 해결 방안

#### Step 1: Core Provider Import로 교체

**파일**: `lib/features/coping_guide/application/providers.dart`

```dart
// ❌ 수정 전
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_provider.dart';
import '../domain/repositories/coping_guide_repository.dart';
import '../infrastructure/repositories/isar_coping_guide_repository.dart';

part 'providers.g.dart';

@riverpod
Isar isar(IsarRef ref) {  // ← 중복 정의 제거
  throw UnimplementedError('isarProvider must be implemented in core');
}

@riverpod
CopingGuideRepository copingGuideRepository(
  CopingGuideRepositoryRef ref,
) {
  final isar = ref.watch(isarProvider);
  return IsarCopingGuideRepository(isar);
}

// ✅ 수정 후
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/isar_provider.dart';  // ← core import
import '../domain/repositories/coping_guide_repository.dart';
import '../infrastructure/repositories/isar_coping_guide_repository.dart';

part 'providers.g.dart';

// isarProvider 정의 삭제

@riverpod
CopingGuideRepository copingGuideRepository(
  CopingGuideRepositoryRef ref,
) {
  final isar = ref.watch(isarProvider);  // ← core의 Provider 직접 사용
  return IsarCopingGuideRepository(isar);
}

@riverpod
Stream<List<String>> availableTags(AvailableTagsRef ref) {
  final repository = ref.watch(copingGuideRepositoryProvider);
  return repository.watchAvailableTags();
}

@riverpod
Future<int> copingGuideCount(CopingGuideCountRef ref) async {
  final repository = ref.watch(copingGuideRepositoryProvider);
  return await repository.getGuidesCount();
}
```

#### Step 2: Build Runner 재실행

```bash
# .g.dart 파일 재생성
dart run build_runner build --delete-conflicting-outputs
```

#### Step 3: 검증

```bash
# 컴파일 에러 확인
flutter analyze

# 문제 없으면 테스트 실행
flutter test
```

---

## 추가 개선 권장 사항

### 1. AutoDisposeProviderRef 업그레이드

**현재 상황**: 40+ 경고 발생
```
info • 'AutoDisposeProviderRef' is deprecated - will be removed in 3.0.0
     Use Ref instead
```

**해결 방법**:
```bash
# Riverpod 라이브러리 업그레이드
flutter pub upgrade riverpod_annotation riverpod_generator

# .g.dart 파일 재생성
dart run build_runner build --delete-conflicting-outputs
```

### 2. 불필요한 import 제거

**파일**: `lib/features/authentication/application/notifiers/auth_notifier.dart:3`

```dart
// ❌ 현재
import 'package:flutter/material.dart' show debugPrint;

// ✅ 수정 (debugPrint만 필요한 경우)
import 'dart:developer' as developer;
// 사용: developer.log('message');
```

### 3. Production print() 제거

4개 파일에서 `print()` 사용 발견:
- `lib/features/tracking/infrastructure/repositories/isar_medication_repository.dart`
- `lib/features/dashboard/application/notifiers/dashboard_notifier.dart`
- 기타 2개

**권장**:
```dart
// ❌ Production 코드
print('Debug message');

// ✅ 개발 전용
import 'dart:developer' as developer;
developer.log('Debug message', name: 'FeatureName');

// ✅ 또는 assert로 제한
assert(() {
  developer.log('Debug message');
  return true;
}());
```

---

## 작업 체크리스트

### 우선순위 1: Domain Layer 순수성 (필수)

- [ ] `notification/domain/value_objects/notification_time.dart` 생성
- [ ] `notification/domain/services/notification_scheduler.dart` 수정 (TimeOfDay → NotificationTime)
- [ ] `notification/domain/entities/notification_settings.dart` 수정
- [ ] `notification/infrastructure/dtos/notification_settings_dto.dart` 수정
- [ ] `notification/infrastructure/services/local_notification_scheduler.dart` 수정
- [ ] `notification/application/notifiers/notification_notifier.dart` 수정
- [ ] `notification/presentation/screens/notification_settings_screen.dart` 수정
- [ ] Build Runner 실행: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 테스트 실행: `flutter test test/features/notification/`
- [ ] Flutter Analyze 검증: `flutter analyze`

**예상 작업 시간**: 1-2시간

### 우선순위 2: Provider 분리 (권장)

- [ ] `notification/application/providers.dart` 파일 생성
- [ ] Repository Provider 이동 (notificationRepositoryProvider, notificationSchedulerProvider)
- [ ] `notification/application/notifiers/notification_notifier.dart`에서 Provider 정의 제거
- [ ] Import 경로 수정
- [ ] Build Runner 실행: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 테스트 실행 및 검증

**예상 작업 시간**: 30분

### 우선순위 3: Core Provider 중복 제거 (권장)

- [ ] `coping_guide/application/providers.dart`에서 `isarProvider` 정의 제거
- [ ] Core의 `isarProvider` import 확인
- [ ] Build Runner 실행
- [ ] 테스트 실행 및 검증

**예상 작업 시간**: 15분

### 선택 사항: 추가 개선

- [ ] Riverpod 라이브러리 업그레이드
- [ ] 불필요한 Flutter import 제거
- [ ] Production print() 제거 또는 developer.log로 교체

**예상 작업 시간**: 30분

---

## 테스트 전략

### 1. Unit Test 우선

```bash
# Notification Feature 테스트
flutter test test/features/notification/

# 특히 중요:
flutter test test/features/notification/domain/entities/notification_settings_test.dart
flutter test test/features/notification/infrastructure/dtos/notification_settings_dto_test.dart
```

### 2. Integration Test

```bash
# 알림 설정 화면 E2E
flutter test integration_test/notification_settings_test.dart
```

### 3. Manual Test

- [ ] 알림 활성화/비활성화 토글
- [ ] 알림 시간 변경
- [ ] 알림이 예약된 시간에 실제로 발생하는지 확인
- [ ] 앱 재시작 후 설정 유지 확인

---

## 회귀 테스트 (Regression Test)

리팩토링 후 다른 Feature에 영향이 없는지 확인:

```bash
# 전체 테스트 실행
flutter test

# 특히 Notification을 사용하는 Feature 확인
flutter test test/features/tracking/
flutter test test/features/dashboard/
```

---

## 롤백 계획

만약 리팩토링 중 문제 발생 시:

### Git Stash 활용
```bash
# 현재 변경사항 임시 저장
git stash save "WIP: Notification TimeOfDay refactor"

# 문제 해결 후 복구
git stash pop
```

### 브랜치 전략
```bash
# 리팩토링 전용 브랜치 생성
git checkout -b refactor/notification-domain-purity

# 작업 완료 후 PR
git push origin refactor/notification-domain-purity
```

---

## 참고 문서

- `docs/external/riverpod_설정가이드.md` - Riverpod 사용 가이드
- `docs/code_structure.md` - 4-Layer Architecture 규칙
- `docs/techstack.md` - Phase 0 → Phase 1 전환 전략
- `CLAUDE.md` - 전체 개발 워크플로우

---

## 결론

### 현재 아키텍처 점수: 8.5/10

코드베이스는 전반적으로 깨끗한 계층 분리를 유지하고 있습니다. 발견된 3가지 이슈는 모두 2-3시간 내에 해결 가능하며, 수정 후에는 완벽한 4-Layer Architecture를 달성할 수 있습니다.

**핵심 장점**:
- Repository Pattern 일관되게 적용
- Provider 정의가 Application Layer에 집중
- Code Generation 설정 완벽
- Domain/Infrastructure Layer 대부분 순수

**개선 후 기대 효과**:
- Domain Layer 100% 프레임워크 독립적
- Phase 0 → Phase 1 전환 시 Infrastructure만 수정
- 테스트 용이성 향상
- 코드 가독성 및 유지보수성 향상
