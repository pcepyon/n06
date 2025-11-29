import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class HowItWorksScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const HowItWorksScreen({
    super.key,
    required this.onNext,
    this.onSkip,
  });

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  final Set<String> _expandedItems = {};

  bool get _allExpanded =>
      _expandedItems.containsAll({'brain', 'stomach'});

  void _onExpansionChanged(String id, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        _expandedItems.add(id);
      } else {
        _expandedItems.remove(id);
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: '이렇게 도와드려요',
      showSkip: true,
      onSkip: widget.onSkip,
      onNext: widget.onNext,
      isNextEnabled: _allExpanded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인터랙션 안내
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB), // Warning Yellow-50
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0x4DD97706), // Yellow-600 with 30% opacity
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app,
                  size: 16,
                  color: Color(0xFFD97706), // Warning Yellow-600
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '탭해서 자세히 알아보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD97706), // Warning Yellow-600
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 뇌 설명
          _buildExpandableCard(
            id: 'brain',
            icon: '🧠',
            title: '뇌',
            description: '• 포만감 신호 강화\n• 음식 보상 반응 조절',
            isExpanded: _expandedItems.contains('brain'),
            onExpansionChanged: (isExpanded) =>
                _onExpansionChanged('brain', isExpanded),
          ),

          const SizedBox(height: 16),

          // 위 설명
          _buildExpandableCard(
            id: 'stomach',
            icon: '🫃',
            title: '위',
            description: '• 음식 소화 속도 조절\n• 포만감 오래 유지',
            isExpanded: _expandedItems.contains('stomach'),
            onExpansionChanged: (isExpanded) =>
                _onExpansionChanged('stomach', isExpanded),
          ),

          const SizedBox(height: 32),

          // 체크리스트
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4), // Green-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x4D4ADE80), // Green-400 with 30% opacity
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckItem('억지로 참는 게 아니에요'),
                const SizedBox(height: 12),
                _buildCheckItem('자연스럽게 덜 먹게 돼요'),
                const SizedBox(height: 12),
                _buildCheckItem('선택의 여유가 생겨요'),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String id,
    required String icon,
    required String title,
    required String description,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Neutral-100
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF4ADE80) // Primary
              : const Color(0xFFE2E8F0), // Neutral-200
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: PageStorageKey<String>(id),
          leading: Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B), // Neutral-800
              height: 1.4,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: const Color(0xFF4ADE80), // Primary
          ),
          onExpansionChanged: onExpansionChanged,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B), // Neutral-500
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          size: 20,
          color: Color(0xFF4ADE80), // Primary
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF166534), // Green-800
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
