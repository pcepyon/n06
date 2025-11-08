import 'package:flutter/material.dart';

/// 입력값 검증 위젯
///
/// 체중 입력값을 실시간으로 검증하고,
/// 에러/성공 상태를 시각적으로 표시합니다.
class InputValidationWidget extends StatefulWidget {
  /// 입력된 값
  final String? initialValue;

  /// 입력 필드의 이름 (예: "체중")
  final String fieldName;

  /// 입력값 변경 시 호출되는 콜백
  final ValueChanged<String> onChanged;

  /// 입력 필드의 라벨
  final String label;

  /// 입력 필드의 힌트
  final String? hint;

  /// 키보드 타입 (기본값: decimal)
  final TextInputType keyboardType;

  const InputValidationWidget({
    super.key,
    this.initialValue,
    required this.fieldName,
    required this.onChanged,
    required this.label,
    this.hint,
    this.keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
      signed: false,
    ),
  });

  @override
  State<InputValidationWidget> createState() => _InputValidationWidgetState();
}

class _InputValidationWidgetState extends State<InputValidationWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 입력값 검증
  /// 반환값: (isValid, errorMessage)
  (bool, String?) _validate(String value) {
    if (value.isEmpty) {
      return (false, null); // 빈 값은 에러 메시지 없이 그냥 유효하지 않음
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return (false, '숫자를 입력하세요');
    }

    if (weight < 20) {
      return (false, '20kg 이상이어야 합니다');
    }

    if (weight > 300) {
      return (false, '300kg 이하여야 합니다');
    }

    return (true, null);
  }

  @override
  Widget build(BuildContext context) {
    final (isValid, errorMessage) = _validate(_controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _controller.text.isEmpty
                          ? Colors.grey
                          : isValid
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _controller.text.isEmpty
                          ? Theme.of(context).primaryColor
                          : isValid
                              ? Colors.green
                              : Colors.red,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_controller.text.isNotEmpty)
              isValid
                  ? const Icon(Icons.check, color: Colors.green, size: 24)
                  : const Icon(Icons.close, color: Colors.red, size: 24),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
