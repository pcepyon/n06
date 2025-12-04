import 'package:flutter/material.dart';
import 'package:n06/l10n/generated/app_localizations.dart';
import 'package:n06/features/daily_checkin/domain/entities/greeting_message_type.dart';

/// GreetingMessageType을 i18n 문자열로 변환하는 확장
extension GreetingMessageTypeExtension on GreetingMessageType {
  String toLocalizedString(BuildContext context) {
    final l10n = L10n.of(context);

    switch (this) {
      case GreetingMessageType.returningLongGap:
        return l10n.greeting_returningLongGap;
      case GreetingMessageType.returningShortGap:
        return l10n.greeting_returningShortGap;
      case GreetingMessageType.postInjection:
        return l10n.greeting_postInjection;
      case GreetingMessageType.morningOne:
        return l10n.greeting_morningOne;
      case GreetingMessageType.morningTwo:
        return l10n.greeting_morningTwo;
      case GreetingMessageType.morningThree:
        return l10n.greeting_morningThree;
      case GreetingMessageType.afternoonOne:
        return l10n.greeting_afternoonOne;
      case GreetingMessageType.afternoonTwo:
        return l10n.greeting_afternoonTwo;
      case GreetingMessageType.afternoonThree:
        return l10n.greeting_afternoonThree;
      case GreetingMessageType.eveningOne:
        return l10n.greeting_eveningOne;
      case GreetingMessageType.eveningTwo:
        return l10n.greeting_eveningTwo;
      case GreetingMessageType.eveningThree:
        return l10n.greeting_eveningThree;
      case GreetingMessageType.nightOne:
        return l10n.greeting_nightOne;
      case GreetingMessageType.nightTwo:
        return l10n.greeting_nightTwo;
      case GreetingMessageType.nightThree:
        return l10n.greeting_nightThree;
    }
  }
}
