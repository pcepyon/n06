# Codebase Structure

## 0. Requirements → Features 매핑

| 기능 ID | 기능명 | 위치 | 비고 |
|---------|--------|------|------|
| F-001 | 소셜 로그인 | `features/authentication/` | 네이버/카카오 OAuth |
| F000 | 온보딩 | `features/onboarding/` | 목표 설정 |
| F001 | 투여 스케줄러 | `features/tracking/` | 스케줄 재계산 로직 |
| F002 | 증상/체중 기록 | `features/tracking/` | F001과 통합 |
| F003 | 데이터 공유 모드 | `features/data_sharing/` | 읽기 전용 화면 |
| F004 | 대처 가이드 | `features/tracking/presentation/widgets/` | 정적 UI 컴포넌트 |
| F005 | 증상 체크 | `features/tracking/` | F002와 연동 |
| F006 | 홈 대시보드 | `features/dashboard/` | 여러 Repository 조합 |

---

## 1. Top Level Structure

```
lib/
├── features/          # 기능별 모듈 (4-layer 아키텍처)
│   ├── authentication/
│   ├── onboarding/
│   ├── tracking/      # F001, F002, F004, F005
│   ├── data_sharing/
│   └── dashboard/
│
├── core/              # 전역 공통
│   ├── constants/     # 앱 상수, UI 상수
│   ├── errors/        # 커스텀 예외
│   ├── routing/       # go_router 설정
│   ├── analytics/     # Firebase Analytics & Crashlytics
│   └── utils/         # 날짜 계산, 검증, 포맷팅
│
└── main.dart          # 앱 진입점, ProviderScope, Firebase 초기화
```

### core/ 상세

```
core/
├── constants/
│   ├── app_constants.dart    # 앱 버전, 기본 설정값
│   └── ui_constants.dart     # 색상, 폰트, 여백
│
├── errors/
│   ├── domain_exception.dart
│   └── repository_exception.dart
│
├── routing/
│   └── app_router.dart
│
├── analytics/
│   ├── analytics_service.dart       # Firebase Analytics wrapper
│   ├── analytics_events.dart        # 이벤트 이름 상수
│   └── crashlytics_service.dart     # Crashlytics wrapper
│
└── utils/
    ├── date_utils.dart       # 날짜 계산
    ├── validators.dart       # 입력 검증
    └── formatters.dart       # 포맷팅
```

---

## 2. Feature-Level Architecture (4-Layer)

**의존성 방향**: Presentation → Application → Domain ← Infrastructure

### 예시: `features/tracking/`

```
tracking/
├── presentation/
│   ├── screens/
│   │   ├── medication_schedule_screen.dart  # F001
│   │   ├── symptom_record_screen.dart       # F002
│   │   └── symptom_check_screen.dart        # F005
│   └── widgets/
│       └── side_effect_guide_card.dart      # F004
│
├── application/
│   ├── medication_schedule_notifier.dart
│   ├── symptom_record_notifier.dart
│   └── tracking_providers.dart              # DI 설정
│
├── domain/
│   ├── entities/
│   │   ├── dose.dart
│   │   └── symptom_log.dart
│   ├── usecases/
│   │   ├── recalculate_dose_schedule_usecase.dart
│   │   └── check_missed_dose_usecase.dart
│   └── rules/
│       └── dose_management_rule.dart
│
└── infrastructure/
    ├── repositories/
    │   ├── medication_repository.dart          # Interface
    │   └── isar_medication_repository.dart     # Phase 0 구현체 (Isar만)
    ├── datasources/
    │   └── isar_client.dart
    └── dtos/
        └── dose_dto.dart                       # @collection + toEntity()
```

**Phase 1 추가 파일**:
```
infrastructure/
├── repositories/
│   └── supabase_medication_repository.dart    # Isar + Supabase 동기화
└── datasources/
    └── supabase_client.dart
```

---

## 3. Layer 책임

| Layer | 기술 | 책임 | 원칙 |
|-------|------|------|------|
| **Presentation** | Flutter Widgets | UI 렌더링, 입력 수신 | SRP |
| **Application** | Riverpod | 오케스트레이션, 상태 관리, UseCase 호출 | SRP |
| **Domain** | Pure Dart | 비즈니스 규칙, 엔티티 (기술 독립적) | ISP |
| **Infrastructure** | Isar (Phase 0) | Repository 구현, DTO 매핑, 스트림 제공 | DIP |

---

## 4. 핵심 규칙

### 4.1 Repository Pattern
- Repository는 단일 Entity의 영속성만 관리
- Interface와 구현체 분리 (DIP)
- Application에서는 Interface만 의존

```dart
// tracking_providers.dart
@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  return IsarMedicationRepository(ref.watch(isarClientProvider));
  // Phase 1: SupabaseMedicationRepository로 교체
}
```

### 4.2 실시간 스트림
- Isar `watch()`를 `Stream<Entity>`로 추상화
- Repository Interface에 정의
- Application에서 `StreamProvider`로 구독

```dart
// medication_repository.dart
abstract class MedicationRepository {
  Stream<List<Dose>> watchDoses();
  Future<void> saveDose(Dose dose);
}
```

### 4.3 DTO 매핑
- DTO는 Infrastructure Layer에 위치
- `toEntity()` 메서드로 Domain Entity 변환
- Isar Schema는 DTO에 정의

```dart
// dose_dto.dart
@collection
class DoseDto {
  Id id = Isar.autoIncrement;
  late DateTime date;
  late double amount;

  Dose toEntity() => Dose(id: id, date: date, amount: amount);
}
```

### 4.4 여러 Repository 조합
- 단일 Repository는 단일 Entity만 관리
- 여러 Repository 데이터 조합은 **Application Layer**에서 수행
- 예: F006 대시보드는 `DashboardNotifier`에서 여러 Repository 호출

---

## 5. Phase 전환 전략

| 항목 | Phase 0 | Phase 1 | 변경 |
|------|---------|---------|------|
| Repository Interface | `medication_repository.dart` | 동일 | 없음 |
| Repository 구현체 | `isar_medication_repository.dart` | `supabase_medication_repository.dart` 추가 | 1개 파일 |
| Provider DI | `IsarMedicationRepository()` | `SupabaseMedicationRepository()` | 1줄 |
| Domain/Application/Presentation | 모든 파일 | 동일 | 없음 |

**Phase 1 전환 시 Infrastructure Layer만 수정**
