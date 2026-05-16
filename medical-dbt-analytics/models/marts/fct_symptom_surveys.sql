{{
  config(
    materialized='table',
    schema="mart"
  )
}}

WITH survey_data AS (
    SELECT * FROM {{ ref('int_survey_trends') }}
),

-- 受診イベントから属性データを取得（1人1行に丸めたもの）
patient_attributes AS (
    SELECT
        user_id,
        gender,
        age_group,
        occupation
    FROM {{ ref('fct_diagnosis_events') }}
    QUALIFY ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY diagnosed_at DESC) = 1
)

SELECT
    s.*,
    p.gender,
    p.age_group,
    p.occupation
FROM survey_data AS s
LEFT JOIN patient_attributes AS p ON s.user_id = p.user_id