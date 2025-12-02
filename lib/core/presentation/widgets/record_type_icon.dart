import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';

/// RecordTypeIcon component
/// 기록 타입별 아이콘과 색상을 반환하는 재사용 가능한 위젯
/// 체중(Emerald), 체크인(Info), 투여(Primary)
enum RecordType {
  weight,
  symptom,
  dose,
  checkin,
}

class RecordTypeIcon extends StatelessWidget {
  final RecordType type;
  final double size;

  const RecordTypeIcon({
    super.key,
    required this.type,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Icon(
      config.icon,
      size: size,
      color: config.color,
    );
  }

  _RecordTypeConfig _getConfig() {
    switch (type) {
      case RecordType.weight:
        return _RecordTypeConfig(
          icon: Icons.monitor_weight_outlined,
          color: AppColors.success,
        );
      case RecordType.symptom:
        return _RecordTypeConfig(
          icon: Icons.warning_amber_outlined,
          color: AppColors.warning,
        );
      case RecordType.dose:
        return _RecordTypeConfig(
          icon: Icons.medical_services_outlined,
          color: AppColors.primary,
        );
      case RecordType.checkin:
        return _RecordTypeConfig(
          icon: Icons.check_circle_outline,
          color: AppColors.info,
        );
    }
  }

  /// 좌측 컬러바 색상 반환
  static Color getColorBarColor(RecordType type) {
    switch (type) {
      case RecordType.weight:
        return AppColors.success;
      case RecordType.symptom:
        return AppColors.warning;
      case RecordType.dose:
        return AppColors.primary;
      case RecordType.checkin:
        return AppColors.info;
    }
  }
}

class _RecordTypeConfig {
  final IconData icon;
  final Color color;

  _RecordTypeConfig({
    required this.icon,
    required this.color,
  });
}
