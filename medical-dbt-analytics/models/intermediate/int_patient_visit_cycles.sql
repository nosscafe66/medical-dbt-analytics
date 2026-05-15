WITH visit_events AS (
    SELECT
        user_id,
        questionnaireid,
        CAST(created_at AS TIMESTAMP) AS diagnosed_at
    FROM {{ ref('stg_medical_diagnosis_form') }}
),

calc_intervals AS (
    SELECT
        *,
        -- 1つ前の受診日を取得
        LAG(diagnosed_at) OVER(PARTITION BY user_id ORDER BY diagnosed_at) AS previous_diagnosed_at,
        -- 患者ごとの通算来院回数
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY diagnosed_at) AS visit_number
    FROM visit_events
)

SELECT
    *,
    -- 前回からの経過日数を計算
    DATE_DIFF(DATE(diagnosed_at), DATE(previous_diagnosed_at), DAY) AS days_since_last_visit,
    -- 初診か再診かのフラグ
    CASE 
        WHEN previous_diagnosed_at IS NULL THEN 'First Visit'
        ELSE 'Return Visit'
    END AS visit_type
FROM calc_intervals