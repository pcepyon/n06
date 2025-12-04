/// Report section types for i18n mapping
///
/// Application layer returns these types with dynamic data.
/// Presentation layer maps them to localized strings.
enum ReportSectionType {
  // Text report sections
  header,
  patientInfo,
  mainMetrics,
  symptomOccurrences,
  redFlagRecords,
  conditionTrend,

  // Helper sections (not displayed directly)
  weightSummary,
  appetiteSummary,
  checkinAchievement,
}

/// Appetite stability values (data-only, no localization)
enum AppetiteStability {
  stable,
  improving,
  declining,
}

/// Weight change direction (data-only, no localization)
enum WeightChangeDirection {
  increased,
  decreased,
  maintained,
}
