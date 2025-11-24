# EditDosagePlanScreen 구현 가이드

## 개요
이 문서는 EditDosagePlanScreen을 Gabium Design System에 맞춰 구현하는 상세한 가이드입니다. 모든 변경사항은 Presentation Layer에만 적용되며, 비즈니스 로직은 완전히 보존됩니다.

**구현 대상**: `/Users/pro16/Desktop/project/n06/lib/features/tracking/presentation/screens/edit_dosage_plan_screen.dart`

**구현 범위**: 1개 파일 수정 + 2개 신규 컴포넌트 생성

---

## 섹션 1: 파일 수정 작업

### 1.1 EditDosagePlanScreen 메인 파일 수정

**파일**: `edit_dosage_plan_screen.dart`

#### 변경 1.1.1: Imports 추가
```dart
// 추가할 import
import 'package:n06/core/presentation/widgets/gabium_app_bar.dart';
import 'package:n06/core/presentation/widgets/impact_analysis_dialog.dart';
import 'package:n06/features/tracking/presentation/widgets/date_picker_field.dart';
```

#### 변경 1.1.2: EditDosagePlanScreen의 build() 메서드 개선
**현재 코드**:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final medicationState = ref.watch(medicationNotifierProvider);

  return Scaffold(
    appBar: AppBar(
      title: const Text('투여 계획 수정'),
    ),
    body: SafeArea(
      // ...
    ),
  );
}
```

**수정 후 코드**:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final medicationState = ref.watch(medicationNotifierProvider);

  return Scaffold(
    appBar: GabiumAppBar(
      title: '투여 계획 수정',
      leading: true,
    ),
    backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
    body: SafeArea(
      child: medicationState.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF4ADE80), // Primary
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: const Color(0xFFEF4444), // Error
              ),
              const SizedBox(height: 16),
              Text(
                '오류가 발생했습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B), // Neutral-500
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GabiumButton(
                variant: 'primary',
                size: 'medium',
                onPressed: () {
                  ref.invalidate(medicationNotifierProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (state) {
          final plan = state.activePlan;
          if (plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: const Color(0xFF3B82F6), // Info
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '활성 투여 계획이 없습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _EditDosagePlanForm(initialPlan: plan),
          );
        },
      ),
    ),
  );
}
```

**근거**:
- GabiumAppBar로 통일된 헤더 제공
- CircularProgressIndicator에 Primary 색상 적용
- 에러/빈 상태에 아이콘 + 타이틀 + 설명 + 버튼 추가
- 배경색 Neutral-50으로 명시화

---

### 1.2 _EditDosagePlanForm 상태 관리 개선

#### 변경 1.2.1: 로딩 상태 추가
```dart
class _EditDosagePlanFormState extends ConsumerState<_EditDosagePlanForm> {
  MedicationTemplate? _selectedTemplate;
  double? _selectedDose;
  late DateTime _selectedStartDate;
  bool _isSaving = false; // 추가

  // ... initState ...

  Future<void> _handleSave() async {
    setState(() => _isSaving = true); // 시작
    try {
      // ... 기존 로직 ...
    } catch (e) {
      _showErrorSnackBar('오류 발생: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false); // 종료
      }
    }
  }
```

#### 변경 1.2.2: SnackBar → GabiumToast 변경
```dart
// 기존
void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

void _showSuccessSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}

// 변경 후 - GabiumToast 사용
void _showErrorSnackBar(String message) {
  GabiumToast.show(
    context,
    message: message,
    variant: 'error',
    duration: const Duration(seconds: 5),
  );
}

void _showSuccessSnackBar(String message) {
  GabiumToast.show(
    context,
    message: message,
    variant: 'success',
    duration: const Duration(seconds: 3),
  );
}
```

#### 변경 1.2.3: 영향 분석 다이얼로그 개선
```dart
Future<bool> _showImpactConfirmationDialog(
  BuildContext context,
  PlanChangeImpact impact,
) async {
  return await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x800F172A), // Neutral-900 at 50%
    builder: (context) => ImpactAnalysisDialog(
      impact: impact,
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    ),
  ) ?? false;
}
```

---

### 1.3 _EditDosagePlanForm의 build() 메서드 전체 재작성

**현재 코드 분석**:
- DropdownButtonFormField × 2 (약물명, 초기 용량)
- InputDecorator (투여 주기)
- ListTile (시작일)
- ElevatedButton (저장)

**수정 후 코드**:
```dart
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // ============== 섹션 제목 ==============
      Text(
        '투여 계획 수정',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: const Color(0xFF1E293B), // Neutral-800
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 24), // lg spacing

      // ============== 약물명 드롭다운 ==============
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '약물명',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF334155), // Neutral-700
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedTemplate == null
                  ? const Color(0xFFCBD5E1) // Neutral-300
                  : const Color(0xFF4ADE80), // Primary (focus state)
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8), // sm
              color: Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
              ),
              child: DropdownButton<MedicationTemplate>(
                isExpanded: true,
                underline: const SizedBox.shrink(),
                value: _selectedTemplate,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '약물을 선택하세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8), // Neutral-400
                    ),
                  ),
                ),
                items: MedicationTemplate.all.map((template) {
                  return DropdownMenuItem<MedicationTemplate>(
                    value: template,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        template.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF334155), // Neutral-700
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newTemplate) {
                  setState(() {
                    _selectedTemplate = newTemplate;
                    _selectedDose = null;
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          if (_selectedTemplate == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '약물을 선택하면 용량을 선택할 수 있습니다',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF94A3B8), // Neutral-400
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16), // md spacing

      // ============== 초기 용량 드롭다운 ==============
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '초기 용량 (mg)',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF334155), // Neutral-700
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedDose == null
                  ? const Color(0xFFCBD5E1) // Neutral-300
                  : const Color(0xFF4ADE80), // Primary
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8), // sm
              color: _selectedTemplate == null
                ? const Color(0xFFF8FAFC) // Neutral-50 (disabled)
                : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
              ),
              child: DropdownButton<double>(
                isExpanded: true,
                underline: const SizedBox.shrink(),
                value: _selectedDose,
                disabledHint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _selectedTemplate == null
                      ? '먼저 약물을 선택하세요'
                      : '용량을 선택하세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8), // Neutral-400
                    ),
                  ),
                ),
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '용량을 선택하세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8), // Neutral-400
                    ),
                  ),
                ),
                items: _selectedTemplate?.availableDoses.map((dose) {
                  return DropdownMenuItem<double>(
                    value: dose,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$dose mg',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF334155), // Neutral-700
                        ),
                      ),
                    ),
                  );
                }).toList() ?? [],
                onChanged: _selectedTemplate == null
                  ? null
                  : (newDose) {
                    setState(() => _selectedDose = newDose);
                  },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16), // md spacing

      // ============== 투여 주기 (읽기 전용) ==============
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '투여 주기',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF334155), // Neutral-700
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE2E8F0), // Neutral-200
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8), // sm
              color: const Color(0xFFF8FAFC), // Neutral-50 (read-only)
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedTemplate != null
                  ? '${_selectedTemplate!.standardCycleDays}일 (매주)'
                  : '-',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569), // Neutral-600
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '약물에 따라 자동으로 설정됩니다',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF94A3B8), // Neutral-400
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16), // md spacing

      // ============== 시작일 선택 ==============
      DatePickerField(
        label: '시작일',
        value: _selectedStartDate,
        onChanged: (newDate) {
          setState(() => _selectedStartDate = newDate);
        },
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ),
      const SizedBox(height: 32), // xl spacing

      // ============== 버튼 그룹 ==============
      Row(
        children: [
          // 취소 버튼
          Expanded(
            child: GabiumButton(
              variant: 'secondary',
              size: 'medium',
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ),
          const SizedBox(width: 12), // md spacing
          // 저장 버튼
          Expanded(
            child: GabiumButton(
              variant: 'primary',
              size: 'medium',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _handleSave,
              child: const Text('저장'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );
}
```

---

## 섹션 2: 신규 컴포넌트 생성

### 2.1 DatePickerField 컴포넌트

**파일 생성**: `/Users/pro16/Desktop/project/n06/lib/features/tracking/presentation/widgets/date_picker_field.dart`

**목적**: GabiumTextField 스타일을 따르는 날짜 선택 필드

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final Function(DateTime) onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool enabled;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.enabled = true,
  });

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ADE80), // Primary
              surface: Colors.white,
              onSurface: Color(0xFF1E293B), // Neutral-800
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != value) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF334155), // Neutral-700
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? () => _selectDate(context) : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: enabled
                  ? const Color(0xFFCBD5E1) // Neutral-300
                  : const Color(0xFFE2E8F0), // Neutral-200
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8), // sm
              color: enabled ? Colors.white : const Color(0xFFF8FAFC), // Neutral-50
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF334155), // Neutral-700
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 24,
                  color: enabled
                    ? const Color(0xFF475569) // Neutral-600
                    : const Color(0xFFCBD5E1), // Neutral-300
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

### 2.2 ImpactAnalysisDialog 컴포넌트

**파일 생성**: `/Users/pro16/Desktop/project/n06/lib/core/presentation/widgets/impact_analysis_dialog.dart`

**목적**: 투여 계획 변경 영향 분석 다이얼로그

```dart
import 'package:flutter/material.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';

class ImpactAnalysisDialog extends StatelessWidget {
  final PlanChangeImpact impact;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ImpactAnalysisDialog({
    super.key,
    required this.impact,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // lg
      ),
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.12), // xl shadow
              blurRadius: 32,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====== 헤더 ======
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE2E8F0), // Neutral-200
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '투여 계획 변경',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1E293B), // Neutral-800
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancel,
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: const Color(0xFF64748B), // Neutral-500
                    ),
                  ),
                ],
              ),
            ),

            // ====== 바디 ======
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 설명 텍스트
                  Text(
                    '투여 계획 변경 시 이후 스케줄이 재계산됩니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475569), // Neutral-600
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 영향받는 스케줄 수
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4), // Success light
                      border: Border.all(
                        color: const Color(0xFFD1FAE5), // Success lighter
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 20,
                          color: const Color(0xFF10B981), // Success
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '영향받는 스케줄: ${impact.affectedScheduleCount}개',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF065F46), // Success dark
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 변경되는 항목 (칩 형식)
                  if (impact.changedFields.isNotEmpty) ...[
                    Text(
                      '변경되는 항목:',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF334155), // Neutral-700
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: impact.changedFields.map((field) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), // Info light
                            border: Border.all(
                              color: const Color(0xFFBFDBFE), // Info lighter
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20), // full
                          ),
                          child: Text(
                            field,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF1E40AF), // Info dark
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 경고 메시지
                  if (impact.warningMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7), // Warning light
                        border: Border.all(
                          color: const Color(0xFFFDE68A), // Warning lighter
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            size: 20,
                            color: const Color(0xFFB45309), // Warning dark
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              impact.warningMessage!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFB45309), // Warning dark
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ====== 푸터 (버튼) ======
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE2E8F0), // Neutral-200
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 취소 버튼
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF4ADE80), // Primary
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF4ADE80), // Primary
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 확인 버튼
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ADE80), // Primary
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '확인',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 섹션 3: 디자인 시스템 토큰 매핑

### 색상 토큰
```
Primary:           #4ADE80 (Primary green)
Neutral-50:        #F8FAFC (Light background)
Neutral-200:       #E2E8F0 (Border)
Neutral-300:       #CBD5E1 (Neutral border)
Neutral-400:       #94A3B8 (Placeholder)
Neutral-500:       #64748B (Secondary text)
Neutral-600:       #475569 (Body text)
Neutral-700:       #334155 (Label text)
Neutral-800:       #1E293B (Headings)
Error:             #EF4444 (Error red)
Warning:           #F59E0B (Amber)
Info:              #3B82F6 (Blue)
Success:           #10B981 (Emerald)
```

### 타이포그래피 스케일
```
Headings (2xl):    24px, Bold (700)
Titles (xl):       20px, Semibold (600)
Labels (sm):       14px, Semibold (600)
Body (base):       16px, Regular (400)
Hints (xs):        12px, Regular (400)
```

### 간격 시스템
```
xs:  4px
sm:  8px
md:  16px
lg:  24px
xl:  32px
```

### 컴포넌트 크기
```
AppBar height:     56px
Input field:       48px
Button:            44px (medium)
Border radius:     8px (sm)
```

---

## 섹션 4: 재사용 컴포넌트

### 4.1 GabiumButton
**출처**: `lib/features/authentication/presentation/widgets/gabium_button.dart`

**사용 예**:
```dart
GabiumButton(
  variant: 'primary',      // 'primary', 'secondary', 'tertiary', 'ghost', 'danger'
  size: 'medium',          // 'small', 'medium', 'large'
  isLoading: false,
  onPressed: () {},
  child: const Text('저장'),
)
```

### 4.2 GabiumTextField
**출처**: `lib/features/authentication/presentation/widgets/gabium_text_field.dart`

**사용 예**:
```dart
GabiumTextField(
  label: '라벨',
  hintText: '힌트 텍스트',
  onChanged: (value) {},
  errorText: null,
)
```

### 4.3 GabiumToast
**출처**: `lib/core/presentation/widgets/gabium_toast.dart`

**사용 예**:
```dart
GabiumToast.show(
  context,
  message: '저장되었습니다',
  variant: 'success',  // 'success', 'error', 'warning', 'info'
  duration: const Duration(seconds: 3),
)
```

### 4.4 GabiumAppBar (또는 AppBar with Design System styling)
**출처**: `lib/core/presentation/widgets/gabium_app_bar.dart`

---

## 섹션 5: 검증 체크리스트

### 색상
- [ ] Primary: #4ADE80 사용
- [ ] Neutral 팔레트 (50, 200, 300, 400, 500, 600, 700, 800) 사용
- [ ] Error, Warning, Info, Success 시맨틱 색상 정확

### 타이포그래피
- [ ] 제목: xl/2xl, Bold/Semibold
- [ ] 라벨: sm, Semibold
- [ ] 본문: base, Regular
- [ ] 힌트: xs, Regular

### 간격
- [ ] 필드 간격: md (16px)
- [ ] 섹션 간격: lg (24px)
- [ ] 하단 여백: xl (32px)

### 컴포넌트
- [ ] 모든 버튼이 GabiumButton
- [ ] 모든 입력 필드가 GabiumTextField 스타일
- [ ] AppBar가 GabiumAppBar
- [ ] 토스트가 GabiumToast
- [ ] 다이얼로그가 ImpactAnalysisDialog

### 상태
- [ ] 로딩 상태: CircularProgressIndicator + Primary 색상
- [ ] 에러 상태: 아이콘 + 제목 + 메시지 + 버튼
- [ ] 비활성 상태: opacity 또는 회색 처리
- [ ] 포커스 상태: Primary 테두리

### 접근성
- [ ] 터치 영역: 44x44px 이상
- [ ] 색상 대비: WCAG AA 이상
- [ ] 라벨: 모든 입력 필드에 명확한 라벨

---

## 섹션 6: 파일 목록

### 수정 파일 (1개)
1. `lib/features/tracking/presentation/screens/edit_dosage_plan_screen.dart`

### 신규 파일 (2개)
1. `lib/features/tracking/presentation/widgets/date_picker_field.dart`
2. `lib/core/presentation/widgets/impact_analysis_dialog.dart`

### 참고 파일 (재사용 컴포넌트)
- `lib/features/authentication/presentation/widgets/gabium_button.dart`
- `lib/features/authentication/presentation/widgets/gabium_text_field.dart`
- `lib/core/presentation/widgets/gabium_toast.dart`
- `lib/core/presentation/widgets/gabium_app_bar.dart` (또는 AppBar styling)

---

**문서 버전**: v1
**작성 날짜**: 2025-11-24
**상태**: Implementation Phase 2B 준비 완료, Phase 2C 실행 대기
