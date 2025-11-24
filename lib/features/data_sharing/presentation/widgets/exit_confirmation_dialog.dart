import 'package:flutter/material.dart';

/// ExitConfirmationDialog - 공유 종료 확인 다이얼로그 (Gabium Design System)
///
/// 데이터 공유를 종료할 때 사용자에게 확인을 요청하는 다이얼로그
/// - Gabium Modal 패턴 적용
/// - 명확한 타이포그래피 계층
/// - Warning 색상 (종료 버튼)
class ExitConfirmationDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ExitConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // lg
      ),
      elevation: 10, // xl shadow
      title: const Text(
        '공유 종료',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700, // Bold
          color: Color(0xFF1E293B), // Neutral-800
        ),
      ),
      content: const Text(
        '정말로 공유를 종료하시겠습니까?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF475569), // Neutral-600
          height: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: const Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569), // Neutral-600
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B), // Warning/Secondary
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // sm
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            '종료',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Semibold
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
