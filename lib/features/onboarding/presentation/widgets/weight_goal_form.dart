import 'package:flutter/material.dart';

/// 체중 및 목표 입력 폼
class WeightGoalForm extends StatefulWidget {
  final Function(double, double, int?) onDataChanged;
  final VoidCallback onNext;

  const WeightGoalForm({
    Key? key,
    required this.onDataChanged,
    required this.onNext,
  }) : super(key: key);

  @override
  State<WeightGoalForm> createState() => _WeightGoalFormState();
}

class _WeightGoalFormState extends State<WeightGoalForm> {
  late TextEditingController _currentWeightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _targetPeriodController;

  double? _currentWeight;
  double? _targetWeight;
  int? _targetPeriod;
  double? _weeklyGoal;
  bool _hasWarning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentWeightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _targetPeriodController = TextEditingController();

    _currentWeightController.addListener(_recalculate);
    _targetWeightController.addListener(_recalculate);
    _targetPeriodController.addListener(_recalculate);
  }

  void _recalculate() {
    _currentWeight =
        double.tryParse(_currentWeightController.text);
    _targetWeight =
        double.tryParse(_targetWeightController.text);
    _targetPeriod =
        int.tryParse(_targetPeriodController.text);

    setState(() {
      _errorMessage = null;
      _weeklyGoal = null;
      _hasWarning = false;

      if (_currentWeight == null || _targetWeight == null) {
        return;
      }

      if (_currentWeight! < 20 || _currentWeight! > 300) {
        _errorMessage = '현재 체중은 20kg 이상 300kg 이하여야 합니다.';
        return;
      }

      if (_targetWeight! < 20 || _targetWeight! > 300) {
        _errorMessage = '목표 체중은 20kg 이상 300kg 이하여야 합니다.';
        return;
      }

      if (_targetWeight! >= _currentWeight!) {
        _errorMessage = '목표 체중은 현재 체중보다 작아야 합니다.';
        return;
      }

      if (_targetPeriod != null && _targetPeriod! > 0) {
        _weeklyGoal = (_currentWeight! - _targetWeight!) / _targetPeriod!;
        _hasWarning = _weeklyGoal! > 1.0;
      }
    });

    widget.onDataChanged(_currentWeight ?? 0, _targetWeight ?? 0, _targetPeriod);
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _targetPeriodController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    return _currentWeight != null &&
        _targetWeight != null &&
        _errorMessage == null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '체중 및 목표 설정',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _currentWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '현재 체중 (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '목표 체중 (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetPeriodController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '목표 기간 (주, 선택)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            if (_weeklyGoal != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '주간 목표: ${_weeklyGoal!.toStringAsFixed(2)}kg/주',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ),
            if (_hasWarning)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠ 주간 목표가 1kg을 초과합니다. 안전한 목표를 권장합니다.',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed() ? widget.onNext : null,
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
