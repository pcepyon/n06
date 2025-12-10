# GLP-1 앱 민감정보 암호화 감사 보고서

> **작성일**: 2025-12-10
> **작성자**: Claude Code
> **버전**: 1.1 (업데이트: 필수 암호화 항목 구현 완료)

---

## 1. 법규 요약

### 1.1 개인정보보호법 민감정보 정의

개인정보 보호법 제23조에 따라 **민감정보**는 다음과 같이 정의됩니다:

| 분류 | 예시 |
|------|------|
| 사상·신념 | 종교, 정치적 견해 |
| 건강 정보 | **과거·현재 병력, 장애 여부, 투약 정보** |
| 성생활 정보 | - |
| 유전정보 | 유전자검사 결과 |
| 범죄경력정보 | 수사자료, 범죄경력 |
| 생체인식정보 | 지문, 홍채, 음성 |
| 인종·민족 정보 | (2024년 4월 개정 추가) |

**GLP-1 앱의 민감정보 해당 범위**:
- 체중 기록 → **건강정보** (체중은 건강 상태를 나타내는 지표)
- 투약 정보 (약물명, 투여량, 투여 부위) → **건강정보**
- 증상 기록 → **건강정보**
- 식욕 점수 → **건강정보**

### 1.2 안전성 확보조치 기준 제7조 (암호화 요구사항)

개인정보보호위원회 고시 「개인정보의 안전성 확보조치 기준」 제7조에 따른 암호화 의무:

| 암호화 필수 대상 | 저장 시 | 전송 시 |
|----------------|--------|--------|
| **고유식별정보** (주민번호, 여권번호 등) | ✅ 필수 | ✅ 필수 |
| 비밀번호 | ✅ 일방향 암호화 | ✅ 필수 |
| 생체인식정보 | ✅ 필수 | ✅ 필수 |
| 신용카드번호/계좌번호 | ✅ 필수 | ✅ 필수 |
| **민감정보 (건강정보 포함)** | ⚠️ 권고 | ✅ 필수 |

#### 안전한 암호 알고리즘

- **AES-128/192/256**: 대칭키 암호 (국제 표준)
- **ARIA-128/192/256**: 한국 표준 암호 알고리즘
- **SEED**: 한국 표준 암호 알고리즘

> **현재 구현**: AES-256-GCM ✅ (국제 표준 준수)

---

## 2. 암호화 현황 (2025-12-10 업데이트)

### 2.1 암호화 서비스 구현

- **알고리즘**: AES-256-GCM (인증된 암호화)
- **IV**: 매 암호화마다 16바이트 랜덤 생성
- **암호문 형식**: Base64(IV + Ciphertext + AuthTag)
- **키 관리**: `user_encryption_keys` 테이블에 사용자별 키 저장 (RLS 보호)

### 2.2 암호화 적용 현황표 (건강정보만)

| 테이블 | 컬럼 | 데이터 유형 | 암호화 상태 |
|--------|------|-----------|-----------|
| **user_profiles** | target_weight_kg | 목표 체중 | ✅ 구현됨 |
| **weight_logs** | weight_kg | 체중 기록 | ✅ 구현됨 |
| **dosage_plans** | medication_name | 약물명 | ✅ 구현됨 |
| **dosage_plans** | initial_dose_mg | 초기 투약량 | ✅ 구현됨 |
| **dosage_plans** | escalation_plan | 용량 증량 계획 | ✅ 구현됨 |
| **dose_schedules** | scheduled_dose_mg | 예정 투약량 | ✅ 구현됨 |
| **dose_records** | actual_dose_mg | 실제 투약량 | ✅ 구현됨 |
| **dose_records** | injection_site | 주사 부위 | ✅ 구현됨 |
| **dose_records** | note | 투약 메모 | ✅ 구현됨 |
| **daily_checkins** | symptom_details | 증상 상세 | ✅ 구현됨 |
| **daily_checkins** | appetite_score | 식욕 점수 | ✅ 구현됨 |
| **plan_change_history** | old_plan | 이전 투약 계획 | ✅ 구현됨 |
| **plan_change_history** | new_plan | 새 투약 계획 | ✅ 구현됨 |

### 2.3 암호화 대상이 아닌 컬럼 (의도적 제외)

| 테이블 | 컬럼 | 사유 |
|--------|------|------|
| `users` | name, email | 일반 개인정보 (민감정보 아님) |
| `daily_checkins` | meal_condition 등 6개 | 열거형 값 (good/moderate 등), 직접적 건강수치 아님 |
| `daily_checkins` | red_flag_detected | 시스템 감지 플래그 |
| `audit_logs` | old_data, new_data | 감사 로그 (선택적) |

---

## 3. Repository별 구현 현황

| Repository | 테이블 | 암호화 컬럼 |
|-----------|--------|-----------|
| `SupabaseProfileRepository` | user_profiles | target_weight_kg |
| `SupabaseTrackingRepository` | weight_logs | weight_kg |
| `SupabaseMedicationRepository` | dosage_plans | medication_name, initial_dose_mg, escalation_plan |
| `SupabaseMedicationRepository` | dose_schedules | scheduled_dose_mg |
| `SupabaseMedicationRepository` | dose_records | actual_dose_mg, injection_site, note |
| `SupabaseMedicationRepository` | plan_change_history | old_plan, new_plan |
| `SupabaseDailyCheckinRepository` | daily_checkins | symptom_details, appetite_score |

---

## 4. DB 마이그레이션 파일

| 파일 | 설명 |
|-----|------|
| `10_encrypt_sensitive_columns.sql` | weight_logs, daily_checkins, dose_records, dosage_plans, user_profiles 컬럼 타입 변경 |
| `11_user_encryption_keys.sql` | 사용자별 암호화 키 저장 테이블 생성 |
| `12_encrypt_dose_schedule_and_history.sql` | dose_schedules, plan_change_history 컬럼 타입 변경 |

---

## 5. 결론

### 5.1 현재 상태 평가

| 평가 항목 | 상태 |
|----------|------|
| 암호화 알고리즘 | AES-256-GCM ✅ |
| 건강정보 암호화 | 모든 필수 항목 완료 ✅ |
| 키 관리 | Supabase + RLS ✅ |
| 전송 구간 암호화 | HTTPS (Supabase) ✅ |

**법적 필수 암호화 대상: 100% 완료**

### 5.2 삭제된 뷰 (암호화로 인해 집계 불가)

- `v_weekly_weight_summary` - 체중 집계
- `v_weekly_checkin_summary` - 체크인 집계
- `v_monthly_dose_adherence` - 투약 순응도 집계

> 집계가 필요한 경우 앱 레벨에서 복호화 후 계산해야 합니다.

---

## 참고 자료

- [국가법령정보센터 - 개인정보의 안전성 확보조치 기준](https://www.law.go.kr/admRulLsInfoP.do?chrClsCd=010202&admRulSeq=2100000229672)
- [IT위키 - 개인정보의 안전성 확보조치 기준](https://itwiki.kr/w/개인정보의_안전성_확보조치_기준)
- [KISA - 디지털 헬스케어 보안모델](https://www.kisa.or.kr/2060205/form?postSeq=10&lang_type=KO)
