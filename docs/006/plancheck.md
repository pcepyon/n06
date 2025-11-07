# F004: 부작용 대처 가이드 Plan 검토 결과

## 검토 일시
2025-11-07

## 검토 범위
- spec.md (명세)와 plan.md (구현 계획) 간 일치성 검증
- 아키텍처 설계 적합성 검토
- 누락된 요구사항 식별

---

## 1. 주요 문제점

### 1.1 피드백 저장 기능 누락 (중요도: 높음)

**spec.md 요구사항**:
- BR-005: "피드백 데이터는 선택적으로 저장"
- Main Scenario 2: 사용자가 "예" 또는 "아니오" 선택 시 피드백 저장
- Sequence Diagram: `BE -> Database: 피드백 기록 저장`

**plan.md 현재 상태**:
- FeedbackWidget에서 콜백만 호출
- CopingGuideNotifier.submitFeedback()에서 "로그만 남김 (Phase 1에서 서버 전송)" 주석만 있음
- 피드백 저장을 위한 Entity, DTO, Repository가 **완전히 누락**

**필요한 수정**:
```dart
// 추가 필요: Domain Layer
class GuideFeedback {
  final String symptomName;
  final bool helpful;
  final DateTime timestamp;
}

// 추가 필요: Infrastructure Layer
@collection
class GuideFeedbackDto {
  Id id = Isar.autoIncrement;
  late String symptomName;
  late bool helpful;
  late DateTime timestamp;
}

// 추가 필요: CopingGuideNotifier
Future<void> submitFeedback(String symptomName, bool helpful) async {
  final feedback = GuideFeedback(
    symptomName: symptomName,
    helpful: helpful,
    timestamp: DateTime.now(),
  );
  await _feedbackRepository.saveFeedback(feedback); // 실제 저장
}
```

**영향 범위**:
- Domain: GuideFeedback Entity 추가
- Infrastructure: GuideFeedbackDto, FeedbackRepository 추가
- Application: CopingGuideNotifier 수정
- Test: 피드백 저장 시나리오 추가

---

### 1.2 심각 증상 연계 기능 누락 (중요도: 높음)

**spec.md 요구사항**:
- BR-007: "기록된 증상의 심각도가 7-10점이고 24시간 이상 지속된다고 선택된 경우, 대처 가이드 외에 증상 체크(F005) 화면으로 추가 안내 제공"

**plan.md 현재 상태**:
- 심각도 체크 로직 **완전히 누락**
- F005 연동 로직 없음

**필요한 수정**:
```dart
// CopingGuideNotifier에 추가
Future<void> checkSeverityAndGuide(
  String symptomName,
  int severity,
  String duration,
) async {
  final guide = await getGuideBySymptom(symptomName);

  // BR-007: 심각 증상 연계
  if (severity >= 7 && duration == '24시간 이상') {
    state = AsyncValue.data(CopingGuideState(
      guide: guide,
      showSeverityWarning: true, // F005 안내 플래그
    ));
  } else {
    state = AsyncValue.data(CopingGuideState(
      guide: guide,
      showSeverityWarning: false,
    ));
  }
}
```

**필요한 UI 변경**:
```dart
// CopingGuideCard에 추가
if (state.showSeverityWarning) {
  SeverityWarningBanner(
    onCheckSymptom: () => Navigator.push(...F005Screen),
  );
}
```

**영향 범위**:
- Domain: CopingGuideState에 showSeverityWarning 플래그 추가
- Application: CopingGuideNotifier에 심각도 체크 로직 추가
- Presentation: CopingGuideCard에 경고 배너 추가
- Test: 심각도 7-10점, 24시간 이상 시나리오 추가
- Integration: F005와 연동 테스트

---

### 1.3 "다른 팁 보기" 기능 불명확 (중요도: 중간)

**spec.md 요구사항**:
- Main Scenario 2: "사용자가 '다른 팁 보기' 선택 시 동일 증상의 추가 팁 표시"

**plan.md 현재 상태**:
- FeedbackWidget에서 "다른 팁 보기" 버튼만 언급
- 추가 팁 데이터 구조 **없음**
- 추가 팁 표시 로직 **없음**

**필요한 수정**:
```dart
// CopingGuide Entity 수정
class CopingGuide {
  final String symptomName;
  final String shortGuide;
  final List<String> alternativeTips; // 추가
  final List<GuideSection>? detailedSections;
}

// FeedbackWidget 수정
if (userSelectedNo && showAlternativeTips) {
  AlternativeTipsDialog(
    tips: guide.alternativeTips,
  );
}
```

**또는 간소화 방안**:
- Phase 0에서는 "다른 팁 보기" → 즉시 상세 가이드(DetailedGuideScreen)로 이동
- alternativeTips 필드는 Phase 1에서 추가

**영향 범위**:
- Domain: CopingGuide.alternativeTips 필드 추가 (또는 Phase 1로 연기)
- Presentation: FeedbackWidget 로직 수정
- Infrastructure: 하드코딩 데이터에 추가 팁 포함

---

### 1.4 가이드 데이터 관리 방식 과도하게 복잡 (중요도: 중간)

**spec.md 요구사항**:
- Edge Case 5: "가이드 데이터는 앱 내 정적 데이터로 관리"
- Edge Case 6: "Phase 0에서는 로컬 DB에 저장된 가이드 데이터 사용"

**plan.md 현재 상태**:
- Isar DB + DTO + Repository 구조로 설계
- 하드코딩된 데이터를 반환하면서도 Isar 인프라 사용

**문제점**:
- Phase 0에서 정적 데이터만 사용하는데 Isar DB 구조가 **불필요하게 복잡**
- Phase 1 전환 시에도 가이드 데이터는 정적이므로 DB 필요 없음
- DTO 변환 오버헤드 불필요

**권장 수정 방안**:

**Option 1: 완전 정적 데이터로 단순화 (권장)**
```dart
// CopingGuideRepository 구현
class StaticCopingGuideRepository implements CopingGuideRepository {
  static final _guides = <String, CopingGuide>{
    '메스꺼움': CopingGuide(...),
    '구토': CopingGuide(...),
    // ... 7가지 증상
  };

  @override
  Future<CopingGuide?> getGuideBySymptom(String symptomName) async {
    return _guides[symptomName];
  }

  @override
  Future<List<CopingGuide>> getAllGuides() async {
    return _guides.values.toList();
  }
}

// Provider
@riverpod
CopingGuideRepository copingGuideRepository(ref) {
  return StaticCopingGuideRepository(); // Isar 제거
}
```

**Option 2: JSON 파일로 관리 (Phase 1 확장성 고려)**
```dart
// assets/data/coping_guides.json
[
  {
    "symptomName": "메스꺼움",
    "shortGuide": "...",
    "detailedSections": [...]
  }
]

// JsonCopingGuideRepository
class JsonCopingGuideRepository implements CopingGuideRepository {
  Future<void> _loadGuides() async {
    final jsonString = await rootBundle.loadString('assets/data/coping_guides.json');
    // parse and cache
  }
}
```

**Option 3: 현재 계획 유지 (비권장)**
- Isar + DTO 구조 유지
- 단, IsarCopingGuideRepository에서 Isar 쓰기 작업 제거
- Phase 1에서도 가이드는 정적 데이터로 유지

**영향 범위**:
- Infrastructure: IsarCopingGuideRepository → StaticCopingGuideRepository로 단순화
- Infrastructure: CopingGuideDto 제거 가능 (Option 1 선택 시)
- Test: Isar 의존성 제거로 테스트 단순화

---

### 1.5 여러 증상 동시 기록 처리 로직 누락 (중요도: 낮음)

**spec.md 요구사항**:
- Edge Case 2: "여러 증상 동시 기록 시 각 증상별 가이드를 순차적으로 표시 또는 증상 목록 형태로 제공하고 사용자가 선택하여 확인"

**plan.md 현재 상태**:
- 단일 증상 가이드 표시만 고려
- 여러 증상 처리 로직 **없음**

**필요한 수정**:
```dart
// F002에서 증상 기록 완료 시
if (recordedSymptoms.length == 1) {
  // 현재 plan대로 단일 가이드 표시
  showCopingGuideCard(recordedSymptoms.first);
} else {
  // 여러 증상 선택 UI 표시
  showMultipleSymptomsGuideSelector(recordedSymptoms);
}

// MultipleSymptomsGuideSelector Widget 추가
class MultipleSymptomsGuideSelector extends StatelessWidget {
  final List<String> symptoms;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('기록한 증상의 가이드를 확인하세요'),
        ...symptoms.map((s) => ListTile(
          title: Text(s),
          trailing: Icon(Icons.arrow_forward),
          onTap: () => showGuideForSymptom(s),
        )),
      ],
    );
  }
}
```

**영향 범위**:
- Presentation: MultipleSymptomsGuideSelector Widget 추가
- Integration: F002와 연동 테스트

---

## 2. 아키텍처 설계 검토

### 2.1 Layer Dependency 준수 여부: ✅ 양호
```
Presentation (CopingGuideScreen, CopingGuideCard)
    ↓
Application (CopingGuideNotifier)
    ↓
Domain (CopingGuideRepository Interface, CopingGuide Entity)
    ↑
Infrastructure (IsarCopingGuideRepository, CopingGuideDto)
```

**문제점 없음**

---

### 2.2 Repository Pattern 준수 여부: ✅ 양호

- Domain에 Repository Interface 정의
- Infrastructure에서 구현
- Application/Presentation은 Interface만 의존

**문제점 없음**

단, 앞서 언급한 대로 **Isar 사용이 과도하게 복잡**한 점은 개선 권장

---

### 2.3 TDD 전략: ⚠️ 부분적 개선 필요

**양호한 점**:
- Unit Test, Widget Test, Integration Test 구분 명확
- AAA 패턴 적용
- Red-Green-Refactor 사이클 준수

**개선 필요**:
- **피드백 저장 테스트 누락** (1.1 문제 해결 시 추가)
- **심각 증상 연계 테스트 누락** (1.2 문제 해결 시 추가)
- **여러 증상 동시 기록 테스트 누락** (1.5 문제 해결 시 추가)

---

## 3. 누락된 시나리오 요약

| 시나리오 | spec.md | plan.md | 우선순위 |
|---------|---------|---------|----------|
| 피드백 저장 | ✅ 명시 | ❌ 누락 | 높음 |
| 심각 증상 연계 (BR-007) | ✅ 명시 | ❌ 누락 | 높음 |
| 다른 팁 보기 | ✅ 명시 | ⚠️ 불명확 | 중간 |
| 여러 증상 동시 기록 | ✅ 명시 | ❌ 누락 | 낮음 |
| 가이드 데이터 정적 관리 | ✅ 명시 | ⚠️ 과도하게 복잡 | 중간 |
| 등록되지 않은 증상 처리 | ✅ 명시 | ✅ 구현 | - |
| 가이드 자동 표시 | ✅ 명시 | ✅ 구현 | - |
| 가이드 탭 조회 | ✅ 명시 | ✅ 구현 | - |

---

## 4. 권장 수정 사항

### 4.1 즉시 수정 필요 (Phase 0 블로커)

1. **피드백 저장 기능 추가** (1.1)
   - GuideFeedback Entity, DTO, Repository 추가
   - CopingGuideNotifier.submitFeedback() 실제 저장 로직 구현
   - 테스트 추가

2. **심각 증상 연계 로직 추가** (1.2)
   - CopingGuideNotifier에 심각도 체크 로직
   - CopingGuideCard에 경고 배너 UI
   - F005 화면 연동
   - 테스트 추가

### 4.2 Phase 0 내 개선 권장

3. **가이드 데이터 관리 단순화** (1.4)
   - Option 1 (권장): StaticCopingGuideRepository로 단순화
   - Isar + DTO 제거
   - 테스트 단순화

4. **"다른 팁 보기" 기능 명확화** (1.3)
   - 간소화: 상세 가이드로 즉시 이동
   - 또는 alternativeTips 필드 추가

### 4.3 Phase 0에서 선택적 구현

5. **여러 증상 동시 기록 처리** (1.5)
   - MultipleSymptomsGuideSelector Widget 추가
   - F002 연동 수정

---

## 5. 수정 우선순위

### Priority 1: 필수 (Phase 0 블로커)
- [ ] 피드백 저장 기능 추가 (1.1)
- [ ] 심각 증상 연계 로직 추가 (1.2)

### Priority 2: 강력 권장 (아키텍처 개선)
- [ ] 가이드 데이터 관리 단순화 (1.4)

### Priority 3: 권장 (UX 개선)
- [ ] "다른 팁 보기" 기능 명확화 (1.3)

### Priority 4: 선택적 (Edge Case 대응)
- [ ] 여러 증상 동시 기록 처리 (1.5)

---

## 6. 수정 후 검증 체크리스트

### 설계 일치성
- [ ] spec.md의 모든 Business Rules가 plan에 반영됨
- [ ] spec.md의 모든 Edge Cases가 plan에 반영됨
- [ ] Sequence Diagram의 모든 흐름이 구현됨

### 아키텍처 준수
- [ ] Layer Dependency 위배 없음
- [ ] Repository Pattern 올바르게 적용
- [ ] Domain Layer가 인프라에 의존하지 않음

### TDD 완성도
- [ ] 모든 시나리오에 대한 테스트 작성
- [ ] Red-Green-Refactor 사이클 준수
- [ ] Code Coverage 80% 이상

### 문서화
- [ ] plan.md 수정 사항 반영
- [ ] 새로 추가된 모듈 문서화
- [ ] QA Sheet 업데이트

---

## 7. 결론

plan.md는 전반적으로 Clean Architecture와 TDD 원칙을 잘 따르고 있으나, **spec.md의 중요한 요구사항 일부가 누락**되어 있습니다.

**핵심 누락 사항**:
1. 피드백 저장 (BR-005)
2. 심각 증상 연계 (BR-007)

이 두 가지는 **Phase 0 완성을 위한 필수 요구사항**이므로 plan.md를 수정하여 반영해야 합니다.

또한, 가이드 데이터를 정적으로 관리한다는 spec의 의도를 고려할 때, Isar DB 구조는 과도하게 복잡하므로 **단순화를 강력히 권장**합니다.

**다음 단계**:
1. plan.md 수정 (피드백 저장, 심각 증상 연계 추가)
2. 가이드 데이터 관리 방식 결정 (Option 1, 2, 3 중 선택)
3. 수정된 plan으로 구현 시작
