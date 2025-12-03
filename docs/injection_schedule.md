# 투여 스케쥴 로직

## 1. 자동 스케쥴 등록

- **RecalculateDoseScheduleUseCase**가 핵심
- `startDate`와 `cycleDays`를 기반으로 365일치 스케쥴 자동 생성
- 스케쥴은 항상 시작 요일과 동일한 요일에 정렬됨 (예: 화요일 시작 → 매주 화요일)
- **증량 계획(escalationPlan)** 자동 적용: 경과 주차에 따라 용량 자동 증가

## 2. 과거/미래 시작일 설정

### 상황별 스케쥴 생성 동작

| 구분 | 과거 날짜 선택 | 과거 스케쥴 생성 | UseCase |
|------|--------------|----------------|---------|
| 온보딩 | 30일 전까지 | **O** (startDate~+90일) | `GenerateDoseSchedulesUseCase` |
| 계획 수정 | 2020년부터 | **X** (오늘 이후만) | `RecalculateDoseScheduleUseCase` |
| 재시작 | 2020년부터 | **O** (startDate부터) | `RecalculateDoseScheduleUseCase` |

### 온보딩 (최초 계획 생성)

- 날짜 선택 범위: `now - 30일` ~ `now + 365일`
- **과거 스케쥴 생성됨**: startDate부터 90일치 생성
- 제한사항: 30일 이전 치료 시작은 선택 불가

### 계획 수정 (`isRestart=false`)

- 날짜 선택 범위: `2020년` ~ `now + 365일`
- **과거 스케쥴 생성 안 됨**: `max(now, startDate)` 이후만 생성
- 정렬 공식: `startDate + (경과 사이클 수 × cycleDays)`
- 원래 요일 패턴 유지

### 재시작 모드 (`isRestart=true`)

- 날짜 선택 범위: `2020년` ~ `now + 365일`
- **과거 스케쥴 생성됨**: startDate부터 365일치 생성
- 기존 모든 스케쥴 삭제 후 재생성

## 3. 지연/조기 투여 로직

### 지연 투여

- 1~5일 연체: **즉시 투여 권장** (기록 가능)
- 5~7일 연체: **다음 예정일까지 대기** 권장
- 7일 이상: **의료진 상담 필요** 안내

### 조기 투여

- 최대 **2일 전**까지 조기 투여 권장
- 마지막 투여 후 **48시간 간격** 강제

## 4. 장기 부재 시 재시작

- **14일 이상 미투여** 감지 시 재시작 다이얼로그 표시
- 재시작 시(`isRestart=true`):
  - 모든 과거 스케쥴 삭제
  - 새 startDate부터 스케쥴 전체 재생성
- 건너뛴 스케쥴 목록 표시 + 의료진 상담 권장

## 5. 스케쥴 수정/변경

- **UpdateDosagePlanUseCase**가 오케스트레이션
- 변경 가능: 약물명, 시작일, 주기, 초기용량, 증량계획
- 변경 시:
  1. **변경 영향도 분석** (영향받는 스케쥴 수, 경고 메시지)
  2. 현재~미래 스케쥴 삭제 후 재생성
  3. **변경 이력(PlanChangeHistory)** 저장

## 핵심 제약 요약

| 항목 | 제한 |
|------|------|
| 시작일 | 과거 무제한, 미래 1년 이내 |
| 투여 간격 | 최소 48시간 |
| 조기 투여 | 2일 전까지 권장 |
| 지연 투여 | 5일 초과 시 차단 |
| 재시작 기준 | 14일 이상 공백 |

## 관련 코드

### Domain Layer
- `lib/features/tracking/domain/usecases/recalculate_dose_schedule_usecase.dart`
- `lib/features/tracking/domain/usecases/missed_dose_analyzer_usecase.dart`
- `lib/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart`
- `lib/features/tracking/domain/usecases/update_dosage_plan_usecase.dart`
- `lib/features/tracking/domain/value_objects/missed_dose_guidance.dart`
- `lib/features/onboarding/domain/usecases/generate_dose_schedules_usecase.dart`

### Application Layer
- `lib/features/tracking/application/notifiers/medication_notifier.dart`
- `lib/features/tracking/application/usecases/update_dosage_plan_usecase.dart`
- `lib/features/onboarding/application/notifiers/onboarding_notifier.dart`

### Presentation Layer
- `lib/features/tracking/presentation/dialogs/restart_schedule_dialog.dart`
- `lib/features/tracking/presentation/widgets/selected_date_detail_card.dart`
- `lib/features/tracking/presentation/screens/edit_dosage_plan_screen.dart`
- `lib/features/onboarding/presentation/widgets/dosage_plan_form.dart`
