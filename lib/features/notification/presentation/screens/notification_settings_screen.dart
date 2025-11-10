import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/notification/application/notifiers/notification_notifier.dart';
import 'package:n06/features/notification/domain/value_objects/notification_time.dart';
import 'package:n06/features/notification/presentation/widgets/time_picker_button.dart';

/// 푸시 알림 설정 화면
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('푸시 알림 설정'), elevation: 0),
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
        // 알림 활성화 토글
        Card(
          elevation: 2,
          child: ListTile(
            title: const Text('알림 활성화'),
            subtitle: Text(settings.notificationEnabled ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다'),
            trailing: Switch(
              value: settings.notificationEnabled,
              onChanged: (value) async {
                await notifier.toggleNotificationEnabled();
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 알림 시간 설정
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('알림 시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TimePickerButton(
                  // NotificationTime → TimeOfDay 변환 (Presentation Layer에서만)
                  currentTime: settings.notificationTime.toTimeOfDay(),
                  onTimeSelected: (selectedTime) async {
                    // TimeOfDay → NotificationTime 변환
                    final notificationTime = NotificationTime.fromTimeOfDay(selectedTime);
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
        const SizedBox(height: 16),

        // 정보
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '알림은 매 투여 예정일 설정된 시간에 발송됩니다.',
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
