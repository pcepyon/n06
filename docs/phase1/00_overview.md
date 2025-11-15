# Phase 1: Supabase 마이그레이션 전체 개요

## 1. 마이그레이션 목표

### 1.1 핵심 목표
- **IsarDB 완전 제거**: 로컬 DB를 완전히 제거하고 Supabase PostgreSQL로 전환
- **클라우드 동기화 구현**: 모든 사용자 데이터를 클라우드에 저장 및 동기화
- **인증 시스템 전환**: 자체 OAuth 구현에서 Supabase Auth로 전환
- **제로 다운타임**: Repository Pattern을 활용하여 Infrastructure Layer만 변경

### 1.2 마이그레이션 범위
- **영향 받는 Layer**: Infrastructure Layer만 (100% 교체)
- **변경 없는 Layer**: Domain, Application, Presentation (0% 변경)
- **교체 대상**: 13개 Repository 구현체 + 17개 DTO
- **신규 추가**: Supabase Auth, RLS Policies, Edge Functions

---

## 2. 현재 아키텍처 분석

### 2.1 현재 구현된 Repository (Isar 기반)

| Feature | Repository Interface | Isar 구현체 | DTO 개수 |
|---------|---------------------|-----------|----------|
| **authentication** | `AuthRepository` | `IsarAuthRepository` | 2 (user, consent) |
| **onboarding** | `ProfileRepository`, `UserRepository` | `IsarProfileRepository`, `IsarUserRepository` | 3 (user, profile, escalation) |
| **tracking** | `MedicationRepository`, `DosagePlanRepository`, `DoseScheduleRepository`, `TrackingRepository`, `EmergencyCheckRepository`, `AuditRepository` | 6개 Isar 구현체 | 7 (dosage_plan, dose_record, dose_schedule, weight_log, symptom_log, symptom_context_tag, emergency_check, plan_history) |
| **dashboard** | `BadgeRepository` | `IsarBadgeRepository` | 2 (badge_definition, user_badge) |
| **notification** | `NotificationRepository` | `IsarNotificationRepository` | 1 (notification_settings) |
| **coping_guide** | `FeedbackRepository` | `IsarFeedbackRepository` | 1 (guide_feedback) |
| **data_sharing** | `SharedDataRepository` | `IsarSharedDataRepository` | 0 (읽기 전용) |

**총계**: 7개 Feature, 13개 Repository Interface, 13개 Isar 구현체, 17개 DTO

### 2.2 데이터베이스 테이블 매핑

| Supabase 테이블 | Isar DTO | 소유 Feature | 비고 |
|----------------|----------|--------------|------|
| `users` | `UserDto` | authentication | Supabase Auth로 통합 |
| `oauth_tokens` | - | - | Supabase Auth 내장 (삭제) |
| `consent_records` | `ConsentRecordDto` | authentication | |
| `user_profiles` | `UserProfileDto` | onboarding | |
| `dosage_plans` | `DosagePlanDto` | tracking | |
| `plan_change_history` | `PlanChangeHistoryDto` | tracking | |
| `dose_schedules` | `DoseScheduleDto` | tracking | |
| `dose_records` | `DoseRecordDto` | tracking | |
| `weight_logs` | `WeightLogDto` | tracking | |
| `symptom_logs` | `SymptomLogDto` | tracking | |
| `symptom_context_tags` | `SymptomContextTagDto` | tracking | |
| `emergency_symptom_checks` | `EmergencySymptomCheckDto` | tracking | |
| `badge_definitions` | `BadgeDefinitionDto` | dashboard | 정적 데이터 |
| `user_badges` | `UserBadgeDto` | dashboard | |
| `notification_settings` | `NotificationSettingsDto` | notification | |
| `guide_feedback` | `GuideFeedbackDto` | coping_guide | 선택적 |
| `password_reset_tokens` | - | authentication | 신규 추가 |

---

## 3. 마이그레이션 단계

### 3.1 단계별 일정

| Phase | 작업 내용 | 기간 | 담당자 | 문서 |
|-------|----------|------|--------|------|
| **1.1** | Supabase 프로젝트 설정, 스키마 생성, RLS 설정 | 1주 | DevOps | [01_setup.md](./01_setup.md) |
| **1.2** | Supabase Repository 구현 (13개) | 2주 | Backend × 2 | [02_repository.md](./02_repository.md) |
| **1.3** | 인증 시스템 전환 (Supabase Auth + Edge Function) | 1주 | Backend | [03_authentication.md](./03_authentication.md) |
| **1.4** | 데이터 마이그레이션 전략 및 UI 구현 | 1주 | Backend | [04_migration.md](./04_migration.md) |
| **1.5** | 테스트 및 검증 (단위/통합/성능) | 1주 | QA × 2 | [05_testing.md](./05_testing.md) |
| **1.6** | 배포 및 모니터링 | 1주 | DevOps | [06_deployment.md](./06_deployment.md) |
| **안정화** | 4주간 모니터링 및 버그 수정 | 4주 | All | [07_stabilization.md](./07_stabilization.md) |
| **Isar 제거** | Isar 완전 제거 및 최종 배포 | 1주 | Backend | [08_cleanup.md](./08_cleanup.md) |

**총 소요 기간**: 약 **12주 (3개월)**

### 3.2 작업 흐름도

```
[Phase 1.1: 사전 준비]
    ↓
[Phase 1.2: Repository 구현] (병렬 작업 가능)
    ↓
[Phase 1.3: 인증 전환]
    ↓
[Phase 1.4: 마이그레이션 전략]
    ↓
[Phase 1.5: 테스트 & 검증]
    ↓
[Phase 1.6: 단계적 배포]
    ↓
[안정화 기간 (4주)]
    ↓
[Isar 완전 제거]
```

---

## 4. 위험 요소 및 대응 방안

### 4.1 기술적 위험

| 위험 | 영향도 | 확률 | 대응 방안 |
|------|--------|------|----------|
| Supabase API 응답 지연 | 높음 | 중간 | - 캐싱 전략 도입<br>- 오프라인 모드 지원 (Phase 2) |
| RLS 정책 설정 오류 | 높음 | 낮음 | - 철저한 테스트<br>- Staging 환경에서 검증 |
| Naver OAuth Edge Function 실패 | 중간 | 중간 | - 재시도 로직 구현<br>- 에러 모니터링 강화 |
| 대용량 데이터 마이그레이션 실패 | 높음 | 낮음 | - 배치 처리 (100개씩)<br>- 재시도 메커니즘 |

### 4.2 비즈니스 위험

| 위험 | 영향도 | 확률 | 대응 방안 |
|------|--------|------|----------|
| 사용자 데이터 손실 | 매우 높음 | 매우 낮음 | - 마이그레이션 전 백업 필수<br>- 롤백 계획 수립 |
| 마이그레이션 중 서비스 중단 | 높음 | 낮음 | - 점진적 배포<br>- Feature Flag 활용 |
| 사용자 불만 (마이그레이션 강제) | 중간 | 중간 | - 충분한 안내 기간<br>- 마이그레이션 보상 (뱃지 등) |

---

## 5. 예상 비용

### 5.1 Supabase 비용 (월간)

**Pro Plan** ($25/월):
- Database: 8GB 포함
- Bandwidth: 50GB 포함
- Edge Functions: 500K 실행 포함
- Storage: 100GB 포함

**예상 사용량** (1,000명 기준):
- Database: ~2GB
- Bandwidth: ~10GB
- Edge Functions: ~100K 실행

**결론**: Pro Plan으로 충분 (**$25/월**)

### 5.2 개발 비용

- 엔지니어 2명 × 3개월 = **6 man-months**

---

## 6. 성공 지표

| 지표 | 목표 |
|------|------|
| **마이그레이션 완료율** | 95% 이상 |
| **에러율** | 0.1% 이하 |
| **API 응답 시간** | 평균 500ms 이하 |
| **사용자 이탈률** | 5% 이하 |
| **앱 크래시율** | 0.1% 이하 |

---

## 7. 전체 체크리스트

### Phase 1.1: 사전 준비 ✅
- [ ] Supabase 프로젝트 생성
- [ ] 환경 변수 설정
- [ ] 스키마 생성 (17개 테이블)
- [ ] RLS 정책 설정
- [ ] OAuth 설정 (Kakao, Naver)

### Phase 1.2: Repository 구현 ✅
- [ ] DTO 변환 (17개)
- [ ] Supabase Repository 구현 (13개)
- [ ] Provider DI 수정 (7개 Feature)

### Phase 1.3: 인증 전환 ✅
- [ ] SupabaseAuthRepository 구현
- [ ] Naver Edge Function 구현
- [ ] 로그인/로그아웃 플로우 테스트

### Phase 1.4: 데이터 마이그레이션 ✅
- [ ] BackupService 구현
- [ ] MigrationService 구현
- [ ] 마이그레이션 UI 구현

### Phase 1.5: 테스트 ✅
- [ ] 단위 테스트 (13개 Repository)
- [ ] 통합 테스트
- [ ] 성능 테스트

### Phase 1.6: 배포 ✅
- [ ] Staging 배포
- [ ] 알파 테스트 (50명)
- [ ] 베타 테스트 (500명)
- [ ] 정식 배포 (단계적 롤아웃)

### 안정화 및 Isar 제거 ✅
- [ ] 4주간 안정적 운영 확인
- [ ] Isar 관련 코드 제거
- [ ] 최종 배포

---

## 8. 다음 단계 안내

1. **[Phase 1.1: 사전 준비](./01_setup.md)** 문서를 읽고 Supabase 프로젝트를 설정하세요.
2. 각 단계별 문서를 순서대로 진행하세요.
3. 각 단계 완료 시 체크리스트를 확인하세요.
4. 문제 발생 시 위험 대응 방안을 참조하세요.

---

## 참고 문서

- [Supabase 공식 문서](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Edge Functions](https://supabase.com/docs/guides/functions)
