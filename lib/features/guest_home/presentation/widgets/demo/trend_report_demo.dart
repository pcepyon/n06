import 'package:flutter/material.dart';

import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/tracking/domain/entities/trend_insight.dart';
import 'package:n06/features/tracking/presentation/widgets/trend_insight_card.dart';
import 'package:n06/features/tracking/presentation/widgets/weekly_condition_chart.dart';

/// 트렌드 리포트 체험용 데모 위젯
///
/// 비로그인 사용자를 위한 하드코딩된 데모 데이터 표시
class TrendReportDemo extends StatelessWidget {
  const TrendReportDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '주간 트렌드 리포트',
                style: AppTypography.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '매주 당신의 여정을 한눈에 확인하고, AI가 분석한 인사이트를 받아보세요',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 트렌드 인사이트 카드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TrendInsightCard(
            insight: _demoTrendInsight,
          ),
        ),
        const SizedBox(height: 24),

        // 주간 컨디션 차트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '6개 영역별 컨디션',
                style: AppTypography.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '각 영역에서 "좋음"을 선택한 비율을 보여드려요',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
              const SizedBox(height: 16),
              WeeklyConditionChart(
                questionTrends: _demoQuestionTrends,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 인사이트 메시지
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 코치의 격려',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '꾸준히 기록하고 계시네요! 체중 감소와 함께 에너지 레벨도 개선되고 있어요. 이대로 잘 유지하시면 됩니다 💪',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 더미 트렌드 인사이트 데이터
final _demoTrendInsight = TrendInsight(
  period: TrendPeriod.weekly,
  dailyConditions: _demoDailyConditions,
  questionTrends: _demoQuestionTrends,
  patternInsight: const WeeklyPatternInsight(
    hasPostInjectionPattern: false,
    postInjectionInsight: null,
    topConcernArea: null,
    improvementArea: QuestionType.energy,
    recommendations: [
      '식사량이 줄어들었어도 영양소는 고르게 섭취하세요',
      '하루 8잔 이상의 물을 마시도록 노력하세요',
      '가벼운 산책으로 컨디션을 개선할 수 있어요',
    ],
  ),
  overallDirection: TrendDirection.improving,
  summaryMessage:
      '지난 주보다 전반적인 컨디션이 개선되고 있어요. 특히 에너지 레벨이 좋아지고 있네요! 식사와 수분 섭취를 꾸준히 유지하시면 더 좋은 결과를 보실 수 있을 거예요.',
  redFlagCount: 0,
  averageAppetiteScore: 72.5,
  consecutiveDays: 7,
  completionRate: 100.0,
);

/// 더미 일별 컨디션 데이터
final _demoDailyConditions = List.generate(7, (index) {
  final now = DateTime.now();
  final date = now.subtract(Duration(days: 6 - index));
  final scores = [65, 70, 72, 75, 78, 80, 82];

  return DailyConditionSummary(
    date: date,
    overallScore: scores[index],
    grade: _getGrade(scores[index]),
    hasRedFlag: false,
    hasCheckin: true,
    isPostInjection: index == 0 || index == 1,
  );
});

/// 더미 질문별 트렌드 데이터
final _demoQuestionTrends = [
  QuestionTrend(
    questionType: QuestionType.meal,
    label: '식사',
    averageScore: 85,
    direction: TrendDirection.stable,
    dailyStatuses: _generateDailyStatuses([80, 85, 85, 90, 85, 85, 90]),
  ),
  QuestionTrend(
    questionType: QuestionType.hydration,
    label: '수분',
    averageScore: 78,
    direction: TrendDirection.improving,
    dailyStatuses: _generateDailyStatuses([70, 75, 75, 80, 80, 85, 85]),
  ),
  QuestionTrend(
    questionType: QuestionType.giComfort,
    label: '속 편안함',
    averageScore: 72,
    direction: TrendDirection.stable,
    dailyStatuses: _generateDailyStatuses([70, 70, 75, 75, 70, 70, 75]),
  ),
  QuestionTrend(
    questionType: QuestionType.bowel,
    label: '배변',
    averageScore: 68,
    direction: TrendDirection.stable,
    dailyStatuses: _generateDailyStatuses([65, 70, 65, 70, 70, 65, 70]),
  ),
  QuestionTrend(
    questionType: QuestionType.energy,
    label: '에너지',
    averageScore: 82,
    direction: TrendDirection.improving,
    dailyStatuses: _generateDailyStatuses([70, 75, 80, 80, 85, 85, 90]),
  ),
  QuestionTrend(
    questionType: QuestionType.mood,
    label: '기분',
    averageScore: 88,
    direction: TrendDirection.improving,
    dailyStatuses: _generateDailyStatuses([80, 85, 85, 90, 90, 90, 95]),
  ),
];

/// 일별 상태 데이터 생성 헬퍼
List<DailyQuestionStatus> _generateDailyStatuses(List<int> scores) {
  final now = DateTime.now();
  return List.generate(7, (index) {
    final date = now.subtract(Duration(days: 6 - index));
    return DailyQuestionStatus(
      date: date,
      score: scores[index],
      noData: false,
    );
  });
}

/// 점수에 따른 등급 계산 헬퍼
ConditionGrade _getGrade(int score) {
  if (score >= 90) return ConditionGrade.excellent;
  if (score >= 70) return ConditionGrade.good;
  if (score >= 50) return ConditionGrade.fair;
  if (score >= 30) return ConditionGrade.poor;
  return ConditionGrade.bad;
}
