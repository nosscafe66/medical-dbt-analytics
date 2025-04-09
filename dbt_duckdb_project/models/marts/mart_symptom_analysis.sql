-- models/warehouse/marts/mart_symptom_analysis.sql
{{
  config(
    materialized='table'
  )
}}

SELECT
  s.symptom_name,
  COUNT(*) AS symptom_count,
  AVG(u.age) AS avg_patient_age,
  SUM(CASE WHEN u.gender = 'male' THEN 1 ELSE 0 END) AS male_count,
  SUM(CASE WHEN u.gender = 'female' THEN 1 ELSE 0 END) AS female_count,
  SUM(CASE WHEN s.is_painful THEN 1 ELSE 0 END) AS painful_count,
  SUM(CASE WHEN s.is_concerning THEN 1 ELSE 0 END) AS concerning_count,
  SUM(CASE WHEN a.sitting_work THEN 1 ELSE 0 END) AS sitting_work_count,
  SUM(CASE WHEN a.frequent_computer_use THEN 1 ELSE 0 END) AS computer_use_count
FROM {{ ref('dim_symptoms') }} s
JOIN {{ ref('fact_medical_diagnosis') }} d ON s.questionnaire_id = d.questionnaire_id
JOIN {{ ref('dim_users') }} u ON d.user_id = u.user_id
JOIN {{ ref('dim_activities') }} a ON d.questionnaire_id = a.questionnaire_id
GROUP BY 1
ORDER BY symptom_count DESC