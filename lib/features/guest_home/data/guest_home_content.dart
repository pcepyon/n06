import 'package:n06/features/guest_home/domain/entities/evidence_card_data.dart';
import 'package:n06/features/guest_home/domain/entities/journey_phase_data.dart';
import 'package:n06/features/guest_home/domain/entities/app_feature_data.dart';
import 'package:n06/features/guest_home/domain/entities/symptom_preview_data.dart';

/// 비로그인 홈 화면 정적 콘텐츠 데이터
///
/// 카피라이팅 원칙:
/// - 사용자 중심 ("가비움이 ~해드려요" → "당신이 ~할 수 있어요")
/// - 혜택 중심 (기능 설명 → 사용자가 얻는 결과)
/// - 공감 → 희망 → 결과 약속 흐름
abstract final class GuestHomeContent {
  // ============================================
  // 섹션 1: 환영 메시지
  // ============================================

  /// 시간대별 인사 메시지 (공감 + 희망)
  static String getGreeting(int hour) {
    if (hour >= 6 && hour < 12) {
      return '오늘도 거울 앞에 서셨나요?';
    } else if (hour >= 12 && hour < 18) {
      return '오늘 하루, 어떠셨어요?';
    } else if (hour >= 18 && hour < 22) {
      return '하루를 마무리하며';
    } else {
      return '밤이 깊었네요';
    }
  }

  static const String welcomeMessage1 = '다이어트, 이번엔 다를 수 있어요.';
  static const String welcomeMessage2 = '의지가 아닌, 과학이 도와줄 거예요.';
  static const String welcomeMessage3 = '12주 후 달라진 나를 만나보세요.';

  // ============================================
  // 섹션 2: 과학적 근거
  // ============================================

  static const String evidenceSectionTitle = '당신의 몸이\n반응할 거예요';
  static const String evidenceSectionSubtitle =
      '전 세계 수만 명이 이미 경험한 변화입니다.';

  static const String evidenceFooterMessage =
      '2023 Science지 선정\n"올해의 과학적 돌파구"';

  static const String evidenceFooterSubtext = '이제, 당신 차례예요.';

  static const List<EvidenceCardData> evidenceCards = [
    EvidenceCardData(
      id: 'weight',
      icon: '⚖️',
      title: '체중이 줄어요',
      mainStat: '20~22',
      mainStatUnit: '%',
      subStat: '평균 체중 감소율',
      summary: '80kg라면, 16~18kg이 빠져요',
      description: '의지력 싸움이 아니에요. 뇌의 식욕 신호가 바뀌면서 '
          '자연스럽게 덜 먹게 됩니다. 2,500명 이상이 72주간 경험한 결과예요.',
      source: 'SURMOUNT-1, NEJM, 2022',
      sourceDetail: '2,539명 대상 72주 임상시험',
      sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/35658024/',
    ),
    EvidenceCardData(
      id: 'cardio',
      icon: '❤️',
      title: '심장이 건강해져요',
      mainStat: '20',
      mainStatUnit: '%',
      subStat: '심혈관 질환 위험 감소',
      summary: '살만 빠지는 게 아니에요',
      description: '혈압, 콜레스테롤, 혈관 염증까지. '
          '체중과 상관없이 심장 건강이 좋아집니다. FDA가 인정한 효과예요.',
      source: 'American College of Cardiology, 2024',
      sourceDetail: 'FDA 승인 대규모 임상',
      sourceUrl:
          'https://www.acc.org/Latest-in-Cardiology/Clinical-Trials/2023/11/09/15/04/select',
    ),
    EvidenceCardData(
      id: 'glucose',
      icon: '🩸',
      title: '혈당이 안정돼요',
      mainStat: '2.58',
      mainStatUnit: '%',
      subStat: '당화혈색소(HbA1c) 감소',
      summary: '97%가 목표 혈당에 도달했어요',
      description: '당뇨가 있거나 걱정되셨다면, 절반 이상이 "정상 혈당" 수준까지 도달했어요. '
          '체중 감량의 보너스가 아닌, 진짜 효과입니다.',
      source: 'SURPASS Trials, ADA',
      sourceDetail: '5개 대규모 임상 종합',
      sourceUrl:
          'https://diabetes.org/newsroom/latest-data-from-SURPASS-trials-demonstrate-tirzepatide-provided-blood-sugar-reductions-weight-loss',
    ),
    EvidenceCardData(
      id: 'metabolic',
      icon: '🔄',
      title: '몸 전체가 달라져요',
      mainStat: '30',
      mainStatUnit: '%p',
      subStat: '대사증후군 유병률 감소',
      summary: '뱃살, 혈압, 혈당이 함께 좋아져요',
      description: '따로따로 관리하느라 지치셨죠? '
          '이 치료는 복부비만, 혈압, 혈당, 중성지방을 한 번에 개선해요.',
      source: 'Cardiovascular Diabetology, 2024',
      sourceDetail: 'SURPASS-4 분석',
      sourceUrl:
          'https://cardiab.biomedcentral.com/articles/10.1186/s12933-024-02147-9',
    ),
    EvidenceCardData(
      id: 'brain',
      icon: '🧠',
      title: '뇌 건강까지 기대돼요',
      mainStat: '40~70',
      mainStatUnit: '%',
      subStat: '치매 위험 감소',
      summary: '체중 관리 그 이상의 가능성',
      description: '아직 연구 중이지만, 뇌의 GLP-1 수용체가 인지 기능 보호에 '
          '관여한다는 결과들이 나오고 있어요. 기대해볼 만해요.',
      source: "AAIC, Nature Medicine, 2025",
      sourceDetail: 'ELAD Phase 2b Trial',
      sourceUrl:
          'https://aaic.alz.org/releases-2024/glp-drug-liraglutide-may-protect-against-dementia.asp',
    ),
  ];

  // ============================================
  // 섹션 3: 치료 여정 미리보기
  // ============================================

  static const String journeySectionTitle = '12주 후,\n당신은 달라져 있을 거예요';
  static const String journeySectionSubtitle =
      '이런 변화를 경험하게 됩니다.';

  static const List<JourneyPhaseData> journeyPhases = [
    JourneyPhaseData(
      id: 'week1-2',
      title: '1~2주: 몸이 반응하기 시작해요',
      weekRange: '1-2주',
      shortLabel: '시작',
      description: '첫 주부터 달라지는 걸 느낄 거예요.',
      expectationsTitle: '💭 이런 변화가 찾아와요',
      expectations: [
        '배가 덜 고파져요',
        '조금만 먹어도 금방 배불러요',
        '간식 생각이 줄어들어요',
      ],
      encouragement:
          '"속이 좀 불편할 수 있어요. 걱정 마세요, 약이 일하고 있다는 신호예요."',
    ),
    JourneyPhaseData(
      id: 'week3-4',
      title: '3~4주: 체중계 숫자가 바뀌어요',
      weekRange: '3-4주',
      shortLabel: '변화',
      description: '거울 속 내가 달라 보이기 시작해요.',
      expectationsTitle: '💭 기대해도 좋아요',
      expectations: [
        '체중 3~5% 감소',
        '옷이 조금 헐렁해져요',
        '초반 불편함이 사라져요',
      ],
      encouragement: '"작은 변화도 기록해두세요. 나중에 보면 놀랄 거예요."',
    ),
    JourneyPhaseData(
      id: 'week5-8',
      title: '5~8주: 본격적으로 빠지기 시작해요',
      weekRange: '5-8주',
      shortLabel: '가속',
      description: '주변에서 "살 빠졌다"는 말을 듣기 시작해요.',
      expectationsTitle: '💭 이때가 중요해요',
      expectations: [
        '용량이 올라가면서 효과가 커져요',
        '식습관 자체가 바뀌어요',
        '에너지가 좋아지는 걸 느껴요',
      ],
      encouragement:
          '"용량 조절 시기예요. 스케줄 관리는 신경 쓰지 마세요."',
    ),
    JourneyPhaseData(
      id: 'week9-12',
      title: '9~12주: 새로운 내가 되어가요',
      weekRange: '9-12주',
      shortLabel: '변신',
      description: '예전 옷이 안 맞기 시작해요.',
      expectationsTitle: '💭 이 정도는 기대하세요',
      expectations: [
        '체중 10% 전후 감소',
        '혈압, 혈당 수치 개선',
        '먹는 것에 덜 집착하게 돼요',
      ],
      encouragement: '"12주, 당신은 해낸 거예요."',
    ),
    JourneyPhaseData(
      id: 'beyond',
      title: '그 이후: 계속 좋아져요',
      weekRange: '12주+',
      shortLabel: '지속',
      description: '12주는 시작이에요.\n1년 후엔 15~17% 감량과 심혈관 보호 효과까지.\n'
          '꾸준히 하면, 몸이 계속 달라져요.',
      expectationsTitle: '',
      expectations: [],
      encouragement: '"여기까지 온 당신, 이제 멈추지 마세요."',
    ),
  ];

  // ============================================
  // 섹션 4: 앱 기능 소개
  // ============================================

  static const String featuresSectionTitle = '치료에만 집중하세요';
  static const String featuresSectionSubtitle =
      '복잡한 건 신경 쓰지 않아도 돼요.';

  static const List<AppFeatureData> appFeatures = [
    AppFeatureData(
      id: 'schedule',
      icon: '📅',
      title: '다음 투여일, 잊어버려도 괜찮아요',
      summary: '알림이 오면 맞으면 돼요',
      description: '4주마다 용량 올리고, 매주 정확히 맞아야 하고... '
          '복잡한 계산은 맡겨두세요. 알림만 확인하면 됩니다.',
      encouragement: '헷갈려도 괜찮아요',
      relatedFeatureId: 'F001',
    ),
    AppFeatureData(
      id: 'record',
      icon: '📝',
      title: '3개월 후 달라진 나를 만나요',
      summary: '매일 30초, 변화가 눈에 보여요',
      description: '기록은 귀찮은 게 아니에요. '
          '나중에 그래프로 보면, 내가 얼마나 달라졌는지 실감하게 될 거예요.',
      encouragement: '작은 변화가 쌓여요',
      relatedFeatureId: 'F002',
    ),
    AppFeatureData(
      id: 'report',
      icon: '🏥',
      title: '진료실에서 말문이 막혀도 괜찮아요',
      summary: '그동안 어땠는지, 리포트가 대신 설명해요',
      description: '"최근에 어떠셨어요?" 갑자기 물어보면 뭐라고 해야 할지 모르겠죠? '
          '자동으로 정리된 리포트를 보여주세요.',
      encouragement: '짧은 진료 시간, 알차게',
      relatedFeatureId: 'F003',
    ),
    AppFeatureData(
      id: 'guide',
      icon: '💊',
      title: '속이 불편해도 당황하지 마세요',
      summary: '뭘 해야 하는지 바로 알려드려요',
      description: '메스꺼움, 변비는 흔한 적응 반응이에요. '
          '증상을 누르면, 지금 당장 할 수 있는 대처법이 나와요.',
      encouragement: '다 지나가는 과정이에요',
      relatedFeatureId: 'F004',
    ),
    AppFeatureData(
      id: 'safety',
      icon: '🚨',
      title: '혼자 걱정하지 않아도 돼요',
      summary: '위험 신호는 바로 알려드려요',
      description: '대부분은 시간이 지나면 괜찮아져요. '
          '하지만 드물게 병원에 가야 할 때가 있어요. 그때 바로 알려드릴게요.',
      encouragement: '함께 지켜보고 있어요',
      relatedFeatureId: 'F005',
    ),
  ];

  // ============================================
  // 섹션 5: 부작용 대처 가이드 미리보기
  // ============================================

  static const String symptomsSectionTitle = '이런 증상, 겁먹지 마세요';
  static const String symptomsSectionSubtitle = '대부분 일시적이고, 대처법이 있어요.';

  static const List<SymptomPreviewData> symptomPreviews = [
    SymptomPreviewData(
      id: 'nausea',
      icon: '😣',
      name: '메스꺼움',
      shortDescription: '10명 중 6명이 겪어요.\n1~2주면 괜찮아져요.',
      fullDescription: '가장 흔한 반응이에요. 약이 일하고 있다는 증거예요.',
      tips: [
        '조금씩 천천히 드세요',
        '기름진 건 피하세요',
        '식후 바로 눕지 마세요',
        '생강차가 도움 돼요',
      ],
      recoveryInfo: '90%가 2주 내 좋아져요',
      frequencyPercent: 0.6,
      recoveryTime: '1~2주',
    ),
    SymptomPreviewData(
      id: 'constipation',
      icon: '🚽',
      name: '변비',
      shortDescription: '장이 느려질 수 있어요.\n물 많이 마시면 좋아져요.',
      fullDescription: '장 운동이 느려지면서 생겨요. 수분과 섬유질이 답이에요.',
      tips: [
        '물 많이 드세요 (하루 2L)',
        '채소 챙겨 드세요',
        '가볍게 걸으세요',
        '규칙적인 습관을 유지하세요',
      ],
      recoveryInfo: '습관만 바꿔도 좋아져요',
      frequencyPercent: 0.4,
      recoveryTime: '2~3주',
    ),
    SymptomPreviewData(
      id: 'appetite',
      icon: '🍽️',
      name: '식욕 감소',
      shortDescription: '이게 바로 효과예요.\n덜 먹게 되는 거죠.',
      fullDescription: '걱정하지 마세요, 이게 약이 하는 일이에요. '
          '배가 덜 고프고, 적게 먹어도 충분해요.',
      tips: [
        '영양가 높은 걸 드세요',
        '단백질 먼저 챙기세요',
        '조금씩 자주 드세요',
        '물은 꼭 챙기세요',
      ],
      recoveryInfo: '이게 치료 효과예요',
      frequencyPercent: 0.7,
      recoveryTime: '지속',
    ),
    SymptomPreviewData(
      id: 'fatigue',
      icon: '😴',
      name: '피로감',
      shortDescription: '덜 먹으니 처음엔 좀 힘들 수 있어요.\n몸이 적응하면 괜찮아져요.',
      fullDescription: '칼로리가 줄면서 처음엔 피곤할 수 있어요. '
          '몸이 새로운 에너지 균형에 적응하는 중이에요.',
      tips: [
        '충분히 주무세요 (7-8시간)',
        '단백질은 꼭 드세요',
        '가볍게 움직이세요',
        '카페인은 적당히만',
      ],
      recoveryInfo: '2~4주면 적응돼요',
      frequencyPercent: 0.35,
      recoveryTime: '2~4주',
    ),
  ];

  // ============================================
  // 섹션 6: CTA
  // ============================================

  static const String ctaTitle = '12주 후,\n거울 속 나를 기대해 보세요';
  static const String ctaDescription = '첫 번째 변화는 생각보다 빨리 찾아와요.';
  static const String ctaPrimaryButton = '지금 시작하기';
  static const String ctaSecondaryButton = '증상 대처법 더 보기';
  static const String ctaFooterMessage = '여기까지 읽은 당신, 이미 한 걸음 내딛었어요.';
}
