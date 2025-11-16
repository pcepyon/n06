import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/usecases/injection_site_rotation_usecase.dart';

class InjectionSiteSelectWidget extends ConsumerStatefulWidget {
  final Function(String) onSiteSelected;

  const InjectionSiteSelectWidget({
    required this.onSiteSelected,
    super.key,
  });

  @override
  ConsumerState<InjectionSiteSelectWidget> createState() => _InjectionSiteSelectWidgetState();
}

class _InjectionSiteSelectWidgetState extends ConsumerState<InjectionSiteSelectWidget> {
  String? selectedSite;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSiteButton(
              context: context,
              site: 'abdomen',
              label: '복부',
              icon: Icons.favorite_outlined,
            ),
            _buildSiteButton(
              context: context,
              site: 'thigh',
              label: '허벅지',
              icon: Icons.accessibility_outlined,
            ),
            _buildSiteButton(
              context: context,
              site: 'arm',
              label: '상완',
              icon: Icons.wb_sunny_outlined,
            ),
          ],
        ),
        if (selectedSite != null) ...[
          const SizedBox(height: 16),
          FutureBuilder<RotationCheckResult>(
            future: ref.read(medicationNotifierProvider.notifier).checkInjectionSiteRotation(selectedSite!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              if (snapshot.hasError) {
                return const SizedBox.shrink();
              }

              final result = snapshot.data;
              if (result == null || !result.needsWarning) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_outlined, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSiteButton({
    required BuildContext context,
    required String site,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedSite == site;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSite = site;
        });
        widget.onSiteSelected(site);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
