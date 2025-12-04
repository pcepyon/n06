import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/application/providers.dart';

class DoseEditDialog extends ConsumerStatefulWidget {
  final DoseRecord currentRecord;
  final String userId;
  final VoidCallback? onSaveSuccess;

  const DoseEditDialog({
    super.key,
    required this.currentRecord,
    required this.userId,
    this.onSaveSuccess,
  });

  @override
  ConsumerState<DoseEditDialog> createState() => _DoseEditDialogState();
}

class _DoseEditDialogState extends ConsumerState<DoseEditDialog> {
  late TextEditingController _doseController;
  late String? _selectedSite;
  late TextEditingController _noteController;
  String? _errorMessage;
  bool _isLoading = false;

  // Map database values to localized keys
  String _getLocalizedSite(BuildContext context, String? dbSite) {
    if (dbSite == null) return '';
    switch (dbSite) {
      case '복부':
        return context.l10n.tracking_editDialog_siteAbdomen;
      case '허벅지':
        return context.l10n.tracking_editDialog_siteThigh;
      case '상완':
        return context.l10n.tracking_editDialog_siteArm;
      default:
        return dbSite;
    }
  }

  // Map localized values back to database format
  String _getDbSite(BuildContext context, String localizedSite) {
    if (localizedSite == context.l10n.tracking_editDialog_siteAbdomen) return '복부';
    if (localizedSite == context.l10n.tracking_editDialog_siteThigh) return '허벅지';
    if (localizedSite == context.l10n.tracking_editDialog_siteArm) return '상완';
    return localizedSite;
  }

  @override
  void initState() {
    super.initState();
    _doseController = TextEditingController(text: widget.currentRecord.actualDoseMg.toString());
    _selectedSite = null; // Will be set in didChangeDependencies
    _noteController = TextEditingController(text: widget.currentRecord.note ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedSite == null && widget.currentRecord.injectionSite != null) {
      _selectedSite = _getLocalizedSite(context, widget.currentRecord.injectionSite);
    }
  }

  @override
  void dispose() {
    _doseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validateDose(String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.isEmpty) return;

    try {
      final dose = double.parse(value);
      if (dose <= 0) {
        setState(() {
          _errorMessage = context.l10n.tracking_editDialog_errorDosePositive;
        });
      }
    } on FormatException {
      setState(() {
        _errorMessage = context.l10n.tracking_editDialog_errorNumberRequired;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_errorMessage != null || _doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? context.l10n.tracking_editDialog_errorInvalidValue), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedSite == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tracking_editDialog_errorSiteRequired), backgroundColor: Colors.red));
      return;
    }

    final newDose = double.parse(_doseController.text);

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(doseRecordEditNotifierProvider.notifier);
      await notifier.updateDoseRecord(
        recordId: widget.currentRecord.id,
        newDoseMg: newDose,
        injectionSite: _getDbSite(context, _selectedSite!),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        userId: widget.userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tracking_editDialog_saveSuccess), backgroundColor: Colors.green),
        );
        widget.onSaveSuccess?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tracking_editDialog_saveFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.tracking_editDialog_title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // 투여량 입력
              Text(context.l10n.tracking_editDialog_doseLabel, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _doseController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: _validateDose,
                decoration: InputDecoration(
                  hintText: context.l10n.tracking_editDialog_doseHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  errorText: _errorMessage,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              // 투여 부위 선택
              Text(context.l10n.tracking_editDialog_siteLabel, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedSite,
                isExpanded: true,
                hint: Text(context.l10n.tracking_editDialog_siteHint),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSite = newValue;
                  });
                },
                items: [
                  DropdownMenuItem<String>(value: context.l10n.tracking_editDialog_siteAbdomen, child: Text(context.l10n.tracking_editDialog_siteAbdomen)),
                  DropdownMenuItem<String>(value: context.l10n.tracking_editDialog_siteThigh, child: Text(context.l10n.tracking_editDialog_siteThigh)),
                  DropdownMenuItem<String>(value: context.l10n.tracking_editDialog_siteArm, child: Text(context.l10n.tracking_editDialog_siteArm)),
                ],
              ),
              const SizedBox(height: 24),
              // 메모
              Text(context.l10n.tracking_editDialog_noteLabel, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.l10n.tracking_editDialog_noteHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              // 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(context.l10n.common_button_cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_isLoading || _errorMessage != null || _selectedSite == null)
                        ? null
                        : _saveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.common_button_save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
