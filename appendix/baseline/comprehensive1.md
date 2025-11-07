# GLP-1 수용체 작용제 치료 관리 앱 개발을 위한 2025년 최신 데이터 종합 분석

Wegovy(세마글루타이드)와 Mounjaro(티르제파타이드)의 자가 주사 사용자를 위한 치료 관리 애플리케이션 구축에 필요한 공식 규제 기관 및 동료 심사 데이터를 종합했습니다.

## 핵심 데이터 요약표

| 카테고리 | 주요 발견사항 | 출처 (APA 또는 URL) | 연도 | 앱 적용 용도 |
|---------|-------------|------------------|------|-------------|
| **1. 용량 및 적정 스케줄링** |
| 세마글루타이드 용량 단계 | 시작용량 0.25mg → 0.5mg → 1mg → 1.7mg → 유지용량 2.4mg, 주 1회 투여, 총 16주 적정 기간 (각 단계 4주) | FDA Wegovy Prescribing Information (08/2025) https://www.accessdata.fda.gov/drugsatfda_docs/label/2025/215256s024lbl.pdf | 2025 | Scheduler |
| 세마글루타이드 고용량 | 신규 7.2mg 용량 승인: 72주차 평균 체중 감량 20.7% (2.4mg의 17.5% 대비 우수); 25% 이상 감량 달성률 33% | The Lancet Diabetes & Endocrinology (STEP UP Trial, 09/2025) | 2025 | Scheduler / Report |
| 티르제파타이드 용량 단계 | 시작용량 2.5mg (4주) → 5mg → 7.5mg → 10mg → 12.5mg → 최대 15mg, 주 1회, 최소 4주마다 2.5mg씩 증량 | FDA Mounjaro Prescribing Information (05/2025) | 2025 | Scheduler |
| 용량 내약성 지침 | 용량 증량 시 내약성 부족 시 4주 지연 권장 (중단하지 말 것); 실제 임상에서 80.8% 환자가 낮은 유지 용량에 머무름 | Gasoyan et al., Obesity 2025 https://onlinelibrary.wiley.com/doi/10.1002/oby.24331 | 2025 | Scheduler / UX |
| 누락 용량 관리 | 5일 이내 누락 시 즉시 투여 가능; 5일 초과 시 다음 예정 투여일까지 건너뛰기 | FDA/EMA Prescribing Information | 2025 | Scheduler / UX |
| 한국 식약처 승인 상태 | Wegovy: 2023년 승인, 2024년 10월 출시; Mounjaro: 2023년 당뇨 승인, 2024년 7월 비만 승인, 2025년 9월 수면무호흡증 승인 | Korean MFDS approval announcements | 2023-2025 | Scheduler |
| **2. 부작용 및 관리 지침** |
| 주요 위장관 부작용 빈도 (세마글루타이드) | 오심 44%, 설사 30%, 변비 24%, 구토 24%, 복통 20% (위약 대비 2-4배 높음); 대부분 경증-중등도, 일시적 | FDA Wegovy Label (08/2025) | 2025 | Side-effect / UX |
| 주요 위장관 부작용 빈도 (티르제파타이드) | 오심 20-40%, 설사 20-40%, 변비 20-40%, 구토 15-30% (용량 의존적); 73%가 경증-중등도 | ICER Report (09/2025) https://icer.org/wp-content/uploads/2025/09/ICER_Obesity_Draft-Report_For-Publication_090925.pdf | 2025 | Side-effect / UX |
| 부작용 발생 시기 | 용량 증량 초기(0-16주)에 가장 심함; 4-8주 후 개선; 새 용량 시작 후 1-4주가 최고점 | PMC Safety Review (07/2025) https://pmc.ncbi.nlm.nih.gov/articles/PMC12270588/ | 2025 | Side-effect / Scheduler |
| 치료 중단률 (부작용) | 세마글루타이드 6.8% (오심 1.8%, 구토 1.2%, 설사 0.7%); 티르제파타이드 6.1% (세마글루타이드 8.0%보다 낮음) | NEJM SURMOUNT-5 (05/2025) https://www.nejm.org/doi/full/10.1056/NEJMoa2416394 | 2025 | Report / UX |
| 오심/구토 가정 관리 | 소량 빈번한 식사(1일 5-6회), 고지방/기름진 음식 회피, 식후 2-3시간 눕지 않기, 생강차/페퍼민트차, 취침 전 주사 권장 | FDA Label + Clinical Practice Guidelines | 2025 | Side-effect / UX |
| 의사 상담 필요 기준 | 24시간 이상 지속 구토, 수분 섭취 불가, 탈수 징후(어두운 소변, 어지러움), 심한 복통, 혈변, 48시간 이상 설사, 3일 이상 배변 없음 | FDA Wegovy Prescribing Information | 2025 | Side-effect / UX |
| 심각한 이상반응 빈도 | 급성 췌장염 0.2/100인년, 담석증 1.6% (위약 0.7%), 담낭염 0.6%, 급성 신손상 0.4/100인년 | FDA Wegovy Label (08/2025) | 2025 | Side-effect / Report |
| 담낭 질환 위험 | 메타분석 76개 RCT: 상대위험도 1.37 (95% CI 1.23-1.52); 체중 감량 적응증 및 고용량에서 위험 증가 | PMC Safety Review (07/2025) | 2025 | Side-effect / Report |
| 수술 전 중단 지침 | 장기 작용형(세마글루타이드, 티르제파타이드) 수술 7일 이상 전 중단; 위 내용물 저류 위험; 표준 금식 지침 준수 | ANZCA Clinical Practice Recommendations (04/2025) https://www.anzca.edu.au | 2025 | UX / Side-effect |
| **3. 체중 변화 및 효능 추세** |
| 세마글루타이드 2.4mg 체중 감량 | STEP 1 (68주): 평균 14.9% 감량; 5% 이상 86%, 10% 이상 69%, 15% 이상 51% 달성 | NEJM STEP 1 / PMC Review | 2025 | Report |
| 세마글루타이드 장기 효능 | SELECT 4년 데이터: 평균 10.2% 감량 유지 (208주); 지속 치료 시 체중 유지 또는 추가 감량 | Nature Medicine (07/2024) https://www.nature.com/articles/s41591-024-02996-7 | 2024-2025 | Report |
| 티르제파타이드 용량별 효능 | 5mg: 15.0% 감량, 10mg: 19.5% 감량, 15mg: 20.9% 감량 (72주); 15mg에서 57%가 20% 이상 감량, 36.2%가 25% 이상 감량 | SURMOUNT-1 / NEJM (03/2025) | 2025 | Report / Scheduler |
| 직접 비교 연구 | 티르제파타이드 20.2% vs. 세마글루타이드 13.7% (72주); 차이 6.5%p (P<0.001); 25% 이상 감량 32% vs. 16% | NEJM SURMOUNT-5 (05/2025) | 2025 | Report |
| 체중 감량 시간대별 패턴 | 0-12주: 급격한 초기 감량, 12-36주: 가장 빠른 감량 속도, 36-72주: 감량 속도 둔화 및 정체기 도달; 60주차가 정점 | STEP 1 Analysis | 2025 | Report / Scheduler |
| 정체기 도달 시점 | 세마글루타이드: 60주, 티르제파타이드: 36-72주(88%가 72주까지 정체기 도달); 고용량, 젊은 연령, 여성에서 정체기 지연 | SURMOUNT plateau analysis | 2025 | Report / UX |
| 치료 중단 후 재증가 | 세마글루타이드 중단 1년 후 감량분의 2/3 재증가 (+11.6%p); 티르제파타이드 중단 후 +14.0% 재증가; 평균 +9.69kg 재증가 | MDPI Journal of Clinical Medicine (05/2025) https://www.mdpi.com/2077-0383/14/11/3791 | 2025 | Report / UX |
| 주간/월간 진행 패턴 | 0-4주: 초기 감량 시작, 4-36주: 지속적 감량, 36-60주: 감량 속도 감소, 60주+: 유지/정체기; 용량 증량마다 반복 패턴 | Clinical trial synthesis | 2025 | Report / Scheduler |
| **4. 순응도 및 환자 행동 통찰** |
| 실제 중단율 (세마글루타이드) | 덴마크 연구 (N=77,310): 3개월 18%, 6개월 31%, 9개월 42%, 12개월 52% 중단; 공급 안정화 후에도 48% 유지 | Thomsen et al., EASD 2025 https://www.tctmd.com/news/half-patients-stop-semaglutide-weight-loss-1-year | 2025 | Report / UX |
| 미국 적정 연구 | 46%가 5개월차에 중단; 57%만 유지 용량 도달 (22% 1.7mg, 34% 2.4mg); 권장 월별 증량 일정에서 대부분 이탈 | Xu et al., Obesity 2025 (PMID: 40464214) https://onlinelibrary.wiley.com/doi/10.1002/oby.24315 | 2025 | Scheduler / UX |
| 티르제파타이드 순응도 | 6개월 지속률 73.8% (다른 GLP-1보다 우수); 56.2%가 6번째 처방 시점에도 <10mg 용량 유지 (임상시험보다 느린 증량) | Hunter Gibble et al., Diabetes Obes Metab (06/2025) PMID: 40084533 | 2025 | Report / Scheduler |
| 중단 주요 원인 - 비용 | 월 $800-1,300 본인부담금; 최고 공동부담금 환자군($161-1,460)에서 33% 더 높은 중단율; 저소득층 14% 더 높은 중단 위험 | WTW Industry Report (04/2025) https://www.wtwco.com/en-us/insights/2025/04/glp-1-drugs-in-2025 | 2025 | UX / Report |
| 중단 원인 - 인구통계 | 젊은 연령(<40세), 고령(>75세), 남성(RR 1.12), 높은 동반질환 지수, 정신과/위장관 약물 과거 사용이 중단 예측 인자 | Danish T2D Study, Cardoso et al. (08/2025) PMID: 39215626 | 2025 | UX / Report |
| 환자 보고 장애물 | 55%가 10년 이상 체중 감량 시도; 주요 장애물: 식습관, 스트레스, 비용, 낙인, 부작용; 주사 자가 투여 주저함 | Naveed et al., Diabetes Obes Metab (07/2025) https://dom-pubs.onlinelibrary.wiley.com/doi/10.1111/dom.16405 | 2025 | UX |
| 접근성 격차 | 미국 적격 성인 3,900만 명 중 2.3%만 GLP-1 처방 받음; 3% 미만만 접근; 농촌/소외 지역 제한적 접근 | Kim et al., JAMA 2025 https://www.tctmd.com/news/access-glp-1-drugs-unequal-us-patients-obesity | 2025 | Report / UX |
| 디지털 교육 중재 효능 | 무작위 연구 (N=85): 6개월 추적 시 HbA1c -3.7% vs. -2.6%, 체중 감량 -8.7kg vs. -4.9kg, 약물 순응도 +13.8% vs. -8% (P=.01) | Caballero Mateos et al., J Med Internet Res (04/2025) https://www.jmir.org/2025/1/e60758 | 2025 | UX / Scheduler |
| 디지털 플랫폼 참여 효과 | Voy 플랫폼 연구: 디지털 플랫폼 참여가 체중 감량 결과 유의하게 향상; 행동 지원 + 약물 치료 조합 효과적; 높은 참여도 = 더 나은 결과 | Johnson et al., J Med Internet Res (03/2025) https://www.jmir.org/2025/1/e69466 | 2025 | UX |
| 모바일 앱 추적 기능 | 주사 로깅, 용량 추적, 부작용 모니터링, 체중/단백질/수분/칼로리 추적, 진행 시각화, 주사 부위 순환 추적, 약물 수준 추정, 주사 알림 | Shotsy GLP-1 Tracker (2025) https://shotsyapp.com/ | 2025 | Scheduler / UX / Side-effect |
| 관계 기반 지원 효과 | Omada Health 연구: 참여도가 높을수록 더 많은 체중 감량; 건강 코치, 동료 지원이 가장 성공적; 앱 기반 추적만으로는 부족 | Omada + Express Scripts (2023-2025) https://www.evernorth.com/articles/glp1s-digital-tools-weight-management | 2025 | UX |
| 원격 환자 모니터링 | 체성분 스케일 연동 (지방 vs. 근육량 구별); 12개월 93%, 24개월 90% 스케일 유지율; 근육량 손실 모니터링 중요 | Withings Health Solutions (10/2025) https://www.prnewswire.com | 2025 | Report / UX |
| 전문 약국 지원 서비스 | 환자 교육, 주사 기술 훈련, 비디오 튜토리얼, 실시간 약사 지원, 사전 추적 관찰, 용량 조정, 부작용 관리, 보험 탐색 지원으로 순응도 개선 | Shields Health Solutions Report https://shieldshealthsolutions.com/glp1-access-adherence-specialty-pharmacy/ | 2025 | UX / Scheduler |
| 복용량 오류 위험 | 복합 약물 사용자: 의도한 용량의 5-20배 투여 사례; "단위" 측정 vs. mg/mL 혼동; 부정확한 주사기 사용; 명확한 지침 필요 | FDA Safety Alert (04/2025) | 2025 | Scheduler / UX |

## 애플리케이션 설계를 위한 핵심 권장사항

### 1. 정확한 스케줄러 기능
- **16-20주 단계적 용량 증량 자동 추적**: 각 용량 단계별 4주 알림, 증량 준비 체크리스트
- **내약성 조정 옵션**: 부작용 심할 시 4주 지연 제안 기능
- **누락 용량 관리**: 5일 이내/초과 시 다른 지침 제공
- **주사 부위 순환 추적**: 복부/허벅지/팔 순환 알림

### 2. 부작용 관리 및 교육
- **시기별 맞춤 경고**: 용량 증량 후 1-4주 집중 모니터링
- **가정 관리 가이드**: 오심/설사/변비별 실행 가능한 조언
- **의사 상담 임계값 자동 감지**: 심각성 평가 알고리즘
- **일지 추적**: 일일 부작용 심각도 평가 (1-10 척도)

### 3. 체중 변화 리포트
- **예상 체중 감량 곡선**: 용량 및 주차별 평균 범위 표시
- **정체기 예측 및 대응**: 36-60주차 정체기 교육 자료
- **장기 추적 (4년)**: 지속 치료 시 유지 패턴 시각화
- **중단 위험 경고**: 체중 재증가 가능성(2/3 재증가) 데이터 공유

### 4. 순응도 향상 UX
- **고위험 중단 시기 집중 지원**: 3-6개월차 특별 체크인
- **비용 투명성**: 월별 비용 추적, 보험 탐색 리소스 링크
- **관계 기반 기능**: 동료 지원 커뮤니티, 코칭 연결
- **양방향 소통**: 챗봇, 약사 실시간 상담, WhatsApp/Instagram 통합
- **멀티 플랫폼**: 웨어러블 연동, 체성분 스케일 연동, 식사/운동 추적
- **게이미피케이션**: 마일스톤 달성 보상 (5%, 10%, 15% 감량)

---

**데이터 출처**: FDA, EMA, KFDA 공식 문서, NEJM, Nature Medicine, Lancet, JAMA, Obesity, Diabetes Care, J Med Internet Res 등 2025년 발행 동료 심사 논문, Novo Nordisk 및 Eli Lilly 공식 문서, 실제 임상 데이터베이스 연구 (N=77,310 ~ 44,343)

**중요 참고사항**: 본 자료는 2025년 11월 기준 최신 공식 및 학술 데이터를 종합한 것으로, 애플리케이션 개발 시 의료 전문가 자문 및 현지 규제 검토가 필수적입니다.