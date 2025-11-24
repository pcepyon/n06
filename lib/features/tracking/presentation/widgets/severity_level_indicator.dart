import 'package:flutter/material.dart';

/// 심각도 레벨 표시 위젯
///
/// 슬라이더를 통해 증상의 심각도를 1-10점으로 선택할 수 있습니다.
/// 심각도에 따라 색상이 자동으로 변경됩니다:
/// - 1-6점: Info 색상 (파란색) - 경미한 증상
/// - 7-10점: Warning 색상 (주황색) - 중증 증상
///
/// Features:
/// - 경미/중증 라벨 표시
/// - 심각도별 색상 변경
/// - 현재 점수 표시
class SeverityLevelIndicator extends StatelessWidget {
  final int severity; // 1-10
  final ValueChanged<int> onChanged;

  const SeverityLevelIndicator({
    super.key,
    required this.severity,
    required this.onChanged,
  });

  Color get _sliderColor =>
      severity <= 6
          ? const Color(0xFF3B82F6) // Info (Blue)
          : const Color(0xFFF59E0B); // Warning (Amber)

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 레벨 라벨 (경미 / 중증)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0), // sm
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '경미',
                style: TextStyle(
                  fontSize: 14.0, // sm
                  fontWeight: FontWeight.w400, // Regular
                  color: const Color(0xFF334155), // Neutral-700
                ),
              ),
              Text(
                '중증',
                style: TextStyle(
                  fontSize: 14.0, // sm
                  fontWeight: FontWeight.w400, // Regular
                  color: const Color(0xFF334155), // Neutral-700
                ),
              ),
            ],
          ),
        ),

        // 슬라이더
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _sliderColor,
            inactiveTrackColor: const Color(0xFFE2E8F0), // Neutral-200
            thumbColor: _sliderColor,
            overlayColor: _sliderColor.withValues(alpha: 0.2),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
          ),
          child: Slider(
            value: severity.toDouble(),
            min: 1.0,
            max: 10.0,
            divisions: 9,
            label: '$severity점',
            onChanged: (value) => onChanged(value.toInt()),
          ),
        ),

        // 값 표시
        Padding(
          padding: const EdgeInsets.only(top: 8.0), // sm
          child: Text(
            '$severity점',
            style: const TextStyle(
              fontSize: 16.0, // base
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF1E293B), // Neutral-800
            ),
          ),
        ),
      ],
    );
  }
}
