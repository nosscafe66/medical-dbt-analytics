{{ config(
    materialized='table',
    description='1ユーザーを1レコードとしたディメンションテーブル。リピート率や治療成果の分析に使用。'
) }}

WITH patient_metrics AS (
    SELECT
        user_id,
        COUNT(questionnaireid) AS total_visits,
        MIN(diagnosed_at) AS first_visit_at,
        MAX(diagnosed_at) AS last_visit_at,
        AVG(physical_pain_severity_score) AS avg_pain_score,
        -- 初回と最新のスコアを比較するための抽出
        ARRAY_AGG(physical_pain_severity_score ORDER BY diagnosed_at ASC LIMIT 1)[OFFSET(0)] AS first_pain_score,
        ARRAY_AGG(physical_pain_severity_score ORDER BY diagnosed_at DESC LIMIT 1)[OFFSET(0)] AS latest_pain_score
    FROM {{ ref('int_medical_diagnoses_enriched') }}
    GROUP BY 1
)

SELECT
    u.user_id,
    u.user_name,
    u.gender,
    u.age,
    u.occupation,
    u.acquisition_channel,
    
    -- 集計指標
    m.total_visits,
    m.first_visit_at,
    m.last_visit_at,
    m.avg_pain_score,
    
    -- 治療効果の判定ロジック
    CASE 
        WHEN m.total_visits = 1 THEN 'First Visit Only'
        WHEN m.latest_pain_score < m.first_pain_score THEN 'Improved'
        WHEN m.latest_pain_score = m.first_pain_score THEN 'No Change'
        ELSE 'Worsened'
    END AS clinical_outcome,

    -- 継続期間（日）
    DATE_DIFF(DATE(m.last_visit_at), DATE(m.first_visit_at), DAY) AS retention_period_days

FROM {{ ref('stg_users') }} u
LEFT JOIN patient_metrics m ON u.user_id = m.user_id