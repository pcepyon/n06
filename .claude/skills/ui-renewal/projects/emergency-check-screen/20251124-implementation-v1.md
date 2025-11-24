# EmergencyCheckScreen - Implementation Specification

**Phase**: 2B (Implementation Specification)
**Date**: 2025-11-24
**Status**: In Progress

---

## 1. Component Architecture

### 1.1 File Structure
```
lib/features/tracking/
├── presentation/
│   ├── screens/
│   │   └── emergency_check_screen.dart (MODIFY)
│   └── widgets/
│       ├── emergency_checklist_item.dart (CREATE)
│       └── consultation_recommendation_dialog.dart (MODIFY)
```

### 1.2 Component Dependencies
```
EmergencyCheckScreen
├─ GabiumButton (reused)
├─ GabiumToast (reused)
├─ EmergencyChecklistItem (new)
│   └─ Checkbox (custom, 44x44px)
└─ ConsultationRecommendationDialog (modified)
    ├─ GabiumButton (reused)
    └─ WarningBanner (pattern)
```

---

## 2. Detailed Implementation Guide

### 2.1 EmergencyChecklistItem (새로운 컴포넌트)

**Purpose**: 개별 긴급 증상 체크 항목 컴포넌트
**Location**: `lib/features/tracking/presentation/widgets/emergency_checklist_item.dart`
**Lines**: ~90 lines

```dart
import 'package:flutter/material.dart';

class EmergencyChecklistItem extends StatelessWidget {
  final String symptom;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const EmergencyChecklistItem({
    required this.symptom,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Colors from Design System
    const errorColor = Color(0xFFEF4444); // Error
    const primaryColor = Color(0xFF4ADE80); // Primary
    const neutral600 = Color(0xFF475569); // Neutral-600

    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            // Custom Checkbox (44x44px touch area)
            SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isChecked ? primaryColor : Color(0xFF94A3B8), // Neutral-400
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: isChecked ? primaryColor : Colors.white,
                  ),
                  child: isChecked
                      ? Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ),
            // Symptom Text
            Expanded(
              child: Text(
                symptom,
                style: TextStyle(
                  fontSize: 16, // base scale
                  fontWeight: FontWeight.w400, // Regular
                  color: neutral600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Features**:
- 44x44px 터치 영역 (WCAG 기준)
- Custom checkbox (Material과 다른 디자인)
- 명확한 상태 전환 (unchecked → checked)
- 의미론적 색상 사용

**Reusability**: 유사 체크리스트 (증상 체크, 옵션 선택 등)에서 재사용 가능

---

### 2.2 ConsultationRecommendationDialog (개선)

**Current**: 65 lines (Material AlertDialog 사용)
**New**: ~120 lines (Gabium Modal 패턴)
**Location**: `lib/features/tracking/presentation/widgets/consultation_recommendation_dialog.dart`

**Key Changes**:
1. AlertDialog → Custom Dialog with Gabium styling
2. Material 색상 → Design System 토큰
3. 타이포그래피 계층화
4. 경고 배너 → Alert Banner 패턴
5. 버튼 표준화 → GabiumButton

```dart
// Colors from Design System
const Color errorColor = Color(0xFFEF4444);      // Error
const Color errorBg = Color(0xFFFEF2F2);          // Error light bg
const Color errorBorder = Color(0xFFFECACA);      // Error border
const Color neutral800 = Color(0xFF1E293B);       // Neutral-800
const Color neutral600 = Color(0xFF475569);       // Neutral-600
const Color neutral50 = Color(0xFFF8FAFC);        // Neutral-50

// Structure:
// ├─ Dialog Background: errorBg
// ├─ Header
// │  ├─ Title: "전문가와 상담이 필요합니다" (2xl, Bold, Error)
// │  └─ Close Button
// ├─ Divider
// ├─ Content
// │  ├─ Label: "선택하신 증상:" (lg, Semibold)
// │  └─ SymptomList
// │     └─ SymptomItem (x7) with warning icon
// ├─ Alert Banner (Warning pattern)
// │  ├─ Background: errorBg
// │  ├─ Border: 1px solid errorBorder
// │  ├─ Icon: warning (Error color)
// │  └─ Text: 상담 권장 메시지
// └─ Footer
//    └─ GabiumButton (Primary, "확인")
```

**Implementation Highlights**:
- Modal 배경: Error-tinted (#FEF2F2)
- 제목: 24px Bold Error 색상
- 선택된 증상 목록: 아이콘 + 텍스트
- 경고 배너: Alert Banner 패턴 (4개 색상 옵션 중 Error)
- 확인 버튼: GabiumButton Primary

---

### 2.3 EmergencyCheckScreen (메인 화면)

**Current**: 182 lines
**New**: ~240 lines
**Location**: `lib/features/tracking/presentation/screens/emergency_check_screen.dart`

**Key Changes**:
1. Material 버튼 → GabiumButton (Primary, Secondary)
2. 헤더 컨테이너 → Card 패턴 + Warning accent
3. CheckboxListTile → EmergencyChecklistItem
4. SnackBar → GabiumToast
5. 색상 시스템 통일
6. 타이포그래피 표준화
7. 간격 시스템 정렬

**Color Scheme**:
```
배경: Neutral-50 (#F8FAFC)
헤더:
  - 배경: Neutral-100 (#F1F5F9)
  - 좌측 상단 accent: Error (#EF4444) 3px bar
제목: Neutral-800 (#1E293B), 24px, Bold
부제: Neutral-600 (#475569), 16px, Regular
```

**Structure**:
```dart
Scaffold(
  appBar: AppBar(
    title: '증상 체크', // xl, Semibold
    backgroundColor: Neutral-50,
    elevation: 0,
    foregroundColor: Neutral-800,
  ),
  body: SingleChildScrollView(
    child: Column(
      children: [
        // 1. Header Card with Warning Accent
        Container(
          padding: EdgeInsets.all(24), // lg
          color: Neutral-100,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Error, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('다음 증상 중 해당하는 것이 있나요?'),
              SizedBox(height: 8),
              Text('해당하는 증상을 선택해주세요.'),
            ],
          ),
        ),

        // 2. Symptom Checklist
        Padding(
          padding: EdgeInsets.all(24), // lg
          child: Column(
            children: List.generate(
              emergencySymptoms.length,
              (index) => EmergencyChecklistItem(
                symptom: emergencySymptoms[index],
                isChecked: selectedStates[index],
                onChanged: (value) {
                  setState(() => selectedStates[index] = value ?? false);
                },
              ),
            ),
          ),
        ),
      ],
    ),
  ),
  bottomNavigationBar: Container(
    padding: EdgeInsets.all(16), // md
    color: Neutral-50,
    child: Row(
      children: [
        // Secondary Button
        Expanded(
          child: GabiumButton(
            variant: ButtonVariant.secondary,
            size: ButtonSize.medium,
            onPressed: _handleNoSymptoms,
            label: '해당 없음',
          ),
        ),
        SizedBox(width: 12),
        // Primary Button
        Expanded(
          child: GabiumButton(
            variant: ButtonVariant.primary,
            size: ButtonSize.medium,
            onPressed: selectedStates.any((s) => s) ? _handleConfirm : null,
            label: '확인',
          ),
        ),
      ],
    ),
  ),
)
```

---

## 3. Design Tokens Applied

### Colors (7 tokens)
```
Primary: #4ADE80
Error: #EF4444
Neutral-50: #F8FAFC
Neutral-100: #F1F5F9
Neutral-600: #475569
Neutral-800: #1E293B
Neutral-400: #94A3B8
```

### Typography (3 scales)
```
2xl: 24px, 700 (Headers)
base: 16px, 400 (Body)
sm: 14px, 400 (Secondary)
xs: 12px, 400 (Captions)
```

### Spacing (3 tokens)
```
md: 16px
lg: 24px
sm: 8px (for small gaps)
```

---

## 4. Business Logic Preservation

### No Changes Required
- ✅ `_handleConfirm()` - 완전 보존
- ✅ `_saveEmergencyCheck()` - 완전 보존
- ✅ `_handleNoSymptoms()` - 완전 보존
- ✅ Data model (EmergencySymptomCheck) - 무영향
- ✅ Provider integration - 무영향
- ✅ Error handling - 강화 (GabiumToast로 개선)

### Enhancement Only
```dart
// Before: SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('증상이 기록되었습니다.')),
);

// After: GabiumToast
GabiumToast.show(
  context: context,
  variant: ToastVariant.success,
  message: '증상이 기록되었습니다.',
  duration: Duration(seconds: 2),
);
```

---

## 5. Implementation Checklist

### Phase 2C (Auto Implementation)
- [ ] 1. Create EmergencyChecklistItem component
- [ ] 2. Update ConsultationRecommendationDialog with Gabium styling
- [ ] 3. Update EmergencyCheckScreen with GabiumButton, GabiumToast
- [ ] 4. Apply Design System colors throughout
- [ ] 5. Standardize typography (2xl, base, sm)
- [ ] 6. Align spacing to 8px multiples
- [ ] 7. Update AppBar styling
- [ ] 8. Verify business logic preservation
- [ ] 9. Run flutter analyze (0 warnings target)
- [ ] 10. Test all states (unchecked, checked, symptoms selected)

### Phase 3 (Asset Organization)
- [ ] 1. Update Component Registry (EmergencyChecklistItem)
- [ ] 2. Move code examples to library docs
- [ ] 3. Update INDEX.md with Phase 3 completion
- [ ] 4. Create completion summary

---

## 6. Quality Metrics

### Code Quality
- Target: 0 warnings from flutter analyze
- Style: Consistent with existing Gabium patterns
- Reusability: EmergencyChecklistItem for similar features

### Accessibility
- Touch targets: 44x44px minimum (checkbox, buttons)
- Color contrast: WCAG AA (4.5:1 for text on background)
- Semantic structure: Clear hierarchy and labels

### Design Fidelity
- Design System tokens: 100% (7 colors, 3 typography, 3 spacing)
- Component patterns: Modal + Alert Banner + Button
- Visual hierarchy: Title → Subtitle → List → CTA

---

## 7. Risk Assessment

### Low Risk (Pure UI)
- No business logic changes
- No data model modifications
- No API/Provider changes
- No state management restructuring

### Compatibility
- ✅ Flutter 3.0+
- ✅ Material 3.0 compliant
- ✅ Safe for existing users (data preserved)

---

## Next Steps

**Phase 2C (Automated Implementation)**:
- Execute all changes per this specification
- Create/update all component files
- Verify Design System token compliance
- Generate Implementation Log with before/after comparisons

**Timeline**: ~60 minutes
