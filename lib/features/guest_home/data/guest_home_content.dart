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

  static const String evidenceSectionTitle = '혁신적인 치료,\n과학이 증명합니다';
  static const String evidenceSectionSubtitle =
      'GLP-1 기반 치료제는 단순한 체중 감량제가 아닙니다.\n'
      '전 세계 최고 의료기관의 대규모 임상시험이\n'
      '입증한 혁신적인 치료입니다.';

  static const String evidenceFooterMessage =
      '"GLP-1 치료는 2023년 Science지가 선정한\n'
      "'올해의 과학적 돌파구(Breakthrough of the Year)'로\n"
      '선정되었습니다."';

  static const String evidenceFooterSubtext =
      '이처럼 검증된 치료를 시작하셨다면,\n이제 중요한 건 "어떻게 잘 사용하느냐"입니다.';

  static const List<EvidenceCardData> evidenceCards = [
    EvidenceCardData(
      id: 'weight',
      icon: '⚖️',
      title: '의미 있는 체중 변화',
      mainStat: '15~17',
      mainStatUnit: '%',
      subStat: '체중 감소',
      description: '80kg 기준 약 12~14kg 감소에 해당합니다.\n\n'
          '기존 다이어트 약물이나 식이요법으로는 달성하기 '
          '어려웠던 수치입니다. GLP-1은 식욕 조절 중추에 '
          '직접 작용하여, 무리한 의지력 없이도 자연스러운 '
          '식사량 조절을 도와줍니다.',
      source: 'SELECT Trial, New England Journal of Medicine, 2023',
      sourceDetail: '17,604명 대상 임상시험 결과',
      sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/37952131/',
    ),
    EvidenceCardData(
      id: 'cardio',
      icon: '❤️',
      title: '심장을 지키는 힘',
      mainStat: '20',
      mainStatUnit: '%',
      subStat: '심혈관 질환 위험 감소',
      description: 'GLP-1 치료제는 최초로 "비만 치료제"로서 '
          '심혈관 질환 예방 효과를 FDA 공인받았습니다.\n\n'
          '체중 감소 효과와 별개로, 혈관 염증 감소, '
          '혈압 개선, 콜레스테롤 조절 등 심장 건강에 '
          '직접적인 보호 효과를 제공합니다.\n\n'
          '이는 단순히 "살을 빼는 약"이 아니라 '
          '"건강 수명을 늘리는 치료"라는 의미입니다.',
      source: 'American College of Cardiology, 2024',
      sourceDetail: 'FDA 승인 기반 대규모 임상 결과',
      sourceUrl:
          'https://www.acc.org/Latest-in-Cardiology/Clinical-Trials/2023/11/09/15/04/select',
    ),
    EvidenceCardData(
      id: 'glucose',
      icon: '🩸',
      title: '혈당 관리의 새로운 기준',
      mainStat: '2.58',
      mainStatUnit: '%',
      subStat: '당화혈색소(HbA1c) 감소',
      description: '당화혈색소 7% 미만은 당뇨 관리의 핵심 목표입니다. '
          'SURPASS 임상시험에서 GLP-1 치료를 받은 참여자의 '
          '97%가 이 목표에 도달했습니다.\n\n'
          '더 놀라운 점은, 참여자의 48~62%가 당화혈색소 '
          '5.7% 미만, 즉 "정상 혈당" 수준에 도달했다는 것입니다.\n\n'
          '이미 당뇨가 있거나, 당뇨 전단계(prediabetes)라면 '
          'GLP-1 치료가 큰 도움이 될 수 있습니다.',
      source: 'SURPASS Clinical Trials, American Diabetes Assoc.',
      sourceDetail: '5개 대규모 임상시험 종합 결과',
      sourceUrl:
          'https://diabetes.org/newsroom/latest-data-from-SURPASS-trials-demonstrate-tirzepatide-provided-blood-sugar-reductions-weight-loss',
    ),
    EvidenceCardData(
      id: 'metabolic',
      icon: '🔄',
      title: '대사증후군, 근본 원인 해결',
      mainStat: '30',
      mainStatUnit: '%p',
      subStat: '대사증후군 유병률 감소',
      description: '대사증후군이란?\n'
          '복부비만 + 고혈압 + 고혈당 + 이상지질혈증이 '
          '동시에 나타나는 상태로, 심혈관 질환과 당뇨의 '
          '주요 위험 요인입니다.\n\n'
          'GLP-1 치료는 이 네 가지 요인을 동시에 개선합니다:\n\n'
          '✓ 복부 지방 감소\n'
          '✓ 수축기/이완기 혈압 개선\n'
          '✓ 혈당 및 인슐린 저항성 개선\n'
          '✓ 중성지방 감소, HDL 콜레스테롤 증가',
      source: 'Cardiovascular Diabetology, 2024',
      sourceDetail: 'SURPASS-4 Post-hoc Analysis',
      sourceUrl:
          'https://cardiab.biomedcentral.com/articles/10.1186/s12933-024-02147-9',
    ),
    EvidenceCardData(
      id: 'brain',
      icon: '🧠',
      title: '기억을 지키는 새로운 가능성',
      mainStat: '40~70',
      mainStatUnit: '%',
      subStat: '치매 발생 위험 감소',
      description: 'GLP-1 수용체는 뇌의 기억과 학습을 담당하는 '
          '해마(hippocampus)에도 존재합니다.\n\n'
          '최근 연구에 따르면, GLP-1 치료를 받은 그룹은 '
          '다른 당뇨 치료제를 사용한 그룹에 비해 '
          '치매 발생률이 현저히 낮았습니다.\n\n'
          'ELAD 임상시험에서는 알츠하이머 환자의 뇌 위축을 '
          '약 50% 늦추고, 인지 기능 저하를 18% 지연시키는 '
          '결과가 보고되었습니다.\n\n'
          '아직 연구가 진행 중이지만, 체중 관리를 넘어 '
          '뇌 건강까지 기대할 수 있는 혁신적인 치료입니다.',
      source: "Alzheimer's Association International Conference",
      sourceDetail: 'ELAD Phase 2b Trial, Nature Medicine, 2025',
      sourceUrl:
          'https://aaic.alz.org/releases-2024/glp-drug-liraglutide-may-protect-against-dementia.asp',
    ),
  ];

  // ============================================
  // 섹션 3: 치료 여정 미리보기
  // ============================================

  static const String journeySectionTitle = '나의 12주 치료 여정,\n미리 살펴볼까요?';
  static const String journeySectionSubtitle =
      'GLP-1 치료는 보통 낮은 용량에서 시작해\n'
      '몸이 적응하면 점차 용량을 높여갑니다.\n'
      '각 단계에서 어떤 변화가 일어나는지 알면\n'
      '더 안심하고 치료를 이어갈 수 있어요.';

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

  static const String featuresSectionTitle = '이렇게 좋은 치료,\n제대로 사용하는 것이 무엇보다 중요해요';
  static const String featuresSectionSubtitle =
      'GLP-1 치료는 정해진 스케줄, 용량 조절, 증상 관리가\n'
      '효과를 좌우합니다. 가비움이 이 모든 것을 도와드릴게요.';

  static const List<AppFeatureData> appFeatures = [
    AppFeatureData(
      id: 'schedule',
      icon: '📅',
      title: '복잡한 투여 스케줄, 알아서 계산해 드려요',
      painPoints: [
        '"이번 주 용량이 몇 mg이지?"',
        '"다음 투여일이 언제였더라?"',
      ],
      description: 'GLP-1 치료는 4주마다 용량을 올리고, '
          '주 1회 정확한 날짜에 투여해야 해요. '
          '헷갈리기 쉽죠. 가비움이 자동으로 계산하고 '
          '투여일에 맞춰 알림을 보내드려요.',
      encouragement: '"처음엔 누구나 헷갈려요. 걱정 마세요."',
      relatedFeatureId: 'F001',
    ),
    AppFeatureData(
      id: 'record',
      icon: '📝',
      title: '간편하게 기록하고, 나의 변화를 확인해요',
      painPoints: [
        '체중, 몸의 신호, 기분까지',
        '하루 30초면 충분해요.',
      ],
      description: '귀찮은 기록이 아니라, '
          '나의 변화를 눈으로 확인하는 시간이에요.',
      encouragement: '"작은 변화도 의미 있어요. 기록하면 더 잘 보여요."',
      relatedFeatureId: 'F002',
    ),
    AppFeatureData(
      id: 'report',
      icon: '🏥',
      title: '진료 시간, 더 효과적으로',
      painPoints: [
        '"지난 한 달 동안 어떠셨어요?"',
        '"부작용은 없으셨고요?"',
      ],
      description: '진료실에서 갑자기 물어보면 기억이 잘 안 나죠.\n\n'
          '가비움이 자동으로 정리한 리포트를 '
          '의료진에게 보여드리세요. '
          '짧은 진료 시간을 더 효과적으로 쓸 수 있어요.',
      encouragement: '"당신의 기록이 상담을 더 효과적으로 만들어요."',
      relatedFeatureId: 'F003',
    ),
    AppFeatureData(
      id: 'guide',
      icon: '💊',
      title: '불편한 증상? 대처법을 바로 알려드려요',
      painPoints: [
        '메스꺼움, 변비, 소화불량...',
        '처음 겪으면 불안할 수 있어요.',
      ],
      description: '하지만 대부분은 몸이 적응하는 과정에서 '
          '나타나는 자연스러운 반응이에요.\n\n'
          '증상을 기록하면 가비움이 바로 '
          '의학적 근거에 기반한 대처법을 알려드려요.',
      encouragement: '"적응 과정이에요. 괜찮아요."',
      relatedFeatureId: 'F004',
    ),
    AppFeatureData(
      id: 'safety',
      icon: '🚨',
      title: '위험 신호는 빠르게 알려드릴게요',
      painPoints: [],
      description: '대부분의 증상은 시간이 지나면 나아지지만, '
          '드물게 전문가 상담이 필요한 경우도 있어요.\n\n'
          '가비움은 기록된 증상을 분석해서 '
          '주의가 필요한 상황을 알려드려요.\n\n'
          '혼자 걱정하지 않아도 돼요. '
          '가비움이 함께 지켜보고 있어요.',
      encouragement: '"당신의 안전이 가장 중요해요."',
      relatedFeatureId: 'F005',
    ),
  ];

  // ============================================
  // 섹션 5: 부작용 대처 가이드 미리보기
  // ============================================

  static const String symptomsSectionTitle = '💡 자주 경험하는 몸의 신호와 대처법';
  static const String symptomsSectionSubtitle =
      'GLP-1 치료를 시작하면 몸이 적응하는 과정에서\n'
      '여러 신호를 보낼 수 있어요. 미리 알아두면 덜 불안해요.';

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

  static const String ctaTitle = '건강한 변화, 함께 시작해볼까요?';
  static const String ctaDescription = 'GLP-1 치료는 혼자 하기엔 복잡하고,\n'
      '오래 지속하기엔 외로울 수 있어요.\n\n'
      '가비움이 매일 함께하며\n'
      '스케줄 관리부터 동기 부여까지\n'
      '당신의 치료 여정을 도와드릴게요.';
  static const String ctaPrimaryButton = '나만의 여정 시작하기';
  static const String ctaSecondaryButton = '부작용 대처 가이드 더 보기';
  static const String ctaFooterMessage = '"처음엔 누구나 두려워요.\n하지만 당신은 이미 시작했어요."';
}
