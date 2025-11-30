import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 상세 가이드 확장 섹션
///
/// Phase 1: 안심 퍼스트 가이드 리뉴얼
/// - "더 알아보기" 탭 시 BottomSheet로 표시
/// - ExpansionTile 사용하여 섹션별 확장 가능
/// - 헤더: 제목 + 항목 수 뱃지
/// - 본문: 번호 리스트 형태
///
/// Design Tokens:
/// - Background: White
/// - Border: Neutral200
/// - Border Radius: 8px (sm)
/// - Padding: 16px (md)
class ExpandableGuideSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool initiallyExpanded;

  const ExpandableGuideSection({
    super.key,
    required this.title,
    required this.items,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${items.length}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            ...items.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}.',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// 상세 가이드 BottomSheet
///
/// ExpandableGuideSection들을 표시하는 BottomSheet
void showDetailedGuideBottomSheet(
  BuildContext context, {
  required String symptomName,
  required List<Map<String, dynamic>> sections,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$symptomName 대처 가이드',
                    style: AppTypography.heading2.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.neutral200, height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ...sections.map(
                    (section) => ExpandableGuideSection(
                      title: section['title'] as String,
                      items: (section['items'] as List<dynamic>)
                          .map((e) => e.toString())
                          .toList(),
                      initiallyExpanded: section['initiallyExpanded'] ?? false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
