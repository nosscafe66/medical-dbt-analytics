SELECT
    *,
    -- これまでの「何回目か」
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY survey_date, created_at) AS survey_number,
    
    -- 「初回のアンケートから何日経過しているか」を計算
    DATE_DIFF(
        survey_date, 
        FIRST_VALUE(survey_date) OVER(PARTITION BY user_id ORDER BY survey_date, created_at), 
        DAY
    ) AS days_since_first_survey
FROM {{ ref('stg_symptom_surveys') }}