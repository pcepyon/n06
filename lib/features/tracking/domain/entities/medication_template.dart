import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

/// Medication template for predefined GLP-1 medications
///
/// Provides:
/// - Standard dose options
/// - Recommended starting dose
/// - Standard cycle days
/// - Standard escalation plan (FDA/MFDS approved)
///
/// Usage:
/// ```dart
/// final wegovy = MedicationTemplate.wegovy;
/// final doses = wegovy.availableDoses; // [0.25, 0.5, 1.0, 1.7, 2.4, 7.2]
/// ```
class MedicationTemplate {
  final String displayName;
  final List<double> availableDoses;
  final double recommendedStartDose;
  final int standardCycleDays;
  final List<EscalationStep> standardEscalation;

  const MedicationTemplate({
    required this.displayName,
    required this.availableDoses,
    required this.recommendedStartDose,
    required this.standardCycleDays,
    required this.standardEscalation,
  });

  /// Wegovy (Semaglutide) template
  ///
  /// Source: FDA Wegovy Prescribing Information (08/2025)
  /// https://www.accessdata.fda.gov/drugsatfda_docs/label/2025/215256s024lbl.pdf
  ///
  /// Dosage escalation:
  /// - Start: 0.25mg (4 weeks)
  /// - 0.5mg (4 weeks)
  /// - 1.0mg (4 weeks)
  /// - 1.7mg (4 weeks)
  /// - Maintenance: 2.4mg
  /// - High dose: 7.2mg (approved 2025)
  static const wegovy = MedicationTemplate(
    displayName: 'Wegovy (세마글루타이드)',
    availableDoses: [0.25, 0.5, 1.0, 1.7, 2.4, 7.2],
    recommendedStartDose: 0.25,
    standardCycleDays: 7, // Weekly injection
    standardEscalation: [
      EscalationStep(weeksFromStart: 4, doseMg: 0.5),
      EscalationStep(weeksFromStart: 8, doseMg: 1.0),
      EscalationStep(weeksFromStart: 12, doseMg: 1.7),
      EscalationStep(weeksFromStart: 16, doseMg: 2.4),
    ],
  );

  /// Mounjaro (Tirzepatide) template
  ///
  /// Source: FDA Mounjaro Prescribing Information (05/2025)
  ///
  /// Dosage escalation:
  /// - Start: 2.5mg (4 weeks minimum)
  /// - 5mg (4 weeks minimum)
  /// - 7.5mg (4 weeks minimum)
  /// - 10mg (4 weeks minimum)
  /// - 12.5mg (4 weeks minimum)
  /// - Maximum: 15mg
  static const mounjaro = MedicationTemplate(
    displayName: 'Mounjaro (티르제파타이드)',
    availableDoses: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0],
    recommendedStartDose: 2.5,
    standardCycleDays: 7, // Weekly injection
    standardEscalation: [
      EscalationStep(weeksFromStart: 4, doseMg: 5.0),
      EscalationStep(weeksFromStart: 8, doseMg: 7.5),
      EscalationStep(weeksFromStart: 12, doseMg: 10.0),
      EscalationStep(weeksFromStart: 16, doseMg: 12.5),
      EscalationStep(weeksFromStart: 20, doseMg: 15.0),
    ],
  );

  /// All available medication templates
  static const all = [wegovy, mounjaro];

  /// Find template by exact display name match
  ///
  /// Returns null if not found.
  static MedicationTemplate? findByName(String name) {
    try {
      return all.firstWhere((t) => t.displayName == name);
    } catch (_) {
      return null;
    }
  }

  /// Check if a dose is valid for this medication
  bool isValidDose(double dose) {
    return availableDoses.contains(dose);
  }
}
