import 'package:flutter/material.dart';

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
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B), // Neutral-800
            centerTitle: true,
            title: const Text(
              '가비움',
              style: TextStyle(
                fontSize: 20, // xl size
                fontWeight: FontWeight.bold, // 700
                color: Color(0xFF1E293B), // Neutral-800
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: '뒤로가기',
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: Color(0xFFE2E8F0), // Neutral-200
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
                        color: const Color(0xFFF8FAFC), // Neutral-50
                        borderRadius: BorderRadius.circular(12.0), // md radius
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFF4ADE80), // Primary
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
                      padding: const EdgeInsets.all(16.0), // md padding
                      child: Text(
                        guide.symptomName,
                        style: const TextStyle(
                          fontSize: 20, // xl size
                          fontWeight: FontWeight.bold, // 700
                          color: Color(0xFF1E293B), // Neutral-800
                          height: 28 / 20, // xl line height
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
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12.0), // md
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0), // Neutral-200
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
                              padding: const EdgeInsets.all(16.0), // md padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Section Title with top border
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Color(0xFF4ADE80), // Primary
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    padding:
                                        const EdgeInsets.only(top: 8.0), // sm
                                    margin: const EdgeInsets.only(
                                      bottom: 8.0,
                                    ), // sm
                                    child: Text(
                                      section.title,
                                      style: const TextStyle(
                                        fontSize: 18, // lg size
                                        fontWeight:
                                            FontWeight.w600, // Semibold
                                        color: Color(0xFF1E293B), // Neutral-800
                                        height: 26 / 18, // lg line height
                                      ),
                                    ),
                                  ),

                                  // Section Content (Body Text)
                                  SelectableText(
                                    section.content,
                                    style: const TextStyle(
                                      fontSize: 16, // base size
                                      fontWeight: FontWeight.normal, // 400
                                      color: Color(0xFF475569), // Neutral-600
                                      height: 1.5, // Explicit line height
                                      letterSpacing: 0,
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
