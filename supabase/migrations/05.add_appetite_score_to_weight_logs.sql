-- ============================================
-- Migration 05: Add appetite_score column to weight_logs
-- ============================================
-- Date: 2025-11-24
-- Description: GLP-1 기록 기능 리팩토링 - 식욕 조절 점수 추가
-- Reference: docs/record_refactoring_final.md

-- Add appetite_score column to weight_logs table
ALTER TABLE public.weight_logs
ADD COLUMN appetite_score INTEGER CHECK (appetite_score >= 1 AND appetite_score <= 5);

-- Comment on column
COMMENT ON COLUMN public.weight_logs.appetite_score IS 'GLP-1 식욕 조절 점수: 1=아예없음, 2=매우감소, 3=약간감소, 4=보통, 5=폭발 (null=기록안함)';

-- 기존 데이터는 자동으로 NULL로 설정됨 (기존 데이터 호환)
