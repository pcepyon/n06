# Task: GLP-1 기록 기능 리팩토링 (통합 데일리 로그 구현)

> **문서 버전**: 3.0 (2025-11-24 수정)
> **최초 작성**: 2025-11-XX
> **최종 검토**: 2025-11-24 - Riverpod 3.0 가이드 준수 업데이트
> **참조 가이드**: `docs/external/riverpod_flutter_gorouter설정가이드.md`

## ⚠️ 중요 변경사항 (v3.0)

본 문서는 Riverpod 3.0 공식 가이드를 기준으로 작성되었습니다:

1. **증상 심각도**: ✅ **증상별 개별 심각도 입력** (기존 공통 심각도 → 개별 심각도로 UI 개선)
2. **Riverpod 패턴**: ✅ **Code Generation (@riverpod)** 사용 (Riverpod 3.0 권장 패턴)
3. **UI 구현**: ExpansionTile을 사용한 접힌 부작용 섹션 구현
4. **데이터베이스**: Supabase `appetite_score` 컬럼 마이그레이션 필수 (증상 심각도는 변경 불필요)
5. **Navigation**: 저장 완료 후 대시보드로 자동 이동

자세한 가이드: `docs/external/riverpod_flutter_gorouter설정가이드.md` 참조.

---

## 1. 배경 및 목표

현재 분리되어 있는 '체중 기록'과 '증상 기록' 화면을 **하나의 '통합 데일리 로그(Daily Tracking)' 화면으로 통합**하여 UX를 개선하고, 네비게이션 단절 문제와 증상별 심각도 기록 불가 문제를 해결합니다.

### 개선 사항
- ✅ **UX 개선**: 하나의 플로우에서 모든 일일 기록 완료 (체중 + 식욕 + 증상)
- ✅ **네비게이션 단절 해결**: 2개 화면 → 1개 통합 화면
- ✅ **기능 추가**: 식욕 조절 점수 추가 (GLP-1 약물의 핵심 임상 지표)
- ✅ **UI 개선**: 부작용 섹션을 접힌 상태로 시작 (깔끔한 인터페이스)
- ✅ **증상별 개별 심각도**: 각 증상마다 독립적인 심각도 입력 (UX 대폭 개선)

---

## 2. 작업 범위

### A. 데이터 모델 업데이트

#### WeightLog 엔티티 확장
기존 `WeightLog` 엔티티에 `appetiteScore` 필드 추가:

```dart
// lib/features/tracking/domain/entities/weight_log.dart
class WeightLog extends Equatable {
  final String id;
  final String userId;
  final DateTime logDate;
  final double weightKg;
  final int? appetiteScore; // 🆕 추가
  final DateTime createdAt;

  const WeightLog({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.weightKg,
    this.appetiteScore, // 🆕 nullable (기존 데이터 호환)
    required this.createdAt,
  });

  // copyWith, props 업데이트 필요
}
```

**식욕 점수 매핑 (Appetite Score Mapping)**:
- 데이터: `int?` (1-5 척도, nullable)
- 의미:
  - `5`: 식욕 폭발 (Severe hunger)
  - `4`: 보통 (Normal)
  - `3`: 약간 감소 (Slight decrease)
  - `2`: 매우 감소 (Significant decrease)
  - `1`: 아예 없음 (No appetite)
  - `null`: 기록 안 함 (기존 데이터 호환)

**선택 근거**:
1. **임상적 중요성**: GLP-1 약물의 핵심 효과가 식욕 억제이므로, 체중과 함께 필수 추적 지표
2. **데이터 일관성**: 매일 체중과 함께 기록되어야 하므로 `WeightLog`에 포함이 적절
3. **확장성**: 향후 다른 신체 지표(혈당, 혈압 등) 추가 시에도 동일 패턴 적용 가능
4. **마이그레이션 용이성**: nullable로 설계하여 기존 데이터와 호환

---

### B. 화면 통합 (New `DailyTrackingScreen`)

기존 `WeightRecordScreen`과 `SymptomRecordScreen`을 대체하는 새로운 화면 구현.

- **위치**: `lib/features/tracking/presentation/screens/daily_tracking_screen.dart`

#### UI 구성 및 플로우

**1. 날짜 선택 (Top)**
- 기존 `DateSelectionWidget` 재사용
- 날짜 이동 가능

**2. 신체 기록 섹션 (Body Section 1)**
- **체중 (Weight)**: 숫자 입력 (기존 `InputValidationWidget` 재사용)
- **식욕 조절 (Appetite Control)**: 🆕 **필수 항목**
  - UI: 5단계 수평 버튼 그룹 또는 슬라이더
  - 레이블: "폭발 - 보통 - 약간↓ - 많이↓ - 없음"
  - 기본값: 선택 안 함 (null)
  - 저장 시 선택 필수 검증

**3. 부작용 기록 섹션 (Body Section 2)** ✅ **접힌 상태로 시작**
- **초기 상태**: 섹션이 접힌 상태 (Collapsed, ExpansionTile 사용)
- **섹션 제목**: "부작용 기록 (선택)" + 펼침/접기 아이콘
- **펼침 시 (Expanded)**:
  - **증상별 개별 심각도 입력 UI** (🆕 핵심 개선사항):
    - 증상 선택 칩(FilterChip) 나열 (메스꺼움, 두통 등)
    - 각 증상 칩 탭 시 → **해당 증상 전용 심각도 입력 영역** 표시
    - 선택된 증상들은 **리스트 형태로 표시** (증상명 + 심각도 슬라이더)
    - 각 증상마다 **독립적인 1-10 슬라이더**
    - 증상별로 다른 심각도 설정 가능 (예: 메스꺼움 8점, 두통 3점)
  - **증상별 개별 옵션**:
    - 심각도 7-10점 증상에만 "24시간 이상 지속 여부" 질문 표시
    - 심각도 1-6점 증상에만 컨텍스트 태그 선택 표시
  - **공통 입력 필드**:
    - 메모 입력 필드 (모든 증상에 공통 적용)

**✅ 데이터 저장**: 여러 증상을 선택하면 **각각 별도의 SymptomLog 레코드로 저장**되며, **각각 다른 심각도**를 가집니다.

**DB/엔티티 변경 불필요**: `symptom_logs` 테이블과 `SymptomLog` 엔티티는 이미 증상별 개별 심각도를 지원합니다.

**4. 저장 버튼 (Bottom)**
- "저장" 버튼 1회 클릭 시 모든 데이터 저장
- 로딩 상태 표시

---

### C. 네비게이션 연결

#### 라우팅 수정
```dart
// lib/core/routing/app_router.dart

// 기존 라우트 삭제
// GoRoute(path: '/tracking/weight', ...)
// GoRoute(path: '/tracking/symptom', ...)

// 신규 라우트 추가
GoRoute(
  path: '/tracking/daily',
  name: 'daily_tracking',
  builder: (context, state) => const DailyTrackingScreen(),
),
```

#### 하단 네비게이션 수정
```dart
// lib/core/presentation/widgets/scaffold_with_bottom_nav.dart

GabiumBottomNavItem(
  label: '기록',
  icon: Icons.edit_note_outlined,
  activeIcon: Icons.edit_note,
  route: '/tracking/daily', // 🔄 변경
),
```

---

### D. 데이터베이스 스키마 업데이트

#### Supabase PostgreSQL (Phase 1 현재 사용 중)

**1. weight_logs 테이블 (변경 필요)**:
```sql
-- weight_logs 테이블에 컬럼 추가
ALTER TABLE weight_logs
ADD COLUMN appetite_score integer CHECK (appetite_score >= 1 AND appetite_score <= 5);

-- 기존 데이터는 자동으로 null로 설정됨
```

**2. symptom_logs 테이블 (변경 불필요 ✅)**:
```sql
-- 현재 스키마 확인 (01.schema.sql line 128-138)
-- 이미 증상별 개별 심각도를 지원하는 구조
CREATE TABLE public.symptom_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL,
  symptom_name VARCHAR(50) NOT NULL,
  severity INTEGER NOT NULL CHECK (severity >= 1 AND severity <= 10), -- ✅ 개별 심각도
  days_since_escalation INTEGER,
  is_persistent_24h BOOLEAN,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- ✅ 변경 불필요: 이미 각 증상별로 severity를 저장할 수 있음
```

**3. symptom_context_tags 테이블 (변경 불필요 ✅)**:
```sql
-- 현재 스키마 확인 (01.schema.sql line 145-152)
CREATE TABLE public.symptom_context_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symptom_log_id UUID NOT NULL REFERENCES public.symptom_logs(id) ON DELETE CASCADE,
  tag_name VARCHAR(50) NOT NULL
);
-- ✅ 변경 불필요: 증상별 태그를 이미 지원
```

#### DTO 업데이트
```dart
// lib/features/tracking/infrastructure/dtos/weight_log_dto.dart

class WeightLogDto {
  final String id;
  final String userId;
  final DateTime logDate;
  final double weightKg;
  final int? appetiteScore; // 🆕 추가
  final DateTime createdAt;

  // fromJson, toJson 업데이트 필요
  factory WeightLogDto.fromJson(Map<String, dynamic> json) {
    return WeightLogDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      appetiteScore: json['appetite_score'] as int?, // 🆕
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'weight_kg': weightKg,
      'appetite_score': appetiteScore, // 🆕
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

---

### E. Repository 및 Notifier 업데이트

#### Repository 인터페이스 (변경 불필요)
기존 `saveWeightLog()` 메서드 그대로 사용. 엔티티가 확장되었으므로 추가 메서드 불필요.

#### Repository 구현 (변경 불필요)
`SupabaseTrackingRepository`의 기존 `saveWeightLog()` 메서드가 새 필드를 자동으로 처리.

```dart
// lib/features/tracking/infrastructure/repositories/supabase_tracking_repository.dart
// 기존 코드 그대로 사용 (DTO 매핑 덕분에 자동 처리)

@override
Future<void> saveWeightLog(WeightLog log) async {
  final dto = WeightLogDto.fromEntity(log);
  await _supabase.from('weight_logs').upsert(
    dto.toJson(), // appetiteScore 자동 포함
    onConflict: 'user_id,log_date',
  );
}
```

#### Notifier 업데이트 (Riverpod 3.0 Code Generation)

**⚠️ 중요**: Riverpod 3.0 가이드에 따라 **Code Generation (@riverpod)** 패턴을 사용합니다.

**TrackingNotifier 구현 (Code Generation 방식)**:
```dart
// lib/features/tracking/application/notifiers/tracking_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'tracking_notifier.g.dart';  // 🆕 Generated file

@riverpod  // 🆕 Code Generation annotation
class TrackingNotifier extends _$TrackingNotifier {
  @override
  Future<TrackingState> build() async {
    // ✅ ref.read 사용 (가이드 권장: Repository는 변경되지 않음)
    final repository = ref.read(trackingRepositoryProvider);
    final userId = ref.read(authNotifierProvider).value?.id;

    if (userId == null) {
      return const TrackingState(weights: [], symptoms: []);
    }

    final weights = await repository.getWeightLogs(userId);
    final symptoms = await repository.getSymptomLogs(userId);

    return TrackingState(weights: weights, symptoms: symptoms);
  }

  // 🆕 데일리 로그 통합 저장 메서드
  Future<void> saveDailyLog({
    required WeightLog weightLog,
    required List<SymptomLog> symptomLogs, // 각 증상마다 개별 심각도 포함
  }) async {
    // 로딩 상태로 전환
    state = const AsyncValue.loading();

    // AsyncValue.guard로 에러 처리 자동화
    state = await AsyncValue.guard(() async {
      final repository = ref.read(trackingRepositoryProvider);
      final userId = ref.read(authNotifierProvider).value?.id;

      // 1. 체중 기록 저장 (appetiteScore 포함)
      await repository.saveWeightLog(weightLog);

      // 2. 증상 기록 저장 (여러 개 가능, 각각 별도 레코드 + 개별 심각도)
      // ✅ 각 symptomLog는 이미 개별 severity를 가지고 있음
      // 예: [
      //   SymptomLog(symptomName: '메스꺼움', severity: 8, ...),
      //   SymptomLog(symptomName: '두통', severity: 3, ...),
      // ]
      for (final symptomLog in symptomLogs) {
        await repository.saveSymptomLog(symptomLog);
      }

      // 3. 태그 저장은 saveSymptomLog에서 자동 처리 (기존 로직)
      //    각 증상별로 다른 태그를 가질 수 있음

      // 4. 🆕 저장 성공 시 대시보드로 이동 (Context 없이 Navigation)
      ref.read(goRouterProvider).go('/dashboard');

      // 5. 최신 데이터 다시 로드
      if (userId != null) {
        final weights = await repository.getWeightLogs(userId);
        final symptoms = await repository.getSymptomLogs(userId);

        final currentState = state.value ?? const TrackingState(
          weights: [],
          symptoms: [],
        );
        return currentState.copyWith(weights: weights, symptoms: symptoms);
      }

      // userId가 없으면 빈 상태 반환
      return const TrackingState(weights: [], symptoms: []);
    });
  }

  // 기존 saveWeightLog, saveSymptomLog 메서드 유지 (변경 없음)
}
```

**패턴 개선 사항 (Riverpod 3.0 가이드 준수)**:
- ✅ `@riverpod` annotation 사용 (Code Generation)
- ✅ `part 'tracking_notifier.g.dart'` 선언
- ✅ `ref.read()` 사용 (build()에서도 read, 메서드에서도 read)
- ✅ 필드 제거 (`_repository`, `_userId` 제거 → 메서드에서 직접 ref.read())
- ✅ Navigation 로직 추가 (저장 완료 후 대시보드 이동)
- ✅ `AsyncValue.guard()` 에러 처리 자동화

**Code Generation 실행**:
```bash
# 파일 저장 후 실행
dart run build_runner build --delete-conflicting-outputs

# 또는 watch mode (개발 중 권장)
dart run build_runner watch --delete-conflicting-outputs
```

**생성되는 Provider**:
```dart
// tracking_notifier.g.dart (자동 생성)
final trackingNotifierProvider = AsyncNotifierProvider.autoDispose<
  TrackingNotifier,
  TrackingState
>.internal(
  TrackingNotifier.new,
  name: r'trackingNotifierProvider',
  // ...
);
```

**트랜잭션 처리**:
- 현재: 순차 저장 (체중 → 증상들)
- Supabase의 암묵적 트랜잭션 활용
- 증상 저장 실패 시 체중만 저장됨 (부분 실패 가능)
- 향후 개선: Supabase RPC 함수로 원자적 저장 구현 가능 (선택 사항)

---

### F. 기존 파일 정리 (Cleanup)

작업 완료 후 아래 파일 **완전 삭제**:
- `lib/features/tracking/presentation/screens/weight_record_screen.dart`
- `lib/features/tracking/presentation/screens/symptom_record_screen.dart`

---

## 3. 테스트 및 검증 계획 (Testing Strategy)

### TDD 원칙 준수 (docs/tdd.md)

**Red → Green → Refactor 사이클을 반드시 따릅니다.**

#### Unit Tests

**1. Domain Layer: WeightLog 엔티티**
```dart
// test/features/tracking/domain/entities/weight_log_test.dart

test('WeightLog should serialize with appetiteScore', () {
  final log = WeightLog(
    id: 'test-id',
    userId: 'user-1',
    logDate: DateTime(2025, 1, 1),
    weightKg: 75.5,
    appetiteScore: 3, // 🆕
    createdAt: DateTime.now(),
  );

  // copyWith 테스트
  final updated = log.copyWith(appetiteScore: 5);
  expect(updated.appetiteScore, 5);
  expect(updated.weightKg, 75.5); // 다른 필드 유지
});

test('WeightLog should handle null appetiteScore', () {
  final log = WeightLog(
    id: 'test-id',
    userId: 'user-1',
    logDate: DateTime(2025, 1, 1),
    weightKg: 75.5,
    appetiteScore: null, // 🆕 null 허용
    createdAt: DateTime.now(),
  );

  expect(log.appetiteScore, isNull);
});
```

**2. Infrastructure Layer: WeightLogDto**
```dart
// test/features/tracking/infrastructure/dtos/weight_log_dto_test.dart

test('WeightLogDto should convert to/from JSON with appetiteScore', () {
  final json = {
    'id': 'test-id',
    'user_id': 'user-1',
    'log_date': '2025-01-01',
    'weight_kg': 75.5,
    'appetite_score': 3, // 🆕
    'created_at': '2025-01-01T10:00:00Z',
  };

  final dto = WeightLogDto.fromJson(json);
  expect(dto.appetiteScore, 3);

  final backToJson = dto.toJson();
  expect(backToJson['appetite_score'], 3);
});

test('WeightLogDto should handle null appetiteScore', () {
  final json = {
    'id': 'test-id',
    'user_id': 'user-1',
    'log_date': '2025-01-01',
    'weight_kg': 75.5,
    'appetite_score': null, // 🆕
    'created_at': '2025-01-01T10:00:00Z',
  };

  final dto = WeightLogDto.fromJson(json);
  expect(dto.appetiteScore, isNull);
});
```

**3. Application Layer: TrackingNotifier.saveDailyLog**
```dart
// test/features/tracking/application/notifiers/tracking_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock classes
class MockTrackingRepository extends Mock implements TrackingRepository {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  // Mocktail fallback values
  setUpAll(() {
    registerFallbackValue(WeightLog(
      id: 'fallback',
      userId: 'fallback',
      logDate: DateTime.now(),
      weightKg: 0,
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(SymptomLog(
      id: 'fallback',
      userId: 'fallback',
      logDate: DateTime.now(),
      symptomName: 'fallback',
      severity: 1,
      createdAt: DateTime.now(),
    ));
  });

  test('saveDailyLog should save weight and symptoms, then navigate', () async {
    // Arrange
    final mockRepo = MockTrackingRepository();
    final mockRouter = MockGoRouter();

    // Repository mocks
    when(() => mockRepo.saveWeightLog(any())).thenAnswer((_) async {});
    when(() => mockRepo.saveSymptomLog(any())).thenAnswer((_) async {});
    when(() => mockRepo.getWeightLogs(any())).thenAnswer((_) async => []);
    when(() => mockRepo.getSymptomLogs(any())).thenAnswer((_) async => []);

    // Router mock
    when(() => mockRouter.go(any())).thenReturn(null);

    final container = ProviderContainer(
      overrides: [
        trackingRepositoryProvider.overrideWithValue(mockRepo),
        goRouterProvider.overrideWithValue(mockRouter),
      ],
    );

    final notifier = container.read(trackingNotifierProvider.notifier);

    final weightLog = WeightLog(
      id: 'test-weight-id',
      userId: 'user-1',
      logDate: DateTime(2025, 1, 1),
      weightKg: 75.5,
      appetiteScore: 4,
      createdAt: DateTime.now(),
    );

    final symptomLogs = [
      SymptomLog(
        id: 'symptom-1',
        userId: 'user-1',
        logDate: DateTime(2025, 1, 1),
        symptomName: '메스꺼움',
        severity: 5,
        createdAt: DateTime.now(),
      ),
      SymptomLog(
        id: 'symptom-2',
        userId: 'user-1',
        logDate: DateTime(2025, 1, 1),
        symptomName: '두통',
        severity: 3,
        createdAt: DateTime.now(),
      ),
    ];

    // Act
    await notifier.saveDailyLog(
      weightLog: weightLog,
      symptomLogs: symptomLogs,
    );

    // Assert
    verify(() => mockRepo.saveWeightLog(weightLog)).called(1);
    verify(() => mockRepo.saveSymptomLog(symptomLogs[0])).called(1);
    verify(() => mockRepo.saveSymptomLog(symptomLogs[1])).called(1);
    verify(() => mockRouter.go('/dashboard')).called(1); // 🆕 Navigation 검증

    container.dispose();
  });
}
```

#### Widget Tests

**1. DailyTrackingScreen UI 상호작용**
```dart
// test/features/tracking/presentation/screens/daily_tracking_screen_test.dart

testWidgets('식욕 조절 버튼 선택 시 상태 변경', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: DailyTrackingScreen())),
  );

  // 식욕 점수 3 선택
  await tester.tap(find.text('약간↓'));
  await tester.pump();

  // 상태 확인 (내부 상태 변수 검증)
  expect(find.text('약간↓'), findsOneWidget);
});

testWidgets('증상 선택 시 개별 심각도 슬라이더 표시', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: DailyTrackingScreen())),
  );

  // 부작용 섹션 펼치기 (ExpansionTile)
  await tester.tap(find.text('부작용 기록 (선택)'));
  await tester.pumpAndSettle(); // ExpansionTile 애니메이션 완료 대기

  // 메스꺼움 선택
  await tester.tap(find.text('메스꺼움'));
  await tester.pump();

  // 메스꺼움 전용 슬라이더 표시 확인
  expect(find.byType(Slider), findsOneWidget);
  expect(find.text('메스꺼움'), findsWidgets); // 칩 + 리스트 아이템

  // 두통 추가 선택
  await tester.tap(find.text('두통'));
  await tester.pump();

  // 🆕 이제 슬라이더가 2개 (각 증상마다 개별 슬라이더)
  expect(find.byType(Slider), findsNWidgets(2));
  expect(find.text('두통'), findsWidgets); // 칩 + 리스트 아이템
});

testWidgets('저장 버튼 클릭 시 검증 로직', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: DailyTrackingScreen())),
  );

  // 식욕 점수 미선택 상태에서 저장 시도
  await tester.tap(find.text('저장'));
  await tester.pump();

  // 에러 다이얼로그 표시 확인
  expect(find.text('식욕 조절을 선택해주세요'), findsOneWidget);
});
```

#### Integration Tests (선택 사항)

```dart
// integration_test/daily_tracking_flow_test.dart

testWidgets('데일리 로그 전체 플로우 통합 테스트', (tester) async {
  // 1. 화면 진입
  // 2. 날짜 선택
  // 3. 체중 입력
  // 4. 식욕 점수 선택
  // 5. 부작용 섹션 펼치기
  // 6. 증상 선택 및 심각도 입력
  // 7. 저장
  // 8. 성공 메시지 확인
});
```

---

## 4. 구현 순서 (TDD 기반)

### Phase 1: Domain Layer (Test-First)
- [ ] **Test**: `weight_log_test.dart` - appetiteScore 필드 테스트 작성
- [ ] **Code**: `WeightLog` 엔티티에 appetiteScore 추가
- [ ] **Refactor**: props, copyWith, toString 업데이트

### Phase 2: Infrastructure Layer (Test-First)
- [ ] **Test**: `weight_log_dto_test.dart` - JSON 직렬화/역직렬화 테스트
- [ ] **Code**: `WeightLogDto` 업데이트 (fromJson, toJson, fromEntity, toEntity)
- [ ] **Refactor**: 코드 정리

### Phase 3: Database Migration
- [ ] Supabase 콘솔에서 `weight_logs` 테이블에 `appetite_score` 컬럼 추가
- [ ] 기존 데이터 확인 (자동으로 null 설정됨)

### Phase 4: Application Layer (Test-First)
- [ ] **Setup**: Code Generation 설정
  - `tracking_notifier.dart` 상단에 `import 'package:riverpod_annotation/riverpod_annotation.dart';` 추가
  - `part 'tracking_notifier.g.dart';` 선언 추가
  - 기존 수동 Provider 선언 삭제 (providers.dart에서)
- [ ] **Test**: `tracking_notifier_test.dart` - saveDailyLog 메서드 테스트
- [ ] **Code**: `TrackingNotifier`를 Code Generation 방식으로 변환
  - `@riverpod` annotation 추가
  - `extends _$TrackingNotifier` 상속
  - `ref.watch` → `ref.read` 변경
  - `saveDailyLog` 메서드 구현 (Navigation 포함)
- [ ] **Generate**: `dart run build_runner build --delete-conflicting-outputs` 실행
- [ ] **Refactor**: 에러 처리 개선

### Phase 5: Presentation Layer (Widget Test-First)
- [ ] **Test**: `daily_tracking_screen_test.dart` - UI 상호작용 테스트 작성
- [ ] **Code**: `DailyTrackingScreen` 구현
  - 날짜 선택 위젯 (재사용: `DateSelectionWidget`)
  - 체중 입력 위젯 (재사용: `InputValidationWidget`)
  - 식욕 조절 버튼 그룹 (신규: 5단계 수평 버튼)
  - 부작용 섹션 (신규: `ExpansionTile`로 접힌 상태 시작)
  - **🆕 증상별 개별 심각도 UI** (핵심 구현):
    - 증상 선택 칩 (FilterChip) - 탭하여 선택/해제
    - 선택된 증상 리스트 표시 (Column/ListView)
    - 각 증상마다 독립적인 슬라이더(1-10) 표시
    - 증상별 심각도 상태 관리: `Map<String, int>` (예: {'메스꺼움': 8, '두통': 3})
  - **증상별 개별 옵션**:
    - 각 증상의 심각도가 7-10점이면 "24시간 지속 여부" 질문 표시
    - 각 증상의 심각도가 1-6점이면 컨텍스트 태그 선택 표시
    - 증상별로 다른 태그를 가질 수 있음: `Map<String, List<String>>`
  - 메모 입력 필드 (공통)
  - 저장 버튼 및 검증 로직 (식욕 점수 필수 확인)
- [ ] **Refactor**: 재사용 가능한 위젯 추출 (`SymptomSeverityInput` 위젯 등)

**⚠️ UI 구현 주의사항**:
- ExpansionTile의 `initiallyExpanded: false` 설정
- **증상별 개별 심각도**: `Map<String, int> symptomSeverities` 상태 관리
- **증상별 개별 태그**: `Map<String, List<String>> symptomTags` 상태 관리
- **증상별 개별 24시간 지속**: `Map<String, bool?> symptomPersistent` 상태 관리
- 저장 시 선택된 증상 수만큼 SymptomLog 레코드 생성 (각각 **다른 심각도**)

**UI 예시**:
```
[ExpansionTile: "부작용 기록 (선택)"]
  [FilterChip: 메스꺼움] [FilterChip: 두통] [FilterChip: 구토] ...

  선택된 증상:
  ┌─────────────────────────────────────┐
  │ 메스꺼움                             │
  │ 심각도: ●────────○──  8점            │
  │ □ 24시간 이상 지속                  │
  └─────────────────────────────────────┘
  ┌─────────────────────────────────────┐
  │ 두통                                 │
  │ 심각도: ○──────────●  3점            │
  │ 태그: [기름진음식] [스트레스]        │
  └─────────────────────────────────────┘

  [메모 입력 필드]
```

### Phase 6: Routing & Navigation
- [ ] `app_router.dart`: `/tracking/daily` 라우트 추가
- [ ] `scaffold_with_bottom_nav.dart`: '기록' 버튼 라우트 변경
- [ ] 기존 라우트 삭제 (`/tracking/weight`, `/tracking/symptom`)

### Phase 7: Cleanup
- [ ] `weight_record_screen.dart` 삭제
- [ ] `symptom_record_screen.dart` 삭제
- [ ] 미사용 import 정리
- [ ] `flutter analyze` 경고 제거

### Phase 8: Integration Test (선택)
- [ ] 전체 플로우 통합 테스트 작성 및 실행

---

## 5. 데이터 상세 (Data Details)

### Appetite Score 상세 스펙

| 점수 | 의미 (한글) | 의미 (영문) | UI 레이블 |
|-----|-----------|-----------|----------|
| 5 | 식욕 폭발 | Severe hunger | 폭발 |
| 4 | 보통 | Normal | 보통 |
| 3 | 약간 감소 | Slight decrease | 약간↓ |
| 2 | 매우 감소 | Significant decrease | 많이↓ |
| 1 | 아예 없음 | No appetite | 없음 |
| null | 기록 안 함 | Not recorded | (미선택) |

### 데이터베이스 제약 조건

```sql
-- weight_logs 테이블
ALTER TABLE weight_logs
ADD COLUMN appetite_score integer
CHECK (appetite_score IS NULL OR (appetite_score >= 1 AND appetite_score <= 5));
```

### 트랜잭션 전략

**현재 (Phase 1)**:
- 순차 저장 (체중 → 증상들)
- Supabase의 암묵적 트랜잭션 활용
- 증상 저장 실패 시 체중만 저장됨 (부분 실패 가능)

**향후 개선 (Optional)**:
```sql
-- Supabase RPC 함수로 원자적 저장
CREATE OR REPLACE FUNCTION save_daily_log(
  p_user_id uuid,
  p_log_date date,
  p_weight_kg numeric,
  p_appetite_score integer,
  p_symptoms jsonb
)
RETURNS void AS $$
BEGIN
  -- 체중 저장
  INSERT INTO weight_logs (user_id, log_date, weight_kg, appetite_score, ...)
  VALUES (p_user_id, p_log_date, p_weight_kg, p_appetite_score, ...)
  ON CONFLICT (user_id, log_date) DO UPDATE
  SET weight_kg = EXCLUDED.weight_kg, appetite_score = EXCLUDED.appetite_score;

  -- 증상들 저장
  INSERT INTO symptom_logs (user_id, log_date, symptom_name, severity, ...)
  SELECT p_user_id, p_log_date, s->>'symptom_name', (s->>'severity')::int, ...
  FROM jsonb_array_elements(p_symptoms) s;

  -- 태그 저장
  -- ...
END;
$$ LANGUAGE plpgsql;
```

---

## 6. 확장성 고려 (Future Considerations)

### 향후 추가 가능한 신체 지표

`WeightLog`에 추가 가능한 필드들:
- `bloodSugarMg` (혈당, mg/dL)
- `bloodPressureSystolic` (수축기 혈압)
- `bloodPressureDiastolic` (이완기 혈압)
- `sleepHours` (수면 시간)
- `waterIntakeMl` (수분 섭취량)

**패턴 유지**:
- nullable로 설계
- DTO 매핑 자동 처리
- UI에서 선택적 입력

### Clean Architecture 유지

```
Presentation → Application → Domain ← Infrastructure
```

- Domain Entity 확장 → DTO 업데이트 → Repository 자동 처리
- Phase 1 전환 시와 동일한 1-line 변경 원칙 유지

---

## 7. 제약 사항 및 중요 결정사항 (Constraints & Key Decisions)

### 아키텍처 제약
- **Clean Architecture 준수**: Presentation, Domain, Data 레이어 분리 유지
- **Repository Pattern**: TrackingRepository 인터페이스를 통한 데이터 접근
- **Riverpod 3.0 Code Generation 패턴**:
  - ✅ `@riverpod` annotation 사용
  - ✅ `part '*.g.dart'` 선언 (Generated file)
  - ✅ `ref.read()` 사용 (build()와 메서드 모두)
  - ✅ Auto-dispose by default (가이드 권장)
- **TDD**: 모든 핵심 로직은 Test-First로 개발

### UI/UX 결정사항
- **증상별 개별 심각도**: ✅ **각 증상마다 독립적인 심각도 입력** (핵심 UX 개선)
  - UI: 증상 선택 후 각 증상마다 슬라이더(1-10) 표시
  - 데이터: `Map<String, int>` 구조로 상태 관리 (예: {'메스꺼움': 8, '두통': 3})
  - 저장: 각 증상을 별도의 SymptomLog 레코드로 저장 (각각 다른 severity)
  - 장점: 실제 사용자 경험에 맞는 정확한 증상 기록 가능
- **증상별 개별 옵션**:
  - 24시간 지속 여부: 심각도 7-10점 증상에만 표시
  - 컨텍스트 태그: 심각도 1-6점 증상에만 표시
  - 각 증상마다 다른 태그 선택 가능
- **부작용 섹션**: ExpansionTile로 접힌 상태 시작 (UX 개선)
- **식욕 점수**: 필수 입력 항목 (저장 시 검증)
- **기존 위젯 재사용**: DateSelectionWidget, InputValidationWidget 등

### 데이터 무결성
- **트랜잭션**: 순차 저장 (체중 → 증상들)
  - 현재: 부분 실패 가능 (증상 실패 시 체중만 저장)
  - 향후: Supabase RPC 함수로 원자적 저장 구현 가능 (선택 사항)
- **기존 데이터 호환**: appetiteScore nullable 설계로 기존 레코드 호환

---

## 8. 완료 체크리스트

### 기능 구현
- [ ] WeightLog 엔티티에 appetiteScore 추가
- [ ] WeightLogDto 업데이트
- [ ] Supabase 스키마 마이그레이션
- [ ] **Code Generation 설정**:
  - [ ] `tracking_notifier.dart`에 `part 'tracking_notifier.g.dart';` 추가
  - [ ] `@riverpod` annotation 추가
  - [ ] `dart run build_runner build --delete-conflicting-outputs` 실행
  - [ ] 생성된 `tracking_notifier.g.dart` 파일 확인
- [ ] DailyTrackingScreen 구현
- [ ] TrackingNotifier.saveDailyLog 구현 (Navigation 포함)
- [ ] 라우팅 업데이트
- [ ] 기존 화면 삭제

### 테스트
- [ ] Unit Tests: WeightLog, WeightLogDto
- [ ] Unit Tests: TrackingNotifier.saveDailyLog
- [ ] Widget Tests: DailyTrackingScreen UI
- [ ] Integration Tests: 전체 플로우 (선택)

### 품질 검증
- [ ] `flutter analyze` 경고 없음
- [ ] `flutter test` 모든 테스트 통과
- [ ] 실제 디바이스에서 동작 확인
- [ ] 기존 데이터 호환성 확인 (appetiteScore null 처리)

---

## 9. 결과물 (Deliverables)

1. **Updated Domain Entity**: `weight_log.dart` (appetiteScore 추가)
2. **Updated DTO**: `weight_log_dto.dart` (직렬화/역직렬화)
3. **New Screen**: `daily_tracking_screen.dart` (통합 UI)
4. **Updated Notifier (Code Generation)**:
   - `tracking_notifier.dart` (Riverpod 3.0 패턴, saveDailyLog + Navigation)
   - `tracking_notifier.g.dart` (자동 생성, Git 추적 안 함)
5. **Updated Router**: `app_router.dart` (`/tracking/daily` 라우트)
6. **Updated Navigation**: `scaffold_with_bottom_nav.dart` (라우트 변경)
7. **Database Migration**: Supabase SQL 스크립트
8. **Test Suite**:
   - Unit Tests (WeightLog, WeightLogDto, TrackingNotifier)
   - Widget Tests (DailyTrackingScreen)
   - Integration Tests (선택 사항)
9. **Documentation**: 이 문서 (`record_refactoring_final.md`)

---

## 10. 구현 전 필수 확인사항 (Pre-Implementation Checklist)

### 🔴 필수 작업 (Critical)

1. **데이터베이스 마이그레이션**
   ```sql
   -- Supabase 콘솔에서 실행
   ALTER TABLE weight_logs
   ADD COLUMN appetite_score integer
   CHECK (appetite_score IS NULL OR (appetite_score >= 1 AND appetite_score <= 5));
   ```
   ⚠️ 이 작업 없이는 appetiteScore 저장 실패

2. **.gitignore 설정 확인**
   ```gitignore
   # .gitignore
   # Generated files (자동 생성 파일은 Git 추적 안 함)
   **/*.g.dart
   **/*.freezed.dart
   ```
   ⚠️ Code Generation으로 생성된 `.g.dart` 파일은 Git에 커밋하지 않습니다.

3. **현재 DB 스키마 확인**
   - `supabase/migrations/01.schema.sql` 읽기
   - `symptom_logs` 테이블 (line 128-138): ✅ 이미 증상별 개별 심각도 지원
   - `symptom_context_tags` 테이블 (line 145-152): ✅ 이미 증상별 태그 지원
   - **변경 불필요**: weight_logs 테이블만 appetite_score 컬럼 추가

4. **기존 코드 이해**
   - `lib/features/tracking/presentation/screens/symptom_record_screen.dart` 읽기
   - 증상 저장 로직 (line 196-214) 확인
   - **문제점**: 현재는 공통 심각도 1개만 사용 (line 44-45: `int severity = 5;`)
   - **개선 방향**: UI를 증상별 개별 심각도 입력으로 변경

### 🟡 권장 작업 (Recommended)

1. **Riverpod 가이드 참조**
   - `docs/external/riverpod_flutter_gorouter설정가이드.md` 읽기
   - Code Generation 패턴 (Section 3.1-3.6) 확인
   - AsyncNotifier 패턴 (Section 3.5) 확인
   - AsyncValue.guard() 사용법 이해 (Section 8, Pattern 3)
   - Navigation without Context (Section 5.3) 확인

2. **Code Generation 설정 확인**
   - `pubspec.yaml`에 `riverpod_annotation`, `riverpod_generator` 의존성 확인
   - `build_runner` 설치 확인
   - `analysis_options.yaml`에서 `*.g.dart` exclude 설정 확인

3. **기존 위젯 파악**
   - `DateSelectionWidget` 사용법 확인
   - `InputValidationWidget` props 확인
   - `ExpansionTile` Flutter 공식 문서 참조

4. **테스트 구조 확인**
   - 기존 `weight_log_test.dart` 패턴 확인
   - Mock Repository 설정 방법 파악

---

## 11. 참고 문서

### 프로젝트 문서
- `docs/tdd.md`: TDD 원칙 및 테스트 전략
- `docs/code_structure.md`: Clean Architecture 레이어 구조
- `docs/state-management.md`: Riverpod Provider 패턴
- `docs/database.md`: 데이터베이스 스키마
- `CLAUDE.md`: 프로젝트 개발 원칙 및 규칙

### 외부 가이드 ⭐ 필독
- `docs/external/riverpod_flutter_gorouter설정가이드.md`: **Riverpod 3.0 + GoRouter 통합 가이드**
  - Section 3: Riverpod Code Generation (필수)
  - Section 3.5: AsyncNotifier 패턴 (saveDailyLog 구현 시 참조)
  - Section 5.3: Navigation without Context (저장 후 화면 전환)
  - Section 8: Common Patterns (에러 처리, 다중 Repository 조합)
- [Riverpod Official Docs](https://riverpod.dev)
- [Flutter ExpansionTile](https://api.flutter.dev/flutter/material/ExpansionTile-class.html)

### 검토 문서
- `docs/record_refactoring_review.md`: 구현 전 검토 분석 (증상 심각도 패턴)
