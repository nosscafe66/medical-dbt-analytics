{{ config(
    materialized='table',
    description='1回の受診・問診を1レコードとしたファクトテーブル。時系列分析に使用。'
) }}

SELECT
    questionnaireid,
    user_id,
    diagnosed_at,
    -- 日付軸の整理
    DATE(diagnosed_at) AS diagnosed_date,
    EXTRACT(YEAR FROM diagnosed_at) AS diagnosed_year,
    EXTRACT(MONTH FROM diagnosed_at) AS diagnosed_month,
    EXTRACT(DAYOFWEEK FROM diagnosed_at) AS diagnosed_day_of_week,

    -- 属性（Intermediateから引き継ぎ）
    gender,
    age_group,
    occupation,
    visit_type,
    visit_number,

    -- 主要な症状フラグとスコア
    has_neck_shoulder_pain,
    has_mental_fatigue,
    physical_pain_severity_score,

    -- 定性データ
    mainComplaint,
    treatment_memo,

    -- 解析用JSON
    marks_json,
    chakura_marks_json

FROM {{ ref('int_medical_diagnoses_enriched') }}