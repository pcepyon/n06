# Tech Stack

## Phase 구분

**Phase 0 (MVP)**: Isar 로컬 DB, 오프라인 동작
**Phase 1**: Supabase 클라우드 동기화 추가

**현재**: Phase 0 구현 중

---

## Tech Stack by Phase

### Phase 0 (Local Only)

| 영역 | 기술 | 버전 | 역할 |
|------|------|------|------|
| **Platform** | Flutter | 3.x | 크로스플랫폼 UI |
| **Language** | Dart | 3.x | |
| **State** | Riverpod | 2.x | 상태 관리 |
| **Local DB** | Isar | 3.x | 오프라인 데이터 저장 |
| **Auth** | kakao_flutter_sdk | 1.7+ | 카카오 로그인 |
| | flutter_naver_login | 1.8+ | 네이버 로그인 |
| | flutter_secure_storage | 9.0+ | 토큰 암호화 저장 |
| **Analytics** | Firebase Analytics | 10.8+ | 사용자 행동 분석 |
| | Firebase Crashlytics | 3.4+ | 크래시 추적 |
| **UI** | fl_chart | 0.66+ | 차트 |
| | go_router | 13.0+ | 내비게이션 |
| | flutter_local_notifications | 16.3+ | 알림 |

**데이터 저장:**
- 사용자 정보: Isar (로컬)
- OAuth 토큰: FlutterSecureStorage (암호화)
- 서버: 없음 (완전 오프라인)

**Analytics 이유:**
Phase 0는 로컬 DB만 사용 → 사용자 정보 수집 불가 → Firebase로 익명 데이터 수집

### Phase 1 (Cloud Sync)

| 영역 | 기술 | 역할 |
|------|------|------|
| **Backend** | Supabase | BaaS |
| **Database** | PostgreSQL | 클라우드 DB (Supabase 내장) |
| **Auth** | Supabase Auth | OAuth 통합 |
| **Functions** | Edge Functions | 네이버 OAuth 처리 |
| **Security** | RLS | DB 레벨 접근 제어 |

**데이터 저장:**
- 사용자 정보: Supabase (auth.users + public.users)
- OAuth 토큰: Supabase 자동 관리
- 로컬 캐시: Isar (오프라인 지원)

---

## Architecture Pattern

**Repository Pattern 필수**

Phase 1 전환 시 Repository 구현체만 교체 → Domain/Application/Presentation Layer 수정 불필요

```dart
// Phase 0
MedicationRepository → IsarMedicationRepository

// Phase 1
MedicationRepository → SupabaseMedicationRepository
```

---

## Phase 전환

### 변경 영역

| 항목 | Phase 0 | Phase 1 |
|------|---------|---------|
| Repository Interface | ✅ 동일 | ✅ 동일 |
| Repository 구현체 | IsarMedicationRepository | SupabaseMedicationRepository (추가) |
| Provider DI | 1줄 수정 | |
| Domain Layer | ✅ 변경 없음 | ✅ 변경 없음 |
| Application Layer | ✅ 변경 없음 | ✅ 변경 없음 |
| Presentation Layer | ✅ 변경 없음 | ✅ 변경 없음 |

**결론**: Infrastructure Layer만 수정