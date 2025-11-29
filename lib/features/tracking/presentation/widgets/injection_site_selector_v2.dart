import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

class InjectionSiteSelectorV2 extends ConsumerStatefulWidget {
  final String? initialSite;
  final List<DoseRecord> recentRecords;
  final Function(String) onSiteSelected;

  const InjectionSiteSelectorV2({
    required this.onSiteSelected,
    required this.recentRecords,
    this.initialSite,
    super.key,
  });

  @override
  ConsumerState<InjectionSiteSelectorV2> createState() => _InjectionSiteSelectorV2State();
}

class _InjectionSiteSelectorV2State extends ConsumerState<InjectionSiteSelectorV2> {
  String? selectedSite;

  @override
  void initState() {
    super.initState();
    selectedSite = widget.initialSite;
  }

  DateTime? _getLastUsedDate(String siteCode) {
    for (final record in widget.recentRecords) {
      if (record.injectionSite == siteCode) {
        return record.administeredAt;
      }
    }
    return null;
  }

  int _getDaysAgo(String siteCode) {
    final lastUsed = _getLastUsedDate(siteCode);
    if (lastUsed == null) return 999;
    return DateTime.now().difference(lastUsed).inDays;
  }

  bool _showRotationWarning() {
    if (selectedSite == null) return false;
    return _getDaysAgo(selectedSite!) < 7;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주사 부위 선택',
          style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        // 복부 4분할
        _buildSiteGroup(
          '복부 (4개 부위)',
          [
            ('abdomen_upper_left', '좌측 상단'),
            ('abdomen_upper_right', '우측 상단'),
            ('abdomen_lower_left', '좌측 하단'),
            ('abdomen_lower_right', '우측 하단'),
          ],
        ),

        const SizedBox(height: 12),

        // 허벅지
        _buildSiteGroup(
          '허벅지 (좌/우)',
          [
            ('thigh_left', '좌측'),
            ('thigh_right', '우측'),
          ],
        ),

        const SizedBox(height: 12),

        // 상완
        _buildSiteGroup(
          '상완 (좌/우)',
          [
            ('arm_left', '좌측'),
            ('arm_right', '우측'),
          ],
        ),

        const SizedBox(height: 16),

        // 경고 메시지
        if (_showRotationWarning())
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '이 부위는 ${_getDaysAgo(selectedSite!)}일 전에 사용했습니다. '
                    '1주 이상 간격을 권장합니다.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSiteGroup(String title, List<(String, String)> sites) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: sites.any((s) => s.$1 == selectedSite),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sites.map((site) {
              return SizedBox(
                width: 140,
                height: 56,
                child: _buildSiteButton(site.$1, site.$2),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteButton(String siteCode, String label) {
    final daysAgo = _getDaysAgo(siteCode);
    final isRecentlyUsed = daysAgo < 7;
    final isSelected = selectedSite == siteCode;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedSite = siteCode;
        });
        widget.onSiteSelected(siteCode);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : isRecentlyUsed
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.surface,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : isRecentlyUsed
                  ? AppColors.warning
                  : AppColors.borderDark,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          if (daysAgo < 999)
            Text(
              '$daysAgo일 전',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
