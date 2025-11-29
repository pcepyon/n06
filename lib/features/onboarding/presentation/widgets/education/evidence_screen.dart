import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class EvidenceScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const EvidenceScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  bool _showCounter = false;

  @override
  void initState() {
    super.initState();
    // Start counter animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showCounter = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: '실제로 일어난 변화들',
      subtitle: '전 세계 수백만 명이 경험한 검증된 결과예요',
      content: _buildContent(),
      onNext: widget.onNext,
      nextButtonText: '다음',
      isNextEnabled: true,
      showSkip: true,
      onSkip: widget.onSkip,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Main data card with animated counter
        _buildMainDataCard(),
        const SizedBox(height: 24), // lg

        // Benefits grid
        _buildBenefitsSection(),
        const SizedBox(height: 24), // lg

        // Closing message
        _buildClosingMessage(),
      ],
    );
  }

  Widget _buildMainDataCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Neutral-100
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
        ),
      ),
      child: Column(
        children: [
          // Animated counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedFlipCounter(
                value: _showCounter ? 21 : 0,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                textStyle: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4ADE80), // Primary
                  height: 1.0,
                ),
              ),
              const Text(
                '%',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4ADE80), // Primary
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '평균 체중 감량',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 16),

          // Source link
          InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              final uri = Uri.parse(
                'https://www.nejm.org/doi/full/10.1056/NEJMoa2206038',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '출처: 72주 임상시험 결과 (NEJM)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B), // Neutral-500
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Color(0xFF64748B), // Neutral-500
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '🔗 탭해서 출처 확인',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8), // Neutral-400
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Neutral-50
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추가 효과',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBenefitChip('🫀 심장 건강 개선'),
              _buildBenefitChip('😴 수면 질 향상'),
              _buildBenefitChip('🩸 혈당 조절 개선'),
              _buildBenefitChip('⚡ 에너지 레벨 상승'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Neutral-100
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF334155), // Neutral-700
        ),
      ),
    );
  }

  Widget _buildClosingMessage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: const Text(
        '체중 감량 그 이상의 변화가\n당신을 기다리고 있어요',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155), // Neutral-700
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
