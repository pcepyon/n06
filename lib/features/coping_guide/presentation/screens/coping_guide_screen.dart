import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';

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
        title: Text('부작용 대처 가이드', style: AppTextStyles.h3),
      ),
      body: guideList.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다', style: AppTextStyles.body1.copyWith(color: AppColors.error))),
        data: (guides) {
          if (guides.isEmpty) {
            return Center(child: Text('가이드가 없습니다', style: AppTextStyles.body1.copyWith(color: AppColors.gray)));
          }

          return ListView.builder(
            itemCount: guides.length,
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
