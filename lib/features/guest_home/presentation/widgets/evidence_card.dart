import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/domain/entities/evidence_card_data.dart';

/// 과학적 근거 카드 위젯
/// P0 인터랙션: Number Counting Animation, Press State with Depth
class EvidenceCard extends StatefulWidget {
  final EvidenceCardData data;
  final bool isVisible;

  const EvidenceCard({
    super.key,
    required this.data,
    this.isVisible = false,
  });

  @override
  State<EvidenceCard> createState() => _EvidenceCardState();
}

class _EvidenceCardState extends State<EvidenceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countController;
  late final Animation<double> _countAnimation;
  bool _hasAnimated = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );

    _countController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void didUpdateWidget(EvidenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_hasAnimated) {
      _hasAnimated = true;
      _countController.forward();
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  double _parseMainStat() {
    // Handle range values like "15~17" or "40~70"
    final stat = widget.data.mainStat;
    if (stat.contains('~')) {
      final parts = stat.split('~');
      return double.tryParse(parts.last) ?? 0;
    }
    return double.tryParse(stat) ?? 0;
  }

  String _formatAnimatedValue(double progress) {
    final stat = widget.data.mainStat;
    final targetValue = _parseMainStat();
    final currentValue = targetValue * progress;

    if (stat.contains('~')) {
      final parts = stat.split('~');
      final startValue = double.tryParse(parts.first) ?? 0;
      final animatedStart = (startValue * progress).toInt();
      final animatedEnd = currentValue.toInt();
      return '$animatedStart~$animatedEnd';
    }

    // Handle decimal values like "2.58"
    if (stat.contains('.')) {
      return currentValue.toStringAsFixed(2);
    }
    return currentValue.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.12 : 0.08),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 8 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 헤더 (아이콘 + 타이틀)
                Row(
                  children: [
                    Text(
                      widget.data.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.data.title,
                        style: AppTypography.heading3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 메인 통계 박스
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // 숫자 카운팅 애니메이션
                      AnimatedBuilder(
                        animation: _countAnimation,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _formatAnimatedValue(_countAnimation.value),
                                style: AppTypography.numericLarge.copyWith(
                                  fontSize: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                widget.data.mainStatUnit,
                                style: AppTypography.heading2.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.data.subStat,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 설명
                Text(
                  widget.data.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                // 출처
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📚', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.data.source,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          widget.data.sourceDetail,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
