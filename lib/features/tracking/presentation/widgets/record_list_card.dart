import 'package:flutter/material.dart';
import 'package:n06/core/presentation/widgets/record_type_icon.dart';

/// RecordListCard component
/// 기록 항목을 표시하는 카드 컨테이너
/// - 좌측 컬러바 (타입별 색상)
/// - 호버 애니메이션 (elevation + transform)
/// - 우측 삭제 버튼
class RecordListCard extends StatefulWidget {
  final Widget child;
  final RecordType recordType;
  final VoidCallback onDelete;

  const RecordListCard({
    super.key,
    required this.child,
    required this.recordType,
    required this.onDelete,
  });

  @override
  State<RecordListCard> createState() => _RecordListCardState();
}

class _RecordListCardState extends State<RecordListCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  bool _isPressed = false;
  late AnimationController _hoverController;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200), // Transitions - base
      vsync: this,
    );
    _offsetAnimation = Tween<double>(begin: 0.0, end: -2.0).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorBarColor = RecordTypeIcon.getColorBarColor(widget.recordType);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _offsetAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _offsetAnimation.value),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16, // md - 모바일 마진
                  vertical: 8, // sm - 카드 간격
                ),
                decoration: BoxDecoration(
                  color: _isPressed
                      ? const Color(0xFFF1F5F9) // Neutral-100 (롱프레스)
                      : const Color(0xFFFFFFFF), // White
                  border: Border.all(
                    color: const Color(0xFFE2E8F0), // Neutral-200
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12), // md
                  boxShadow: [
                    // Shadow sm (기본)
                    BoxShadow(
                      color: const Color(0x0F0F172A).withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: const Color(0x0F0F172A).withValues(alpha: 0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                    // Shadow md (호버)
                    if (_isHovering)
                      BoxShadow(
                        color: const Color(0x0F0F172A).withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    if (_isHovering)
                      BoxShadow(
                        color: const Color(0x0F0F172A).withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 좌측 컬러바 (4px, 타입별 색상)
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: colorBarColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      // 카드 컨텐츠
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16), // md
                          child: widget.child,
                        ),
                      ),
                      // 삭제 버튼 (44x44px 터치 영역)
                      Container(
                        width: 44,
                        alignment: Alignment.center,
                        child: IconButton(
                          onPressed: widget.onDelete,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 24,
                            color: Color(0xFFEF4444), // Error
                          ),
                          splashColor:
                              const Color(0xFFFEF2F2), // Error at 10%
                          highlightColor: const Color(0xFFFEF2F2),
                          hoverColor: const Color(0xFFFEF2F2),
                          tooltip: '삭제',
                        ),
                      ),
                    ],
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
