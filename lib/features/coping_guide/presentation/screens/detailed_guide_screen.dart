import 'package:flutter/material.dart';
import 'package:n06/core/theme/app_text_styles.dart';

import '../../domain/entities/coping_guide.dart';

/// 상세 가이드 화면
class DetailedGuideScreen extends StatelessWidget {
  final CopingGuide guide;

  const DetailedGuideScreen({required this.guide, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${guide.symptomName} 대처 가이드', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              guide.symptomName,
              style: AppTextStyles.h2,
            ),
            SizedBox(height: 16),
            if (guide.detailedSections != null &&
                guide.detailedSections!.isNotEmpty)
              ...guide.detailedSections!.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: AppTextStyles.h3,
                    ),
                    SizedBox(height: 8),
                    Text(
                      section.content,
                      style: AppTextStyles.body1,
                    ),
                    SizedBox(height: 24),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}
