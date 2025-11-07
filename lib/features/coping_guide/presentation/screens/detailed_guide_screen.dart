import 'package:flutter/material.dart';

import '../../domain/entities/coping_guide.dart';

/// 상세 가이드 화면
class DetailedGuideScreen extends StatelessWidget {
  final CopingGuide guide;

  const DetailedGuideScreen({required this.guide, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${guide.symptomName} 대처 가이드'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              guide.symptomName,
              style: Theme.of(context).textTheme.headlineSmall,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      section.content,
                      style: Theme.of(context).textTheme.bodyMedium,
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
