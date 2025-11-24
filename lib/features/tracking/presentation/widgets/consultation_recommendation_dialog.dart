import 'package:flutter/material.dart';

/// F005: 전문가 상담 권장 다이얼로그
///
/// 사용자가 긴급 증상 중 하나라도 선택했을 때,
/// 전문가와의 상담이 필요함을 안내하는 모달 다이얼로그
///
/// Gabium Design System 적용:
/// - Error 색상 강조 (비상 상황)
/// - Alert Banner 패턴 (경고 메시지)
/// - Modal 컴포넌트 구조 (헤더, 컨텐츠, 푸터)
/// - 타이포그래피 계층화 (2xl, base, sm)
class ConsultationRecommendationDialog extends StatelessWidget {
  /// 사용자가 선택한 증상 목록
  final List<String> selectedSymptoms;

  const ConsultationRecommendationDialog({super.key, required this.selectedSymptoms});

  @override
  Widget build(BuildContext context) {
    // Gabium Design System Colors
    const errorColor = Color(0xFFEF4444); // Error
    const errorBg = Color(0xFFFEF2F2); // Error light bg (50)
    const errorBorder = Color(0xFFFECACA); // Error 200
    const neutral800 = Color(0xFF1E293B); // Neutral-800
    const neutral600 = Color(0xFF475569); // Neutral-600
    const neutral100 = Color(0xFFF1F5F9); // Neutral-100
    const white = Color(0xFFFFFFFF);

    return Dialog(
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // lg
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Error accent
            Container(
              padding: const EdgeInsets.all(24), // lg
              decoration: BoxDecoration(
                color: errorBg,
                border: Border(
                  left: BorderSide(color: errorColor, width: 4),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '전문가와 상담이 필요합니다',
                      style: TextStyle(
                        fontSize: 24, // 2xl
                        fontWeight: FontWeight.w700, // Bold
                        color: neutral800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: errorColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24), // lg
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    '선택하신 증상:',
                    style: TextStyle(
                      fontSize: 18, // lg
                      fontWeight: FontWeight.w600, // Semibold
                      color: neutral800,
                    ),
                  ),
                  const SizedBox(height: 16), // md

                  // Symptom List
                  ...selectedSymptoms.map(
                    (symptom) => Padding(
                      padding: const EdgeInsets.only(bottom: 12), // md
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.warning_rounded,
                              color: errorColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12), // md
                          Expanded(
                            child: Text(
                              symptom,
                              style: TextStyle(
                                fontSize: 14, // sm
                                fontWeight: FontWeight.w400, // Regular
                                color: neutral600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // lg

                  // Alert Banner (Warning pattern)
                  Container(
                    padding: const EdgeInsets.all(16), // md
                    decoration: BoxDecoration(
                      color: errorBg,
                      border: Border.all(
                        color: errorBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8), // sm
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outlined,
                          color: errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12), // md
                        Expanded(
                          child: Text(
                            '선택하신 증상으로 보아 전문가의 상담이 필요해 보입니다. '
                            '가능한 한 빨리 의료진에게 연락하시기 바랍니다.',
                            style: TextStyle(
                              fontSize: 14, // sm
                              fontWeight: FontWeight.w400, // Regular
                              color: neutral600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer with action button
            Container(
              padding: const EdgeInsets.all(24), // lg
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: neutral100,
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44, // Medium button height
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: white,
                    disabledBackgroundColor: errorColor.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // sm
                    ),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16, // base
                      fontWeight: FontWeight.w600, // Semibold
                      color: white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
