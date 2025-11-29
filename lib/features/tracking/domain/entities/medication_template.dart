/// Medication template for predefined GLP-1 medications
///
/// Provides:
/// - Standard dose options
/// - Recommended starting dose
/// - Standard cycle days
///
/// Usage:
/// ```dart
/// final wegovy = MedicationTemplate.wegovy;
/// final doses = wegovy.availableDoses; // [0.25, 0.5, 1.0, 1.7, 2.4]
/// ```
class MedicationTemplate {
  final String displayName;
  final List<double> availableDoses;
  final double recommendedStartDose;
  final int standardCycleDays;

  const MedicationTemplate({
    required this.displayName,
    required this.availableDoses,
    required this.recommendedStartDose,
    required this.standardCycleDays,
  });

  /// Wegovy (Semaglutide) template
  ///
  /// Source: FDA Wegovy Prescribing Information (08/2025)
  /// https://www.accessdata.fda.gov/drugsatfda_docs/label/2025/215256s024lbl.pdf
  ///
  /// 용량 적정 스케줄 (각 단계 4주, 총 16주):
  /// 0.25mg → 0.5mg → 1.0mg → 1.7mg → 2.4mg (유지용량)
  /// Recommended start dose: 0.25mg
  static const wegovy = MedicationTemplate(
    displayName: 'Wegovy (세마글루타이드)',
    availableDoses: [0.25, 0.5, 1.0, 1.7, 2.4],
    recommendedStartDose: 0.25,
    standardCycleDays: 7, // Weekly injection
  );

  /// Mounjaro (Tirzepatide) template
  ///
  /// Source: FDA Mounjaro Prescribing Information (05/2025)
  ///
  /// Available doses: 2.5mg, 5.0mg, 7.5mg, 10.0mg, 12.5mg, 15.0mg
  /// Recommended start dose: 2.5mg
  static const mounjaro = MedicationTemplate(
    displayName: 'Mounjaro (티르제파타이드)',
    availableDoses: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0],
    recommendedStartDose: 2.5,
    standardCycleDays: 7, // Weekly injection
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
