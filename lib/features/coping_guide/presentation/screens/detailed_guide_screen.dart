import 'package:flutter/material.dart';

import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import '../../domain/entities/coping_guide.dart';

/// 상세 가이드 화면
class DetailedGuideScreen extends StatelessWidget {
  final CopingGuide guide;

  const DetailedGuideScreen({required this.guide, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar with Gabium Design System styling
          SliverAppBar(
            floating: true,
            snap: false,
            elevation: 0,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            centerTitle: true,
            title: Text(
              context.l10n.coping_detailed_appTitle,
              style: AppTypography.heading2,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: context.l10n.coping_detailed_backTooltip,
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: AppColors.border,
                thickness: 1,
              ),
            ),
          ),

          // Main content in SliverList
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, // md padding
                  vertical: 32.0, // xl padding top
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Card (Symptom Name)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.educationBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: const Border(
                          left: BorderSide(
                            color: AppColors.education,
                            width: 4.0,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 2.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        guide.symptomName,
                        style: AppTypography.heading2.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0), // lg spacing

                    // Section Cards
                    if (guide.detailedSections != null &&
                        guide.detailedSections!.isNotEmpty)
                      ...guide.detailedSections!.map((section) {
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 2.0,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Section Title with top border
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColors.education,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(top: 8.0),
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      section.title,
                                      style: AppTypography.heading3.copyWith(
                                        height: 26 / 18,
                                      ),
                                    ),
                                  ),

                                  // Section Content (Body Text)
                                  SelectableText(
                                    section.content,
                                    style: AppTypography.bodyMedium.copyWith(
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24.0,
                            ), // lg spacing between cards
                          ],
                        );
                      }),

                    // Bottom padding
                    const SizedBox(height: 32.0), // xl bottom padding
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
