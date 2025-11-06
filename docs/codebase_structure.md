## 1. Top Level Directory Structure (`lib/`)

코드베이스의 최상위 레벨은 책임 분리(SRP)에 따라 3개 영역으로 분류됩니다.

```
lib/
├── features/          # 핵심 기능별 모듈 (Feature-Driven). 대부분의 UI 및 비즈니스 로직 포함.
│   ├── authentication/
│   ├── onboarding/
│   ├── tracking/      # F001 스케줄러, F002 기록
│   ├── data_sharing/
│   └── dashboard/     # F006 대시보드
│
├── core/              # 전역 공통 모듈. (라우팅, 유틸리티, 전역 계약/서비스 인터페이스)
│   ├── constants/
│   ├── errors/
│   ├── routing/
│   └── utils/
│
└── main.dart          # 애플리케이션 진입점 및 전역 Provider 설정
```

## 2. Feature-Level Layered Architecture (`lib/features/feature_name/`)

각 기능 모듈은 엄격한 **Dependency Rule**을 따르는 4개 레이어 구조를 갖습니다. 의존성 흐름은 반드시 **Presentation $\rightarrow$ Application $\rightarrow$ Domain $\leftarrow$ Infrastructure** 방향으로 이루어집니다.

### 예시: `lib/features/tracking/` (F001, F002 관리)

```
lib/features/tracking/
├── presentation/      # Layer 1: UI 렌더링, 사용자 입력 수신
│   ├── widgets/
│   └── medication_schedule_screen.dart
│
├── application/       # Layer 2: 오케스트레이션, 상태 관리 (Riverpod Notifiers/Providers)
│   ├── medication_schedule_notifier.dart 
│   └── tracking_providers.dart          # Feature별 의존성 주입(DI) 설정 파일
│
├── domain/            # Layer 3: Pure Business Logic (기술 독립적)
│   ├── entities/      # (예: dose.dart, symptom_log.dart)
│   ├── usecases/      # (예: RecalculateDoseScheduleUseCase - F001 핵심 로직)
│   └── rules/         # (예: DoseManagementRule - 5일 초과 누락 안내 로직)
│
└── infrastructure/    # Layer 4 & 5: Repository Pattern 및 Data Access
    ├── repositories/
    │   ├── medication_repository.dart       # [Interface/Contract] (Domain, Application 의존)
    │   ├── isar_medication_repository_impl.dart  # [Isar Implementation] (DTO-Entity 매핑 및 Isar/Supabase 동기화 로직 포함)
    │   └── isar_tracking_repository_impl.dart   
    ├── datasources/   # (선택적) 상세 데이터 소스 클라이언트 (IsarClient, SupabaseClient)
    └── dtos/          # Data Transfer Objects (Isar Schema/Supabase JSON 매핑 및 Entity 변환 로직 포함)
```

---

## 3. 핵심 Layer 책임 및 SOLID 원칙 (DIP & SRP)

| 레이어 | 기술 스택 | 핵심 책임 (SRP) | 핵심 원칙 반영 |
| :--- | :--- | :--- | :--- |
| **1. Presentation** | Flutter Widgets | UI 렌더링, 사용자 입력 수신, **Application Layer의 Notifier** 호출 | **SRP (UI/BL 분리)** |
| **2. Application** | Riverpod | **오케스트레이션** 및 **Presentation State** 관리. 여러 **Domain Use Cases**를 호출하고, 여러 **Repository Interface**의 데이터를 조합함. | **SRP (오케스트레이션)** |
| **3. Domain** | Pure Dart | **기술 독립적인 비즈니스 규칙 및 엔티티 정의.** Infrastructure 및 Application을 알지 못함. | **ISP, 확장성 코어** |
| **4. Infrastructure** | Isar, Supabase | **Repository Interface 계약 이행** 및 데이터 영속성 관리. **DTO $\leftrightarrow$ Entity 변환(매핑)** 및 **실시간 스트림(Isar watch)** 제공/추상화. | **DIP (Dependency Inversion)** |

### 확정된 구조의 핵심 규칙

1.  **Repository의 역할:** Repository는 특정 Aggregate Root (Entity)의 영속성(Persistence)만 관리합니다. (예: `MedicationRepository`는 `Dose`만) $\rightarrow$ **F006 대시보드 데이터 조합은 Application Layer (Notifier)에서 수행합니다.**
2.  **DIP 강제:** Application Layer에서 Repository를 주입할 때, Riverpod Provider는 반드시 **Interface**(`MedicationRepository`)를 반환해야 합니다. 이는 컴파일 타임에 DIP를 강제합니다.
3.  **실시간 스트림:** Isar의 `watch()` 기능은 **Repository Interface**에 `Stream<Entity>` 형태로 추상화되어 노출되며, Application Layer에서 `StreamProvider`를 통해 구독하여 사용합니다. (Domain Layer 오염 방지)
4.  **매핑 로직:** DTO (`infrastructure/dtos/`)가 `toEntity()` 확장 함수를 통해 Domain Entity로 변환하며, 이 로직은 **Infrastructure Layer 내부에 위치**합니다. (Dependency Rule 준수)