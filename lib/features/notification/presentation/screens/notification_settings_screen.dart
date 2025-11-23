import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/notification/application/notifiers/notification_notifier.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:n06/features/notification/presentation/widgets/time_picker_button.dart';

/// 푸시 알림 설정 화면
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  /// NotificationTime → TimeOfDay 변환 헬퍼 (Presentation Layer에서만 사용)
  TimeOfDay _toTimeOfDay(NotificationTime notificationTime) {
    return TimeOfDay(hour: notificationTime.hour, minute: notificationTime.minute);
  }

  /// TimeOfDay → NotificationTime 변환 헬퍼 (Presentation Layer에서만 사용)
  NotificationTime _fromTimeOfDay(TimeOfDay timeOfDay) {
    return NotificationTime(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('푸시 알림 설정'),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
      body: settingsAsync.when(
        data: (settings) => _buildContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('오류가 발생했습니다: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic settings) {
    final notifier = ref.read(notificationNotifierProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Change 2: 알림 활성화 토글 카드 강화
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // md
          ),
          shadowColor: const Color.fromARGB(20, 15, 23, 42),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), // md
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ), // md shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ), // md shadow
              ],
            ),
            child: ListTile(
              title: const Text(
                '알림 활성화',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600, // Semibold (xl)
                  color: Color(0xFF1E293B), // Neutral-800
                ),
              ),
              subtitle: Text(
                settings.notificationEnabled ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF64748B), // Neutral-500
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              trailing: Switch(
                value: settings.notificationEnabled,
                onChanged: (value) async {
                  await notifier.toggleNotificationEnabled();
                },
              ),
            ),
          ),
        ),

        // Change 5: 섹션 간격 lg (24px)
        const SizedBox(height: 24),

        // Change 3: 알림 시간 설정 카드 (제목 타이포그래피 강화)
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // md
          ),
          child: Padding(
            padding: const EdgeInsets.all(16), // md
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Change 3: 섹션 제목 xl (20px, Semibold)로 강화
                const Text(
                  '알림 시간',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600, // Semibold (xl)
                    color: Color(0xFF1E293B), // Neutral-800
                  ),
                ),
                const SizedBox(height: 16), // md spacing

                // Change 4: TimePickerButton (Secondary 스타일)
                TimePickerButton(
                  currentTime: _toTimeOfDay(settings.notificationTime),
                  onTimeSelected: (selectedTime) async {
                    final notificationTime = _fromTimeOfDay(selectedTime);
                    await notifier.updateNotificationTime(notificationTime);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('알림 설정이 저장되었습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        // Change 5: 섹션 간격 lg (24px)
        const SizedBox(height: 24),

        // Change 1: Info 색상 메시지 박스 개선 (Alert Banner 패턴)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // md
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // Blue-50
            border: Border.all(
              color: const Color.fromARGB(102, 59, 130, 246), // Blue at 40%
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8), // sm
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), // xs shadow
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF3B82F6), // Blue
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '알림은 매 투여 예정일 설정된 시간에 발송됩니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF1E40AF), // Blue-800
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
