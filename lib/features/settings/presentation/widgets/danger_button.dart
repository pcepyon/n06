import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

class DangerButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const DangerButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  });

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || widget.isLoading;

    return GestureDetector(
      onTap: (!isDisabled) ? widget.onPressed : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        cursor: isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            Color bgColor;
            double elevation;

            if (_isPressed && !isDisabled) {
              // Active state
              bgColor = const Color(0xFFB91C1C);
              elevation = 1.0; // xs shadow
            } else if (_controller.value > 0 && !isDisabled) {
              // Hover state (interpolated)
              bgColor = Color.lerp(
                AppColors.error,
                const Color(0xFFDC2626),
                _controller.value,
              )!;
              elevation = 2.0 + (2.0 * _controller.value);
            } else {
              // Default state
              bgColor = AppColors.error;
              elevation = 2.0; // sm shadow
            }

            if (isDisabled) {
              bgColor = AppColors.error.withValues(alpha: 0.4);
            }

            return Container(
              width: double.infinity,
              height: 44.0, // Medium button height
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8.0), // sm border-radius
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral900.withValues(alpha: 0.06),
                    blurRadius: elevation * 2,
                    offset: Offset(0, elevation),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: null, // Already handled by GestureDetector
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(
                            alpha: isDisabled ? 0.6 : 1.0,
                          ),
                        ),
                        strokeWidth: 2.0,
                      ),
                    )
                        : Text(
                      widget.text,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white.withValues(
                          alpha: isDisabled ? 0.6 : 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
