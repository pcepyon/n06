import 'package:flutter/material.dart';

import 'package:n06/core/presentation/theme/app_typography.dart';
import '../../../../features/authentication/presentation/widgets/gabium_button.dart';
import 'coping_guide_feedback_result.dart';

/// 피드백 위젯 (도움이 되었나요?)
class FeedbackWidget extends StatefulWidget {
  final Function(bool) onFeedback;

  const FeedbackWidget({required this.onFeedback, super.key});

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  bool? _feedbackGiven;

  @override
  Widget build(BuildContext context) {
    if (_feedbackGiven != null) {
      return CopingGuideFeedbackResult(
        onRetry: () {
          setState(() {
            _feedbackGiven = null;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '도움이 되었나요?',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GabiumButton(
                text: '네',
                onPressed: () {
                  widget.onFeedback(true);
                  setState(() {
                    _feedbackGiven = true;
                  });
                },
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.small,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GabiumButton(
                text: '아니오',
                onPressed: () {
                  widget.onFeedback(false);
                  setState(() {
                    _feedbackGiven = false;
                  });
                },
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.small,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
