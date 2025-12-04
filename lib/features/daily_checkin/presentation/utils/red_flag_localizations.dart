import 'package:flutter/material.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/l10n/generated/app_localizations.dart';

/// Red Flag 메시지 i18n 헬퍼
///
/// Application Layer에서 반환된 RedFlagType을 Presentation Layer에서
/// 로컬라이즈된 메시지로 변환합니다.
///
/// Layer 규칙 준수:
/// - Application Layer: RedFlagType enum만 반환 (메시지 없음)
/// - Presentation Layer: l10n으로 메시지 매핑 (이 파일)
extension RedFlagLocalizations on RedFlagType {
  /// Red Flag 타입별 안내 메시지 반환
  ///
  /// 의료 콘텐츠 검수 필수 (docs/i18n/special/medical-terms.md 참조)
  String getMessage(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      RedFlagType.pancreatitis => l10n.checkin_redFlag_pancreatitis,
      RedFlagType.cholecystitis => l10n.checkin_redFlag_cholecystitis,
      RedFlagType.severeDehydration => l10n.checkin_redFlag_severeDehydration,
      RedFlagType.bowelObstruction => l10n.checkin_redFlag_bowelObstruction,
      RedFlagType.hypoglycemia => l10n.checkin_redFlag_hypoglycemia,
      RedFlagType.renalImpairment => l10n.checkin_redFlag_renalImpairment,
    };
  }

  /// Red Flag 심각도별 다이얼로그 제목 반환
  String getSeverityTitle(BuildContext context, RedFlagSeverity severity) {
    final l10n = L10n.of(context);
    return switch (severity) {
      RedFlagSeverity.warning => l10n.checkin_redFlag_title_warning,
      RedFlagSeverity.urgent => l10n.checkin_redFlag_title_urgent,
    };
  }
}

/// Red Flag 심각도 i18n 헬퍼
extension RedFlagSeverityLocalizations on RedFlagSeverity {
  /// 심각도별 다이얼로그 제목 반환
  String getTitle(BuildContext context) {
    final l10n = L10n.of(context);
    return switch (this) {
      RedFlagSeverity.warning => l10n.checkin_redFlag_title_warning,
      RedFlagSeverity.urgent => l10n.checkin_redFlag_title_urgent,
    };
  }
}
