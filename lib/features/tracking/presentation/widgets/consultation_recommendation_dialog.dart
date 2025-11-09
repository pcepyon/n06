import 'package:flutter/material.dart';

/// F005: 전문가 상담 권장 다이얼로그
///
/// 사용자가 긴급 증상 중 하나라도 선택했을 때,
/// 전문가와의 상담이 필요함을 안내하는 모달 다이얼로그
class ConsultationRecommendationDialog extends StatelessWidget {
  /// 사용자가 선택한 증상 목록
  final List<String> selectedSymptoms;

  const ConsultationRecommendationDialog({super.key, required this.selectedSymptoms});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '전문가와 상담이 필요합니다',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 선택된 증상 목록
            const Text('선택하신 증상:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...selectedSymptoms.map(
              (symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(symptom, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: const Text(
                '선택하신 증상으로 보아 전문가의 상담이 필요해 보입니다. '
                '가능한 한 빨리 의료진에게 연락하시기 바랍니다.',
                style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
