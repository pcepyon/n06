import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

class SettingsMenuItemImproved extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const SettingsMenuItemImproved({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  @override
  State<SettingsMenuItemImproved> createState() =>
      _SettingsMenuItemImprovedState();
}

class _SettingsMenuItemImprovedState extends State<SettingsMenuItemImproved>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _bgColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _bgColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.surfaceVariant,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44.0), // Minimum touch target
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0, // md
            vertical: 8.0, // sm
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 1.0,
              ),
            ),
          ),
          child: AnimatedBuilder(
            animation: _bgColorAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: _bgColorAnimation.value,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.bodyLarge.copyWith(
                          color: widget.enabled
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        widget.subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: widget.enabled
                              ? AppColors.textTertiary
                              : AppColors.textTertiary.withValues(alpha: 0.4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),

                // Trailing chevron icon
                Icon(
                  Icons.chevron_right,
                  size: 20.0, // Icon size
                  color: widget.enabled
                      ? AppColors.textDisabled
                      : AppColors.textDisabled.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
