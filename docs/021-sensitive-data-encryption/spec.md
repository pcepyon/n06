# F021: 민감 정보 암호화 저장

## 개요
민감한 건강 정보(체중, 증상, 투약 기록)를 AES-256-GCM으로 암호화하여 DB 탈취 시에도 개인정보를 보호한다.

## 배경
- 현재 문제: 민감 건강 정보가 Supabase DB에 평문 저장 → DB 관리자 탈취/백업 유출 시 노출 위험
- 기대 효과: 암호화 키 없이는 복호화 불가, HIPAA/GDPR 준수 강화

## 목표
- [ ] 민감 정보 컬럼을 AES-256-GCM으로 암호화하여 저장
- [ ] 암호화 키를 플랫폼 보안 저장소(iOS Keychain/Android Keystore)에 보관
- [ ] 기존 앱 동작에 영향 없이 투명하게 암호화/복호화 수행

## 사용자 시나리오

### 시나리오 1: 앱 최초 실행 (키 생성)
1. 사용자가 앱 최초 설치 후 실행
2. 시스템이 256비트 랜덤 암호화 키 생성 후 보안 저장소에 저장
3. 결과: 이후 모든 민감 정보 저장/조회에 해당 키 사용

### 시나리오 2: 데이터 저장/조회
1. 체중 72.5kg 입력 → AES-GCM 암호화 → Base64 암호문을 DB에 저장
2. 대시보드 진입 → DB에서 암호문 조회 → 복호화 → 72.5kg 표시

### 시나리오 3: 앱 재설치 (키 분실)
1. 앱 삭제 후 재설치 → 새 암호화 키 생성
2. 결과: 기존 암호화 데이터는 복호화 불가 (MVP 정책)

## 제약 조건
- **암호화**: AES-256-GCM (인증된 암호화)
- **IV**: 매 암호화마다 새로운 16바이트 랜덤 IV 생성
- **암호문 형식**: Base64(IV + Ciphertext + AuthTag)
- **키 저장**: flutter_secure_storage 사용, 'ENCRYPTION_KEY' 키로 저장
- **NULL 처리**: 원본 NULL → NULL 유지, 빈 문자열 → 암호화
- **마이그레이션**: 앱 출시 전이므로 기존 데이터 마이그레이션 불필요

## 암호화 대상

| 테이블 | 암호화 컬럼 | 변경 |
|--------|------------|------|
| `weight_logs` | `weight_kg` | NUMERIC → TEXT |
| `daily_checkins` | `symptom_details`, `appetite_score` | JSONB/INT → TEXT |
| `dose_records` | `actual_dose_mg`, `injection_site`, `note` | NUMERIC/VARCHAR/TEXT → TEXT |
| `dosage_plans` | `medication_name`, `initial_dose_mg`, `escalation_plan` | VARCHAR/NUMERIC/JSONB → TEXT |
| `user_profiles` | `target_weight_kg` | NUMERIC → TEXT |

## 참조 코드
> 에이전트는 아래 파일을 먼저 읽고 패턴을 따를 것

| 참조 대상 | 경로 | 참조 이유 |
|----------|------|----------|
| 보안 저장소 패턴 | `lib/features/authentication/infrastructure/repositories/flutter_secure_storage_repository.dart` | 키 저장 패턴 |
| Repository 구현체 | `lib/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart` | 암호화 적용 위치 |
| DTO 패턴 | `lib/features/tracking/infrastructure/dtos/weight_log_dto.dart` | 데이터 변환 |
| Provider 패턴 | `lib/features/tracking/application/providers.dart` | 의존성 주입 |
| 상태관리 문서 | `docs/state-management.md` | Provider 규칙 |

## 신규 파일 구조
```
lib/core/encryption/
├── domain/encryption_service.dart       # 인터페이스
├── infrastructure/aes_encryption_service.dart  # 구현체
└── application/providers.dart           # Provider
```

## 구현 시 주의사항

### 1. Repository 계층 암호화 처리
- **위치**: Repository 구현체에서 암호화/복호화 수행
- **이유**: DTO는 순수 데이터 변환, Repository는 비즈니스 로직(암호화 포함)

### 2. 직접 update 쿼리 처리 (중요)
아래 메서드들은 DTO를 거치지 않으므로 **암호화 서비스 직접 호출** 필요:
```
supabase_tracking_repository.dart:
- updateWeightLog() → weight_kg 암호화 필요
- updateWeightLogWithDate() → weight_kg 암호화 필요

supabase_medication_repository.dart:
- updateDoseRecord() → actual_dose_mg, injection_site, note 암호화 필요
```

### 3. Stream 메서드 복호화 처리
실시간 스트림도 동일하게 복호화 적용:
```
- watchWeightLogs() → weight_kg 복호화
- watchDoseRecords() → actual_dose_mg, injection_site, note 복호화
- watchActiveDosagePlan() → medication_name, initial_dose_mg, escalation_plan 복호화
```

### 4. 타입 변환 주의
DB 컬럼이 TEXT로 변경되므로 DTO의 `fromJson()` 수정 필요:
```dart
// Before: (json['weight_kg'] as num).toDouble()
// After: double.parse(decrypt(json['weight_kg'] as String))
```

### 5. Profile Repository 특수 케이스
`supabase_profile_repository.dart`에서 직접 weight_logs 조회 → 복호화 필요:
```dart
// getUserProfile(), watchUserProfile() 내 weight_logs 조회 시 복호화
final decrypted = decrypt(weightResponse['weight_kg'] as String);
```

### 6. LLM 연동 영향 없음
- `LLMContextBuilder`는 도메인 엔티티에서 데이터 가져옴
- Repository에서 이미 복호화된 값이 전달되므로 추가 작업 불필요

## 수정 대상 파일

| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | `encrypt: ^5.0.3` 추가 |
| `supabase/migrations/XX_encrypt_columns.sql` | 컬럼 타입 TEXT 변경 |
| `lib/core/encryption/` | 신규 암호화 모듈 |
| `lib/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart` | 암호화 적용 |
| `lib/features/tracking/infrastructure/repositories/supabase_medication_repository.dart` | 암호화 적용 |
| `lib/features/daily_checkin/infrastructure/repositories/supabase_daily_checkin_repository.dart` | 암호화 적용 |
| `lib/features/onboarding/infrastructure/repositories/supabase_profile_repository.dart` | 암호화 적용 |
| `lib/features/tracking/application/providers.dart` | EncryptionService 주입 |
| `lib/features/daily_checkin/application/providers.dart` | EncryptionService 주입 |
| `lib/core/providers.dart` | EncryptionService Provider |
| `lib/main.dart` | 암호화 서비스 초기화 |

## 성공 지표
- [ ] 체중 저장 후 DB에서 직접 조회 시 암호문만 보임
- [ ] 앱에서 조회 시 정상 복호화된 값 표시
- [ ] 앱 재시작 후에도 기존 데이터 정상 복호화
- [ ] Stream(실시간 조회)에서도 정상 복호화
- [ ] 잘못된 암호문 복호화 시 적절한 에러 처리
- [ ] 기존 테스트 통과
- [ ] 빌드 성공
