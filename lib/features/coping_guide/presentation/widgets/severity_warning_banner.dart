import 'package:flutter/material.dart';

/// 심각도 경고 배너
class SeverityWarningBanner extends StatelessWidget {
  final VoidCallback onCheckSymptom;

  const SeverityWarningBanner({required this.onCheckSymptom, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade100,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '증상이 심각하거나 지속됩니다',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: onCheckSymptom,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('증상 체크하기'),
          ),
        ],
      ),
    );
  }
}
