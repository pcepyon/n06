import '../../domain/entities/coping_guide.dart';
import '../../domain/entities/guide_section.dart';
import '../../domain/repositories/coping_guide_repository.dart';

/// 정적 가이드 데이터를 제공하는 Repository 구현
class StaticCopingGuideRepository implements CopingGuideRepository {
  static const Map<String, CopingGuide> _guides = {
    '메스꺼움': CopingGuide(
      symptomName: '메스꺼움',
      shortGuide: '소량씩 자주 식사하고, 생강차나 박하 음료를 마시세요.',
      reassuranceMessage: '몸이 약에 적응하는 자연스러운 반응이에요',
      reassuranceStat: '85%가 2주 내 개선을 경험해요',
      immediateAction: '시원한 물 한 모금 마시기',
      positiveFraming: '메스꺼움은 약이 작동하고 있다는 신호예요',
      detailedSections: [
        GuideSection(
          title: '이렇게 드시면 도움이 돼요',
          content: '- 소량씩 자주 드세요 (하루 5-6회)\n- 포만감이 느껴지면 바로 식사를 멈추세요\n- 식사 후 최소 2-3시간은 눕지 마세요',
        ),
        GuideSection(
          title: '잠시 피해주세요',
          content: '- 기름진 음식 (튀김, 패스트푸드)\n- 매운 음식\n- 고당분 음식\n- 카페인, 알코올',
        ),
        GuideSection(
          title: '이런 음식이 좋아요',
          content: '- 토스트, 크래커, 쌀\n- 생강차, 페퍼민트차\n- 차가운 음료 (소량씩)',
        ),
      ],
    ),
    '구토': CopingGuide(
      symptomName: '구토',
      shortGuide: '수분을 조금씩 자주 마시고, 회복 단계별로 천천히 음식을 섭취하세요.',
      reassuranceMessage: '불편하시죠. 대부분 며칠 내 나아져요',
      reassuranceStat: '대부분 1주 내 완화돼요',
      immediateAction: '10분간 휴식 후 물 섭취',
      detailedSections: [
        GuideSection(
          title: '수분 보충이 중요해요',
          content: '- 소량씩 자주 (한 번에 많이 X)\n- 전해질 음료 권장\n- 얼음 조각을 천천히 녹여 먹기',
        ),
        GuideSection(
          title: '식사는 천천히 재개해요',
          content: '1. 구토 멈춘 후 1-2시간 대기\n2. 맑은 육수, 크래커부터 시작\n3. 점차 부드러운 음식으로',
        ),
      ],
    ),
    '변비': CopingGuide(
      symptomName: '변비',
      shortGuide: '섬유질과 수분 섭취를 늘리고, 신체 활동을 유지하세요.',
      reassuranceMessage: '장이 새로운 리듬을 찾는 중이에요',
      reassuranceStat: '수분과 섬유질 섭취로 80% 이상이 개선을 경험해요',
      immediateAction: '물 한 컵 마시기',
      detailedSections: [
        GuideSection(
          title: '물을 충분히 마셔주세요',
          content: '- 하루 8잔 이상의 물\n- 아침 기상 후 따뜻한 물 한 잔',
        ),
        GuideSection(
          title: '섬유질이 도움이 돼요',
          content: '- 통곡물, 과일, 채소\n- 단, 갑자기 늘리지 말고 점진적으로',
        ),
        GuideSection(
          title: '가볍게 움직여보세요',
          content: '- 가벼운 산책\n- 규칙적인 움직임',
        ),
      ],
    ),
    '설사': CopingGuide(
      symptomName: '설사',
      shortGuide: '수분과 전해질을 보충하고, 소화 부담을 줄이세요.',
      reassuranceMessage: '장이 적응하는 과정이에요',
      reassuranceStat: '보통 2-3일 내 안정돼요',
      immediateAction: '전해질 음료 섭취',
      detailedSections: [
        GuideSection(
          title: '수분과 전해질을 보충해주세요',
          content: '- 물, 전해질 음료\n- 소량씩 자주',
        ),
        GuideSection(
          title: '잠시 피해주세요',
          content: '- 유제품 (일시적으로)\n- 고섬유질 음식\n- 기름진 음식',
        ),
        GuideSection(
          title: 'BRAT 식단을 추천해요',
          content: '- Banana (바나나)\n- Rice (쌀밥)\n- Applesauce (사과소스)\n- Toast (토스트)',
        ),
      ],
    ),
    '복통': CopingGuide(
      symptomName: '복통',
      shortGuide: '온찜질을 하고, 가벼운 식사를 하며, 스트레스를 관리하세요.',
      reassuranceMessage: '소화기관이 적응 중이에요',
      reassuranceStat: '가벼운 식사와 휴식으로 대부분 완화돼요',
      immediateAction: '따뜻한 물 + 휴식',
      detailedSections: [
        GuideSection(
          title: '이렇게 하면 편해질 수 있어요',
          content: '- 따뜻한 물 또는 차\n- 옆으로 누워 휴식\n- 꽉 끼는 옷 피하기',
        ),
        GuideSection(
          title: '식사는 이렇게 해보세요',
          content: '- 소량씩 자주\n- 부드러운 음식 선택\n- 기름진/매운 음식 피하기',
        ),
      ],
    ),
    '두통': CopingGuide(
      symptomName: '두통',
      shortGuide: '충분한 수분을 섭취하고, 휴식을 취하며, 스트레스를 줄이세요.',
      reassuranceMessage: '수분 부족이나 혈당 변화일 수 있어요',
      reassuranceStat: '수분 섭취로 빠르게 완화되는 경우가 많아요',
      immediateAction: '물 한 컵 + 5분 휴식',
      detailedSections: [
        GuideSection(
          title: '지금 바로 해보세요',
          content: '- 충분한 수분 섭취\n- 조용하고 어두운 곳에서 휴식\n- 카페인 음료는 피하기',
        ),
        GuideSection(
          title: '예방에 도움이 돼요',
          content: '- 규칙적인 식사 (소량이라도)\n- 하루 8잔 이상 물\n- 충분한 수면',
        ),
      ],
    ),
    '피로': CopingGuide(
      symptomName: '피로',
      shortGuide: '충분한 수면과 영양가 있는 식사를 하고, 활동을 조절하세요.',
      reassuranceMessage: '에너지 조절 중이에요',
      reassuranceStat: '1-2주 후 적응해요',
      immediateAction: '10분 가벼운 휴식',
      detailedSections: [
        GuideSection(
          title: '에너지 관리에 도움이 돼요',
          content: '- 규칙적인 가벼운 운동\n- 충분한 수면 (7-8시간)\n- 카페인은 오전에만',
        ),
        GuideSection(
          title: '영양 섭취도 중요해요',
          content: '- 단백질 충분히\n- 소량이라도 규칙적으로\n- 비타민/미네랄 보충',
        ),
      ],
    ),
    // === 추가된 증상 가이드 (의학 논문 기반) ===
    '식욕 감소': CopingGuide(
      symptomName: '식욕 감소',
      shortGuide: '소량씩 자주 식사하고, 영양 밀도가 높은 음식을 선택하세요.',
      // SURPASS-2 trial: 5-9%에서 식욕 감소 보고
      // PMC5573908: 세마글루타이드가 포만감 증가, 식욕 억제 작용
      reassuranceMessage: '약이 식욕 조절에 작용하고 있어요',
      reassuranceStat: '자연스러운 반응이고, 영양만 잘 챙기면 괜찮아요',
      immediateAction: '좋아하는 음식 소량 섭취',
      positiveFraming: '식욕 감소는 체중 관리에 도움이 되는 작용이에요',
      detailedSections: [
        GuideSection(
          title: '이렇게 드시면 도움이 돼요',
          content: '- 소량씩 하루 5-6회 나눠 드세요\n- 단백질 위주로 선택\n- 영양 밀도 높은 음식 우선',
        ),
        GuideSection(
          title: '식사가 더 편해지는 팁',
          content: '- 정해진 시간에 식사하기\n- 좋아하는 음식으로 시작\n- 무리하게 많이 먹지 않아도 돼요',
        ),
      ],
    ),
    '조기 포만감': CopingGuide(
      symptomName: '조기 포만감',
      shortGuide: '소량씩 자주 식사하고, 포만감이 오면 멈추세요.',
      // PMC7898914: 세마글루타이드 2.4mg이 포만감과 만족감 증가
      // 위 배출 지연으로 인한 자연스러운 반응
      reassuranceMessage: '위장이 약에 적응하는 자연스러운 과정이에요',
      reassuranceStat: '몸의 신호에 맞춰 드시면 돼요',
      immediateAction: '잠시 쉬었다가 나중에 드세요',
      positiveFraming: '조기 포만감은 과식을 막아주는 신호예요',
      detailedSections: [
        GuideSection(
          title: '이렇게 드시면 편해요',
          content: '- 소량씩 자주 (하루 5-6회)\n- 천천히 씹어 드세요\n- 포만감 느끼면 바로 멈춰도 돼요',
        ),
        GuideSection(
          title: '이런 음식이 좋아요',
          content: '- 부드러운 음식 선택\n- 기름진 음식은 잠시 피하기\n- 수분은 식사 사이에',
        ),
      ],
    ),
    '속쓰림': CopingGuide(
      symptomName: '속쓰림',
      shortGuide: '식후 바로 눕지 말고, 소량씩 자주 식사하세요.',
      // PMC6004661: GLP-1 RA와 위식도역류 증상 연관성
      // 임상시험에서 소화불량 3-9% 보고
      reassuranceMessage: '위장이 적응하는 과정이에요',
      reassuranceStat: '생활습관 조절로 대부분 편해져요',
      immediateAction: '물 한 모금 + 상체 세우기',
      detailedSections: [
        GuideSection(
          title: '지금 바로 해보세요',
          content: '- 상체를 세운 자세 유지\n- 꽉 끼는 옷 피하기\n- 시원한 물 소량 섭취',
        ),
        GuideSection(
          title: '예방에 도움이 돼요',
          content: '- 식후 2-3시간은 눕지 않기\n- 소량씩 자주 식사\n- 취침 전 3시간 내 식사 피하기',
        ),
        GuideSection(
          title: '잠시 피해주세요',
          content: '- 매운 음식, 산성 음식\n- 카페인, 탄산음료\n- 기름진 음식',
        ),
      ],
    ),
    '복부 팽만': CopingGuide(
      symptomName: '복부 팽만',
      shortGuide: '천천히 식사하고, 가스를 유발하는 음식을 피하세요.',
      // PMC10614464: 티르제파타이드 복부팽만 1-10% 발생
      // 위 배출 지연으로 인한 증상
      reassuranceMessage: '장이 새로운 리듬에 적응 중이에요',
      reassuranceStat: '가벼운 활동으로 금방 편해져요',
      immediateAction: '가벼운 산책 10분',
      detailedSections: [
        GuideSection(
          title: '지금 바로 해보세요',
          content: '- 가벼운 산책\n- 따뜻한 물 마시기\n- 꽉 끼는 옷 풀기',
        ),
        GuideSection(
          title: '이렇게 드시면 도움이 돼요',
          content: '- 천천히 꼭꼭 씹어 드세요\n- 식사 중 대화 줄이기\n- 빨대 사용 피하기',
        ),
        GuideSection(
          title: '잠시 피해주세요',
          content: '- 탄산음료\n- 콩류, 양배추\n- 껌 씹기',
        ),
      ],
    ),
    '어지러움': CopingGuide(
      symptomName: '어지러움',
      shortGuide: '천천히 일어나고, 충분한 수분과 영양을 섭취하세요.',
      // Nature Scientific Reports: GLP-1 RA 관련 어지러움 보고
      // 저혈당, 탈수, 혈압 변화와 연관
      reassuranceMessage: '몸이 적응하면서 나타날 수 있어요',
      reassuranceStat: '수분과 영양 섭취로 대부분 좋아져요',
      immediateAction: '앉아서 물 한 잔 마시기',
      detailedSections: [
        GuideSection(
          title: '지금 바로 해보세요',
          content: '- 안전한 곳에 앉거나 눕기\n- 물 또는 주스 마시기\n- 급하게 움직이지 않기',
        ),
        GuideSection(
          title: '예방에 도움이 돼요',
          content: '- 천천히 일어나기\n- 규칙적으로 식사하기\n- 충분한 수분 섭취',
        ),
        GuideSection(
          title: '이것만 기억하세요',
          content: '- 잠깐 쉬면 괜찮아져요\n- 반복되면 의료진과 상담해보세요',
        ),
      ],
    ),
    '식은땀': CopingGuide(
      symptomName: '식은땀',
      shortGuide: '당분을 섭취하면 금방 나아져요.',
      // PMC8506728: GLP-1 RA 저혈당 실제 발생률 분석
      // 저혈당 증상: 떨림, 두근거림, 식은땀, 어지러움
      reassuranceMessage: '혈당이 조금 낮아진 것일 수 있어요',
      reassuranceStat: '당분 섭취로 빠르게 회복돼요',
      immediateAction: '사탕이나 주스 한 잔',
      detailedSections: [
        GuideSection(
          title: '지금 바로 해보세요',
          content: '- 사탕, 주스, 포도당 섭취\n- 15분 후 증상 확인\n- 필요시 반복 섭취',
        ),
        GuideSection(
          title: '예방에 도움이 돼요',
          content: '- 규칙적인 식사 (소량이라도)\n- 사탕이나 포도당 휴대\n- 공복 시간 너무 길지 않게',
        ),
        GuideSection(
          title: '이것만 기억하세요',
          content: '- 대부분 금방 좋아져요\n- 자주 반복되면 의료진과 상담해보세요',
        ),
      ],
    ),
    '부종': CopingGuide(
      symptomName: '부종',
      shortGuide: '다리를 올리고 휴식하면 편해져요.',
      // 임상시험에서 드물게 보고되는 부작용
      // 수분 균형 변화와 관련
      reassuranceMessage: '수분 균형이 변화하는 과정이에요',
      reassuranceStat: '휴식과 가벼운 움직임으로 대부분 좋아져요',
      immediateAction: '다리 올리고 휴식',
      detailedSections: [
        GuideSection(
          title: '지금 바로 해보세요',
          content: '- 다리를 심장보다 높이 올리기\n- 꽉 끼는 옷/양말 피하기\n- 오래 서 있지 않기',
        ),
        GuideSection(
          title: '생활습관이 도움이 돼요',
          content: '- 염분 섭취 줄이기\n- 가벼운 스트레칭\n- 규칙적인 움직임',
        ),
        GuideSection(
          title: '이것만 기억하세요',
          content: '- 대부분 일시적이에요\n- 호흡이 불편하면 의료진과 상담해보세요',
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
