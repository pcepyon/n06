/// Supabase DTO for SymptomContextTag entity.
///
/// Stores symptom context tags in Supabase database.
class SymptomContextTagDto {
  final String id;
  final String symptomLogId;
  final String tagName;

  const SymptomContextTagDto({
    required this.id,
    required this.symptomLogId,
    required this.tagName,
  });

  /// Creates DTO from Supabase JSON.
  factory SymptomContextTagDto.fromJson(Map<String, dynamic> json) {
    return SymptomContextTagDto(
      id: json['id'] as String,
      symptomLogId: json['symptom_log_id'] as String,
      tagName: json['tag_name'] as String,
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symptom_log_id': symptomLogId,
      'tag_name': tagName,
    };
  }

  @override
  String toString() =>
      'SymptomContextTagDto(id: $id, symptomLogId: $symptomLogId, tagName: $tagName)';
}
