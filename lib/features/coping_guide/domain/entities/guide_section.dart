import 'package:flutter/foundation.dart';

/// 상세 가이드 섹션 (제목과 내용)
@immutable
class GuideSection {
  final String title;
  final String content;

  const GuideSection({
    required this.title,
    required this.content,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuideSection &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          content == other.content;

  @override
  int get hashCode => title.hashCode ^ content.hashCode;

  @override
  String toString() => 'GuideSection(title: $title, content: $content)';
}
