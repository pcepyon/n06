import 'package:flutter/material.dart';

import '../../domain/entities/coping_guide.dart';
import '../../domain/entities/coping_guide_state.dart';
import 'feedback_widget.dart';
import 'severity_warning_banner.dart';

/// 부작용 대처 가이드 카드
class CopingGuideCard extends StatelessWidget {
  final CopingGuide? guide;
  final CopingGuideState? state;
  final VoidCallback? onDetailTap;
  final VoidCallback? onCheckSymptom;
  final Function(bool)? onFeedback;

  const CopingGuideCard({
    this.guide,
    this.state,
    this.onDetailTap,
    this.onCheckSymptom,
    this.onFeedback,
    super.key,
  }) : assert(guide != null || state != null);

  @override
  Widget build(BuildContext context) {
    final currentGuide = state?.guide ?? guide!;
    final showWarning = state?.showSeverityWarning ?? false;

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showWarning && onCheckSymptom != null) ...[
              SeverityWarningBanner(onCheckSymptom: onCheckSymptom!),
              SizedBox(height: 16),
            ],
            Text(
              '${currentGuide.symptomName} 대처 가이드',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            Text(
              currentGuide.shortGuide,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onDetailTap,
                  child: Text('더 자세한 가이드 보기'),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (onFeedback != null)
              FeedbackWidget(onFeedback: onFeedback!),
          ],
        ),
      ),
    );
  }
}
