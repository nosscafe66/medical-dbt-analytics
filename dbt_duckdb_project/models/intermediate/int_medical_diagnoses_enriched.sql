WITH users AS (
    SELECT * FROM {{ ref('stg_users') }}
),

forms AS (
    SELECT * FROM {{ ref('stg_medical_diagnosis_form') }}
),

logic_added AS (
    SELECT 
        *,
        CAST(created_at AS TIMESTAMP) AS diagnosed_at,
        (
            CAST(mss_armpain_most AS INT64) + 
            CAST(mss_legpain_most AS INT64) + 
            CAST(mss_stiffneck_most AS INT64) +
            CAST(mss_lkowerback_most AS INT64)
        ) AS physical_pain_severity_score,
        (mss_stiffneck_most OR mss_stiffness_most OR mss_backstiffness_most) AS has_neck_shoulder_pain,
        (mss_insomnia_most OR mss_irritability_most) AS has_mental_fatigue
    FROM forms
)

SELECT
    l.user_id,
    l.questionnaireid,
    l.diagnosed_at,
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

    -- 受診順序と、Martでエラーになっていた visit_type の定義
    ROW_NUMBER() OVER(PARTITION BY l.user_id ORDER BY l.diagnosed_at) AS visit_number,
    CASE 
        WHEN ROW_NUMBER() OVER(PARTITION BY l.user_id ORDER BY l.diagnosed_at) = 1 THEN 'First Visit' 
        ELSE 'Follow-up' 
    END AS visit_type,
    
    l.physical_pain_severity_score,
    l.has_neck_shoulder_pain,
    l.has_mental_fatigue,
    l.mainComplaint,
    l.treatment_memo,
    l.diagnosesdata_json,
    l.marks_json,
    l.chakura_marks_json
FROM logic_added l
LEFT JOIN users u ON l.user_id = u.user_id