# 푸시 알림 설정 Plan 검토 결과

## 분석 일자
2025-11-07

## 검토 결과: 양호 (일부 개선 필요)

---

## 1. 명세(spec.md) 대비 설계(plan.md) 적합성 분석

### ✅ 잘 설계된 부분

#### 1.1 Architecture 구조
- **Clean Architecture 레이어 분리**: Domain → Application → Infrastructure → Presentation 구조가 명확하게 정의됨
- **Repository Pattern**: NotificationRepository 인터페이스와 IsarNotificationRepository 구현체 분리가 올바름
- **Dependency Inversion**: Application이 Domain의 인터페이스에만 의존하도록 설계됨

#### 1.2 도메인 모델
- **NotificationSettings Entity**: spec.md의 BR7(데이터 저장) 요구사항을 충족
  - userId, notificationTime, notificationEnabled 필드 포함
  - 불변성 보장 (copyWith, Equatable)

#### 1.3 알림 스케줄링 계약
- **NotificationScheduler Interface**: spec.md의 Main Scenario 5(알림 스케줄 업데이트) 요구사항 반영
  - checkPermission, requestPermission, scheduleNotifications, cancelAllNotifications 메서드 정의
  - Edge Case EC2(같은 날 여러 투여), EC3(과거 날짜) 처리 로직 포함

#### 1.4 TDD 전략
- **Outside-In 접근**: UI → Application → Domain → Infrastructure 순서로 테스트 작성
- **Test Pyramid 준수**: Unit(70%), Integration(20%), Acceptance(10%) 비율 적절
- **Mock 활용**: Repository, Scheduler Mock을 사용한 격리 테스트 설계

---

## 2. ⚠️ 개선 필요 사항

### 2.1 명세 요구사항 누락

#### 🔴 **Critical: 투여 스케줄 조회 로직 누락**
- **spec.md 요구사항**:
  - Main Scenario 5.1: "시스템이 투여 스케줄 조회"
  - Sequence Diagram Line 156-157: `SELECT * FROM dose_schedules WHERE dosage_plan_id = ?`

- **plan.md 문제**:
  - NotificationNotifier가 MedicationRepository에 의존한다고 명시 (line 43, 871)
  - 하지만 **투여 스케줄 조회 메서드가 명시되지 않음**
  - NotificationNotifier 테스트에서 `mockMedicationRepo.getDoseSchedules()`를 사용하지만 (line 727), **MedicationRepository 인터페이스에 이 메서드가 정의되어 있는지 불명확**

- **해결 방안**:
  ```dart
  // features/medication/domain/repositories/medication_repository.dart에 추가 필요
  abstract class MedicationRepository {
    // 기존 메서드들...

    // 알림 스케줄링을 위한 투여 예정일 조회
    Future<List<DoseSchedule>> getFutureDoseSchedules(String dosagePlanId);
  }
  ```

---

#### 🟡 **Medium: 알림 내용 생성 로직 누락**
- **spec.md 요구사항**:
  - BR4: 알림 제목 "투여 예정일 알림", 알림 본문 "오늘은 {약물명} {용량}mg 투여일입니다"

- **plan.md 문제**:
  - LocalNotificationScheduler의 scheduleNotifications 메서드에서 **알림 본문 생성 로직이 구체적으로 명시되지 않음**
  - DoseSchedule 엔티티에서 약물명을 가져오는 방법이 불명확

- **해결 방안**:
  ```dart
  // LocalNotificationScheduler.scheduleNotifications 구현 시
  final notification = NotificationDetails(
    android: AndroidNotificationDetails(
      'dose_reminder_channel',
      '투여 알림',
      channelDescription: 'GLP-1 투여 예정일 알림',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  for (final schedule in doseSchedules) {
    final medicationName = await _getMedicationName(schedule.dosagePlanId);
    final title = '투여 예정일 알림';
    final body = '오늘은 $medicationName ${schedule.scheduledDoseMg}mg 투여일입니다';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      schedule.id.hashCode,
      title,
      body,
      _scheduleNotificationTime(schedule.scheduledDate, notificationTime),
      notification,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
  ```

---

#### 🟡 **Medium: 알림 터치 시 화면 이동 처리 누락**
- **spec.md 요구사항**:
  - BR4: "알림 터치 시 투여 스케줄러 화면으로 이동"

- **plan.md 문제**:
  - LocalNotificationScheduler 테스트 시나리오에 **알림 터치 핸들링이 없음**
  - NotificationDetails에 payload 또는 navigation action 설정 로직 미정의

- **해결 방안**:
  ```dart
  // LocalNotificationScheduler 초기화 시
  final initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // payload에서 dosagePlanId 추출
      if (response.payload != null) {
        // 투여 스케줄러 화면으로 이동
        navigatorKey.currentState?.pushNamed(
          '/medication/scheduler',
          arguments: response.payload,
        );
      }
    },
  );
  ```

---

#### 🟡 **Medium: 네트워크 오류 처리 로직 누락**
- **spec.md 요구사항**:
  - EC6: "네트워크 오류로 저장 실패" - 로컬 임시 저장 후 재시도 큐 등록

- **plan.md 문제**:
  - NotificationNotifier의 에러 핸들링이 **단순 catch만 있음**
  - **재시도 큐 메커니즘이 설계에 없음**

- **해결 방안**:
  ```dart
  // NotificationNotifier에 재시도 로직 추가
  Future<void> updateNotificationTime(TimeOfDay time) async {
    state = AsyncLoading();
    try {
      final updated = state.value!.copyWith(notificationTime: time);
      await _repository.saveNotificationSettings(updated);
      await _rescheduleNotifications(updated);
      state = AsyncData(updated);
    } on NetworkException catch (e) {
      // 로컬에 임시 저장
      await _localRepository.saveNotificationSettings(updated);
      // 재시도 큐 등록
      await _retryQueue.enqueue(RetryTask(
        type: RetryTaskType.saveNotificationSettings,
        data: updated,
      ));
      state = AsyncError(e, StackTrace.current);
      // 사용자에게 "로컬에 저장되었습니다. 네트워크 연결 시 동기화됩니다." 메시지 표시
    }
  }
  ```

---

#### 🟡 **Medium: 앱 백그라운드 제한 안내 누락**
- **spec.md 요구사항**:
  - EC7: "배터리 최적화로 백그라운드 제한된 경우" - 배터리 최적화 예외 설정 안내

- **plan.md 문제**:
  - PermissionService에서 **배터리 최적화 확인 메서드가 없음**
  - NotificationSettingsScreen에서 **배터리 최적화 안내 UI가 없음**

- **해결 방안**:
  ```dart
  // PermissionService에 추가
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    }
    return true; // iOS는 해당 없음
  }

  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    }
    return true;
  }
  ```

---

### 2.2 설계 일관성 문제

#### 🟡 **Medium: TimeOfDay 직렬화 문제**
- **plan.md 문제**:
  - NotificationSettingsDto에서 TimeOfDay를 `notificationHour`, `notificationMinute`로 분해 (line 524-527)
  - 하지만 **Isar 스키마에 이 필드들이 명시되지 않음**
  - TimeOfDay는 Flutter 클래스라서 **Domain Layer에서 사용하면 Flutter 의존성 발생**

- **해결 방안**:
  ```dart
  // Domain Layer에서 TimeOfDay 대신 커스텀 Value Object 사용
  class NotificationTime {
    final int hour; // 0-23
    final int minute; // 0-59

    const NotificationTime({required this.hour, required this.minute});

    TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
    factory NotificationTime.fromTimeOfDay(TimeOfDay time) =>
        NotificationTime(hour: time.hour, minute: time.minute);
  }

  // NotificationSettings Entity
  class NotificationSettings {
    final String userId;
    final NotificationTime notificationTime; // TimeOfDay 대신
    final bool notificationEnabled;
    // ...
  }
  ```

---

#### 🟡 **Medium: 알림 ID 생성 전략 미정의**
- **plan.md 문제**:
  - LocalNotificationScheduler에서 `schedule.id.hashCode`를 알림 ID로 사용 (line 410)
  - 하지만 **hashCode 충돌 가능성**이 있음 (다른 문자열이 같은 hashCode 반환 가능)

- **해결 방안**:
  ```dart
  // 알림 ID 생성 전략 명시
  int _generateNotificationId(DoseSchedule schedule) {
    // scheduledDate를 YYYYMMDD 형식으로 변환하여 고유 ID 생성
    final dateInt = int.parse(
      schedule.scheduledDate.toString().substring(0, 10).replaceAll('-', '')
    );
    return dateInt; // 예: 20251107
  }

  // 또는 UUID 해시 사용
  int _generateNotificationId(DoseSchedule schedule) {
    return schedule.id.hashCode.abs() % 2147483647; // int32 max
  }
  ```

---

### 2.3 테스트 시나리오 보완

#### 🟡 **Medium: Edge Case 테스트 누락**
- **spec.md EC4**: "알림 설정 변경 후 즉시 반영 불가" - "다음 알림부터 적용됩니다" 안내 메시지
  - **plan.md에 이 시나리오 테스트가 없음**

- **추가 필요 테스트**:
  ```dart
  test('should show "applies from next notification" message when changing time on dose day', () async {
    // Arrange
    final today = DateTime.now();
    final doseScheduleToday = DoseSchedule(
      id: 'schedule1',
      dosagePlanId: 'plan1',
      scheduledDate: today,
      scheduledDoseMg: 0.5,
    );
    when(mockMedicationRepo.getDoseSchedules(any))
        .thenAnswer((_) async => [doseScheduleToday]);

    // Act
    await notifier.updateNotificationTime(TimeOfDay(hour: 21, minute: 0));

    // Assert
    // "다음 알림부터 적용됩니다" 메시지 검증
  });
  ```

---

#### 🟡 **Medium: 복수 디바이스 시나리오 누락**
- **spec.md BR6**: "Phase 1 이후 복수 디바이스 지원" - 각 디바이스에서 독립적으로 알림 설정 관리
  - **plan.md에 이에 대한 설계나 테스트가 없음** (Phase 0에서는 불필요하지만 향후 확장성 고려 필요)

- **해결 방안**:
  - NotificationSettings에 `deviceId` 필드 추가 고려
  - Phase 1 전환 시 마이그레이션 계획 문서화

---

## 3. 🟢 추가 강점

### 3.1 상세한 TDD 시나리오
- Domain, Infrastructure, Application, Presentation 각 레이어별로 구체적인 테스트 케이스 작성
- Red-Green-Refactor 사이클이 명확하게 정의됨

### 3.2 Edge Case 처리
- 과거 날짜 알림 제외 (line 448-467)
- 같은 날짜 여러 투여 시 중복 제거 (line 469-497)
- 권한 거부 시 재요청 로직 (line 782-812)

### 3.3 QA Sheet 제공
- 수동 테스트 체크리스트 포함 (line 1048-1060)
- 실제 디바이스 테스트 가이드 제공

---

## 4. 우선순위별 개선 작업

### 🔴 Critical (반드시 수정)
1. **MedicationRepository에 getFutureDoseSchedules 메서드 추가**
   - NotificationNotifier가 의존하는 메서드 명시
   - 투여 스케줄 조회 계약 정의

### 🟡 High (구현 전 수정 권장)
2. **Domain Layer에서 TimeOfDay 제거**
   - NotificationTime Value Object 도입
   - Flutter 의존성 제거

3. **알림 본문 생성 로직 구체화**
   - LocalNotificationScheduler에 약물명 조회 및 본문 생성 로직 추가

4. **알림 터치 핸들링 추가**
   - LocalNotificationScheduler 초기화 시 onDidReceiveNotificationResponse 구현

### 🟢 Medium (시간 여유 있을 때 개선)
5. **네트워크 오류 재시도 큐 설계**
   - Phase 1 전환 시 필요할 수 있으므로 아키텍처 고려

6. **배터리 최적화 확인 로직 추가**
   - PermissionService에 배터리 최적화 관련 메서드 추가

7. **알림 ID 생성 전략 문서화**
   - hashCode 충돌 방지 방안 명시

---

## 5. 결론

### 전체 평가: ⭐⭐⭐⭐☆ (4/5)

**장점**:
- Clean Architecture 레이어 분리가 명확함
- Repository Pattern이 올바르게 적용됨
- TDD 전략이 상세하고 체계적임
- Edge Case 처리가 대부분 포함됨

**단점**:
- 투여 스케줄 조회 메서드 정의 누락 (Critical)
- Domain Layer의 Flutter 의존성 (TimeOfDay)
- 알림 본문 생성 및 터치 핸들링 구체화 필요
- 네트워크 오류 재시도 로직 미설계

**권장사항**:
1. Critical 이슈(MedicationRepository 메서드 정의)는 **즉시 수정**
2. High 이슈(TimeOfDay, 알림 본문, 터치 핸들링)는 **구현 전 반영**
3. Medium 이슈는 Phase 0 구현 후 **리팩토링 단계에서 개선**

---

## 6. 다음 단계

### 수정 후 재검토 항목
- [ ] MedicationRepository 인터페이스 업데이트 확인
- [ ] NotificationTime Value Object 도입 검토
- [ ] LocalNotificationScheduler 알림 생성 로직 검토
- [ ] Phase 1 전환 시 마이그레이션 계획 검토

### 구현 시작 전 체크리스트
- [ ] 모든 Critical 이슈 해결
- [ ] 모든 High 이슈 해결 또는 대안 마련
- [ ] 테스트 시나리오에 누락된 Edge Case 추가
- [ ] TDD 워크플로우 최종 확인
