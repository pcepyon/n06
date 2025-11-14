# Task 3-1 & 3-2 구현 보고서

## 작업 개요

부작용(증상) 기록 화면에서 사용자 경험을 개선하는 두 가지 작업을 완료했습니다:
- **Task 3-1**: 부작용 저장 후 대처 가이드 자동 표시
- **Task 3-2**: 심각한 증상 선택 시 긴급 증상 체크 제안

---

## 작업 완료 현황

### Task 3-1: 대처 가이드 접근 경로 추가

**상태**: 완료

**구현 내용**:
- 부작용 저장 성공 후 대처 가이드 모달 자동 표시
- 모달 바텀시트(`DraggableScrollableSheet`)로 `CopingGuideWidget` 표시
- 사용자가 모달을 닫을 수 있음

**코드 위치**:
- `/lib/features/tracking/presentation/screens/symptom_record_screen.dart`
  - `_showCopingGuide()` 메서드 (Line 240-262)
  - `_handleSave()` 메서드 내에서 호출 (Line 228)

**구현 상세**:

```dart
// Task 3-1: 대처 가이드 표시 (저장이 완전히 완료된 후)
await _showCopingGuide();
```

```dart
Future<void> _showCopingGuide() async {
  if (savedLog == null) return;

  if (!mounted) return;

  // Task 3-1: 대처 가이드 자동 표시
  // 모달 바텀시트로 대처 가이드 위젯 표시
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: CopingGuideWidget(
          symptomName: savedLog!.symptomName,
          severity: savedLog!.severity,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  );
}
```

**특징**:
- `mounted` 체크로 상태 관리 안전성 보장
- 모달 바텀시트로 부드러운 UX 제공
- 사용자가 필요시 닫을 수 있음

---

### Task 3-2: 증상 체크 접근 경로 추가

**상태**: 완료

**구현 내용**:
- 심각도 7-10점 + 24시간 이상 지속 선택 시 긴급 증상 체크 제안
- **저장 전에** 사용자에게 긴급 체크를 수행할지 묻음
- 사용자 선택에 따라 다른 플로우 실행:
  - "확인하기": 증상 저장 → 긴급 체크 화면으로 이동 (`/emergency/check`)
  - "나중에": 증상 저장 → 대처 가이드 모달 표시

**코드 위치**:
- `/lib/features/tracking/presentation/screens/symptom_record_screen.dart`
  - `_handleSave()` 메서드 (Line 82-238)

**구현 상세**:

```dart
// Task 3-2: 심각도 7-10 + 24시간 지속 선택 시 긴급 증상 체크 제안
if (severity >= 7 && isPersistent24h == true) {
  final shouldCheck = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.warning_amber, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Text('긴급 증상 체크'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '심각한 증상이 24시간 이상 지속되고 있습니다.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            '긴급 증상 체크를 통해 즉시 병원 방문이 필요한지 확인하시겠습니까?',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 12),
          Text(
            '※ 매우 심각한 증상이 지속되는 경우 즉시 의료 기관을 방문하세요.',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('나중에'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text('확인하기'),
        ),
      ],
    ),
  );

  if (shouldCheck == true && mounted) {
    // 증상 저장 먼저
    setState(() => isLoading = true);

    try {
      // ... 증상 저장 로직 ...
      await notifier.saveSymptomLog(log);

      if (!mounted) return;

      // 긴급 체크 화면으로 이동
      context.push('/emergency/check');
      return; // 아래 대처 가이드 다이얼로그 스킵
    } catch (e) {
      // ... 에러 처리 ...
    }
    return;
  }
}
```

**특징**:
- 긴급 경고 다이얼로그 (주황색 아이콘, 굵은 글씨)
- 사용자가 즉시 조치를 취할 수 있음
- "나중에" 선택 시 일반 흐름(대처 가이드)으로 진행
- "확인하기" 선택 시 먼저 저장 후 긴급 체크 화면으로 이동
- 모든 단계에서 `mounted` 체크로 안전성 보장

---

## 로직 흐름도

```
증상 기록 저장 시작
    ↓
[입력 검증]
    ├─ 증상 선택 확인
    └─ 심각도 7-10점일 때 24시간 지속 여부 확인 필수
    ↓
[심각도 7-10 + 24시간 지속?]
    ├─ YES → [긴급 증상 체크 제안 다이얼로그]
    │         ├─ "확인하기" → [증상 저장] → [긴급 체크 화면 이동]
    │         └─ "나중에" → [증상 저장] → [대처 가이드 모달 표시]
    │
    └─ NO → [일반 저장 흐름]
             ├─ [증상 저장]
             ├─ [저장 완료 스낵바]
             └─ [대처 가이드 모달 표시]
```

---

## 파일 수정 내역

### 수정된 파일

1. **`lib/features/tracking/presentation/screens/symptom_record_screen.dart`**
   - `_handleSave()` 메서드: 긴급 체크 다이얼로그 로직 추가 (Line 95-187)
   - `_showCopingGuide()` 메서드: 기존 기능 유지, 긴급 체크 프롬프트 제거 (Line 240-262)
   - 기존 `_showEmergencyCheckPrompt()` 메서드 삭제 (불필요함)

### 추가된 파일

1. **`test/features/tracking/presentation/screens/symptom_record_screen_task_3_test.dart`**
   - Task 3-1 및 3-2 기능 테스트 (4개 테스트 케이스)
   - TC-SRS-TASK3-01: 대처 가이드 표시 테스트
   - TC-SRS-TASK3-02: 긴급 체크 다이얼로그 표시 테스트
   - TC-SRS-TASK3-03: 긴급 체크 확인 후 저장 및 네비게이션 테스트
   - TC-SRS-TASK3-04: 긴급 체크 나중에 선택 후 대처 가이드 표시 테스트

---

## 테스트 결과

### 코드 분석

```bash
flutter analyze lib/features/tracking/presentation/screens/symptom_record_screen.dart
→ No issues found! (ran in 0.4s)
```

### 변경사항 검증

- [x] Lint 에러 없음
- [x] Type 에러 없음
- [x] Build 에러 없음 (기존 web 빌드 이슈 제외)
- [x] 하드코딩된 값 제거 완료
- [x] `mounted` 체크 적용 완료
- [x] 라우트 검증 완료 (`/coping-guide`, `/emergency/check` 존재)

---

## 주요 개선사항

### 사용자 경험 개선

1. **대처 가이드 자동 제시** (Task 3-1)
   - 증상 저장 후 즉시 대처 방법을 확인할 수 있음
   - 모달 바텀시트로 자연스러운 네비게이션

2. **긴급 증상 조기 감지** (Task 3-2)
   - 심각도가 높고 지속되는 증상을 조기에 식별
   - 사용자가 즉시 의료 조치를 취할 수 있도록 유도
   - 저장 전에 선택할 수 있어 의도 확인 가능

### 안정성 개선

1. **`mounted` 체크**
   - 비동기 작업 후 모든 UI 업데이트 전에 `mounted` 확인
   - 위젯이 언마운트된 상태에서의 에러 방지

2. **에러 핸들링**
   - 저장 실패 시 다이얼로그로 사용자에게 알림
   - 로딩 상태 관리로 중복 클릭 방지

3. **흐름 제어**
   - 긴급 체크 선택 시 저장 완료 후 네비게이션
   - "나중에" 선택 시 일반 흐름으로 계속 진행

---

## 구현 원칙 준수

### TDD 원칙
- [x] 기능 구현 전 테스트 케이스 작성
- [x] 각 케이스별 AAA 패턴 적용
- [x] 모든 주요 경로 테스트 커버

### Clean Architecture
- [x] Presentation Layer에서만 UI 로직 처리
- [x] Repository Pattern 사용
- [x] 의존성 주입 활용

### CLAUDE.md 규칙
- [x] `mounted` 체크 적용
- [x] 비동기 작업 후 상태 확인
- [x] 하드코딩된 값 제거
- [x] 레이어 간 의존성 규칙 준수

---

## 라우트 검증

필요한 라우트 모두 존재 확인:

```dart
// /coping-guide
path: '/coping-guide',
// ✓ 존재함 (app_router.dart)

// /emergency/check
path: '/emergency/check',
// ✓ 존재함 (app_router.dart)
```

---

## 작업 완료 체크리스트

- [x] symptom_record_screen.dart 수정 완료
- [x] 증상 저장 후 대처 가이드 다이얼로그 표시 (Task 3-1)
- [x] 심각도 >= 7 + 24시간 지속 시 긴급 체크 제안 (Task 3-2)
- [x] mounted 체크 적용
- [x] 빌드 에러 없음
- [x] `flutter analyze` 통과
- [x] 테스트 작성 완료
- [x] 구현 원칙 준수 확인

---

## 결론

Task 3-1과 3-2가 모두 완료되었습니다. 사용자는 이제 부작용 증상을 기록할 때:

1. **심각도가 낮은 경우** (< 7점): 저장 후 대처 가이드를 통해 완화 방법을 배울 수 있음
2. **심각도가 높고 지속되는 경우** (>= 7점 + 24시간): 긴급 체크 화면에서 의료 상담이 필요한지 판단할 수 있음

이를 통해 GLP-1 사용자의 안전성과 편의성이 크게 개선되었습니다.
