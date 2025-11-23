import 'package:flutter/material.dart';

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
      end: const Color(0xFFF1F5F9), // Neutral-100
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
          height: 44.0, // Touch area height
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0, // md
            vertical: 8.0, // sm
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE2E8F0), // Neutral-200
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: widget.enabled
                              ? const Color(0xFF1E293B) // Neutral-800
                              : const Color(0xFF1E293B).withOpacity(0.4),
                          fontSize: 16.0, // base
                          fontWeight: FontWeight.w600, // Semibold
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: widget.enabled
                              ? const Color(0xFF64748B) // Neutral-500
                              : const Color(0xFF64748B).withOpacity(0.4),
                          fontSize: 14.0, // sm
                          fontWeight: FontWeight.w400, // Regular
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
                      ? const Color(0xFF94A3B8) // Neutral-400
                      : const Color(0xFF94A3B8).withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
