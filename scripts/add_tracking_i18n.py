#!/usr/bin/env python3
"""
Add tracking i18n keys to app_ko.arb and app_en.arb
"""

import json
import os
import sys

# Get the project root
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ko_path = os.path.join(project_root, 'lib', 'l10n', 'app_ko.arb')
en_path = os.path.join(project_root, 'lib', 'l10n', 'app_en.arb')

# Korean tracking strings
tracking_ko = {
    "tracking_dailyTracking_title": "데일리 기록",
    "@tracking_dailyTracking_title": {
        "description": "Daily tracking screen title"
    },
    "tracking_dailyTracking_bodySection": "신체 기록",
    "@tracking_dailyTracking_bodySection": {
        "description": "Body metrics section title"
    },
    "tracking_dailyTracking_sideEffectsSection": "부작용 기록 (선택)",
    "@tracking_dailyTracking_sideEffectsSection": {
        "description": "Side effects section title"
    },
    "tracking_dailyTracking_weightLabel": "체중 (kg)",
    "@tracking_dailyTracking_weightLabel": {
        "description": "Weight input label"
    },
    "tracking_dailyTracking_weightHint": "예: 75.5",
    "@tracking_dailyTracking_weightHint": {
        "description": "Weight input hint"
    },
    "tracking_dailyTracking_weightFieldName": "체중",
    "@tracking_dailyTracking_weightFieldName": {
        "description": "Weight field name for validation widget"
    },
    "tracking_dailyTracking_symptomSelection": "증상 선택",
    "@tracking_dailyTracking_symptomSelection": {
        "description": "Symptom selection section title"
    },
    "tracking_dailyTracking_selectedSymptoms": "선택된 증상",
    "@tracking_dailyTracking_selectedSymptoms": {
        "description": "Selected symptoms section title"
    },
    "tracking_dailyTracking_severityLabel": "심각도",
    "@tracking_dailyTracking_severityLabel": {
        "description": "Severity slider label"
    },
    "tracking_dailyTracking_persistent24Hours": "24시간 이상 지속되고 있나요?",
    "@tracking_dailyTracking_persistent24Hours": {
        "description": "24 hour persistence question"
    },
    "tracking_dailyTracking_persistentYes": "예",
    "@tracking_dailyTracking_persistentYes": {
        "description": "Persistent yes option"
    },
    "tracking_dailyTracking_persistentNo": "아니오",
    "@tracking_dailyTracking_persistentNo": {
        "description": "Persistent no option"
    },
    "tracking_dailyTracking_memoLabel": "메모 (선택)",
    "@tracking_dailyTracking_memoLabel": {
        "description": "Memo input label"
    },
    "tracking_dailyTracking_memoHint": "추가 메모를 입력하세요",
    "@tracking_dailyTracking_memoHint": {
        "description": "Memo input placeholder"
    },
    "tracking_dailyTracking_saveButton": "저장",
    "@tracking_dailyTracking_saveButton": {
        "description": "Save button text"
    },
    "tracking_dailyTracking_weightRequired": "체중을 입력해주세요",
    "@tracking_dailyTracking_weightRequired": {
        "description": "Weight required error message"
    },
    "tracking_dailyTracking_weightInvalid": "유효한 체중을 입력해주세요 (20-300kg)",
    "@tracking_dailyTracking_weightInvalid": {
        "description": "Invalid weight error message"
    },
    "tracking_dailyTracking_loginRequired": "로그인이 필요합니다",
    "@tracking_dailyTracking_loginRequired": {
        "description": "Login required error message"
    },
    "tracking_dailyTracking_saveFailed": "저장 중 오류가 발생했습니다: {error}",
    "@tracking_dailyTracking_saveFailed": {
        "description": "Save failed error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_symptom_nausea": "메스꺼움",
    "@tracking_symptom_nausea": {
        "description": "Symptom: Nausea - MEDICAL TERM"
    },
    "tracking_symptom_vomiting": "구토",
    "@tracking_symptom_vomiting": {
        "description": "Symptom: Vomiting - MEDICAL TERM"
    },
    "tracking_symptom_constipation": "변비",
    "@tracking_symptom_constipation": {
        "description": "Symptom: Constipation - MEDICAL TERM"
    },
    "tracking_symptom_diarrhea": "설사",
    "@tracking_symptom_diarrhea": {
        "description": "Symptom: Diarrhea - MEDICAL TERM"
    },
    "tracking_symptom_abdominalPain": "복통",
    "@tracking_symptom_abdominalPain": {
        "description": "Symptom: Abdominal pain - MEDICAL TERM"
    },
    "tracking_symptom_headache": "두통",
    "@tracking_symptom_headache": {
        "description": "Symptom: Headache - MEDICAL TERM"
    },
    "tracking_symptom_fatigue": "피로",
    "@tracking_symptom_fatigue": {
        "description": "Symptom: Fatigue - MEDICAL TERM"
    },
    "tracking_contextTag_oilyFood": "기름진음식",
    "@tracking_contextTag_oilyFood": {
        "description": "Context tag: Oily food"
    },
    "tracking_contextTag_overeating": "과식",
    "@tracking_contextTag_overeating": {
        "description": "Context tag: Overeating"
    },
    "tracking_contextTag_alcohol": "음주",
    "@tracking_contextTag_alcohol": {
        "description": "Context tag: Alcohol consumption"
    },
    "tracking_contextTag_emptyStomach": "공복",
    "@tracking_contextTag_emptyStomach": {
        "description": "Context tag: Empty stomach"
    },
    "tracking_contextTag_stress": "스트레스",
    "@tracking_contextTag_stress": {
        "description": "Context tag: Stress"
    },
    "tracking_contextTag_sleepDeprivation": "수면부족",
    "@tracking_contextTag_sleepDeprivation": {
        "description": "Context tag: Sleep deprivation"
    },
    "tracking_calendar_title": "투여 스케줄",
    "@tracking_calendar_title": {
        "description": "Dose calendar screen title"
    },
    "tracking_calendar_todayButton": "오늘",
    "@tracking_calendar_todayButton": {
        "description": "Today button tooltip"
    },
    "tracking_calendar_noPlan": "투여 계획이 없습니다",
    "@tracking_calendar_noPlan": {
        "description": "No plan message"
    },
    "tracking_calendar_noPlanDescription": "온보딩을 완료하여 투여 일정을 등록해주세요",
    "@tracking_calendar_noPlanDescription": {
        "description": "No plan description"
    },
    "tracking_calendar_pastRecordMode": "과거 기록 입력 모드",
    "@tracking_calendar_pastRecordMode": {
        "description": "Past record mode banner text"
    },
    "tracking_calendar_pastRecordModeComplete": "완료",
    "@tracking_calendar_pastRecordModeComplete": {
        "description": "Complete past record mode button"
    },
    "tracking_calendar_error": "오류가 발생했습니다: {error}",
    "@tracking_calendar_error": {
        "description": "Calendar error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_doseRecord_title": "투여 기록",
    "@tracking_doseRecord_title": {
        "description": "Dose record dialog title"
    },
    "tracking_doseRecord_dateLabel": "{month}월 {day}일 ({weekday})",
    "@tracking_doseRecord_dateLabel": {
        "description": "Date display in dose record dialog",
        "placeholders": {
            "month": {
                "type": "int",
                "example": "12"
            },
            "day": {
                "type": "int",
                "example": "4"
            },
            "weekday": {
                "type": "String",
                "example": "수"
            }
        }
    },
    "tracking_doseRecord_pastDateQuestion": "이 날짜에 실제로 투여하셨나요?",
    "@tracking_doseRecord_pastDateQuestion": {
        "description": "Past date confirmation question"
    },
    "tracking_doseRecord_pastDateInstructions": "• 예 → 아래에서 주사 부위를 선택하고 기록하세요\n• 아니오 → 실제 투여한 날짜를 선택해서 기록하세요",
    "@tracking_doseRecord_pastDateInstructions": {
        "description": "Past date instructions"
    },
    "tracking_doseRecord_doseAmount": "{dose} mg를 투여합니다.",
    "@tracking_doseRecord_doseAmount": {
        "description": "Dose amount display",
        "placeholders": {
            "dose": {
                "type": "double",
                "format": "decimalPattern"
            }
        }
    },
    "tracking_doseRecord_noteLabel": "메모 (선택사항)",
    "@tracking_doseRecord_noteLabel": {
        "description": "Note input label"
    },
    "tracking_doseRecord_noteHint": "메모를 입력하세요",
    "@tracking_doseRecord_noteHint": {
        "description": "Note input placeholder"
    },
    "tracking_doseRecord_cancelButton": "취소",
    "@tracking_doseRecord_cancelButton": {
        "description": "Cancel button text"
    },
    "tracking_doseRecord_saveButton": "저장",
    "@tracking_doseRecord_saveButton": {
        "description": "Save button text"
    },
    "tracking_doseRecord_siteRequired": "주사 부위를 선택해주세요",
    "@tracking_doseRecord_siteRequired": {
        "description": "Injection site required error"
    },
    "tracking_doseRecord_noPlanError": "활성 투여 계획이 없습니다",
    "@tracking_doseRecord_noPlanError": {
        "description": "No active plan error"
    },
    "tracking_doseRecord_saveSuccess": "투여 기록이 저장되었습니다",
    "@tracking_doseRecord_saveSuccess": {
        "description": "Save success message"
    },
    "tracking_doseRecord_saveError": "오류가 발생했습니다: {error}",
    "@tracking_doseRecord_saveError": {
        "description": "Save error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_trend_title": "트렌드 대시보드",
    "@tracking_trend_title": {
        "description": "Trend dashboard screen title"
    },
    "tracking_trend_loginRequired": "로그인이 필요합니다",
    "@tracking_trend_loginRequired": {
        "description": "Login required message"
    },
    "tracking_trend_periodWeekly": "주간",
    "@tracking_trend_periodWeekly": {
        "description": "Weekly period tab"
    },
    "tracking_trend_periodMonthly": "월간",
    "@tracking_trend_periodMonthly": {
        "description": "Monthly period tab"
    },
    "tracking_trend_calendarTitle": "일상 상태 캘린더",
    "@tracking_trend_calendarTitle": {
        "description": "Daily condition calendar section title"
    },
    "tracking_trend_calendarSubtitle": "날짜별 컨디션을 확인하세요",
    "@tracking_trend_calendarSubtitle": {
        "description": "Daily condition calendar section subtitle"
    },
    "tracking_trend_conditionTitle": "컨디션 추이",
    "@tracking_trend_conditionTitle": {
        "description": "Condition trend section title"
    },
    "tracking_trend_conditionSubtitle": "6가지 영역별 상태를 확인하세요",
    "@tracking_trend_conditionSubtitle": {
        "description": "Condition trend section subtitle"
    },
    "tracking_trend_detailTitle": "일별 상세 차트",
    "@tracking_trend_detailTitle": {
        "description": "Daily detail chart section title"
    },
    "tracking_trend_detailSubtitle": "영역별 일간 변화를 확인하세요",
    "@tracking_trend_detailSubtitle": {
        "description": "Daily detail chart section subtitle"
    },
    "tracking_trend_dayDetailDate": "{month}월 {day}일",
    "@tracking_trend_dayDetailDate": {
        "description": "Day detail date display",
        "placeholders": {
            "month": {
                "type": "int",
                "example": "12"
            },
            "day": {
                "type": "int",
                "example": "4"
            }
        }
    },
    "tracking_trend_overallCondition": "전반적 컨디션",
    "@tracking_trend_overallCondition": {
        "description": "Overall condition label"
    },
    "tracking_trend_scoreDisplay": "{score}점",
    "@tracking_trend_scoreDisplay": {
        "description": "Score display format",
        "placeholders": {
            "score": {
                "type": "int",
                "example": "85"
            }
        }
    },
    "tracking_trend_gradeLabel": "컨디션 등급",
    "@tracking_trend_gradeLabel": {
        "description": "Condition grade label"
    },
    "tracking_trend_gradeExcellent": "아주 좋음",
    "@tracking_trend_gradeExcellent": {
        "description": "Excellent condition grade"
    },
    "tracking_trend_gradeGood": "좋음",
    "@tracking_trend_gradeGood": {
        "description": "Good condition grade"
    },
    "tracking_trend_gradeFair": "보통",
    "@tracking_trend_gradeFair": {
        "description": "Fair condition grade"
    },
    "tracking_trend_gradePoor": "주의",
    "@tracking_trend_gradePoor": {
        "description": "Poor condition grade"
    },
    "tracking_trend_gradeBad": "나쁨",
    "@tracking_trend_gradeBad": {
        "description": "Bad condition grade"
    },
    "tracking_trend_redFlagWarning": "주의가 필요한 증상이 기록되었습니다",
    "@tracking_trend_redFlagWarning": {
        "description": "Red flag warning message"
    },
    "tracking_trend_postInjectionLabel": "주사 다음날이에요",
    "@tracking_trend_postInjectionLabel": {
        "description": "Post injection day label"
    },
    "tracking_trend_errorMessage": "데이터를 불러오는 중 오류가 발생했어요",
    "@tracking_trend_errorMessage": {
        "description": "Data loading error message"
    },
    "tracking_dosagePlan_editTitle": "투여 계획 수정",
    "@tracking_dosagePlan_editTitle": {
        "description": "Edit dosage plan screen title"
    },
    "tracking_dosagePlan_restartTitle": "투여 계획 재설정",
    "@tracking_dosagePlan_restartTitle": {
        "description": "Restart dosage plan screen title"
    },
    "tracking_dosagePlan_errorTitle": "오류가 발생했습니다",
    "@tracking_dosagePlan_errorTitle": {
        "description": "Error title"
    },
    "tracking_dosagePlan_noPlanMessage": "활성 투여 계획이 없습니다",
    "@tracking_dosagePlan_noPlanMessage": {
        "description": "No active plan message"
    },
    "tracking_dosagePlan_formTitle": "투여 계획 수정",
    "@tracking_dosagePlan_formTitle": {
        "description": "Form section title"
    },
    "tracking_dosagePlan_medicationLabel": "약물명",
    "@tracking_dosagePlan_medicationLabel": {
        "description": "Medication field label"
    },
    "tracking_dosagePlan_medicationHint": "약물을 선택하세요",
    "@tracking_dosagePlan_medicationHint": {
        "description": "Medication field hint"
    },
    "tracking_dosagePlan_medicationHelp": "약물을 선택하면 용량을 선택할 수 있습니다",
    "@tracking_dosagePlan_medicationHelp": {
        "description": "Medication field help text"
    },
    "tracking_dosagePlan_doseLabel": "초기 용량 (mg)",
    "@tracking_dosagePlan_doseLabel": {
        "description": "Initial dose field label"
    },
    "tracking_dosagePlan_doseHint": "용량을 선택하세요",
    "@tracking_dosagePlan_doseHint": {
        "description": "Dose field hint"
    },
    "tracking_dosagePlan_doseHintDisabled": "먼저 약물을 선택하세요",
    "@tracking_dosagePlan_doseHintDisabled": {
        "description": "Dose field hint when disabled"
    },
    "tracking_dosagePlan_doseDisplay": "{dose} mg",
    "@tracking_dosagePlan_doseDisplay": {
        "description": "Dose display format",
        "placeholders": {
            "dose": {
                "type": "double",
                "format": "decimalPattern"
            }
        }
    },
    "tracking_dosagePlan_cycleLabel": "투여 주기",
    "@tracking_dosagePlan_cycleLabel": {
        "description": "Cycle period field label"
    },
    "tracking_dosagePlan_cycleDisplay": "{days}일 (매주)",
    "@tracking_dosagePlan_cycleDisplay": {
        "description": "Cycle period display format",
        "placeholders": {
            "days": {
                "type": "int",
                "example": "7"
            }
        }
    },
    "tracking_dosagePlan_cycleHelp": "약물에 따라 자동으로 설정됩니다",
    "@tracking_dosagePlan_cycleHelp": {
        "description": "Cycle period help text"
    },
    "tracking_dosagePlan_startDateLabel": "시작일",
    "@tracking_dosagePlan_startDateLabel": {
        "description": "Start date field label"
    },
    "tracking_dosagePlan_selectMedicationError": "약물을 선택하세요",
    "@tracking_dosagePlan_selectMedicationError": {
        "description": "Select medication error"
    },
    "tracking_dosagePlan_selectDoseError": "용량을 선택하세요",
    "@tracking_dosagePlan_selectDoseError": {
        "description": "Select dose error"
    },
    "tracking_dosagePlan_updateSuccess": "투여 계획이 수정되었습니다",
    "@tracking_dosagePlan_updateSuccess": {
        "description": "Update success message"
    },
    "tracking_dosagePlan_updateFailed": "업데이트 실패",
    "@tracking_dosagePlan_updateFailed": {
        "description": "Update failed error"
    },
    "tracking_dosagePlan_updateError": "오류 발생: {error}",
    "@tracking_dosagePlan_updateError": {
        "description": "Update error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_emergency_title": "증상 체크",
    "@tracking_emergency_title": {
        "description": "Emergency check screen title"
    },
    "tracking_emergency_question": "다음 증상 중 해당하는 것이 있나요?",
    "@tracking_emergency_question": {
        "description": "Emergency symptoms question"
    },
    "tracking_emergency_instruction": "해당하는 증상을 선택해주세요.",
    "@tracking_emergency_instruction": {
        "description": "Emergency symptoms selection instruction"
    },
    "tracking_emergency_noSymptomsButton": "해당 없음",
    "@tracking_emergency_noSymptomsButton": {
        "description": "No symptoms button"
    },
    "tracking_emergency_confirmButton": "확인",
    "@tracking_emergency_confirmButton": {
        "description": "Confirm button"
    },
    "tracking_emergency_symptom1": "24시간 이상 계속 구토하고 있어요",
    "@tracking_emergency_symptom1": {
        "description": "Emergency symptom 1 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom2": "물이나 음식을 전혀 삼킬 수 없어요",
    "@tracking_emergency_symptom2": {
        "description": "Emergency symptom 2 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom3": "매우 심한 복통이 있어요 (견디기 어려운 정도)",
    "@tracking_emergency_symptom3": {
        "description": "Emergency symptom 3 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom4": "설사가 48시간 이상 계속되고 있어요",
    "@tracking_emergency_symptom4": {
        "description": "Emergency symptom 4 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom5": "소변이 진한 갈색이거나 8시간 이상 나오지 않았어요",
    "@tracking_emergency_symptom5": {
        "description": "Emergency symptom 5 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom6": "대변에 피가 섞여 있거나 검은색이에요",
    "@tracking_emergency_symptom6": {
        "description": "Emergency symptom 6 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom7": "피부나 눈 흰자위가 노랗게 변했어요",
    "@tracking_emergency_symptom7": {
        "description": "Emergency symptom 7 - MEDICAL CONTENT"
    },
    "tracking_emergency_saveSuccess": "증상이 기록되었습니다.",
    "@tracking_emergency_saveSuccess": {
        "description": "Emergency symptoms save success message"
    },
    "tracking_emergency_saveFailed": "기록 실패: {error}",
    "@tracking_emergency_saveFailed": {
        "description": "Emergency symptoms save failed message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_weekday_monday": "월",
    "@tracking_weekday_monday": {
        "description": "Monday abbreviation"
    },
    "tracking_weekday_tuesday": "화",
    "@tracking_weekday_tuesday": {
        "description": "Tuesday abbreviation"
    },
    "tracking_weekday_wednesday": "수",
    "@tracking_weekday_wednesday": {
        "description": "Wednesday abbreviation"
    },
    "tracking_weekday_thursday": "목",
    "@tracking_weekday_thursday": {
        "description": "Thursday abbreviation"
    },
    "tracking_weekday_friday": "금",
    "@tracking_weekday_friday": {
        "description": "Friday abbreviation"
    },
    "tracking_weekday_saturday": "토",
    "@tracking_weekday_saturday": {
        "description": "Saturday abbreviation"
    },
    "tracking_weekday_sunday": "일",
    "@tracking_weekday_sunday": {
        "description": "Sunday abbreviation"
    }
}

# English tracking strings
tracking_en = {
    "tracking_dailyTracking_title": "Daily Tracking",
    "@tracking_dailyTracking_title": {
        "description": "Daily tracking screen title"
    },
    "tracking_dailyTracking_bodySection": "Body Metrics",
    "@tracking_dailyTracking_bodySection": {
        "description": "Body metrics section title"
    },
    "tracking_dailyTracking_sideEffectsSection": "Side Effects (Optional)",
    "@tracking_dailyTracking_sideEffectsSection": {
        "description": "Side effects section title"
    },
    "tracking_dailyTracking_weightLabel": "Weight (kg)",
    "@tracking_dailyTracking_weightLabel": {
        "description": "Weight input label"
    },
    "tracking_dailyTracking_weightHint": "e.g., 75.5",
    "@tracking_dailyTracking_weightHint": {
        "description": "Weight input hint"
    },
    "tracking_dailyTracking_weightFieldName": "Weight",
    "@tracking_dailyTracking_weightFieldName": {
        "description": "Weight field name for validation widget"
    },
    "tracking_dailyTracking_symptomSelection": "Select Symptoms",
    "@tracking_dailyTracking_symptomSelection": {
        "description": "Symptom selection section title"
    },
    "tracking_dailyTracking_selectedSymptoms": "Selected Symptoms",
    "@tracking_dailyTracking_selectedSymptoms": {
        "description": "Selected symptoms section title"
    },
    "tracking_dailyTracking_severityLabel": "Severity",
    "@tracking_dailyTracking_severityLabel": {
        "description": "Severity slider label"
    },
    "tracking_dailyTracking_persistent24Hours": "Has this lasted more than 24 hours?",
    "@tracking_dailyTracking_persistent24Hours": {
        "description": "24 hour persistence question"
    },
    "tracking_dailyTracking_persistentYes": "Yes",
    "@tracking_dailyTracking_persistentYes": {
        "description": "Persistent yes option"
    },
    "tracking_dailyTracking_persistentNo": "No",
    "@tracking_dailyTracking_persistentNo": {
        "description": "Persistent no option"
    },
    "tracking_dailyTracking_memoLabel": "Notes (Optional)",
    "@tracking_dailyTracking_memoLabel": {
        "description": "Memo input label"
    },
    "tracking_dailyTracking_memoHint": "Add any notes",
    "@tracking_dailyTracking_memoHint": {
        "description": "Memo input placeholder"
    },
    "tracking_dailyTracking_saveButton": "Save",
    "@tracking_dailyTracking_saveButton": {
        "description": "Save button text"
    },
    "tracking_dailyTracking_weightRequired": "Please enter your weight",
    "@tracking_dailyTracking_weightRequired": {
        "description": "Weight required error message"
    },
    "tracking_dailyTracking_weightInvalid": "Please enter a valid weight (20-300kg)",
    "@tracking_dailyTracking_weightInvalid": {
        "description": "Invalid weight error message"
    },
    "tracking_dailyTracking_loginRequired": "Login required",
    "@tracking_dailyTracking_loginRequired": {
        "description": "Login required error message"
    },
    "tracking_dailyTracking_saveFailed": "Error saving: {error}",
    "@tracking_dailyTracking_saveFailed": {
        "description": "Save failed error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_symptom_nausea": "Nausea",
    "@tracking_symptom_nausea": {
        "description": "Symptom: Nausea - MEDICAL TERM"
    },
    "tracking_symptom_vomiting": "Vomiting",
    "@tracking_symptom_vomiting": {
        "description": "Symptom: Vomiting - MEDICAL TERM"
    },
    "tracking_symptom_constipation": "Constipation",
    "@tracking_symptom_constipation": {
        "description": "Symptom: Constipation - MEDICAL TERM"
    },
    "tracking_symptom_diarrhea": "Diarrhea",
    "@tracking_symptom_diarrhea": {
        "description": "Symptom: Diarrhea - MEDICAL TERM"
    },
    "tracking_symptom_abdominalPain": "Abdominal pain",
    "@tracking_symptom_abdominalPain": {
        "description": "Symptom: Abdominal pain - MEDICAL TERM"
    },
    "tracking_symptom_headache": "Headache",
    "@tracking_symptom_headache": {
        "description": "Symptom: Headache - MEDICAL TERM"
    },
    "tracking_symptom_fatigue": "Fatigue",
    "@tracking_symptom_fatigue": {
        "description": "Symptom: Fatigue - MEDICAL TERM"
    },
    "tracking_contextTag_oilyFood": "Oily food",
    "@tracking_contextTag_oilyFood": {
        "description": "Context tag: Oily food"
    },
    "tracking_contextTag_overeating": "Overeating",
    "@tracking_contextTag_overeating": {
        "description": "Context tag: Overeating"
    },
    "tracking_contextTag_alcohol": "Alcohol",
    "@tracking_contextTag_alcohol": {
        "description": "Context tag: Alcohol consumption"
    },
    "tracking_contextTag_emptyStomach": "Empty stomach",
    "@tracking_contextTag_emptyStomach": {
        "description": "Context tag: Empty stomach"
    },
    "tracking_contextTag_stress": "Stress",
    "@tracking_contextTag_stress": {
        "description": "Context tag: Stress"
    },
    "tracking_contextTag_sleepDeprivation": "Sleep deprivation",
    "@tracking_contextTag_sleepDeprivation": {
        "description": "Context tag: Sleep deprivation"
    },
    "tracking_calendar_title": "Dose Schedule",
    "@tracking_calendar_title": {
        "description": "Dose calendar screen title"
    },
    "tracking_calendar_todayButton": "Today",
    "@tracking_calendar_todayButton": {
        "description": "Today button tooltip"
    },
    "tracking_calendar_noPlan": "No dose plan found",
    "@tracking_calendar_noPlan": {
        "description": "No plan message"
    },
    "tracking_calendar_noPlanDescription": "Please complete onboarding to set up your schedule",
    "@tracking_calendar_noPlanDescription": {
        "description": "No plan description"
    },
    "tracking_calendar_pastRecordMode": "Past Record Mode",
    "@tracking_calendar_pastRecordMode": {
        "description": "Past record mode banner text"
    },
    "tracking_calendar_pastRecordModeComplete": "Done",
    "@tracking_calendar_pastRecordModeComplete": {
        "description": "Complete past record mode button"
    },
    "tracking_calendar_error": "Error occurred: {error}",
    "@tracking_calendar_error": {
        "description": "Calendar error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_doseRecord_title": "Record Dose",
    "@tracking_doseRecord_title": {
        "description": "Dose record dialog title"
    },
    "tracking_doseRecord_dateLabel": "{month}/{day} ({weekday})",
    "@tracking_doseRecord_dateLabel": {
        "description": "Date display in dose record dialog",
        "placeholders": {
            "month": {
                "type": "int",
                "example": "12"
            },
            "day": {
                "type": "int",
                "example": "4"
            },
            "weekday": {
                "type": "String",
                "example": "Wed"
            }
        }
    },
    "tracking_doseRecord_pastDateQuestion": "Did you actually take your dose on this date?",
    "@tracking_doseRecord_pastDateQuestion": {
        "description": "Past date confirmation question"
    },
    "tracking_doseRecord_pastDateInstructions": "• Yes → Select injection site and save\n• No → Select the actual date you took it",
    "@tracking_doseRecord_pastDateInstructions": {
        "description": "Past date instructions"
    },
    "tracking_doseRecord_doseAmount": "Administering {dose} mg.",
    "@tracking_doseRecord_doseAmount": {
        "description": "Dose amount display",
        "placeholders": {
            "dose": {
                "type": "double",
                "format": "decimalPattern"
            }
        }
    },
    "tracking_doseRecord_noteLabel": "Notes (Optional)",
    "@tracking_doseRecord_noteLabel": {
        "description": "Note input label"
    },
    "tracking_doseRecord_noteHint": "Add notes",
    "@tracking_doseRecord_noteHint": {
        "description": "Note input placeholder"
    },
    "tracking_doseRecord_cancelButton": "Cancel",
    "@tracking_doseRecord_cancelButton": {
        "description": "Cancel button text"
    },
    "tracking_doseRecord_saveButton": "Save",
    "@tracking_doseRecord_saveButton": {
        "description": "Save button text"
    },
    "tracking_doseRecord_siteRequired": "Please select injection site",
    "@tracking_doseRecord_siteRequired": {
        "description": "Injection site required error"
    },
    "tracking_doseRecord_noPlanError": "No active dosage plan found",
    "@tracking_doseRecord_noPlanError": {
        "description": "No active plan error"
    },
    "tracking_doseRecord_saveSuccess": "Dose recorded successfully",
    "@tracking_doseRecord_saveSuccess": {
        "description": "Save success message"
    },
    "tracking_doseRecord_saveError": "Error occurred: {error}",
    "@tracking_doseRecord_saveError": {
        "description": "Save error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_trend_title": "Trend Dashboard",
    "@tracking_trend_title": {
        "description": "Trend dashboard screen title"
    },
    "tracking_trend_loginRequired": "Login required",
    "@tracking_trend_loginRequired": {
        "description": "Login required message"
    },
    "tracking_trend_periodWeekly": "Weekly",
    "@tracking_trend_periodWeekly": {
        "description": "Weekly period tab"
    },
    "tracking_trend_periodMonthly": "Monthly",
    "@tracking_trend_periodMonthly": {
        "description": "Monthly period tab"
    },
    "tracking_trend_calendarTitle": "Condition Calendar",
    "@tracking_trend_calendarTitle": {
        "description": "Daily condition calendar section title"
    },
    "tracking_trend_calendarSubtitle": "View your daily condition",
    "@tracking_trend_calendarSubtitle": {
        "description": "Daily condition calendar section subtitle"
    },
    "tracking_trend_conditionTitle": "Condition Trends",
    "@tracking_trend_conditionTitle": {
        "description": "Condition trend section title"
    },
    "tracking_trend_conditionSubtitle": "Track 6 key areas",
    "@tracking_trend_conditionSubtitle": {
        "description": "Condition trend section subtitle"
    },
    "tracking_trend_detailTitle": "Daily Detail Charts",
    "@tracking_trend_detailTitle": {
        "description": "Daily detail chart section title"
    },
    "tracking_trend_detailSubtitle": "View daily changes by area",
    "@tracking_trend_detailSubtitle": {
        "description": "Daily detail chart section subtitle"
    },
    "tracking_trend_dayDetailDate": "{month}/{day}",
    "@tracking_trend_dayDetailDate": {
        "description": "Day detail date display",
        "placeholders": {
            "month": {
                "type": "int",
                "example": "12"
            },
            "day": {
                "type": "int",
                "example": "4"
            }
        }
    },
    "tracking_trend_overallCondition": "Overall Condition",
    "@tracking_trend_overallCondition": {
        "description": "Overall condition label"
    },
    "tracking_trend_scoreDisplay": "{score} pts",
    "@tracking_trend_scoreDisplay": {
        "description": "Score display format",
        "placeholders": {
            "score": {
                "type": "int",
                "example": "85"
            }
        }
    },
    "tracking_trend_gradeLabel": "Condition Grade",
    "@tracking_trend_gradeLabel": {
        "description": "Condition grade label"
    },
    "tracking_trend_gradeExcellent": "Excellent",
    "@tracking_trend_gradeExcellent": {
        "description": "Excellent condition grade"
    },
    "tracking_trend_gradeGood": "Good",
    "@tracking_trend_gradeGood": {
        "description": "Good condition grade"
    },
    "tracking_trend_gradeFair": "Fair",
    "@tracking_trend_gradeFair": {
        "description": "Fair condition grade"
    },
    "tracking_trend_gradePoor": "Poor",
    "@tracking_trend_gradePoor": {
        "description": "Poor condition grade"
    },
    "tracking_trend_gradeBad": "Bad",
    "@tracking_trend_gradeBad": {
        "description": "Bad condition grade"
    },
    "tracking_trend_redFlagWarning": "Symptoms needing attention were recorded",
    "@tracking_trend_redFlagWarning": {
        "description": "Red flag warning message"
    },
    "tracking_trend_postInjectionLabel": "Day after injection",
    "@tracking_trend_postInjectionLabel": {
        "description": "Post injection day label"
    },
    "tracking_trend_errorMessage": "Error loading data",
    "@tracking_trend_errorMessage": {
        "description": "Data loading error message"
    },
    "tracking_dosagePlan_editTitle": "Edit Dose Plan",
    "@tracking_dosagePlan_editTitle": {
        "description": "Edit dosage plan screen title"
    },
    "tracking_dosagePlan_restartTitle": "Restart Dose Plan",
    "@tracking_dosagePlan_restartTitle": {
        "description": "Restart dosage plan screen title"
    },
    "tracking_dosagePlan_errorTitle": "Error Occurred",
    "@tracking_dosagePlan_errorTitle": {
        "description": "Error title"
    },
    "tracking_dosagePlan_noPlanMessage": "No active dose plan found",
    "@tracking_dosagePlan_noPlanMessage": {
        "description": "No active plan message"
    },
    "tracking_dosagePlan_formTitle": "Edit Dose Plan",
    "@tracking_dosagePlan_formTitle": {
        "description": "Form section title"
    },
    "tracking_dosagePlan_medicationLabel": "Medication",
    "@tracking_dosagePlan_medicationLabel": {
        "description": "Medication field label"
    },
    "tracking_dosagePlan_medicationHint": "Select medication",
    "@tracking_dosagePlan_medicationHint": {
        "description": "Medication field hint"
    },
    "tracking_dosagePlan_medicationHelp": "Select medication to choose dose",
    "@tracking_dosagePlan_medicationHelp": {
        "description": "Medication field help text"
    },
    "tracking_dosagePlan_doseLabel": "Starting Dose (mg)",
    "@tracking_dosagePlan_doseLabel": {
        "description": "Initial dose field label"
    },
    "tracking_dosagePlan_doseHint": "Select dose",
    "@tracking_dosagePlan_doseHint": {
        "description": "Dose field hint"
    },
    "tracking_dosagePlan_doseHintDisabled": "Select medication first",
    "@tracking_dosagePlan_doseHintDisabled": {
        "description": "Dose field hint when disabled"
    },
    "tracking_dosagePlan_doseDisplay": "{dose} mg",
    "@tracking_dosagePlan_doseDisplay": {
        "description": "Dose display format",
        "placeholders": {
            "dose": {
                "type": "double",
                "format": "decimalPattern"
            }
        }
    },
    "tracking_dosagePlan_cycleLabel": "Dose Cycle",
    "@tracking_dosagePlan_cycleLabel": {
        "description": "Cycle period field label"
    },
    "tracking_dosagePlan_cycleDisplay": "{days} days (weekly)",
    "@tracking_dosagePlan_cycleDisplay": {
        "description": "Cycle period display format",
        "placeholders": {
            "days": {
                "type": "int",
                "example": "7"
            }
        }
    },
    "tracking_dosagePlan_cycleHelp": "Automatically set based on medication",
    "@tracking_dosagePlan_cycleHelp": {
        "description": "Cycle period help text"
    },
    "tracking_dosagePlan_startDateLabel": "Start Date",
    "@tracking_dosagePlan_startDateLabel": {
        "description": "Start date field label"
    },
    "tracking_dosagePlan_selectMedicationError": "Please select medication",
    "@tracking_dosagePlan_selectMedicationError": {
        "description": "Select medication error"
    },
    "tracking_dosagePlan_selectDoseError": "Please select dose",
    "@tracking_dosagePlan_selectDoseError": {
        "description": "Select dose error"
    },
    "tracking_dosagePlan_updateSuccess": "Dose plan updated",
    "@tracking_dosagePlan_updateSuccess": {
        "description": "Update success message"
    },
    "tracking_dosagePlan_updateFailed": "Update failed",
    "@tracking_dosagePlan_updateFailed": {
        "description": "Update failed error"
    },
    "tracking_dosagePlan_updateError": "Error occurred: {error}",
    "@tracking_dosagePlan_updateError": {
        "description": "Update error message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_emergency_title": "Symptom Check",
    "@tracking_emergency_title": {
        "description": "Emergency check screen title"
    },
    "tracking_emergency_question": "Do any of the following apply?",
    "@tracking_emergency_question": {
        "description": "Emergency symptoms question"
    },
    "tracking_emergency_instruction": "Select any symptoms that apply.",
    "@tracking_emergency_instruction": {
        "description": "Emergency symptoms selection instruction"
    },
    "tracking_emergency_noSymptomsButton": "None",
    "@tracking_emergency_noSymptomsButton": {
        "description": "No symptoms button"
    },
    "tracking_emergency_confirmButton": "Confirm",
    "@tracking_emergency_confirmButton": {
        "description": "Confirm button"
    },
    "tracking_emergency_symptom1": "Vomiting continuously for more than 24 hours",
    "@tracking_emergency_symptom1": {
        "description": "Emergency symptom 1 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom2": "Unable to swallow any food or water",
    "@tracking_emergency_symptom2": {
        "description": "Emergency symptom 2 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom3": "Severe abdominal pain (unbearable)",
    "@tracking_emergency_symptom3": {
        "description": "Emergency symptom 3 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom4": "Diarrhea continuing for more than 48 hours",
    "@tracking_emergency_symptom4": {
        "description": "Emergency symptom 4 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom5": "Dark brown urine or no urination for 8+ hours",
    "@tracking_emergency_symptom5": {
        "description": "Emergency symptom 5 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom6": "Blood in stool or black colored stool",
    "@tracking_emergency_symptom6": {
        "description": "Emergency symptom 6 - MEDICAL CONTENT"
    },
    "tracking_emergency_symptom7": "Yellowing of skin or whites of eyes",
    "@tracking_emergency_symptom7": {
        "description": "Emergency symptom 7 - MEDICAL CONTENT"
    },
    "tracking_emergency_saveSuccess": "Symptoms recorded.",
    "@tracking_emergency_saveSuccess": {
        "description": "Emergency symptoms save success message"
    },
    "tracking_emergency_saveFailed": "Save failed: {error}",
    "@tracking_emergency_saveFailed": {
        "description": "Emergency symptoms save failed message",
        "placeholders": {
            "error": {
                "type": "String",
                "example": "Network error"
            }
        }
    },
    "tracking_weekday_monday": "Mon",
    "@tracking_weekday_monday": {
        "description": "Monday abbreviation"
    },
    "tracking_weekday_tuesday": "Tue",
    "@tracking_weekday_tuesday": {
        "description": "Tuesday abbreviation"
    },
    "tracking_weekday_wednesday": "Wed",
    "@tracking_weekday_wednesday": {
        "description": "Wednesday abbreviation"
    },
    "tracking_weekday_thursday": "Thu",
    "@tracking_weekday_thursday": {
        "description": "Thursday abbreviation"
    },
    "tracking_weekday_friday": "Fri",
    "@tracking_weekday_friday": {
        "description": "Friday abbreviation"
    },
    "tracking_weekday_saturday": "Sat",
    "@tracking_weekday_saturday": {
        "description": "Saturday abbreviation"
    },
    "tracking_weekday_sunday": "Sun",
    "@tracking_weekday_sunday": {
        "description": "Sunday abbreviation"
    }
}

def add_tracking_keys():
    """Add tracking keys to both Korean and English ARB files"""

    # Read Korean ARB
    with open(ko_path, 'r', encoding='utf-8') as f:
        ko_arb = json.load(f)

    # Read English ARB
    with open(en_path, 'r', encoding='utf-8') as f:
        en_arb = json.load(f)

    # Add tracking keys
    ko_arb.update(tracking_ko)
    en_arb.update(tracking_en)

    # Write back Korean ARB
    with open(ko_path, 'w', encoding='utf-8') as f:
        json.dump(ko_arb, f, ensure_ascii=False, indent=2)

    # Write back English ARB
    with open(en_path, 'w', encoding='utf-8') as f:
        json.dump(en_arb, f, ensure_ascii=False, indent=2)

    print(f"✅ Added {len([k for k in tracking_ko if not k.startswith('@')])} tracking keys to app_ko.arb")
    print(f"✅ Added {len([k for k in tracking_en if not k.startswith('@')])} tracking keys to app_en.arb")

if __name__ == '__main__':
    add_tracking_keys()
