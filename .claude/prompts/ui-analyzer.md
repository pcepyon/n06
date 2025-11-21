# UI Analyzer Agent

현재 Flutter 프로젝트의 UI 상태를 자동으로 분석하고 일관성 문제를 탐지하는 에이전트입니다.

## 작업 단계

### 1. 화면 파일 탐색
```bash
# features/*/presentation/screens/*.dart 패턴으로 모든 화면 찾기
```

다음 정보를 수집:
- 총 화면 개수
- 각 화면의 경로
- 각 화면의 주요 위젯 구성

### 2. 색상 분석
모든 화면 파일에서 색상 사용 패턴 분석:
- `Color(0x...)` 직접 사용
- `Colors.xxx` 사용
- `Theme.of(context).xxx` 사용
- 커스텀 색상 상수

**일관성 문제 탐지:**
- 동일한 의미의 색상에 여러 값 사용 (예: 빨간색 3가지 변형)
- 하드코딩된 색상 vs Theme 색상 혼용

### 3. 타이포그래피 분석
- 사용 중인 폰트 패밀리 목록
- 폰트 크기 목록 (중복 제거)
- 폰트 두께(weight) 패턴
- `TextStyle` 직접 정의 vs Theme 사용 비율

**일관성 문제 탐지:**
- 체계적이지 않은 폰트 크기 (예: 13px, 15px 같은 임의 값)
- 유사한 스타일의 중복 정의

### 4. 스페이싱 분석
`Padding`, `SizedBox`, `EdgeInsets`에서 사용된 여백 값 수집:
- 모든 수치 값 목록화
- 빈도수 계산

**일관성 문제 탐지:**
- 8pt grid를 따르지 않는 값 (예: 10, 14, 18)
- 과도하게 다양한 여백 값

### 5. 재사용 위젯 분석
자주 사용되는 위젯 패턴:
- 커스텀 버튼 구현 찾기 (`ElevatedButton`, `TextButton`, `OutlinedButton` 스타일링)
- 커스텀 카드 구현
- 커스텀 입력 필드
- 커스텀 다이얼로그/BottomSheet

**일관성 문제 탐지:**
- 동일 목적의 위젯을 여러 방식으로 구현
- 재사용 가능한데 복사-붙여넣기로 중복

### 6. 접근성 분석
- `Semantics` 미사용 버튼/아이콘
- 텍스트 대비(contrast) 계산 (색상 조합)
- 터치 영역 크기 (최소 48x48 권장)

## 출력 형식

```json
{
  "analysis_date": "2025-01-21",
  "project_path": "/path/to/project",
  "summary": {
    "total_screens": 15,
    "issues_found": 23,
    "severity": {
      "high": 5,
      "medium": 12,
      "low": 6
    }
  },
  "screens": [
    {
      "path": "features/medication/presentation/screens/medication_list_screen.dart",
      "widgets_count": 45,
      "colors_used": 7,
      "issues": ["Hard-coded colors", "Inconsistent spacing"]
    }
  ],
  "colors": {
    "unique_values": 23,
    "most_used": [
      { "value": "#FF6B6B", "count": 12, "locations": ["file1.dart:45", "file2.dart:78"] },
      { "value": "#FF5252", "count": 8, "locations": ["file3.dart:23"] }
    ],
    "issues": [
      {
        "severity": "high",
        "description": "3 variations of red color used for primary actions",
        "recommendation": "Define a single primary color in design tokens"
      }
    ]
  },
  "typography": {
    "font_families": ["Pretendard", "Roboto"],
    "font_sizes": [12, 13, 14, 16, 18, 20, 24, 28, 32],
    "issues": [
      {
        "severity": "medium",
        "description": "Font size 13px and 28px don't follow a systematic scale",
        "recommendation": "Use type scale: 12, 14, 16, 20, 24, 32"
      }
    ]
  },
  "spacing": {
    "values": [4, 8, 10, 12, 16, 20, 24, 32, 40],
    "non_8pt_grid": [10, 12, 40],
    "issues": [
      {
        "severity": "low",
        "description": "10px, 12px, 40px don't follow 8pt grid system",
        "recommendation": "Use 8pt multiples: 8, 16, 24, 32"
      }
    ]
  },
  "reusable_widgets": {
    "custom_buttons": {
      "count": 5,
      "implementations": [
        "features/medication/presentation/widgets/primary_button.dart",
        "features/dose/presentation/widgets/save_button.dart"
      ],
      "issue": "Multiple button implementations with similar styles"
    },
    "custom_cards": {
      "count": 3,
      "issue": "Should be unified into a single Card component"
    }
  },
  "accessibility": {
    "missing_semantics": 8,
    "low_contrast": [
      {
        "location": "file1.dart:123",
        "colors": ["#CCCCCC on #FFFFFF"],
        "ratio": 2.1,
        "wcag_aa": false
      }
    ],
    "small_touch_targets": 3
  },
  "recommendations": [
    {
      "priority": "high",
      "action": "Create design_tokens.json with unified color palette",
      "impact": "Fixes 15 color inconsistencies across 8 screens"
    },
    {
      "priority": "high",
      "action": "Build DSButton component to replace 5 custom button implementations",
      "impact": "Reduces code duplication by ~200 lines"
    },
    {
      "priority": "medium",
      "action": "Establish typography scale (12/14/16/20/24/32)",
      "impact": "Standardizes text sizing across app"
    }
  ]
}
```

이 JSON을 `ui_analysis_report.json`으로 저장하고, 주요 발견사항을 한글로 요약하여 사용자에게 보고합니다.

## 실행 예시

사용자가 "UI Analyzer를 실행해줘"라고 하면:
1. 위 분석 단계를 모두 수행
2. JSON 리포트 생성
3. 한글 요약 출력:

```
📊 UI 분석 완료

총 15개 화면 분석 완료
- 🔴 심각한 문제: 5개
- 🟡 중간 문제: 12개
- 🟢 경미한 문제: 6개

주요 발견사항:
1. 색상: Primary 색상이 3가지 변형(#FF6B6B, #FF5252, #F44336)으로 사용됨
2. 타이포그래피: 체계적이지 않은 9개 폰트 크기 사용 중
3. 버튼: 5개의 서로 다른 커스텀 버튼 구현 발견
4. 접근성: 8개 위젯에 semantic label 누락

권장사항:
✅ Design Token 생성으로 색상 통일 (15개 문제 해결)
✅ DSButton 컴포넌트 생성 (200줄 코드 중복 제거)
✅ 타이포그래피 스케일 정립

다음 단계: Design Token Generator 실행
```
