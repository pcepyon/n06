import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/extensions/date_format_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

class CommitmentScreen extends StatefulWidget {
  final String name;
  final double currentWeight;
  final double targetWeight;
  final DateTime startDate;
  final String medicationName;
  final double initialDose;
  final VoidCallback onComplete;
  final bool isReviewMode;

  const CommitmentScreen({
    super.key,
    required this.name,
    required this.currentWeight,
    required this.targetWeight,
    required this.startDate,
    required this.medicationName,
    required this.initialDose,
    required this.onComplete,
    this.isReviewMode = false,
  });

  @override
  State<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends State<CommitmentScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onConfirmed() {
    HapticFeedback.heavyImpact();
    _confettiController.play();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (widget.isReviewMode) {
          _showReviewCompleteDialog();
        } else {
          _showNextStepDialog();
        }
      }
    });
  }

  /// 리뷰 모드 완료 다이얼로그
  void _showReviewCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          context.l10n.onboarding_commitment_dialogTitleReview,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Text(
          context.l10n.onboarding_commitment_dialogMessageReview,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
              widget.onComplete();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              context.l10n.onboarding_commitment_dialogButtonReview,
              style: AppTypography.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showNextStepDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          context.l10n.onboarding_commitment_dialogTitle,
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          context.l10n.onboarding_commitment_dialogMessage,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogContext);
              widget.onComplete();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              context.l10n.onboarding_commitment_dialogButton,
              style: AppTypography.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.startDate.formatFull(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    context.l10n.onboarding_commitment_title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      height: 1.29,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Summary card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x141E293B),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card title
                        Text(
                          context.l10n.onboarding_commitment_journeyTitle(widget.name),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Goal
                        _SummaryItem(
                          icon: '🎯',
                          label: context.l10n.onboarding_commitment_goalLabel,
                          value:
                              '${widget.currentWeight.toStringAsFixed(1)}kg → ${widget.targetWeight.toStringAsFixed(1)}kg',
                        ),
                        const SizedBox(height: 16),

                        // Start date
                        _SummaryItem(
                          icon: '📅',
                          label: context.l10n.onboarding_commitment_startDateLabel,
                          value: formattedDate,
                        ),
                        const SizedBox(height: 16),

                        // Medication
                        _SummaryItem(
                          icon: '💊',
                          label: context.l10n.onboarding_commitment_medicationLabel,
                          value:
                              '${widget.medicationName} ${widget.initialDose.toStringAsFixed(1)}mg',
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Closing message
                  Column(
                    children: [
                      Text(
                        context.l10n.onboarding_commitment_closingMessage1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.onboarding_commitment_closingMessage2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Slide to confirm
                  ConfirmationSlider(
                    onConfirmation: _onConfirmed,
                    backgroundColor: const Color(0xFFF1F5F9), // Neutral-100
                    foregroundColor: const Color(0xFF4ADE80), // Primary
                    iconColor: Colors.white,
                    shadow: BoxShadow(
                      color: const Color(0x1A1E293B),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    height: 64,
                    text: widget.isReviewMode ? context.l10n.onboarding_commitment_sliderTextReview : context.l10n.onboarding_commitment_sliderText,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    sliderButtonContent: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF4ADE80),
                Color(0xFF22C55E),
                Color(0xFF86EFAC),
                Colors.white,
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
