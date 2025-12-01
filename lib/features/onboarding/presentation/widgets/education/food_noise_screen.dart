import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/onboarding/presentation/widgets/common/onboarding_page_template.dart';

class FoodNoiseScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final Function(int) onFoodNoiseLevelChanged;

  const FoodNoiseScreen({
    super.key,
    required this.onNext,
    this.onSkip,
    required this.onFoodNoiseLevelChanged,
  });

  @override
  State<FoodNoiseScreen> createState() => _FoodNoiseScreenState();
}

class _FoodNoiseScreenState extends State<FoodNoiseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  double _userLevel = 5.0;
  bool _hasSimulated = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _userLevel = value;
      if (!_hasSimulated) {
        _lottieController.value = value / 10.0;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _simulateChange() {
    if (_hasSimulated) return;

    setState(() => _hasSimulated = true);
    _lottieController.animateTo(
      0.16, // 치료 후 예상값 (약 16%)
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
    widget.onFoodNoiseLevelChanged(_userLevel.toInt());
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageTemplate(
      title: '머릿속 음식 생각, 줄어들 거예요',
      subtitle: '혹시 이런 경험 있으신가요?',
      showSkip: true,
      onSkip: widget.onSkip,
      onNext: widget.onNext,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 공감 문구
          _buildEmpathyQuote('배고프지도 않은데 자꾸 뭔가 먹고 싶어...'),
          const SizedBox(height: 8),
          _buildEmpathyQuote('방금 먹었는데 벌써 다음 끼니 생각이...'),
          const SizedBox(height: 8),
          _buildEmpathyQuote('다이어트 중인데 음식 생각을 멈출 수가...'),

          const SizedBox(height: 24),

          // Food Noise 설명
          Text(
            '이걸 \'Food Noise\'라고 불러요',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 32),

          // Lottie 애니메이션
          Center(
            child: _buildLottieWithFallback(
              'assets/animations/food_noise.json',
              height: 200,
            ),
          ),

          const SizedBox(height: 32),

          // 현재 상태 입력
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나의 상태',
                  style: AppTypography.heading3.copyWith(
                    color: const Color(0xFF334155), // Neutral-700
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '현재 음식 생각이 얼마나 자주 나나요?',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '1',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _userLevel,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        onChanged: _hasSimulated ? null : _onSliderChanged,
                      ),
                    ),
                    Text(
                      '10',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    '${_userLevel.toInt()}',
                    style: AppTypography.numericMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 변화 시뮬레이션 버튼
          if (!_hasSimulated)
            Center(
              child: ElevatedButton(
                onPressed: _simulateChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.educationBackground, // Blue-50
                  foregroundColor: AppColors.education, // Blue-500
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '변화 예측 보기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // 변화 예측 결과
          if (_hasSimulated) ...[
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
                  const Text(
                    '변화 예측',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF166534), // Green-800
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '🔊',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.16,
                            minHeight: 8,
                            backgroundColor:
                                const Color(0xFFE2E8F0), // Neutral-200
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4ADE80), // Primary
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '🔈',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '치료 후 약 16% 수준으로 감소 예상',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF166534), // Green-800
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 데이터 인포카드
          _buildInfoCard(
            'GLP-1 사용자 중 62%가\n음식 관련 생각이 크게 줄었다고 해요',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmpathyQuote(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Neutral-100
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
        ),
      ),
      child: Row(
        children: [
          const Text(
            '"',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4ADE80), // Primary
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155), // Neutral-700
                height: 1.43,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLottieWithFallback(String assetPath, {double? height}) {
    final effectiveHeight = height ?? 200.0;

    return FutureBuilder(
      future: Future.delayed(Duration.zero, () async {
        try {
          await rootBundle.load(assetPath);
          return true;
        } catch (e) {
          return false;
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Lottie.asset(
            assetPath,
            height: effectiveHeight,
            controller: _lottieController,
            onLoaded: (composition) {
              _lottieController.duration = composition.duration;
              _lottieController.value = _userLevel / 10.0;
            },
          );
        }
        return Container(
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.animation,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.educationBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.education.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.education,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
