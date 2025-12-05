import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/features/guest_home/presentation/widgets/welcome_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/scientific_evidence_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/journey_preview_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/app_features_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/side_effects_guide_section.dart';
import 'package:n06/features/guest_home/presentation/widgets/cta_section.dart';

/// 비로그인 홈 화면
/// 앱 스토어 심사 통과 및 신규 사용자 전환을 위한 화면
class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    // 회원가입 화면으로 이동
    context.go('/sign-up');
  }

  void _handleLearnMore() {
    // 부작용 가이드 섹션으로 스크롤
    // 또는 별도 화면으로 이동 가능
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. 환영 섹션
            const SliverToBoxAdapter(
              child: WelcomeSection(),
            ),

            // 섹션 간격
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),

            // 2. 과학적 근거 섹션
            const SliverToBoxAdapter(
              child: ScientificEvidenceSection(),
            ),

            // 섹션 간격
            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),

            // 3. 치료 여정 미리보기 섹션
            const SliverToBoxAdapter(
              child: JourneyPreviewSection(),
            ),

            // 섹션 간격
            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),

            // 4. 앱 기능 소개 섹션
            const SliverToBoxAdapter(
              child: AppFeaturesSection(),
            ),

            // 섹션 간격
            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),

            // 5. 부작용 대처 가이드 섹션
            const SliverToBoxAdapter(
              child: SideEffectsGuideSection(),
            ),

            // 섹션 간격
            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),

            // 6. CTA 섹션
            SliverToBoxAdapter(
              child: CtaSection(
                onSignUp: _handleSignUp,
                onLearnMore: _handleLearnMore,
              ),
            ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}
