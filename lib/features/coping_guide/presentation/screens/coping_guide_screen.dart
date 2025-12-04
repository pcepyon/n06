import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import '../../application/notifiers/coping_guide_notifier.dart';
import '../widgets/coping_guide_card.dart';
import 'detailed_guide_screen.dart';

/// 부작용 대처 가이드 탭 화면
class CopingGuideScreen extends ConsumerStatefulWidget {
  const CopingGuideScreen({super.key});

  @override
  ConsumerState<CopingGuideScreen> createState() => _CopingGuideScreenState();
}

class _CopingGuideScreenState extends ConsumerState<CopingGuideScreen> {
  @override
  void initState() {
    super.initState();
    // 가이드 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(copingGuideListNotifierProvider.notifier).loadAllGuides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final guideList = ref.watch(copingGuideListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.coping_screen_title,
          style: AppTypography.heading2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Column(
            children: [
              const Divider(
                color: AppColors.border,
                height: 1,
                thickness: 1,
              ),
              Container(
                height: 3,
                color: AppColors.education,
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),
      body: guideList.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.education),
          ),
        ),
        error: (err, stack) => Center(child: Text(context.l10n.coping_screen_error)),
        data: (guides) {
          if (guides.isEmpty) {
            return Center(child: Text(context.l10n.coping_screen_empty));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: guides.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: AppColors.border,
                height: 1,
                thickness: 1,
              ),
            ),
            itemBuilder: (context, index) {
              final guide = guides[index];
              return CopingGuideCard(
                guide: guide,
                onDetailTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailedGuideScreen(guide: guide),
                    ),
                  );
                },
                onFeedback: (helpful) {
                  ref
                      .read(copingGuideNotifierProvider.notifier)
                      .submitFeedback(guide.symptomName, helpful: helpful);
                },
              );
            },
          );
        },
      ),
    );
  }
}
