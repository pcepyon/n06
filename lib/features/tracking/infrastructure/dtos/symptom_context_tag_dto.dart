import 'package:isar/isar.dart';

part 'symptom_context_tag_dto.g.dart';

@collection
class SymptomContextTagDto {
  Id id = Isar.autoIncrement;
  late int symptomLogIsarId;
  late String tagName;

  SymptomContextTagDto();

  @override
  String toString() => 'SymptomContextTagDto(id: $id, symptomLogIsarId: $symptomLogIsarId, tagName: $tagName)';
}
