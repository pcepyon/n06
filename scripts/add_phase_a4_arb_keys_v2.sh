#!/bin/bash
# Phase A-4: Application Layer i18n 키 추가 스크립트 v2
# 작성일: 2024-12-04

set -e

PROJECT_ROOT="/Users/pro16/Desktop/project/n06"
KO_ARB="$PROJECT_ROOT/lib/l10n/app_ko.arb"
EN_ARB="$PROJECT_ROOT/lib/l10n/app_en.arb"

echo "Phase A-4 ARB 키 추가 시작 (v2)..."

# 백업 생성
cp "$KO_ARB" "${KO_ARB}.backup2"
cp "$EN_ARB" "${EN_ARB}.backup2"

# 한국어 ARB 파일: 마지막 } 제거하고 , 추가 후 새 키 추가
python3 << 'PYTHON_EOF'
import json

ko_arb_path = '/Users/pro16/Desktop/project/n06/lib/l10n/app_ko.arb'
en_arb_path = '/Users/pro16/Desktop/project/n06/lib/l10n/app_en.arb'

# 한국어 ARB 처리
with open(ko_arb_path, 'r', encoding='utf-8') as f:
    ko_data = json.load(f)

# 한국어 새 키 추가
ko_new_keys = {
    "_comment_greeting": "===== Greeting Messages (daily_checkin) =====",
    "greeting_returningLongGap": "다시 만나서 반가워요 😊\n쉬어가는 것도 여정의 일부예요.\n오늘부터 다시 함께해요!",
    "@greeting_returningLongGap": {"description": "Returning user greeting for 7+ days gap"},
    "greeting_returningShortGap": "다시 만나서 반가워요 😊\n오늘부터 다시 함께해요!",
    "@greeting_returningShortGap": {"description": "Returning user greeting for 3-6 days gap"},
    "greeting_postInjection": "어제 주사 맞으셨죠?\n오늘 컨디션은 어떠세요? 💉",
    "@greeting_postInjection": {"description": "Post-injection day greeting"},
    "greeting_morningOne": "좋은 아침이에요 ☀️",
    "@greeting_morningOne": {"description": "Morning greeting variant 1"},
    "greeting_morningTwo": "오늘 하루도 화이팅! ☀️",
    "@greeting_morningTwo": {"description": "Morning greeting variant 2"},
    "greeting_morningThree": "좋은 아침이에요! 오늘도 함께해요 ☀️",
    "@greeting_morningThree": {"description": "Morning greeting variant 3"},
    "greeting_afternoonOne": "오늘 하루 어떠세요?",
    "@greeting_afternoonOne": {"description": "Afternoon greeting variant 1"},
    "greeting_afternoonTwo": "오후에도 잘 보내고 계신가요?",
    "@greeting_afternoonTwo": {"description": "Afternoon greeting variant 2"},
    "greeting_afternoonThree": "점심은 드셨나요?",
    "@greeting_afternoonThree": {"description": "Afternoon greeting variant 3"},
    "greeting_eveningOne": "오늘 하루 수고하셨어요 🌙",
    "@greeting_eveningOne": {"description": "Evening greeting variant 1"},
    "greeting_eveningTwo": "저녁이에요! 오늘 하루는 어떠셨어요?",
    "@greeting_eveningTwo": {"description": "Evening greeting variant 2"},
    "greeting_eveningThree": "하루를 마무리하며 체크인해요 🌙",
    "@greeting_eveningThree": {"description": "Evening greeting variant 3"},
    "greeting_nightOne": "늦은 시간까지 수고 많으셨어요",
    "@greeting_nightOne": {"description": "Night greeting variant 1"},
    "greeting_nightTwo": "오늘도 수고하셨어요 🌃",
    "@greeting_nightTwo": {"description": "Night greeting variant 2"},
    "greeting_nightThree": "하루를 마무리하고 계시군요",
    "@greeting_nightThree": {"description": "Night greeting variant 3"},

    "_comment_dashboard": "===== Dashboard Messages =====",
    "dashboard_errorNotAuthenticated": "사용자 인증이 필요합니다",
    "@dashboard_errorNotAuthenticated": {"description": "Error message for unauthenticated user"},
    "dashboard_errorProfileNotFound": "프로필을 찾을 수 없습니다. 온보딩을 완료해주세요.",
    "@dashboard_errorProfileNotFound": {"description": "Error message for missing user profile"},
    "dashboard_errorActivePlanNotFound": "활성 투여 계획을 찾을 수 없습니다. 약물 계획을 설정해주세요.",
    "@dashboard_errorActivePlanNotFound": {"description": "Error message for missing dosage plan"},
    "dashboard_timelineTreatmentStart": "치료 시작",
    "@dashboard_timelineTreatmentStart": {"description": "Timeline event title for treatment start"},
    "dashboard_timelineTreatmentStartDesc": "{doseMg}mg 투여 시작",
    "@dashboard_timelineTreatmentStartDesc": {"description": "Timeline event description for treatment start", "placeholders": {"doseMg": {"type": "String"}}},
    "dashboard_timelineEscalation": "용량 증량",
    "@dashboard_timelineEscalation": {"description": "Timeline event title for dose escalation"},
    "dashboard_timelineEscalationDesc": "{doseMg}mg로 증량",
    "@dashboard_timelineEscalationDesc": {"description": "Timeline event description for dose escalation", "placeholders": {"doseMg": {"type": "String"}}},
    "dashboard_timelineWeightMilestone": "목표 진행도 {milestonePercent}%",
    "@dashboard_timelineWeightMilestone": {"description": "Timeline event title for weight milestone", "placeholders": {"milestonePercent": {"type": "int"}}},
    "dashboard_timelineWeightMilestoneTitle": "목표 진행도 {milestonePercent}%",
    "@dashboard_timelineWeightMilestoneTitle": {"description": "Timeline weight milestone title", "placeholders": {"milestonePercent": {"type": "int"}}},
    "dashboard_timelineWeightMilestoneDesc": "{weightKg}kg 달성",
    "@dashboard_timelineWeightMilestoneDesc": {"description": "Timeline event description for weight milestone", "placeholders": {"weightKg": {"type": "String"}}},
    "dashboard_insight30DaysStreak": "대단해요! 30일 연속 기록을 달성했어요. 이대로라면 건강한 습관이 완성될 거예요!",
    "@dashboard_insight30DaysStreak": {"description": "Insight message for 30 days streak achievement"},
    "dashboard_insightWeeklyStreak": "축하합니다! 연속 {days}일 기록을 달성했어요. 좋은 기록 유지하세요!",
    "@dashboard_insightWeeklyStreak": {"description": "Insight message for weekly streak", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightWeeklyStreakWithDays": "축하합니다! 연속 {days}일 기록을 달성했어요. 좋은 기록 유지하세요!",
    "@dashboard_insightWeeklyStreakWithDays": {"description": "Insight message for weekly streak with days parameter", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightWeight10Percent": "놀라운 진전이에요! 목표의 10%를 달성했습니다. 계속 응원할게요!",
    "@dashboard_insightWeight10Percent": {"description": "Insight message for 10% weight loss achievement"},
    "dashboard_insightWeight5Percent": "훌륭해요! 이미 목표의 5%에 도달했어요. 현재 추세라면 목표 달성 가능해요!",
    "@dashboard_insightWeight5Percent": {"description": "Insight message for 5% weight loss achievement"},
    "dashboard_insightWeight1Percent": "좋은 시작이에요! 이미 첫 감량 목표를 달성했습니다. 계속 유지하세요!",
    "@dashboard_insightWeight1Percent": {"description": "Insight message for 1% weight loss achievement"},
    "dashboard_insightKeepRecording": "{days}일 동안 꾸준히 기록해주셨어요. 오늘도 계속해주세요!",
    "@dashboard_insightKeepRecording": {"description": "Insight message to encourage continued recording", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightKeepRecordingWithDays": "{days}일 동안 꾸준히 기록해주셨어요. 오늘도 계속해주세요!",
    "@dashboard_insightKeepRecordingWithDays": {"description": "Insight message to encourage continued recording with days parameter", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightFirstRecord": "오늘도 함께 목표를 향해 나아가요! 첫 기록을 해보세요.",
    "@dashboard_insightFirstRecord": {"description": "Insight message to encourage first record"},

    "_comment_copingGuide": "===== Coping Guide Default Messages - MEDICAL REVIEW REQUIRED =====",
    "copingGuide_defaultSymptomName": "일반",
    "@copingGuide_defaultSymptomName": {"description": "Default symptom name - MEDICAL REVIEW REQUIRED"},
    "copingGuide_defaultShortGuide": "전문가와 상담하여 구체적인 조언을 받으시기 바랍니다.",
    "@copingGuide_defaultShortGuide": {"description": "Default short guide message - MEDICAL REVIEW REQUIRED"},
    "copingGuide_defaultReassuranceMessage": "전문가와 함께 관리해봐요",
    "@copingGuide_defaultReassuranceMessage": {"description": "Default reassurance message - MEDICAL REVIEW REQUIRED"},
    "copingGuide_defaultImmediateAction": "의료진에게 문의하기",
    "@copingGuide_defaultImmediateAction": {"description": "Default immediate action message - MEDICAL REVIEW REQUIRED"}
}

ko_data.update(ko_new_keys)

with open(ko_arb_path, 'w', encoding='utf-8') as f:
    json.dump(ko_data, f, ensure_ascii=False, indent=2)

print("한국어 ARB 키 추가 완료")

# 영어 ARB 처리
with open(en_arb_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

en_new_keys = {
    "_comment_greeting": "===== Greeting Messages (daily_checkin) =====",
    "greeting_returningLongGap": "Welcome back! 😊\nResting is part of the journey too.\nLet's continue together from today!",
    "@greeting_returningLongGap": {"description": "Returning user greeting for 7+ days gap"},
    "greeting_returningShortGap": "Welcome back! 😊\nLet's continue together from today!",
    "@greeting_returningShortGap": {"description": "Returning user greeting for 3-6 days gap"},
    "greeting_postInjection": "You had your injection yesterday, right?\nHow are you feeling today? 💉",
    "@greeting_postInjection": {"description": "Post-injection day greeting"},
    "greeting_morningOne": "Good morning! ☀️",
    "@greeting_morningOne": {"description": "Morning greeting variant 1"},
    "greeting_morningTwo": "Have a great day! ☀️",
    "@greeting_morningTwo": {"description": "Morning greeting variant 2"},
    "greeting_morningThree": "Good morning! Let's make today count ☀️",
    "@greeting_morningThree": {"description": "Morning greeting variant 3"},
    "greeting_afternoonOne": "How's your day going?",
    "@greeting_afternoonOne": {"description": "Afternoon greeting variant 1"},
    "greeting_afternoonTwo": "Hope you're having a good afternoon!",
    "@greeting_afternoonTwo": {"description": "Afternoon greeting variant 2"},
    "greeting_afternoonThree": "Did you have lunch?",
    "@greeting_afternoonThree": {"description": "Afternoon greeting variant 3"},
    "greeting_eveningOne": "Good work today! 🌙",
    "@greeting_eveningOne": {"description": "Evening greeting variant 1"},
    "greeting_eveningTwo": "Good evening! How was your day?",
    "@greeting_eveningTwo": {"description": "Evening greeting variant 2"},
    "greeting_eveningThree": "Let's check in as the day wraps up 🌙",
    "@greeting_eveningThree": {"description": "Evening greeting variant 3"},
    "greeting_nightOne": "Thank you for your hard work today",
    "@greeting_nightOne": {"description": "Night greeting variant 1"},
    "greeting_nightTwo": "Well done today! 🌃",
    "@greeting_nightTwo": {"description": "Night greeting variant 2"},
    "greeting_nightThree": "Wrapping up your day, I see",
    "@greeting_nightThree": {"description": "Night greeting variant 3"},

    "_comment_dashboard": "===== Dashboard Messages =====",
    "dashboard_errorNotAuthenticated": "User authentication required",
    "@dashboard_errorNotAuthenticated": {"description": "Error message for unauthenticated user"},
    "dashboard_errorProfileNotFound": "User profile not found. Please complete onboarding first.",
    "@dashboard_errorProfileNotFound": {"description": "Error message for missing user profile"},
    "dashboard_errorActivePlanNotFound": "Active dosage plan not found. Please set up your medication plan.",
    "@dashboard_errorActivePlanNotFound": {"description": "Error message for missing dosage plan"},
    "dashboard_timelineTreatmentStart": "Treatment Start",
    "@dashboard_timelineTreatmentStart": {"description": "Timeline event title for treatment start"},
    "dashboard_timelineTreatmentStartDesc": "Started {doseMg}mg dose",
    "@dashboard_timelineTreatmentStartDesc": {"description": "Timeline event description for treatment start", "placeholders": {"doseMg": {"type": "String"}}},
    "dashboard_timelineEscalation": "Dose Escalation",
    "@dashboard_timelineEscalation": {"description": "Timeline event title for dose escalation"},
    "dashboard_timelineEscalationDesc": "Increased to {doseMg}mg",
    "@dashboard_timelineEscalationDesc": {"description": "Timeline event description for dose escalation", "placeholders": {"doseMg": {"type": "String"}}},
    "dashboard_timelineWeightMilestone": "{milestonePercent}% Goal Progress",
    "@dashboard_timelineWeightMilestone": {"description": "Timeline event title for weight milestone", "placeholders": {"milestonePercent": {"type": "int"}}},
    "dashboard_timelineWeightMilestoneTitle": "{milestonePercent}% Goal Progress",
    "@dashboard_timelineWeightMilestoneTitle": {"description": "Timeline weight milestone title", "placeholders": {"milestonePercent": {"type": "int"}}},
    "dashboard_timelineWeightMilestoneDesc": "Reached {weightKg}kg",
    "@dashboard_timelineWeightMilestoneDesc": {"description": "Timeline event description for weight milestone", "placeholders": {"weightKg": {"type": "String"}}},
    "dashboard_insight30DaysStreak": "Amazing! You've achieved a 30-day streak. Keep it up and you'll build a lasting healthy habit!",
    "@dashboard_insight30DaysStreak": {"description": "Insight message for 30 days streak achievement"},
    "dashboard_insightWeeklyStreak": "Congratulations! You've achieved a {days}-day streak. Keep up the good work!",
    "@dashboard_insightWeeklyStreak": {"description": "Insight message for weekly streak", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightWeeklyStreakWithDays": "Congratulations! You've achieved a {days}-day streak. Keep up the good work!",
    "@dashboard_insightWeeklyStreakWithDays": {"description": "Insight message for weekly streak with days parameter", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightWeight10Percent": "Incredible progress! You've reached 10% of your goal. Keep going!",
    "@dashboard_insightWeight10Percent": {"description": "Insight message for 10% weight loss achievement"},
    "dashboard_insightWeight5Percent": "Excellent! You've already reached 5% of your goal. At this rate, you'll achieve your goal!",
    "@dashboard_insightWeight5Percent": {"description": "Insight message for 5% weight loss achievement"},
    "dashboard_insightWeight1Percent": "Great start! You've achieved your first weight loss milestone. Keep it up!",
    "@dashboard_insightWeight1Percent": {"description": "Insight message for 1% weight loss achievement"},
    "dashboard_insightKeepRecording": "You've been tracking consistently for {days} days. Keep it going today!",
    "@dashboard_insightKeepRecording": {"description": "Insight message to encourage continued recording", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightKeepRecordingWithDays": "You've been tracking consistently for {days} days. Keep it going today!",
    "@dashboard_insightKeepRecordingWithDays": {"description": "Insight message to encourage continued recording with days parameter", "placeholders": {"days": {"type": "int"}}},
    "dashboard_insightFirstRecord": "Let's work toward your goal together! Start your first record today.",
    "@dashboard_insightFirstRecord": {"description": "Insight message to encourage first record"},

    "_comment_copingGuide": "===== Coping Guide Default Messages - MEDICAL REVIEW REQUIRED =====",
    "copingGuide_defaultSymptomName": "General",
    "@copingGuide_defaultSymptomName": {"description": "Default symptom name - MEDICAL REVIEW REQUIRED"},
    "copingGuide_defaultShortGuide": "Please consult with a healthcare professional for specific advice.",
    "@copingGuide_defaultShortGuide": {"description": "Default short guide message - MEDICAL REVIEW REQUIRED"},
    "copingGuide_defaultReassuranceMessage": "Let's manage this with professional help",
    "@copingGuide_defaultReassuranceMessage": {"description": "Default reassurance message - MEDICAL REVIEW REQUIRED"},
    "copingGuide_defaultImmediateAction": "Contact your healthcare provider",
    "@copingGuide_defaultImmediateAction": {"description": "Default immediate action message - MEDICAL REVIEW REQUIRED"}
}

en_data.update(en_new_keys)

with open(en_arb_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)

print("영어 ARB 키 추가 완료")
PYTHON_EOF

echo "Phase A-4 ARB 키 추가 완료 (v2)!"
echo ""
echo "백업 파일:"
echo "  - ${KO_ARB}.backup2"
echo "  - ${EN_ARB}.backup2"
