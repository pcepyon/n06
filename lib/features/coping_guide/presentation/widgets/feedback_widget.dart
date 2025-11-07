import 'package:flutter/material.dart';

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
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            _feedbackGiven! ? '도움이 되어 기쁩니다!' : '더 자세한 가이드 보기',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '도움이 되었나요?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.onFeedback(true);
                  setState(() {
                    _feedbackGiven = true;
                  });
                },
                child: Text('예'),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  widget.onFeedback(false);
                  setState(() {
                    _feedbackGiven = false;
                  });
                },
                child: Text('아니오'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
