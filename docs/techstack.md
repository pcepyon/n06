# Tech Stack

---

### Phase 1 

**구현 완료된 기술 스택:**

| 영역 | 기술 | 역할 |
|------|------|------|
| **Platform** | Flutter | 3.x | 크로스플랫폼 UI |
| **Language** | Dart | 3.x | |
| **State** | Riverpod | 3.0.3 | 상태 관리 (Code Generation) |
| **Backend** | Supabase Flutter | 2.10.3 | BaaS (Backend as a Service) |
| **Database** | PostgreSQL | 클라우드 DB (Supabase 내장) |
| **Auth** | Supabase Auth | 통합 인증 시스템 (이메일/소셜 로그인) |
| **Security** | RLS (Row Level Security) | DB 레벨 접근 제어 |
| **UI** | fl_chart | 1.1.1 | 차트 |
| | go_router | 17.0.0 | 내비게이션 |
| | flutter_local_notifications | 19.5.0 | 알림 |

**Phase 1 데이터 저장:**
- 사용자 정보: Supabase PostgreSQL (auth.users + public schema tables)
- 모든 비즈니스 데이터: Supabase PostgreSQL (dosage_plans, dose_records, weight_logs, symptom_logs 등)
- OAuth 토큰: Supabase Auth 자동 관리
- 인증 토큰: Supabase SDK 내부 관리

---

## Architecture Pattern

**Repository Pattern 활용 완료**

```dart
// Phase 1
MedicationRepository → SupabaseMedicationRepository
```

---