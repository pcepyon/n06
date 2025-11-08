# GLP-1 MVP 구현 상태 보고서 (001-015)

**작성일**: 2025-11-08
**검사 대상**: UF-F-001 ~ UF-013 (15개 기능)
**평균 완성도**: 75%

---

## Executive Summary

| 상태 | 개수 | 비율 |
|------|------|------|
| ✅ 완료 (배포 가능) | 5개 | 33% |
| ⚠️ 부분완료 (긴급 수정 필요) | 9개 | 60% |
| ❌ 미완료 | 1개 | 7% |

**즉시 조치 필요**: Critical 버그 3개 + Repository 분리 1개 (4-5시간)
**본 릴리스 전 완료**: High Priority 5개 (15-20시간)

---

## 기능별 상태

| # | 기능명 | 상태 | 완성도 | 구현 레이어 | 핵심 이슈 |
|---|--------|------|--------|-----------|----------|
| **001** | 소셜 로그인 및 인증 | ✅ 완료 | 100% | D/I/A/P | - |
| **002** | 온보딩 및 목표 설정 | ✅ 완료 | 100% | D/I/A/P | 테스트 추가 권장 |
| **003** | 투여 스케줄 관리 | ✅ 완료 | 100% | D/I/A/P | 42개 테스트 통과 |
| **004** | 증상 및 체중 기록 | ⚠️ 부분 | 92% | D/I/A | **P 전체 미구현** |
| **005** | 데이터 공유 모드 | ⚠️ 부분 | 70% | D/A | **I 버그**, P 부분 미구현 |
| **006** | 부작용 대처 가이드 | ✅ 완료 | 100% | D/I/A/P | 49개 테스트 91.8% |
| **007** | 증상 체크 및 상담 | ✅ 배포가능 | 95% | D/I/A/P | 테스트 환경만 설정 |
| **008** | 홈 대시보드 | ⚠️ 부분 | 60-70% | D/I | **A 미완성**, **P 부분** |
| **009** | 설정 화면 | ⚠️ 부분 | 50% | P | **GoRouter 미설정**, **대상 화면 4개 미구현** |
| **010** | 로그아웃 | ✅ 완료 | 100% | D/I/A/P | 67개 테스트 통과 |
| **011** | 프로필 및 목표 수정 | ⚠️ 부분 | 85% | D/I/A/P | 검증 로직 3개 미완성 |
| **012** | 투여 계획 수정 | ⚠️ 부분 | 70-80% | D/I/A/P | **JSON 버그**, **Repository 분리 필요** |
| **013** | 과거 기록 수정/삭제 | ⚠️ 부분 | 40% | D/I | **P 전체 미구현**, **통계 미연동** |
| **014** | 푸시 알림 설정 | ⚠️ 부분 | 70-75% | D/I/A/P | **무한 재귀 버그** |
| **015** | 주간 기록 목표 조정 | ✅ 완료 | 95% | D/I/A/P | 컴파일 에러 1개 |

**범례**: D=Domain, I=Infrastructure, A=Application, P=Presentation

---

## 🔴 CRITICAL ISSUES (즉시 해결 - 4-5시간)

### 1. 014: PermissionService 무한 재귀
- **파일**: `/lib/features/notification/infrastructure/services/permission_service.dart:19`
- **문제**: `openAppSettings()`가 자기 자신을 호출
- **영향**: 알림 설정 앱 이동 불가
- **수정**: `openAppSettings` 호출 → `openAppSettings()` 제거

### 2. 012: PlanChangeHistoryDto JSON 직렬화
- **파일**: `/lib/features/tracking/infrastructure/dtos/plan_change_history_dto.dart:39-48`
- **문제**: `toString()` 사용으로 복원 실패 (빈 맵 반환)
- **영향**: 투여 계획 변경 이력 미저장
- **수정**: `jsonEncode/jsonDecode` 구현

### 3. 015: DashboardNotifier 컴파일 에러
- **파일**: `/lib/features/dashboard/application/notifiers/dashboard_notifier.dart`
- **문제**: Import 누락, 메서드 서명 오류
- **영향**: 대시보드 업데이트 작동 불가
- **수정**: profileRepositoryProvider, trackingRepositoryProvider import 추가

### 4. 012: Repository 패턴 위반
- **문제**: DosagePlan, DoseSchedule가 MedicationRepository에 통합됨
- **영향**: Phase 1 전환 불가능 (Repository 분리 필요)
- **필요 작업**:
  - `DosagePlanRepository` 인터페이스 생성 (Domain)
  - `IsarDosagePlanRepository` 구현 (Infrastructure)
  - `DoseScheduleRepository` 인터페이스 생성 (Domain)
  - `IsarDoseScheduleRepository` 구현 (Infrastructure)

---

## 🟡 HIGH PRIORITY (본 릴리스 전 - 15-20시간)

### 004: 증상 및 체중 기록 - Presentation 완전 미구현 (12-16시간)
- **미구현 화면**: WeightRecordScreen, SymptomRecordScreen
- **미구현 위젯**: DateSelectionWidget, InputValidationWidget
- **필수 기능**:
  - 체중 기록 입력 UI (20-300kg 검증)
  - 증상 기록 입력 UI (심각도 1-10, 태그 선택)
  - 중복 확인 (같은 날짜 방지)
  - F004, F005 통합 (대처 가이드, 긴급 체크)

### 005: 데이터 공유 모드 - Infrastructure 버그 (2-3시간)
- **버그 1**: DoseScheduleDto Isar 컬렉션 호환성
- **버그 2**: List<SymptomLog> 타입 안전성
- **미완료**: 홈 대시보드 "기록 보여주기" 버튼 연결

### 008: 홈 대시보드 - Application 미완성 (2-3일)
- **미구현**:
  - DashboardNotifier._buildTimeline() (더미 데이터)
  - DashboardNotifier._calculateNextSchedule() (하드코딩)
  - Derived Providers 4개 (continuousRecordDaysProvider 등)
- **필수 테스트**: Domain/Infra/App 74개 테스트 추가

### 009: 설정 화면 - GoRouter + 대상 화면 (3-5일)
- **필수**: GoRouter 설정 (main.dart)
- **미구현 화면 4개**:
  - ProfileEditScreen (UF-008)
  - DosePlanScreen (UF-009 수정)
  - NotificationSettingsScreen (UF-012)
  - WeeklyGoalScreen (UF-013)
- **추가**: 라우팅 네비게이션 통합

### 013: 과거 기록 수정/삭제 - Presentation 완전 미구현 (12-16시간)
- **미구현 Notifier**: SymptomRecordEditNotifier, DoseRecordEditNotifier
- **미구현 Dialog 4개**: WeightEditDialog, SymptomEditDialog, DoseEditDialog, RecordDeleteDialog
- **Critical**: Dashboard invalidate 통계 재계산 미연동
- **필수**: 수정/삭제 후 DashboardNotifier invalidate 트리거

### 011: 프로필 및 목표 수정 - 검증 로직 (3-4시간)
- **미구현 검증**:
  1. 체중 범위 (20-300kg) 실시간 검증
  2. 현재 체중 불일치 감지 (최근 기록 비교, 확인 다이얼로그)
  3. 사용자 이름 필드 처리

### 014: 푸시 알림 설정 - 권한 처리 (1-2시간)
- **미구현**: 권한 거부 시 설정 앱 이동 UI
- **미구현**: 네트워크 오류 처리 (로컬 저장 후 재시도)
- **필수 테스트**: mockito 통합, 6개 테스트 파일 컴파일 에러 수정

---

## 🟢 MEDIUM PRIORITY (배포 후 개선 가능)

### 005: 차트/그래프 시각화 (선택사항)
- 체중 변화 그래프
- 부작용 강도 추이 차트
- 부작용 발생 패턴 차트

### 008: Advanced Features
- CelebrationAnimationWidget 구현
- GenerateInsightMessageUseCase 세부 구현
- QuickActionWidget 라우팅 완성

### 테스트 커버리지 개선
- 002, 003, 006: 테스트 확대
- 007: Isar 환경 설정

---

## 📅 Implementation Roadmap

### Phase 1: Critical Fixes (1일)
**목표**: 모든 Critical 버그 수정

#### Task 1: Bug Fixes (4-5시간)
- 014 PermissionService 무한 재귀 수정
- 012 PlanChangeHistoryDto JSON 직렬화 수정
- 015 DashboardNotifier 컴파일 에러 수정

#### Task 2: Repository 분리 (2-3시간)
- 012 DosagePlanRepository, DoseScheduleRepository 생성

**서브에이전트**: implementer (코드 작성)

---

### Phase 2: High Priority Features (3-5일)

#### Task 3: 004 Presentation 구현 (12-16시간)
- WeightRecordScreen, SymptomRecordScreen 구현
- DateSelectionWidget, InputValidationWidget 구현
- F004, F005 통합

#### Task 4: 013 Application + Presentation (12-16시간)
- SymptomRecordEditNotifier, DoseRecordEditNotifier 구현
- Dialog 4개 구현
- Dashboard invalidate 트리거 추가

#### Task 5: 008 DashboardNotifier 완성 (2-3시간)
- _buildTimeline(), _calculateNextSchedule() 구현
- Derived Providers 4개 구현
- 74개 테스트 작성

#### Task 6: 011 검증 로직 (3-4시간)
- 체중 범위 검증 UI
- 현재 체중 불일치 감지
- 사용자 이름 필드 처리

#### Task 7: 014 권한 처리 (1-2시간)
- 권한 거부 시 설정 앱 이동
- 네트워크 오류 처리
- mockito 테스트 통합

#### Task 8: 005 Infrastructure 버그 수정 (2-3시간)
- DoseScheduleDto Isar 호환성
- 홈 대시보드 버튼 연결

#### Task 9: 009 라우팅 + 화면 구현 (3-5일)
- GoRouter 설정
- 대상 화면 4개 구현 (별도 spec 필요)

**서브에이전트**: implementer (코드 작성)

---

### Phase 3: Testing & Validation (2주)

#### Task 10: 테스트 작성 (10-15시간)
- 002, 003, 006 테스트 확대
- 007 Isar 환경 설정
- 004, 013 Widget/Integration 테스트

#### Task 11: 통합 테스트 (5-8시간)
- 001-015 전체 흐름 테스트
- 엣지 케이스 검증

**서브에이전트**: implementer (테스트 코드 작성)

---

## 기능별 상세 작업 명세

### 001: 소셜 로그인 및 인증 ✅
**상태**: 완료
**조치**: 없음

---

### 002: 온보딩 및 목표 설정 ✅
**상태**: 완료
**권장**: 테스트 추가 (Domain, Infrastructure, Application 계층)

---

### 003: 투여 스케줄 관리 ✅
**상태**: 완료
**권장**: iOS 알림 지원 추가

---

### 004: 증상 및 체중 기록 ⚠️
**상태**: Domain/Infra/App 완료, **Presentation 전체 미구현**

**필수 작업**:
1. WeightRecordScreen 구현
   - 체중, 날짜 입력
   - 20-300kg 검증
   - 중복 확인 (같은 날짜 덮어쓰기)
   - 90일 과거 기록만 수정 가능

2. SymptomRecordScreen 구현
   - 증상명 선택
   - 심각도 1-10 입력
   - 태그 선택 (checkbox)
   - 심각도 7-10 AND 24시간 이상 시 긴급 안내

3. DateSelectionWidget & InputValidationWidget 구현

4. F004, F005 통합
   - 기록 후 CopingGuideWidget 표시
   - 심각도 높으면 EmergencyCheckScreen 안내

**예상 소요**: 12-16시간

---

### 005: 데이터 공유 모드 ⚠️
**상태**: Domain/App 완료, **Infrastructure 버그**, Presentation 부분 미구현

**필수 작업**:
1. Infrastructure 버그 수정
   - DoseScheduleDto Isar 컬렉션 호환성 확인
   - List<SymptomLog> 타입 안전성 해결

2. 홈 대시보드 연결
   - QuickActionWidget에 "기록 보여주기" 버튼 추가
   - DataSharingScreen으로 라우팅

**권장 (선택사항)**: 차트/그래프 시각화

**예상 소요**: 2-3시간 (필수), 4-6시간 (시각화)

---

### 006: 부작용 대처 가이드 ✅
**상태**: 완료
**조치**: 없음

---

### 007: 증상 체크 및 상담 ✅
**상태**: 배포 가능 (테스트 환경만 설정)

**필수 작업**: Isar 네이티브 라이브러리 설정 (dlopen 에러 해결)

**예상 소요**: 1-2시간

---

### 008: 홈 대시보드 ⚠️
**상태**: Domain 완료, **Notifier 미완성**, Presentation 부분 미구현

**필수 작업**:
1. DashboardNotifier 완성
   - _buildTimeline() 구현 (DoseRecord 기반)
   - _calculateNextSchedule() 구현 (DoseSchedule 조회)
   - _generateInsightMessage() 완성

2. Derived Providers 4개 구현
   - continuousRecordDaysProvider
   - currentWeekProvider
   - weeklyProgressProvider
   - insightMessageProvider

3. 테스트 추가
   - Domain 유닛 테스트 (기존 기본)
   - Application 통합 테스트 (새로 작성)
   - Infrastructure 리포지토리 테스트
   - Widget 테스트 (74개 추가)

**예상 소요**: 2-3일

---

### 009: 설정 화면 ⚠️
**상태**: Presentation 부분 완료, **라우팅 미설정**, **대상 화면 미구현**

**필수 작업**:
1. GoRouter 설정 (main.dart)
   - MaterialApp.router 설정
   - 라우트 정의 (/login, /settings, /profile/edit, /dose-plan/edit, /weekly-goal/edit, /notification-settings)

2. 대상 화면 4개 구현
   - ProfileEditScreen (UF-008 참고)
   - DosePlanEditScreen (UF-009 참고)
   - NotificationSettingsScreen (UF-012 참고)
   - WeeklyGoalSettingsScreen (UF-015 참고)

**예상 소요**: 3-5일

---

### 010: 로그아웃 ✅
**상태**: 완료
**조치**: 없음

---

### 011: 프로필 및 목표 수정 ⚠️
**상태**: Domain/Infra/App 완료, Presentation 부분 미완성

**필수 작업**:
1. 체중 범위 검증 (20-300kg)
   - UI에서 실시간 검증
   - 에러 메시지 표시, 저장 불가

2. 현재 체중 불일치 감지
   - TrackingRepository에서 최근 기록 조회
   - 현재 입력값과 비교
   - 차이 발생 시 확인 다이얼로그

3. 사용자 이름 필드
   - Entity에 필드 추가 또는 별도 소스 연동
   - 수정 화면에 표시

**예상 소요**: 3-4시간

---

### 012: 투여 계획 수정 ⚠️
**상태**: Domain/App/Presentation 완료, **Infrastructure 문제**

**필수 작업**:
1. PlanChangeHistoryDto JSON 직렬화 수정 (CRITICAL)
2. Repository 분리 (CRITICAL)
   - DosagePlanRepository 인터페이스 생성
   - IsarDosagePlanRepository 구현
   - DoseScheduleRepository 인터페이스 생성
   - IsarDoseScheduleRepository 구현

3. 통합 테스트 추가
   - UpdateDosagePlanUseCase 테스트
   - Widget 테스트

**예상 소요**: 6-8시간

---

### 013: 과거 기록 수정/삭제 ⚠️
**상태**: Domain/Infra 부분 완료, **Application 부분**, **Presentation 전체 미구현**

**필수 작업**:
1. Application Layer
   - SymptomRecordEditNotifier 구현
   - DoseRecordEditNotifier 구현
   - **Dashboard invalidate 트리거 추가** (CRITICAL)
     - ref.invalidate(dashboardNotifierProvider)를 각 수정/삭제 메서드에 추가

2. Presentation Layer
   - WeightEditDialog 구현
   - SymptomEditDialog 구현
   - DoseEditDialog 구현
   - RecordDeleteDialog 구현
   - RecordDetailSheet 구현

3. RecordListScreen에 편집 기능 통합
   - 기록 항목 롱탭 → 편집/삭제 메뉴
   - 기록 상세 조회 → 편집 버튼

**예상 소요**: 12-16시간

---

### 014: 푸시 알림 설정 ⚠️
**상태**: Domain/Infra/App 완료, Presentation 부분 완료

**필수 작업**:
1. PermissionService 무한 재귀 버그 수정 (CRITICAL)

2. 권한 거부 처리
   - NotificationSettingsScreen에서 권한 거부 시 설정 앱 이동 버튼 추가
   - EC1 구현

3. 네트워크 오류 처리
   - 로컬 저장 후 재시도 큐
   - EC6 구현

4. 테스트 통합
   - mockito 패키지 설정
   - 6개 테스트 파일 컴파일 에러 해결

**예상 소요**: 3-4시간

---

### 015: 주간 기록 목표 조정 ✅
**상태**: 거의 완료

**필수 작업**:
1. DashboardNotifier 컴파일 에러 수정 (CRITICAL)
   - profileRepositoryProvider, trackingRepositoryProvider import 추가
   - 메서드 서명 수정

**예상 소요**: 30분

---

## Implementation Execution Guide

### 오케스트레이션 에이전트 지시사항

1. **Phase 1 Critical Fixes (1일)**
   - Task 1-2 순차 실행 (의존성: Task 1 완료 후 Task 2)
   - 담당: implementer 에이전트 × 1

2. **Phase 2 High Priority (3-5일)**
   - Task 3-8 병렬 실행 (독립적)
   - Task 9 병렬 실행 (독립적이지만 별도 담당자 권장)
   - 담당: implementer 에이전트 × 2-3

3. **Phase 3 Testing (2주)**
   - Task 10-11 순차 실행 (Task 10 완료 후 Task 11)
   - 담당: implementer 에이전트 × 1

### 담당자 할당 권장사항

**리딩 에이전트**: 오케스트레이션 (일정 관리, 병렬화)

**서브에이전트 (implementer)** 4명:
- 에이전트 1: 004 (Presentation)
- 에이전트 2: 008, 013 (Application/Presentation)
- 에이전트 3: 005, 012, 014 (Infrastructure/Bug Fix)
- 에이전트 4: 009, 011, 015 (Presentation/라우팅)

---

## Appendix: 파일 목록

### Critical Files
- `/lib/features/notification/infrastructure/services/permission_service.dart` (014)
- `/lib/features/tracking/infrastructure/dtos/plan_change_history_dto.dart` (012)
- `/lib/features/dashboard/application/notifiers/dashboard_notifier.dart` (015)
- `/lib/main.dart` (009 - GoRouter)

### 상세 보고서
- `/docs/001/usecase-checker.md`
- `/docs/002/usecase-checker.md`
- ... (001-015 모두)

---

**최종 예상 완성 시간**: 4-6주 (Phase 1: 1일, Phase 2: 5일, Phase 3: 14일 + 버퍼)
