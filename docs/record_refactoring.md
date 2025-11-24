# Task: GLP-1 기록 기능 리팩토링 (통합 데일리 로그 구현)
## 1. 배경 및 목표
현재 분리되어 있는 '체중 기록'과 '증상 기록' 화면을 **하나의 '통합 데일리 로그(Daily Log)' 화면으로 통합**하여 UX를 개선하고, 네비게이션 단절 문제와 증상별 심각도 기록 불가 문제를 해결해야 합니다.
## 2. 작업 범위
### A. 화면 통합 (New `DailyLogScreen`)
기존 [WeightRecordScreen](cci:2://file:///Users/pro16/Desktop/project/n06/lib/features/tracking/presentation/screens/weight_record_screen.dart:14:0-19:1)과 [SymptomRecordScreen](cci:2://file:///Users/pro16/Desktop/project/n06/lib/features/tracking/presentation/screens/symptom_record_screen.dart:14:0-20:1)을 대체하는 새로운 화면을 구현하세요.
- **위치**: `lib/features/tracking/presentation/screens/daily_log_screen.dart`
**[UI 구성 및 플로우]**
1.  **날짜 선택 (Top)**: 기존과 동일하게 날짜 이동 가능.
2.  **신체 기록 (Section 1)**:
    -   **체중 (Weight)**: 숫자 입력 (기존 로직 재사용).
    -   **식욕 조절 (Appetite Control)**: **[신규 필수 항목]**
        -   UI: 슬라이더 또는 5단계 버튼 (예: 폭발 - 보통 - 약간 감소 - 매우 감소 - 아예 없음).
        -   데이터: `WeightLog` 엔티티에 `appetiteScore` (int) 필드를 추가하여 저장.
3.  **부작용 기록 (Section 2)**:
    -   **초기 상태**: 증상 리스트를 숨기고, 부드러운 질문 표시.
        -   *"오늘 몸에 불편한 점이 있으셨나요?"* (Yes/No 토글 또는 버튼).
    -   **Yes 선택 시**:
        -   증상 선택 칩(Chip) 나열 (메스꺼움, 두통 등 기존 항목).
        -   증상 선택 시, 해당 증상에 대한 **개별 심각도 슬라이더(1-10)**가 동적으로 생성됨.
        -   (기존 문제 해결: 모든 증상에 같은 점수가 들어가는 버그 수정).
### B. 네비게이션 연결
- [scaffold_with_bottom_nav.dart](cci:7://file:///Users/pro16/Desktop/project/n06/lib/core/presentation/widgets/scaffold_with_bottom_nav.dart:0:0-0:0) 수정.
- 하단 탭의 '기록(Record)' 버튼 클릭 시 `/tracking/weight` 대신 **새로운 `/tracking/daily` 라우트로 이동**하도록 변경.
### C. 데이터베이스 및 엔티티
- **기존 스키마 유지 원칙**: 테이블을 새로 만들지 말고 기존 `WeightLog`, [SymptomLog](cci:2://file:///Users/pro16/Desktop/project/n06/lib/features/tracking/domain/entities/symptom_log.dart:2:0-70:1)를 활용.
- **변경 사항**:
    -   `WeightLog` 엔티티/모델에 `appetiteScore` 필드 추가 (Migration 필요 시 처리).
    -   저장 로직: '저장' 버튼 1회 클릭 시 `WeightLog`와 [SymptomLog](cci:2://file:///Users/pro16/Desktop/project/n06/lib/features/tracking/domain/entities/symptom_log.dart:2:0-70:1)(여러 개)를 트랜잭션 또는 순차적으로 저장.
## 3. 제약 사항 (Constraints)
- **Clean Architecture 준수**: Presentation, Domain, Data 레이어 분리 유지.
- **Provider**: Riverpod `TrackingNotifier`에 통합 저장 메서드(`saveDailyLog`) 구현.
- **기존 코드 재사용**: 날짜 선택 위젯, 입력 검증 로직 등은 최대한 재사용.
## 4. 결과물
- `DailyLogScreen` 구현 코드
- 수정된 `WeightLog` 엔티티 및 모델
- 수정된 `TrackingNotifier` 및 Repository
- 업데이트된 라우팅 및 네비게이션 설정