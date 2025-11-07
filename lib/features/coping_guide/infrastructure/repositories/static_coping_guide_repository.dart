import '../../domain/entities/coping_guide.dart';
import '../../domain/entities/guide_section.dart';
import '../../domain/repositories/coping_guide_repository.dart';

/// 정적 가이드 데이터를 제공하는 Repository 구현
class StaticCopingGuideRepository implements CopingGuideRepository {
  static const Map<String, CopingGuide> _guides = {
    '메스꺼움': CopingGuide(
      symptomName: '메스꺼움',
      shortGuide: '소량씩 자주 식사하고, 생강차나 박하 음료를 마시세요.',
      detailedSections: [
        GuideSection(
          title: '즉시 조치',
          content: '- 천천히 깊게 숨 쉬기\n- 신선한 공기 마시기\n- 생강, 박하 등의 향기 맡기\n- 얼음 조각 천천히 먹기',
        ),
        GuideSection(
          title: '식이 조절',
          content: '- 소량의 음식을 자주 먹기\n- 차갑고 가벼운 음식 선택 (요거트, 과일, 국수)\n- 기름진 음식, 카페인, 자극적인 음식 피하기\n- 수분 섭취 (물, 스포츠음료, 맑은 국)',
        ),
        GuideSection(
          title: '생활 습관',
          content: '- 충분한 휴식 취하기\n- 천천히 움직이기\n- 주사 후 2-3시간 뒤에 식사하기\n- 스트레스 관리하기',
        ),
        GuideSection(
          title: '경과 관찰',
          content: '- 3-5일 후 증상 개선되는지 확인\n- 식사 후 1시간 동안 누워있기\n- 증상 강도나 빈도가 증가하면 의료진 상담\n- 수분 섭취량 추적하기',
        ),
      ],
    ),
    '구토': CopingGuide(
      symptomName: '구토',
      shortGuide: '수분을 조금씩 자주 마시고, 회복 단계별로 천천히 음식을 섭취하세요.',
      detailedSections: [
        GuideSection(
          title: '즉시 조치',
          content: '- 침대에서 휴식\n- 깊게 숨쉬기\n- 냉수로 입헹굼\n- 2시간 동안 음식 피하기',
        ),
        GuideSection(
          title: '식이 조절',
          content: '- 맑은 음료부터 시작 (물, 스포츠음료, 맑은 국)\n- 2-4시간마다 작은 양의 액체 (스푼 한두 개)\n- 6시간 후 고체음식 시작 (크래커, 쌀밥)\n- 자극적이지 않은 부드러운 음식 선택',
        ),
        GuideSection(
          title: '생활 습관',
          content: '- 편한 자세로 누워있기\n- 찬 수건으로 이마와 목 식히기\n- 구토 후 입 헹굼\n- 야한 냄새 피하기',
        ),
        GuideSection(
          title: '경과 관찰',
          content: '- 체온 모니터링\n- 수분 섭취 상태 확인\n- 2-3시간 구토 없이 지나면 진전\n- 지속적인 구토는 의료진 상담 필수',
        ),
      ],
    ),
    '변비': CopingGuide(
      symptomName: '변비',
      shortGuide: '섬유질과 수분 섭취를 늘리고, 신체 활동을 유지하세요.',
      detailedSections: [
        GuideSection(
          title: '즉시 조치',
          content: '- 따뜻한 물 마시기\n- 온찜질 또는 따뜻한 목욕\n- 가벼운 복부 마사지 (시계 방향)\n- 화장실 시간 정하기',
        ),
        GuideSection(
          title: '식이 조절',
          content: '- 수분 섭취 증가 (하루 2-3리터)\n- 섬유질 풍부한 음식 (과일, 채소, 통곡물)\n- 자두, 무화과, 키위, 메론 섭취\n- 아침에 따뜻한 음료 마시기',
        ),
        GuideSection(
          title: '생활 습관',
          content: '- 하루 30분 이상 운동\n- 화장실 가기 좋은 시간 정하기 (보통 아침)\n- 서둘지 않기\n- 규칙적인 일일 스케줄 유지',
        ),
        GuideSection(
          title: '경과 관찰',
          content: '- 2-3일 이내 개선 여부 확인\n- 변의 부드러움 정도 관찰\n- 복부 불편감 모니터링\n- 1주일 이상 지속되면 의료진 상담',
        ),
      ],
    ),
    '설사': CopingGuide(
      symptomName: '설사',
      shortGuide: '수분과 전해질을 보충하고, 소화 부담을 줄이세요.',
      detailedSections: [
        GuideSection(
          title: '즉시 조치',
          content: '- 수분 섭취 (스포츠음료, 이온 음료)\n- 염분과 당분 균형 유지\n- 카페인 피하기\n- 복부 열 가하기',
        ),
        GuideSection(
          title: '식이 조절',
          content: '- BRAT 식단 (바나나, 쌀, 사과, 토스트)\n- 부드럽고 소화 잘 되는 음식\n- 유제품, 자극적인 음식 피하기\n- 수프나 미음 같은 따뜻한 음식',
        ),
        GuideSection(
          title: '생활 습관',
          content: '- 충분한 휴식\n- 위생 관리 철저\n- 손 자주 씻기\n- 스트레스 관리',
        ),
        GuideSection(
          title: '경과 관찰',
          content: '- 24시간마다 수분 섭취 기록\n- 배변 횟수와 형태 추적\n- 복부 경련 정도 모니터링\n- 48시간 이상 지속되면 의료진 상담',
        ),
      ],
    ),
    '복통': CopingGuide(
      symptomName: '복통',
      shortGuide: '온찜질을 하고, 가벼운 식사를 하며, 스트레스를 관리하세요.',
      detailedSections: [
        GuideSection(
          title: '즉시 조치',
          content: '- 따뜻한 물병으로 온찜질\n- 편안한 자세로 누워있기\n- 천천히 깊게 숨 쉬기\n- 복부 마사지 (가볍게)',
        ),
        GuideSection(
          title: '식이 조절',
          content: '- 소량의 가벼운 음식\n- 부드러운 음식 선택\n- 기름진 음식, 자극적인 음식 피하기\n- 따뜻한 음료 (생강차, 민트차)',
        ),
        GuideSection(
          title: '생활 습관',
          content: '- 충분한 휴식\n- 스트레스 관리 (명상, 심호흡)\n- 가벼운 운동 (산책)\n- 규칙적인 일일 생활',
        ),
        GuideSection(
          title: '경과 관찰',
          content: '- 통증 위치와 강도 기록\n- 음식과의 연관성 추적\n- 배변과의 관계 확인\n- 심하거나 지속되면 의료진 상담',
        ),
      ],
    ),
    '두통': CopingGuide(
      symptomName: '두통',
      shortGuide: '충분한 수분을 섭취하고, 휴식을 취하며, 스트레스를 줄이세요.',
      detailedSections: [
        GuideSection(
          title: '즉시 조치',
          content: '- 수분 섭취 (시간당 250ml)\n- 어두운 환경에서 휴식\n- 찬 또는 따뜻한 찜질\n- 목과 어깨 이완 스트레칭',
        ),
        GuideSection(
          title: '식이 조절',
          content: '- 규칙적인 식사\n- 카페인 피하기\n- 알코올 금지\n- 에너지 음료 피하기\n- 철분이 풍부한 음식 섭취',
        ),
        GuideSection(
          title: '생활 습관',
          content: '- 7-9시간 충분한 수면\n- 정기적인 운동\n- 근육 이완 기술\n- 휴식 시간 정하기',
        ),
        GuideSection(
          title: '경과 관찰',
          content: '- 두통 일기 작성\n- 유발 요인 추적\n- 통증 강도와 지속 시간 기록\n- 심하거나 지속되면 의료진 상담',
        ),
      ],
    ),
    '피로': CopingGuide(
      symptomName: '피로',
      shortGuide: '충분한 수면과 영양가 있는 식사를 하고, 활동을 조절하세요.',
      detailedSections: [
        GuideSection(
          title: '즉시 조치',
          content: '- 편안한 수면 환경 조성\n- 낮 시간에 가벼운 휴식\n- 신선한 공기 마시기\n- 명상이나 심호흡',
        ),
        GuideSection(
          title: '식이 조절',
          content: '- 균형 잡힌 영양가 높은 식사\n- 철분이 풍부한 음식 (붉은 육류, 시금치)\n- B 비타민 섭취 (계란, 통곡물)\n- 정크 푸드 피하기',
        ),
        GuideSection(
          title: '생활 습관',
          content: '- 8-10시간 충분한 수면\n- 일과 휴식의 균형\n- 가벼운 운동 (산책, 스트레칭)\n- 취침 시간 정하기',
        ),
        GuideSection(
          title: '경과 관찰',
          content: '- 에너지 수준 추적\n- 수면의 질 모니터링\n- 식사 후 에너지 변화 기록\n- 2주 이상 지속되면 의료진 상담',
        ),
      ],
    ),
  };

  @override
  Future<CopingGuide?> getGuideBySymptom(String symptomName) async {
    return _guides[symptomName];
  }

  @override
  Future<List<CopingGuide>> getAllGuides() async {
    return _guides.values.toList();
  }
}
