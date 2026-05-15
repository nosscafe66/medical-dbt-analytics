WITH progression AS (
    SELECT * FROM {{ ref('int_symptom_progression') }}
),

patients AS (
    SELECT 
        user_id,
        gender,
        age, -- 年齢を取得
        occupation
    FROM {{ ref('dim_patients') }}
)

SELECT
    p.gender,
    -- age から age_group を生成するロジックを追加
    CASE 
        WHEN p.age < 20 THEN '10s'
        WHEN p.age < 30 THEN '20s'
        WHEN p.age < 40 THEN '30s'
        WHEN p.age < 50 THEN '40s'
        WHEN p.age < 60 THEN '50s'
        ELSE '60s+' 
    END AS age_group,
    p.occupation,
    prog.*
FROM progression prog
LEFT JOIN patients p ON prog.user_id = p.user_id