import 'package:flutter/material.dart';

/// F004: 부작용 대처 가이드 위젯
///
/// 선택된 증상에 대한 간단한 대처 가이드를 표시합니다.
/// 사용자가 도움이 되었는지 피드백할 수 있습니다.
class CopingGuideWidget extends StatefulWidget {
  /// 증상명
  final String symptomName;

  /// 증상의 심각도 (1-10)
  final int severity;

  /// 위젯이 닫힐 때 호출되는 콜백
  final VoidCallback? onClose;

  const CopingGuideWidget({
    super.key,
    required this.symptomName,
    required this.severity,
    this.onClose,
  });

  @override
  State<CopingGuideWidget> createState() => _CopingGuideWidgetState();
}

class _CopingGuideWidgetState extends State<CopingGuideWidget> {
  bool? _feedbackGiven;

  /// 증상별 대처 가이드 (간단 버전)
  static const Map<String, Map<String, String>> _guides = {
    '메스꺼움': {
      'title': '메스꺼움 대처 가이드',
      'content': '''
        1. 식사 방법
        - 작은 양을 자주 먹기
        - 차가운 음식이나 음료 섭취하기
        - 기름진 음식 피하기

        2. 도움이 되는 음료
        - 생강차
        - 레몬물
        - 맑은 국물

        3. 주사 타이밍 조정
        - 저녁 시간에 투여하면 수면 중 증상 경험 가능
        - 의료진과 상담하여 타이밍 조정

        4. 일상 관리
        - 신선한 공기 마시기
        - 천천히 움직이기
        - 얼굴에 찬 수건 대기
      ''',
    },
    '구토': {
      'title': '구토 대처 가이드',
      'content': '''
        1. 응급 대응
        - 탈수 방지를 위해 수분 천천히 섭취
        - 전해질 음료 (물+소금+설탕) 마시기

        2. 식사 재개 순서
        - 처음: 물, 얼음 조각
        - 2-4시간 후: 맑은 국물, 스포츠 음료
        - 8시간 후: 우동, 미음 등 소화하기 쉬운 음식
        - 24시간 후: 일반 음식 (기름진 음식 제외)

        3. 약 복용
        - 복용한 약이 섭취되지 않았을 수 있으므로 의료진에 상담

        4. 의료진 상담 필요
        - 24시간 이상 계속되는 경우
        - 탈수 증상이 있는 경우
      ''',
    },
    '변비': {
      'title': '변비 대처 가이드',
      'content': '''
        1. 식이 조절
        - 식이섬유 섭취 (채소, 과일, 통곡물)
        - 자두, 무화과 등 도움이 되는 음식
        - 유제품 대신 비유제품 선택

        2. 수분 섭취
        - 하루 8-10잔 물 마시기
        - 따뜻한 물이 더 효과적

        3. 신체 활동
        - 가벼운 운동 (산책, 스트레칭)
        - 규칙적인 활동으로 장 운동 촉진

        4. 배변 습관 개선
        - 매일 정해진 시간에 화장실 가기
        - 충분한 시간 가지기
        - 필요시 의료진과 상담 가능 약물 사용
      ''',
    },
    '설사': {
      'title': '설사 대처 가이드',
      'content': '''
        1. 수분 및 전해질 관리
        - 깨끗한 물 자주 마시기
        - 스포츠 음료, 국물 섭취
        - 전해질 보충 (나트륨, 칼륨)

        2. 식이 조절
        - 기름진 음식, 유제품, 고지방 피하기
        - 흰 쌀밥, 삶은 계란, 닭가슴살 섭취
        - 섬유질 많은 음식 처음에 피하기

        3. 약물 고려
        - 로페라마이드(이모디움) 등 사용 가능
        - 의료진과 상담 필수

        4. 의료진 상담
        - 48시간 이상 지속되는 경우
        - 심한 복통이 동반되는 경우
      ''',
    },
    '복통': {
      'title': '복통 대처 가이드',
      'content': '''
        1. 즉각적인 완화
        - 따뜻한 수건으로 복부 찜질
        - 좌식 또는 누운 자세 취하기
        - 천천히 깊게 숨쉬기

        2. 식이 조절
        - 소화하기 쉬운 음식 섭취
        - 자극적인 음식 (카페인, 기름진 음식) 피하기
        - 작은 양을 자주 먹기

        3. 스트레스 관리
        - 명상, 요가 시도
        - 규칙적인 휴식
        - 스트레스 유발 상황 피하기

        4. 의료진 상담
        - 심한 복통이 있는 경우
        - 계속되는 경우
      ''',
    },
    '두통': {
      'title': '두통 대처 가이드',
      'content': '''
        1. 수분 섭취
        - 물 자주 마시기 (탈수 방지)
        - 카페인 섭취 조절

        2. 휴식 방법
        - 조용한 어두운 곳에서 쉬기
        - 30분 정도 눈을 감고 있기
        - 편안한 자세 취하기

        3. 물리적 완화
        - 목, 어깨 마사지
        - 따뜻한 샤워
        - 냉찜질 또는 온찜질

        4. 일상 관리
        - 규칙적인 수면
        - 규칙적인 식사
        - 스트레스 관리
      ''',
    },
    '피로': {
      'title': '피로 대처 가이드',
      'content': '''
        1. 휴식 및 회복
        - 충분한 수면 (7-9시간)
        - 낮 시간에 짧은 휴식 (15-30분)
        - 부드러운 스트레칭

        2. 영양 관리
        - 균형잡힌 식단
        - 철분, 비타민B 섭취
        - 규칙적인 식사

        3. 활동량 조절
        - 과로하지 않기
        - 힘이 들 때는 쉬기
        - 가벼운 활동은 도움이 될 수 있음

        4. 언제 의료진 상담
        - 2주 이상 심한 피로
        - 다른 증상과 함께 나타나는 경우
      ''',
    },
  };

  String _getGuideContent() {
    final guide = _guides[widget.symptomName];
    if (guide != null) {
      return guide['content'] ?? '';
    }
    return '전문 의료진과 상담하세요.';
  }

  String _getGuideTitle() {
    final guide = _guides[widget.symptomName];
    if (guide != null) {
      return guide['title'] ?? '대처 가이드';
    }
    return '${widget.symptomName} 대처 가이드';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGuideTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '심각도: ${widget.severity}/10',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // 가이드 내용
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _getGuideContent(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),

          // 피드백 섹션
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '도움이 되었나요?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _feedbackGiven = false);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _feedbackGiven == false
                              ? Colors.grey.shade300
                              : Colors.white,
                        ),
                        child: const Text('아니오'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _feedbackGiven = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _feedbackGiven == true
                              ? Colors.green
                              : Colors.grey,
                        ),
                        child: const Text(
                          '예',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_feedbackGiven == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '피드백해주셔서 감사합니다!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onClose?.call();
                      Navigator.of(context).pop();
                    },
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
