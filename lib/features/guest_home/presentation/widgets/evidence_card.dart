import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/guest_home/domain/entities/evidence_card_data.dart';

/// 과학적 근거 카드 위젯
/// P0 인터랙션: Number Counting Animation, Press State with Depth, Expandable Card
/// 탭 시 카드 자체가 확장되어 상세 정보 표시
class EvidenceCard extends StatefulWidget {
  final EvidenceCardData data;
  final bool isVisible;
  final ValueChanged<bool>? onExpandChanged;

  const EvidenceCard({
    super.key,
    required this.data,
    this.isVisible = false,
    this.onExpandChanged,
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
  bool _isExpanded = false;

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

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpandChanged?.call(_isExpanded);
    HapticFeedback.selectionClick();
  }

  double _parseMainStat() {
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

    if (stat.contains('.')) {
      return currentValue.toStringAsFixed(2);
    }
    return currentValue.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _toggleExpand();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isExpanded
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.12 : 0.08),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 8 : 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더 (아이콘 + 타이틀 + 확장 인디케이터)
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
                      // 확장 인디케이터
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isExpanded
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.neutral100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: _isExpanded
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 메인 통계 박스
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: _isExpanded ? 12 : 16,
                      horizontal: 12,
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
                                    fontSize: _isExpanded ? 32 : 36,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  widget.data.mainStatUnit,
                                  style: AppTypography.heading3.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data.subStat,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 한 줄 요약 (항상 표시)
                  Text(
                    widget.data.summary,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // 확장 시 상세 정보
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              // 상세 설명
                              Text(
                                widget.data.description,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // 출처 (탭하면 논문 링크로 이동)
                              GestureDetector(
                                onTap: () async {
                                  final url = widget.data.sourceUrl;
                                  if (url != null && url.isNotEmpty) {
                                    HapticFeedback.lightImpact();
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('📚',
                                          style: TextStyle(fontSize: 12)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${widget.data.source} · ${widget.data.sourceDetail}',
                                          style: AppTypography.caption.copyWith(
                                            color: widget.data.sourceUrl != null
                                                ? AppColors.primary
                                                : AppColors.textTertiary,
                                            decoration:
                                                widget.data.sourceUrl != null
                                                    ? TextDecoration.underline
                                                    : TextDecoration.none,
                                            decorationColor: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      if (widget.data.sourceUrl != null)
                                        Icon(
                                          Icons.open_in_new,
                                          size: 12,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  // 접혀있을 때 탭 힌트
                  if (!_isExpanded) ...[
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        '탭하여 자세히 보기',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
