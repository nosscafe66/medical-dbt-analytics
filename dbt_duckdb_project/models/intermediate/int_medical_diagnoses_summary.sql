{{
  config(
    materialized='table',
    schema="intermediate"
  )
}}
WITH users AS (
    SELECT * FROM {{ ref('stg_users') }}
),
forms AS (
    SELECT * FROM {{ ref('stg_medical_diagnosis_form') }}
),
-- ユーザーごとの受診回数を計算
visit_ordered AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY CAST(created_at AS TIMESTAMP)) as visit_number
    FROM forms
)

SELECT
    -- 1. 基本キー
    f.user_id,
    f.questionnaireid,
    CAST(f.created_at AS TIMESTAMP) AS diagnosed_at,

    -- 2. ユーザー属性（分析の切り口）
    u.gender,
    u.age,
    CASE 
        WHEN u.age < 20 THEN '10s'
        WHEN u.age < 30 THEN '20s'
        WHEN u.age < 40 THEN '30s'
        WHEN u.age < 50 THEN '40s'
        WHEN u.age < 60 THEN '50s'
        ELSE '60s+' 
    END AS age_group,
    u.occupation,

    -- 3. 受診コンテキスト
    CASE WHEN f.visit_number = 1 THEN 'First Visit' ELSE 'Follow-up' END AS visit_type,
    f.visit_number,

    -- 4. 症状の集計（Lightdashで合計しやすい形に）
    -- 肩・首周りの悩みがあるか
    (f.mss_stiffneck_most OR f.mss_stiffness_most OR f.mss_backstiffness_most) AS has_neck_shoulder_pain,
    
    -- 精神的疲労に関連するフラグ
    (f.mss_insomnia_most OR f.mss_irritability_most) AS has_mental_fatigue,

    -- 重症フラグの合計（深刻度スコア）
    (
        CAST(f.mss_armpain_most AS INT64) + 
        CAST(f.mss_legpain_most AS INT64) + 
        CAST(f.mss_stiffneck_most AS INT64) +
        CAST(f.mss_lkowerback_most AS INT64)
    ) AS physical_pain_severity_score,

    -- 5. 解析用JSON（Lightdash側で利用可能）
    f.marks_json,
    f.chakura_marks_json

FROM visit_ordered f
LEFT JOIN users u ON f.user_id = u.user_id