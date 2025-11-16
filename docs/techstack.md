# Tech Stack

## Phase 구분

**Phase 0 (MVP)**: Isar 로컬 DB, 오프라인 동작 (완료)
**Phase 1**: Supabase 클라우드 동기화 추가

**현재**: Phase 1 완료 (Supabase 마이그레이션 완료)

---

## Tech Stack by Phase

### Phase 0 (Local Only) - 완료

Phase 0에서는 다음 기술 스택을 사용했습니다:

| 영역 | 기술 | 버전 | 역할 |
|------|------|------|------|
| **Platform** | Flutter | 3.x | 크로스플랫폼 UI |
| **Language** | Dart | 3.x | |
| **State** | Riverpod | 2.x | 상태 관리 |
| **Local DB** | Isar | 3.x | 오프라인 데이터 저장 (Phase 1에서 Supabase로 전환 완료) |
| **Auth** | kakao_flutter_sdk | 1.7+ | 카카오 로그인 (Phase 1에서 제거) |
| | flutter_naver_login | 1.8+ | 네이버 로그인 (Phase 1에서 제거) |
| | crypto | 5.0+ | 비밀번호 해싱 (Phase 1에서 Supabase Auth로 전환) |
| | flutter_secure_storage | 9.0+ | 토큰 암호화 저장 (Phase 1에서 Supabase Auth로 전환) |
| **UI** | fl_chart | 0.66+ | 차트 |
| | go_router | 13.0+ | 내비게이션 |
| | flutter_local_notifications | 16.3+ | 알림 |

**Phase 0 데이터 저장:**
- 사용자 정보: Isar (로컬)
- OAuth 토큰: FlutterSecureStorage (암호화)
- 서버: 없음 (완전 오프라인)

### Phase 1 (Cloud Sync) - 현재 상태 ✅

**구현 완료된 기술 스택:**

| 영역 | 기술 | 역할 |
|------|------|------|
| **Platform** | Flutter | 3.x | 크로스플랫폼 UI |
| **Language** | Dart | 3.x | |
| **State** | Riverpod | 2.x | 상태 관리 |
| **Backend** | Supabase | BaaS (Backend as a Service) |
| **Database** | PostgreSQL | 클라우드 DB (Supabase 내장) |
| **Auth** | Supabase Auth | 통합 인증 시스템 (이메일/소셜 로그인) |
| **Security** | RLS (Row Level Security) | DB 레벨 접근 제어 |
| **UI** | fl_chart | 0.66+ | 차트 |
| | go_router | 13.0+ | 내비게이션 |
| | flutter_local_notifications | 16.3+ | 알림 |

**Phase 1 데이터 저장:**
- 사용자 정보: Supabase PostgreSQL (auth.users + public schema tables)
- 모든 비즈니스 데이터: Supabase PostgreSQL (dosage_plans, dose_records, weight_logs, symptom_logs 등)
- OAuth 토큰: Supabase Auth 자동 관리
- 인증 토큰: Supabase SDK 내부 관리

---

## Architecture Pattern

**Repository Pattern 활용 완료**

Phase 1 전환 시 Repository 구현체만 교체하여 Domain/Application/Presentation Layer는 수정하지 않았습니다.

```dart
// Phase 0 (과거)
MedicationRepository → IsarMedicationRepository

// Phase 1 (현재) ✅
MedicationRepository → SupabaseMedicationRepository
```

**전환 결과:**
- Infrastructure Layer만 수정 (Repository 구현체 교체)
- Domain, Application, Presentation Layer 변경 없음
- 비즈니스 로직 완전 보존

---

## Phase 전환 완료 내역

### 변경 영역 정리

| 항목 | Phase 0 (과거) | Phase 1 (현재) | 변경 여부 |
|------|---------|---------|---------|
| Repository Interface | MedicationRepository 등 | ✅ 동일 | 변경 없음 |
| Repository 구현체 | IsarXxxRepository | SupabaseXxxRepository | ✅ 교체 완료 |
| Provider DI | Isar 주입 | Supabase 주입 | ✅ 1줄 수정 |
| Domain Layer | 비즈니스 로직 | ✅ 동일 | 변경 없음 |
| Application Layer | 상태 관리 로직 | ✅ 동일 | 변경 없음 |
| Presentation Layer | UI 코드 | ✅ 동일 | 변경 없음 |

**결론**: Infrastructure Layer만 수정 완료

**주요 변경 사항:**
1. 모든 `IsarXxxRepository` → `SupabaseXxxRepository`로 교체
2. DTO 구조 변경: Isar annotations → Supabase JSON 직렬화
3. Provider DI 수정: `isarProvider` → `supabaseProvider`
4. 인증 시스템: 자체 OAuth 구현 → Supabase Auth 활용