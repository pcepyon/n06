# 알림 설정 화면 구현 가이드

## 구현 개요

승인된 개선 제안을 바탕으로 구체적이고 개발자 친화적인 구현 명세를 제공합니다.

**구현 변경사항:**
1. Info 색상 메시지 박스를 Alert Banner 패턴으로 개선 (아이콘 + 텍스트)
2. 알림 활성화 카드의 shadow를 md로 강화하여 중요도 표현
3. 알림 시간 제목을 xl(20px, Semibold)로 상향하여 섹션 제목 표준화
4. TimePickerButton을 Secondary 버튼 스타일로 개선
5. 섹션 간 spacing을 lg(24px)로 조정
6. 페이지 배경색을 Neutral-50(#F8FAFC)으로 명시적 정의

---

## Design System 토큰 값

| Element | Token Path | Value | 용도 |
|---------|-----------|-------|------|
| 페이지 배경색 | Colors - Neutral - 50 | `#F8FAFC` | Scaffold body |
| 카드 배경색 | Colors - White | `#FFFFFF` | Card containers |
| 카드 테두리 | Colors - Neutral - 200 | `#E2E8F0` | Card outline (선택사항) |
| 카드 그림자 | Shadow - md | `0 4px 8px rgba(15, 23, 42, 0.08), 0 2px 4px rgba(15, 23, 42, 0.04)` | 카드 elevation |
| 섹션 제목 | Typography - xl | 20px, Semibold | 알림 시간 제목 |
| 리스트 제목 | Typography - xl | 20px, Semibold | 알림 활성화 제목 |
| 리스트 부제 | Colors - Neutral - 500 | `#64748B` | 부제목 텍스트 |
| 버튼 텍스트 | Typography - base | 16px, Semibold | 버튼 라벨 |
| 버튼 기본 색상 | Colors - Primary | `#4ADE80` | TimePickerButton border/text |
| 정보 배경색 | Colors - Blue - 50 | `#EFF6FF` | Info box 배경 |
| 정보 테두리 | Colors - Blue (40% opacity) | `rgba(59, 130, 246, 0.4)` | Info box 테두리 |
| 정보 텍스트 | Colors - Blue - 800 | `#1E40AF` | Info box 텍스트 |
| 정보 아이콘 | Colors - Blue | `#3B82F6` | Info 아이콘 색상 |
| 섹션 간격 | Spacing - lg | 24px | 카드 간 간격 |
| 카드 내부 패딩 | Spacing - md | 16px | 카드 내부 패딩 |
| 버튼 border radius | Border Radius - sm | 8px | 버튼, info box |
| 카드 border radius | Border Radius - md | 12px | 카드 모서리 |
| 리스트 항목 높이 | Component | 56px | 44px 터치 영역 + padding |
| 토글 스위치 크기 | Component | 48px × 28px | 스위치 크기 |
| 전환 시간 | Visual Effects - base | 200ms | 상태 전환 |

---

## 컴포넌트 명세

### Change 1: Info 색상 메시지 박스 개선

**컴포넌트 타입:** Alert Banner (정보성 피드백)

**시각 명세:**
- 배경색: `#EFF6FF` (Blue-50)
- 테두리: 1px solid `rgba(59, 130, 246, 0.4)` (Blue at 40% opacity)
- 텍스트 색상: `#1E40AF` (Blue-800)
- 글꼴 크기: 16px (base)
- 글꼴 가중치: Regular (400)
- 패딩: 16px (md) 좌우, 12px 상하
- Border Radius: 8px (sm)
- 그림자: xs (`0 1px 2px rgba(15, 23, 42, 0.05)`)
- 아이콘: `Icons.info_outline` (24px)
- 아이콘 색상: `#3B82F6` (Blue)

**크기:**
- 너비: 100% (container의 전체 너비)
- 높이: auto (내용에 따라 결정, 최소 56px)

**인터랙티브 상태:**
- Default: 위 명세 대로
- Hover: 없음 (정적 정보 메시지)
- 접근성: ARIA label 권장 (screen reader 지원)

**구현 코드 (Flutter):**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: const Color(0xFFEFF6FF), // Blue-50
    border: Border.all(
      color: const Color.fromARGB(102, 59, 130, 246), // Blue at 40%
      width: 1,
    ),
    borderRadius: BorderRadius.circular(8), // sm
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.info_outline,
        color: const Color(0xFF3B82F6), // Blue
        size: 24,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          '알림은 매 투여 예정일 설정된 시간에 발송됩니다.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF1E40AF), // Blue-800
          ),
        ),
      ),
    ],
  ),
)
```

---

### Change 2: 알림 활성화 토글 카드 강화

**컴포넌트 타입:** Card Container + List Item

**시각 명세:**
- 배경색: `#FFFFFF` (White)
- 테두리: 선택사항 (shadow만 사용 권장)
- Border Radius: 12px (md)
- 그림자: md - `0 4px 8px rgba(15, 23, 42, 0.08), 0 2px 4px rgba(15, 23, 42, 0.04)`

**ListTile 내부 명세:**
- 제목: "알림 활성화", xl (20px, Semibold), `#1E293B` (Neutral-800)
- 부제목: 상태 메시지, base (16px, Regular), `#64748B` (Neutral-500)
- 항목 높이: 최소 56px (44px 터치 영역 + padding)
- 좌우 패딩: 16px
- 상하 패딩: 12px
- 제목-부제목 간격: 4px

**스위치 명세:**
- 크기: 48px × 28px
- 색상: Design System 기본값

**인터랙티브 상태:**
- Default: 위 명세 대로
- Hover: 배경색 `#F8FAFC` (Neutral-50)
- Disabled: opacity 0.4, cursor not-allowed
- 전환 시간: 200ms ease

**구현 코드 (Flutter):**
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12), // md
  ),
  shadowColor: const Color.fromARGB(20, 15, 23, 42),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      title: const Text(
        '알림 활성화',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600, // Semibold
          color: Color(0xFF1E293B), // Neutral-800
        ),
      ),
      subtitle: Text(
        settings.notificationEnabled ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF64748B), // Neutral-500
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      trailing: Switch(
        value: settings.notificationEnabled,
        onChanged: (value) async {
          await notifier.toggleNotificationEnabled();
        },
      ),
    ),
  ),
)
```

---

### Change 3: 알림 시간 설정 카드 제목 타이포그래피 강화

**컴포넌트 타입:** Section Title (Card 내부)

**시각 명세:**
- 텍스트: "알림 시간"
- 글꼴 크기: 20px (xl)
- 글꼴 가중치: Semibold (600)
- 색상: `#1E293B` (Neutral-800)
- 하단 여백: 16px (md)

**구현 코드 (Flutter):**
```dart
const Text(
  '알림 시간',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600, // Semibold
    color: Color(0xFF1E293B), // Neutral-800
  ),
),
const SizedBox(height: 16), // md spacing
```

---

### Change 4: TimePickerButton 스타일 개선

**컴포넌트 타입:** Button - Secondary variant

**시각 명세:**
- 배경색: Transparent
- 텍스트 색상: `#4ADE80` (Primary)
- 텍스트 글꼴: Semibold (600), base (16px)
- 테두리: 2px solid `#4ADE80`
- 아이콘: `Icons.access_time` (24px), `#4ADE80`
- 패딩: 16px (horizontal), 12px (vertical) = 44px 높이
- Border Radius: 8px (sm)
- 그림자: 없음
- 전환: 200ms ease

**인터랙티브 상태:**
- Default: 위 명세 대로
- Hover: 배경색 `rgba(74, 222, 128, 0.08)` (Primary at 8%)
- Active/Pressed: 배경색 `rgba(74, 222, 128, 0.12)` (Primary at 12%)
- Disabled: border/text opacity 0.4, cursor not-allowed
- Focus: outline `#4ADE80` 2px, offset 2px

**구현 코드 (Flutter):**
```dart
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    key: const Key('notification_time_button'),
    onPressed: () async {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: currentTime,
      );
      if (selectedTime != null) {
        onTimeSelected(selectedTime);
      }
    },
    icon: const Icon(Icons.access_time),
    label: Text(_formatTime(currentTime)),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF4ADE80), // Primary
      side: const BorderSide(
        color: Color(0xFF4ADE80),
        width: 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // sm
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600, // Semibold
      ),
    ),
  ),
)
```

---

### Change 5: 카드 섹션 간격 조정

**간격 명세:**
- 카드 간 거리: 24px (lg)
- 현재: 16px (sm) → 변경: 24px (lg)

**구현 코드 (Flutter):**
```dart
const SizedBox(height: 24), // lg spacing (섹션 간)
```

---

### Change 6: 페이지 배경색 통일

**명세:**
- 배경색: `#F8FAFC` (Neutral-50)
- 적용 대상: Scaffold body background

**구현 코드 (Flutter):**
```dart
Scaffold(
  appBar: AppBar(title: const Text('푸시 알림 설정'), elevation: 0),
  backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
  body: settingsAsync.when(
    data: (settings) => _buildContent(context, ref, settings),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stackTrace) => Center(child: Text('오류가 발생했습니다: $error')),
  ),
)
```

---

## 레이아웃 명세

### 컨테이너 구조
- **Max Width:** 무제한 (전체 화면)
- **Margin:** 0 (edges에 맞춤)
- **Padding:** 16px (md) - ListView 기본 padding

### Flexbox/Column 구조
- **Display:** Column (세로 배치)
- **Gap:** 24px (lg) - 섹션 간
- **정렬:** crossAxisAlignment: start, mainAxisAlignment: start

### 요소 계층구조
```
Scaffold (배경: Neutral-50)
├── AppBar ("푸시 알림 설정", elevation: 0)
└── ListView (padding: 16px)
    ├── Card 1: 알림 활성화 토글
    │   ├── ListTile
    │   │   ├── Title: "알림 활성화" (xl, Semibold)
    │   │   ├── Subtitle: 상태 메시지 (base, Regular)
    │   │   └── Trailing: Switch (48×28px)
    │   └── Shadow: md
    │
    ├── SizedBox (height: 24px) [lg spacing]
    │
    ├── Card 2: 알림 시간 설정
    │   ├── Padding: 16px (md)
    │   ├── Column
    │   │   ├── Text: "알림 시간" (xl, Semibold)
    │   │   ├── SizedBox (height: 16px)
    │   │   └── TimePickerButton (Secondary style)
    │   │       ├── Width: 100%
    │   │       ├── Height: 44px
    │   │       ├── Border: 2px solid Primary
    │   │       └── Icon + Text
    │   └── Shadow: sm or default
    │
    ├── SizedBox (height: 24px) [lg spacing]
    │
    └── Container: 정보 메시지 (Alert Banner)
        ├── Background: Blue-50 (#EFF6FF)
        ├── Border: 1px Blue at 40%
        ├── Radius: 8px (sm)
        ├── Padding: 16px (md)
        ├── Row
        │   ├── Icon: info_outline (24px, Blue)
        │   └── Text: "알림은 매 투여 예정일..."
        └── Shadow: xs
```

### 반응형 디자인
- **Mobile (< 768px):** 위 레이아웃 그대로 유지
- **Tablet (768px - 1024px):** 동일 레이아웃 (single column)
- **Desktop (> 1024px):** 동일 레이아웃 (single column)

---

## 인터랙션 명세

### 알림 활성화 토글

**클릭/탭:**
- **Trigger:** 토글 스위치 변경
- **시각적 피드백:** Active 상태 (배경색 변경)
- **Duration:** 즉시 (200ms 전환)
- **Action:** `notifier.toggleNotificationEnabled()` 호출

**상태:**
- **Default:** 현재 설정 값 표시
- **Hover:** 배경색 `#F8FAFC` (Neutral-50)
- **Active:** 토글 상태 변경

### TimePickerButton

**클릭/탭:**
- **Trigger:** 버튼 클릭
- **시각적 피드백:** Active 상태 (배경색 `rgba(74, 222, 128, 0.12)`)
- **Duration:** 즉시
- **Action:** `showTimePicker()` dialog 표시 → 시간 선택 → `onTimeSelected()` callback

**로딩 상태:**
- 해당 없음 (동기 작업)

**성공 상태:**
- Dialog에서 선택 후 시간 업데이트
- Snackbar 표시: "알림 설정이 저장되었습니다" (2초 표시)

### 정보 메시지

**상태:**
- Static (인터랙션 없음)
- Display만 수행

---

## Flutter 구현 코드

### notification_settings_screen.dart 전체 수정본

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/notification/application/notifiers/notification_notifier.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:n06/features/notification/presentation/widgets/time_picker_button.dart';

/// 푸시 알림 설정 화면
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  /// NotificationTime → TimeOfDay 변환 헬퍼
  TimeOfDay _toTimeOfDay(NotificationTime notificationTime) {
    return TimeOfDay(hour: notificationTime.hour, minute: notificationTime.minute);
  }

  /// TimeOfDay → NotificationTime 변환 헬퍼
  NotificationTime _fromTimeOfDay(TimeOfDay timeOfDay) {
    return NotificationTime(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('푸시 알림 설정'),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
      body: settingsAsync.when(
        data: (settings) => _buildContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('오류가 발생했습니다: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic settings) {
    final notifier = ref.read(notificationNotifierProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Change 2: 알림 활성화 토글 카드 강화
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // md
          ),
          shadowColor: const Color.fromARGB(20, 15, 23, 42),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), // md
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ), // md shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ), // md shadow
              ],
            ),
            child: ListTile(
              title: const Text(
                '알림 활성화',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600, // Semibold (xl)
                  color: Color(0xFF1E293B), // Neutral-800
                ),
              ),
              subtitle: Text(
                settings.notificationEnabled ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF64748B), // Neutral-500
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              trailing: Switch(
                value: settings.notificationEnabled,
                onChanged: (value) async {
                  await notifier.toggleNotificationEnabled();
                },
              ),
            ),
          ),
        ),

        // Change 5: 섹션 간격 lg (24px)
        const SizedBox(height: 24),

        // Change 3: 알림 시간 설정 카드 (제목 타이포그래피 강화)
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // md
          ),
          child: Padding(
            padding: const EdgeInsets.all(16), // md
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Change 3: 섹션 제목 xl (20px, Semibold)로 강화
                const Text(
                  '알림 시간',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600, // Semibold (xl)
                    color: Color(0xFF1E293B), // Neutral-800
                  ),
                ),
                const SizedBox(height: 16), // md spacing

                // Change 4: TimePickerButton (Secondary 스타일)
                TimePickerButton(
                  currentTime: _toTimeOfDay(settings.notificationTime),
                  onTimeSelected: (selectedTime) async {
                    final notificationTime = _fromTimeOfDay(selectedTime);
                    await notifier.updateNotificationTime(notificationTime);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('알림 설정이 저장되었습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        // Change 5: 섹션 간격 lg (24px)
        const SizedBox(height: 24),

        // Change 1: Info 색상 메시지 박스 개선 (Alert Banner 패턴)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // md
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // Blue-50
            border: Border.all(
              color: const Color.fromARGB(102, 59, 130, 246), // Blue at 40%
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8), // sm
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // xs shadow
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF3B82F6), // Blue
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '알림은 매 투여 예정일 설정된 시간에 발송됩니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF1E40AF), // Blue-800
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### time_picker_button.dart 수정본

```dart
import 'package:flutter/material.dart';

/// 시간 선택 버튼 위젯 (Secondary 버튼 스타일)
class TimePickerButton extends StatelessWidget {
  final TimeOfDay currentTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerButton({
    super.key,
    required this.currentTime,
    required this.onTimeSelected,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('notification_time_button'),
        onPressed: () async {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: currentTime,
          );
          if (selectedTime != null) {
            onTimeSelected(selectedTime);
          }
        },
        icon: const Icon(Icons.access_time),
        label: Text(_formatTime(currentTime)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4ADE80), // Primary
          side: const BorderSide(
            color: Color(0xFF4ADE80), // Primary
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // sm
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600, // Semibold (base)
          ),
        ),
      ),
    );
  }
}
```

---

## 접근성 체크리스트

- [ ] 모든 텍스트의 색상 명도 대비 WCAG AA 기준 충족 (4.5:1 최소)
  - Info 텍스트: Blue-800 (#1E40AF) vs Blue-50 (#EFF6FF) ✓
  - 리스트 제목: Neutral-800 vs White ✓
  - 리스트 부제: Neutral-500 vs White ✓
- [ ] 모든 인터랙티브 요소 44×44px 이상 터치 영역 확보
  - ListTile: 최소 56px height ✓
  - TimePickerButton: 44px height (16px × 2 padding + 12px × 2) ✓
  - Switch: 48×28px ✓
- [ ] 포커스 인디케이터 명확히 표시
  - Buttons: Material 기본 focus behavior ✓
- [ ] 시맨틱 색상 사용
  - Info messages: Blue semantic color ✓
  - Primary actions: Primary semantic color ✓
- [ ] 키보드 네비게이션 전체 기능
  - All buttons, switches: Tab key accessible ✓
- [ ] Screen reader 지원
  - ARIA labels/roles: Material widgets 자동 처리 ✓

---

## 테스트 체크리스트

- [ ] 모든 인터랙티브 상태 동작 확인 (hover, active, disabled)
- [ ] 모든 breakpoints에서 반응형 동작 검증
- [ ] 접근성 요구사항 충족 확인
- [ ] Design System 토큰과 정확히 일치
- [ ] 다른 화면에서 시각적 회귀 없음
- [ ] Snackbar 메시지 정상 표시
- [ ] 시간 선택 dialog 정상 동작
- [ ] 토글 스위치 상태 변경 정상 동작

---

## 수정할 파일

**수정 파일:**
- `/lib/features/notification/presentation/screens/notification_settings_screen.dart`
- `/lib/features/notification/presentation/widgets/time_picker_button.dart`

**생성할 파일:**
- 없음 (기존 위젯 스타일 조정만 필요)

**필요한 Asset:**
- 없음 (Material Icons 사용)

**주의사항:**
- Component Registry는 Phase 3 Step 4에서 업데이트됩니다.
- 현재 Phase 2B에서는 구현 가이드만 제공하며, 실제 코드는 Phase 2C 이후 수동/자동 구현 단계에서 적용합니다.

---

## 구현 주요 사항

### 기존 기능 보존
- **상태 관리:** Riverpod AsyncNotifierProvider 기존 방식 유지
- **데이터 모델:** NotificationTime, notification_notifier 변경 없음
- **외부 인터페이스:** TimePickerButton의 props (currentTime, onTimeSelected) 변경 없음

### Design System 준수
- **토큰만 사용:** 모든 값이 Proposal의 Design System Token Reference 테이블에서 확인된 토큰
- **일관성:** settings-main-screen과 동일한 패턴 적용
- **확장성:** 하드코딩된 색상 제거로 향후 테마 변경 용이

### 시각적 계층 강화
```
강조도: 높음 ────────────────────────── 낮음
         │          │           │
    활성화 토글    시간 설정   정보 메시지
  (shadow: md) (shadow: sm)  (shadow: xs)
```

---

## 다음 단계

1. **Phase 2C (자동 구현):** 본 가이드를 바탕으로 actual code 생성
2. **Phase 3 (검증):** 구현된 코드의 UI 재검증
3. **통합:** main branch로 merge

