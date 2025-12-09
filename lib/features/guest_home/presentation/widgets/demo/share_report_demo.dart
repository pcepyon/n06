import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 의료진 공유하기 체험용 데모 위젯
///
/// Provider 의존성 없이 하드코딩된 더미 데이터로 동작하는 순수 UI 데모입니다.
/// ShareReportScreen의 핵심 UI를 재현하여 의료진 공유 기능을 체험할 수 있습니다.
class ShareReportDemo extends StatefulWidget {
  final VoidCallback? onComplete;

  const ShareReportDemo({super.key, this.onComplete});

  @override
  State<ShareReportDemo> createState() => _ShareReportDemoState();
}

class _ShareReportDemoState extends State<ShareReportDemo>
    with SingleTickerProviderStateMixin {
  int _selectedWeekOffset = 0;
  bool _copied = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleCopy() {
    HapticFeedback.mediumImpact();
    setState(() {
      _copied = true;
    });

    // 2초 후 복사 상태 리셋
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 선택
          _buildPeriodSelector(),
          const SizedBox(height: 16),

          // 리포트 카드
          _buildReportCard(),
          const SizedBox(height: 16),

          // 텍스트 리포트 미리보기
          _buildTextReportPreview(),
          const SizedBox(height: 24),

          // 하단 액션 버튼
          _buildActions(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodChip(0, '이번 주'),
        const SizedBox(width: 8),
        _buildPeriodChip(1, '지난주'),
      ],
    );
  }

  Widget _buildPeriodChip(int weekOffset, String label) {
    final isSelected = _selectedWeekOffset == weekOffset;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedWeekOffset = weekOffset;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.neutral100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.neutral700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주간 리포트',
                      style: AppTypography.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _selectedWeekOffset == 0
                          ? '12.2 - 12.8'
                          : '11.25 - 12.1',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 주요 지표
          _buildMetricRow(
            '체크인',
            _selectedWeekOffset == 0 ? '5/7일 (71%)' : '6/7일 (86%)',
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),

          _buildMetricRow(
            '체중 변화',
            _selectedWeekOffset == 0
                ? '78.5kg → 77.8kg (-0.7kg)'
                : '79.2kg → 78.5kg (-0.7kg)',
            Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 12),

          _buildMetricRow(
            '식욕 수준',
            '평균 2.3점 (안정적)',
            Icons.restaurant_outlined,
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // 증상 섹션
          Text(
            '주요 증상',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '• 메스꺼움: 2일 발생 (경미)',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• 변비: 1일 발생 (보통)',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // 컨디션 추이
          Text(
            '주간 컨디션',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayMood('월', '😊'),
              _buildDayMood('화', '😐'),
              _buildDayMood('수', '😊'),
              _buildDayMood('목', '😔'),
              _buildDayMood('금', '😊'),
              _buildDayMood('토', '--'),
              _buildDayMood('일', '😊'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.neutral500,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral800,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDayMood(String day, String mood) {
    return Column(
      children: [
        Text(
          mood,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTypography.caption.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextReportPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                size: 16,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: 8),
              Text(
                '텍스트 리포트 (복사용)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getTextReport(),
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getTextReport() {
    if (_selectedWeekOffset == 0) {
      return '''📊 주간 리포트 (12.2 - 12.8)

✅ 체크인: 5/7일 (71%)
⚖️ 체중: 78.5kg → 77.8kg (-0.7kg)
🍽️ 식욕: 평균 2.3점 (안정적)

📋 주요 증상
• 메스꺼움: 2일 (경미)
• 변비: 1일 (보통)

💬 특이사항
전반적으로 양호한 주였습니다.''';
    } else {
      return '''📊 주간 리포트 (11.25 - 12.1)

✅ 체크인: 6/7일 (86%)
⚖️ 체중: 79.2kg → 78.5kg (-0.7kg)
🍽️ 식욕: 평균 2.5점 (안정적)

📋 주요 증상
• 메스꺼움: 3일 (보통)
• 피로감: 2일 (경미)

💬 특이사항
용량 조절 후 적응 중입니다.''';
    }
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _handleCopy,
            icon: Icon(
              _copied ? Icons.check : Icons.copy,
              size: 20,
            ),
            label: Text(_copied ? '복사됨!' : '복사하기'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  _copied ? AppColors.success : AppColors.neutral700,
              side: BorderSide(
                color: _copied ? AppColors.success : AppColors.neutral300,
              ),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleCopy,
            icon: const Icon(Icons.share, size: 20),
            label: const Text('공유하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
