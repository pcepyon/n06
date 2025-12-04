import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

class InjectionSiteSelectorV2 extends ConsumerStatefulWidget {
  final String? initialSite;
  final List<DoseRecord> recentRecords;
  final Function(String) onSiteSelected;
  final DateTime? referenceDate; // 기준 날짜 (null이면 오늘)

  const InjectionSiteSelectorV2({
    required this.onSiteSelected,
    required this.recentRecords,
    this.initialSite,
    this.referenceDate,
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
    final refDate = widget.referenceDate ?? DateTime.now();
    final diff = refDate.difference(lastUsed).inDays;
    return diff < 0 ? 999 : diff; // 미래 기록은 무시
  }

  bool _showRotationWarning() {
    if (selectedSite == null) return false;
    return _getDaysAgo(selectedSite!) < 7;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tracking_siteSelector_title,
          style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        // 복부 4분할
        _buildSiteGroup(
          l10n.tracking_siteSelector_abdomen,
          [
            ('abdomen_upper_left', l10n.tracking_siteSelector_abdomenUpperLeft),
            ('abdomen_upper_right', l10n.tracking_siteSelector_abdomenUpperRight),
            ('abdomen_lower_left', l10n.tracking_siteSelector_abdomenLowerLeft),
            ('abdomen_lower_right', l10n.tracking_siteSelector_abdomenLowerRight),
          ],
        ),

        const SizedBox(height: 12),

        // 허벅지
        _buildSiteGroup(
          l10n.tracking_siteSelector_thigh,
          [
            ('thigh_left', l10n.tracking_siteSelector_left),
            ('thigh_right', l10n.tracking_siteSelector_right),
          ],
        ),

        const SizedBox(height: 12),

        // 상완
        _buildSiteGroup(
          l10n.tracking_siteSelector_arm,
          [
            ('arm_left', l10n.tracking_siteSelector_left),
            ('arm_right', l10n.tracking_siteSelector_right),
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
                    l10n.tracking_siteSelector_rotationWarning(_getDaysAgo(selectedSite!)),
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
              context.l10n.tracking_siteSelector_daysAgo(daysAgo),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
