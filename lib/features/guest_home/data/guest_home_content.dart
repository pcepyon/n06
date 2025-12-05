import 'package:n06/features/guest_home/domain/entities/evidence_card_data.dart';
import 'package:n06/features/guest_home/domain/entities/journey_phase_data.dart';
import 'package:n06/features/guest_home/domain/entities/app_feature_data.dart';
import 'package:n06/features/guest_home/domain/entities/symptom_preview_data.dart';

/// 비로그인 홈 화면 정적 콘텐츠 데이터
abstract final class GuestHomeContent {
  // ============================================
  // 섹션 1: 환영 메시지
  // ============================================

  /// 시간대별 인사 메시지
  static String getGreeting(int hour) {
    if (hour >= 6 && hour < 12) {
      return '좋은 아침이에요 ☀️';
    } else if (hour >= 12 && hour < 18) {
      return '오늘 하루도 잘 보내고 계신가요?';
    } else if (hour >= 18 && hour < 22) {
      return '오늘 하루 수고 많으셨어요';
    } else {
      return '편안한 밤 되세요';
    }
  }

  static const String welcomeMessage1 = '건강한 변화를 시작하려는 당신,';
  static const String welcomeMessage2 = '이미 용기 있는 첫 걸음을 내딛고 계세요.';
  static const String welcomeMessage3 = '가비움이 그 여정에 함께할게요.';

  // ============================================
  // 섹션 2: 과학적 근거
  // ============================================

  static const String evidenceSectionTitle = '과학이 증명한\n혁신적인 치료';
  static const String evidenceSectionSubtitle =
      '전 세계 대규모 임상시험이 입증한 효과입니다.';

  static const String evidenceFooterMessage =
      '2023년 Science지 선정\n"올해의 과학적 돌파구"';

  static const String evidenceFooterSubtext = '검증된 치료, 이제 잘 사용하는 것이 중요해요.';

  static const List<EvidenceCardData> evidenceCards = [
    EvidenceCardData(
      id: 'weight',
      icon: '⚖️',
      title: '체중 감소',
      mainStat: '20~22',
      mainStatUnit: '%',
      subStat: '평균 체중 감소율',
      summary: '80kg 기준 약 16~18kg 감소 효과',
      description: '기존 다이어트 약물 대비 47% 더 높은 감량 효과입니다. '
          'GIP+GLP-1 이중 작용으로 식욕 조절과 대사 개선을 동시에 돕습니다.',
      source: 'SURMOUNT-1, NEJM, 2022',
      sourceDetail: '2,539명 대상 72주 임상시험',
      sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/35658024/',
    ),
    EvidenceCardData(
      id: 'cardio',
      icon: '❤️',
      title: '심혈관 보호',
      mainStat: '20',
      mainStatUnit: '%',
      subStat: '심혈관 질환 위험 감소',
      summary: 'FDA가 공인한 최초의 비만 치료제 심혈관 보호 효과',
      description: '체중 감소와 별개로, 혈관 염증 감소, 혈압 개선, 콜레스테롤 조절 등 '
          '심장 건강에 직접적인 보호 효과를 제공합니다.',
      source: 'American College of Cardiology, 2024',
      sourceDetail: 'FDA 승인 대규모 임상',
      sourceUrl:
          'https://www.acc.org/Latest-in-Cardiology/Clinical-Trials/2023/11/09/15/04/select',
    ),
    EvidenceCardData(
      id: 'glucose',
      icon: '🩸',
      title: '혈당 개선',
      mainStat: '2.58',
      mainStatUnit: '%',
      subStat: '당화혈색소(HbA1c) 감소',
      summary: '참여자 97%가 목표 혈당(7% 미만) 달성',
      description: '참여자의 48~62%가 당화혈색소 5.7% 미만, 즉 "정상 혈당" 수준에 도달했습니다. '
          '당뇨가 있거나 당뇨 전단계라면 큰 도움이 됩니다.',
      source: 'SURPASS Trials, ADA',
      sourceDetail: '5개 대규모 임상 종합',
      sourceUrl:
          'https://diabetes.org/newsroom/latest-data-from-SURPASS-trials-demonstrate-tirzepatide-provided-blood-sugar-reductions-weight-loss',
    ),
    EvidenceCardData(
      id: 'metabolic',
      icon: '🔄',
      title: '대사증후군 개선',
      mainStat: '30',
      mainStatUnit: '%p',
      subStat: '대사증후군 유병률 감소',
      summary: '복부비만, 혈압, 혈당, 지질 동시 개선',
      description: '복부 지방, 혈압, 혈당, 인슐린 저항성, 중성지방을 동시에 개선합니다. '
          '대사증후군은 심혈관 질환과 당뇨의 주요 위험 요인입니다.',
      source: 'Cardiovascular Diabetology, 2024',
      sourceDetail: 'SURPASS-4 분석',
      sourceUrl:
          'https://cardiab.biomedcentral.com/articles/10.1186/s12933-024-02147-9',
    ),
    EvidenceCardData(
      id: 'brain',
      icon: '🧠',
      title: '뇌 건강 보호',
      mainStat: '40~70',
      mainStatUnit: '%',
      subStat: '치매 위험 감소',
      summary: '뇌 위축 50% 감소, 인지 기능 저하 18% 지연',
      description: 'GLP-1 수용체는 뇌의 해마에도 존재합니다. 연구 진행 중이지만, '
          '체중 관리를 넘어 뇌 건강까지 기대할 수 있습니다.',
      source: "AAIC, Nature Medicine, 2025",
      sourceDetail: 'ELAD Phase 2b Trial',
      sourceUrl:
          'https://aaic.alz.org/releases-2024/glp-drug-liraglutide-may-protect-against-dementia.asp',
    ),
  ];

  // ============================================
  // 섹션 3: 치료 여정 미리보기
  // ============================================

  static const String journeySectionTitle = '12주 치료 여정\n미리 보기';
  static const String journeySectionSubtitle =
      '낮은 용량에서 시작해 점차 높여갑니다.';

  static const List<JourneyPhaseData> journeyPhases = [
    JourneyPhaseData(
      id: 'week1-2',
      title: '1~2주차: 적응의 시작',
      weekRange: '1-2주',
      shortLabel: '적응',
      description: '몸이 새로운 신호에 적응하는 시간이에요.',
      expectationsTitle: '💭 이런 느낌이 들 수 있어요',
      expectations: [
        '식사량이 자연스럽게 줄어드는 느낌',
        '가벼운 메스꺼움이나 더부룩함',
        '평소보다 빨리 포만감을 느낌',
      ],
      encouragement:
          '"이 증상들은 약이 제대로 작용하고 있다는 신호예요. 보통 1~2주 내에 나아져요."',
    ),
    JourneyPhaseData(
      id: 'week3-4',
      title: '3~4주차: 첫 번째 변화',
      weekRange: '3-4주',
      shortLabel: '변화',
      description: '많은 분들이 첫 번째 의미 있는 변화를 느끼는 시점.',
      expectationsTitle: '💭 기대할 수 있는 변화',
      expectations: [
        '체중 감소 시작 (평균 3~5% 전후)',
        '식욕 조절이 한결 수월해짐',
        '초기 적응 증상이 줄어듦',
        '혈당 수치 개선 (해당 시)',
      ],
      encouragement: '"작은 변화도 큰 의미가 있어요. 꾸준히 기록하면 변화가 더 잘 보여요."',
    ),
    JourneyPhaseData(
      id: 'week5-8',
      title: '5~8주차: 용량 조절기',
      weekRange: '5-8주',
      shortLabel: '조절',
      description: '의료진과 상담하며 적정 용량을 찾아가는 시기.',
      expectationsTitle: '💭 이 시기에 중요한 것',
      expectations: [
        '정해진 일정에 맞춰 투여하기',
        '증상 변화를 꼼꼼히 기록하기',
        '용량 변경 시 몸의 반응 관찰하기',
      ],
      encouragement:
          '"용량이 바뀌면 처음처럼 적응 기간이 필요해요. 가비움이 스케줄을 자동으로 관리해 드릴게요."',
    ),
    JourneyPhaseData(
      id: 'week9-12',
      title: '9~12주차: 안정기 진입',
      weekRange: '9-12주',
      shortLabel: '안정',
      description: '몸이 치료에 잘 적응하고, 효과가 본격적으로 나타나요.',
      expectationsTitle: '💭 기대할 수 있는 결과',
      expectations: [
        '체중 감소 10% 전후 도달',
        '적응 증상 대부분 해소',
        '새로운 식습관이 자연스러워짐',
        '혈압, 혈당 등 건강 지표 개선',
      ],
      encouragement: '"여기까지 오신 것만으로도 대단해요! 앞으로의 여정도 함께할게요."',
    ),
    JourneyPhaseData(
      id: 'beyond',
      title: '그 이후: 지속적인 건강 관리',
      weekRange: '12주+',
      shortLabel: '지속',
      description: '12주는 시작일 뿐이에요.\nGLP-1 치료의 진정한 효과는 꾸준한 사용에서 나와요.\n\n'
          '임상시험에서 68주(약 1년 4개월) 치료 시\n'
          '15~17%의 체중 감소와 심혈관 보호 효과가\n'
          '확인되었습니다.',
      expectationsTitle: '',
      expectations: [],
      encouragement: '"긴 여정이지만, 혼자가 아니에요. 가비움이 매일 함께할게요."',
    ),
  ];

  // ============================================
  // 섹션 4: 앱 기능 소개
  // ============================================

  static const String featuresSectionTitle = '효과적인 치료를 위한\n스마트한 도우미';
  static const String featuresSectionSubtitle =
      '스케줄, 용량, 증상 관리를 가비움이 도와드려요.';

  static const List<AppFeatureData> appFeatures = [
    AppFeatureData(
      id: 'schedule',
      icon: '📅',
      title: '투여 스케줄 자동 관리',
      summary: '용량 계산과 투여일 알림을 자동으로',
      description: 'GLP-1 치료는 4주마다 용량을 올리고, 주 1회 정확한 날짜에 투여해야 해요. '
          '가비움이 자동으로 계산하고 알림을 보내드려요.',
      encouragement: '처음엔 누구나 헷갈려요',
      relatedFeatureId: 'F001',
    ),
    AppFeatureData(
      id: 'record',
      icon: '📝',
      title: '간편 기록',
      summary: '체중, 증상, 기분을 30초 만에',
      description: '귀찮은 기록이 아니라, 나의 변화를 눈으로 확인하는 시간이에요.',
      encouragement: '작은 변화도 의미 있어요',
      relatedFeatureId: 'F002',
    ),
    AppFeatureData(
      id: 'report',
      icon: '🏥',
      title: '진료 리포트',
      summary: '자동 정리된 기록을 의료진에게',
      description: '진료실에서 갑자기 물어봐도 걱정 없어요. '
          '가비움이 자동으로 정리한 리포트로 짧은 진료 시간을 더 효과적으로 쓸 수 있어요.',
      encouragement: '기록이 상담을 효과적으로 만들어요',
      relatedFeatureId: 'F003',
    ),
    AppFeatureData(
      id: 'guide',
      icon: '💊',
      title: '증상 대처 가이드',
      summary: '불편한 증상에 맞춤 대처법 제공',
      description: '메스꺼움, 변비 등은 몸이 적응하는 자연스러운 반응이에요. '
          '증상을 기록하면 의학적 근거에 기반한 대처법을 바로 알려드려요.',
      encouragement: '적응 과정이에요, 괜찮아요',
      relatedFeatureId: 'F004',
    ),
    AppFeatureData(
      id: 'safety',
      icon: '🚨',
      title: '안전 알림',
      summary: '주의가 필요한 상황을 빠르게 감지',
      description: '대부분의 증상은 시간이 지나면 나아지지만, '
          '드물게 전문가 상담이 필요한 경우도 있어요. 가비움이 함께 지켜보고 있어요.',
      encouragement: '당신의 안전이 가장 중요해요',
      relatedFeatureId: 'F005',
    ),
  ];

  // ============================================
  // 섹션 5: 부작용 대처 가이드 미리보기
  // ============================================

  static const String symptomsSectionTitle = '흔한 증상과 대처법';
  static const String symptomsSectionSubtitle = '미리 알아두면 덜 불안해요.';

  static const List<SymptomPreviewData> symptomPreviews = [
    SymptomPreviewData(
      id: 'nausea',
      icon: '😣',
      name: '메스꺼움',
      shortDescription: '가장 흔한 적응 반응이에요.\n보통 1~2주면 나아져요.',
      fullDescription: '가장 흔한 적응 반응이에요. 보통 1~2주면 나아져요.',
      tips: [
        '소량씩 천천히 식사하기',
        '기름진 음식 피하기',
        '식후 바로 눕지 않기',
        '생강차나 페퍼민트차 마시기',
      ],
      recoveryInfo: '90% 이상이 2주 내 호전',
      frequencyPercent: 0.6,
      recoveryTime: '1~2주',
    ),
    SymptomPreviewData(
      id: 'constipation',
      icon: '🚽',
      name: '변비',
      shortDescription: '장 운동이 느려져 생길 수 있어요.\n수분 섭취가 도움이 돼요.',
      fullDescription: '장 운동이 느려져 생길 수 있어요. 수분 섭취가 도움이 돼요.',
      tips: [
        '하루 2L 이상 수분 섭취',
        '식이섬유가 풍부한 채소 섭취',
        '가벼운 운동 (걷기 등)',
        '규칙적인 배변 습관 유지',
      ],
      recoveryInfo: '생활습관 개선으로 대부분 호전',
      frequencyPercent: 0.4,
      recoveryTime: '2~3주',
    ),
    SymptomPreviewData(
      id: 'appetite',
      icon: '🍽️',
      name: '식욕 감소',
      shortDescription: '약이 제대로 작용하고 있다는\n신호예요.',
      fullDescription: '약이 제대로 작용하고 있다는 신호예요. '
          '포만감이 오래 유지되어 자연스럽게 식사량이 줄어듭니다.',
      tips: [
        '영양 밀도 높은 음식 선택',
        '단백질 섭취 우선',
        '소량씩 자주 먹기',
        '수분 섭취 충분히',
      ],
      recoveryInfo: '치료 효과의 일부 - 점차 적응',
      frequencyPercent: 0.7,
      recoveryTime: '지속',
    ),
    SymptomPreviewData(
      id: 'fatigue',
      icon: '😴',
      name: '피로감',
      shortDescription: '칼로리 섭취가 줄면서\n일시적으로 느낄 수 있어요.',
      fullDescription: '칼로리 섭취가 줄면서 일시적으로 느낄 수 있어요. '
          '몸이 새로운 에너지 균형에 적응하는 과정입니다.',
      tips: [
        '충분한 수면 확보 (7-8시간)',
        '단백질 섭취량 유지',
        '가벼운 운동으로 에너지 활성화',
        '카페인은 적당히',
      ],
      recoveryInfo: '2~4주 내 대부분 적응',
      frequencyPercent: 0.35,
      recoveryTime: '2~4주',
    ),
  ];

  // ============================================
  // 섹션 6: CTA
  // ============================================

  static const String ctaTitle = '함께 시작해요';
  static const String ctaDescription = '가비움이 매일 함께하며\n치료 여정을 도와드릴게요.';
  static const String ctaPrimaryButton = '나만의 여정 시작하기';
  static const String ctaSecondaryButton = '부작용 가이드 더 보기';
  static const String ctaFooterMessage = '당신은 이미 시작했어요.';
}
