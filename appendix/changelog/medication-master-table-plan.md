# Medication 마스터 테이블 구현 계획

## 개요

현재 `MedicationTemplate` 클래스에 하드코딩된 약물 정보를 DB 마스터 테이블로 이전하여, 앱 배포 없이 새 약물을 추가할 수 있도록 합니다.

## 현재 상태

```
MedicationTemplate (하드코딩)
├── wegovy: Wegovy (세마글루타이드)
└── mounjaro: Mounjaro (티르제파타이드)
```

**사용처:**
- `dosage_plan_form.dart` - 온보딩 약물 선택
- `edit_dosage_plan_screen.dart` - 투여 계획 수정

---

## 변경 범위

### Phase 1: DB 마이그레이션

#### 1.1 medications 마스터 테이블

```sql
CREATE TABLE public.medications (
  id VARCHAR(50) PRIMARY KEY,
  name_ko VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  generic_name VARCHAR(100),
  manufacturer VARCHAR(100),
  available_doses JSONB NOT NULL,        -- [0.25, 0.5, 1.0, ...]
  recommended_start_dose NUMERIC(6,2),
  dose_unit VARCHAR(10) NOT NULL DEFAULT 'mg',
  cycle_days INTEGER NOT NULL DEFAULT 7,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**초기 데이터:**

| id | name_ko | name_en | generic_name | manufacturer | doses | cycle |
|----|---------|---------|--------------|--------------|-------|-------|
| wegovy | 위고비 | Wegovy | 세마글루타이드 | Novo Nordisk | [0.25,0.5,1.0,1.7,2.4] | 7 |
| ozempic | 오젬픽 | Ozempic | 세마글루타이드 | Novo Nordisk | [0.25,0.5,1.0] | 7 |
| mounjaro | 마운자로 | Mounjaro | 티르제파타이드 | Eli Lilly | [2.5,5.0,7.5,10.0,12.5,15.0] | 7 |
| zepbound | 젭바운드 | Zepbound | 티르제파타이드 | Eli Lilly | [2.5,5.0,7.5,10.0,12.5,15.0] | 7 |
| saxenda | 삭센다 | Saxenda | 리라글루타이드 | Novo Nordisk | [0.6,1.2,1.8,2.4,3.0] | 1 |

**RLS:**
```sql
CREATE POLICY "Medications readable by authenticated users"
ON medications FOR SELECT
USING (auth.role() = 'authenticated');
```

#### 1.2 symptom_types 마스터 테이블

```sql
CREATE TABLE public.symptom_types (
  id VARCHAR(50) PRIMARY KEY,
  name_ko VARCHAR(100) NOT NULL,
  name_en VARCHAR(100) NOT NULL,
  category VARCHAR(20) NOT NULL,          -- digestive, systemic, metabolic
  is_red_flag BOOLEAN NOT NULL DEFAULT false,
  display_order INTEGER NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**초기 데이터:** 현재 SymptomType enum 13개 + RedFlagType 6개

#### 1.3 분석 뷰

- `v_weekly_weight_summary` - 주간 체중 요약
- `v_weekly_checkin_summary` - 주간 체크인 요약
- `v_monthly_dose_adherence` - 월별 투여 순응도

---

### Phase 2: Flutter 코드 변경

#### 2.1 Domain Layer

**새 엔티티: `lib/features/tracking/domain/entities/medication.dart`**

```dart
class Medication extends Equatable {
  final String id;
  final String nameKo;
  final String nameEn;
  final String? genericName;
  final String? manufacturer;
  final List<double> availableDoses;
  final double? recommendedStartDose;
  final String doseUnit;
  final int cycleDays;
  final bool isActive;
  final int displayOrder;

  String get displayName => '$nameEn ($genericName)';
}
```

**새 Repository 인터페이스: `lib/features/tracking/domain/repositories/medication_master_repository.dart`**

```dart
abstract class MedicationMasterRepository {
  Future<List<Medication>> getActiveMedications();
  Future<Medication?> getMedicationById(String id);
}
```

#### 2.2 Infrastructure Layer

**새 DTO: `lib/features/tracking/infrastructure/dtos/medication_dto.dart`**

**새 구현체: `lib/features/tracking/infrastructure/repositories/supabase_medication_master_repository.dart`**

#### 2.3 Application Layer

**Provider 추가: `lib/features/tracking/application/providers.dart`**

```dart
@riverpod
MedicationMasterRepository medicationMasterRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseMedicationMasterRepository(supabase);
}

@riverpod
Future<List<Medication>> activeMedications(Ref ref) async {
  final repo = ref.watch(medicationMasterRepositoryProvider);
  return repo.getActiveMedications();
}
```

#### 2.4 Presentation Layer 수정

**`dosage_plan_form.dart` 변경:**
- `MedicationTemplate.all` → `ref.watch(activeMedicationsProvider)`
- AsyncValue 처리 추가

**`edit_dosage_plan_screen.dart` 변경:**
- 동일한 패턴 적용

#### 2.5 기존 코드 정리

- `medication_template.dart` 삭제 (deprecated 처리 후)

---

### Phase 3: 문서 업데이트

- `docs/database.md` 업데이트

---

## 작업 순서

| # | 작업 | 파일 |
|---|------|------|
| 1 | 마이그레이션 파일 생성 | `supabase/migrations/07_add_master_tables.sql` |
| 2 | Medication 엔티티 생성 | `domain/entities/medication.dart` |
| 3 | MedicationMasterRepository 인터페이스 | `domain/repositories/medication_master_repository.dart` |
| 4 | MedicationDto 생성 | `infrastructure/dtos/medication_dto.dart` |
| 5 | Supabase 구현체 생성 | `infrastructure/repositories/supabase_medication_master_repository.dart` |
| 6 | Provider 추가 | `application/providers.dart` |
| 7 | dosage_plan_form.dart 수정 | 온보딩 UI |
| 8 | edit_dosage_plan_screen.dart 수정 | 투여 계획 수정 UI |
| 9 | medication_template.dart 삭제 | 기존 코드 정리 |
| 10 | database.md 업데이트 | 문서화 |
| 11 | 테스트 작성 | 단위 테스트 |

---

## 제약사항

- 기존 `dosage_plans.medication_name` 컬럼은 변경하지 않음
- FK 제약조건 추가하지 않음 (MVP 후 검토)
- 기존 데이터와의 호환성 유지 (displayName 형식 일치)

---

## 호환성 전략

현재 `dosage_plans.medication_name`에는 `"Wegovy (세마글루타이드)"` 형식으로 저장됨.

새 medications 테이블의 `displayName` getter가 동일한 형식을 반환하도록 구현:
```dart
String get displayName => '$nameEn ($genericName)';
```

향후 마이그레이션 시 `medication_id` 컬럼 추가 및 FK 연결 가능.
