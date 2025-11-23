import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        title: const Text(
          '부작용 대처 가이드',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Column(
            children: [
              const Divider(
                color: Color(0xFFE2E8F0),
                height: 1,
                thickness: 1,
              ),
              Container(
                height: 3,
                color: const Color(0xFF4ADE80),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF475569),
          size: 24,
        ),
      ),
      body: guideList.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
          ),
        ),
        error: (err, stack) => const Center(child: Text('오류가 발생했습니다')),
        data: (guides) {
          if (guides.isEmpty) {
            return const Center(child: Text('가이드가 없습니다'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: guides.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: Color(0xFFE2E8F0),
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
