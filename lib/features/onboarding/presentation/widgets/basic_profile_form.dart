import 'package:flutter/material.dart';

/// 기본 프로필(이름) 입력 폼
class BasicProfileForm extends StatefulWidget {
  final Function(String) onNameChanged;
  final VoidCallback onNext;

  const BasicProfileForm({super.key, required this.onNameChanged, required this.onNext});

  @override
  State<BasicProfileForm> createState() => _BasicProfileFormState();
}

class _BasicProfileFormState extends State<BasicProfileForm> {
  late TextEditingController _nameController;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(_validateName);
  }

  void _validateName() {
    final isValid = _nameController.text.trim().isNotEmpty;
    setState(() {
      _isNameValid = isValid;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('이름을 입력해주세요', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '성명',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorText: _nameController.text.isEmpty && _nameController.text.isNotEmpty
                  ? '이름을 입력해주세요'
                  : null,
            ),
            onChanged: (value) {
              widget.onNameChanged(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isNameValid ? widget.onNext : null,
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}
