-- models/warehouse/marts/mart_user_diagnosis_summary.sql
{{
  config(
    materialized='table'
  )
}}

SELECT
  u.user_id,
  u.user_name,
  u.gender,
  u.age,
  u.first_treatment_date,
  u.acquisition_channel,
  COUNT(d.questionnaire_id) AS total_diagnoses,
  MIN(d.diagnosis_date) AS first_diagnosis_date,
  MAX(d.diagnosis_date) AS latest_diagnosis_date,
  -- 主な症状の集計
  SUM(CASE WHEN d.primary_symptom = 'armpain' THEN 1 ELSE 0 END) AS armpain_count,
  SUM(CASE WHEN d.primary_symptom = 'legpain' THEN 1 ELSE 0 END) AS legpain_count,
  SUM(CASE WHEN d.primary_symptom = 'malaise' THEN 1 ELSE 0 END) AS malaise_count,
  -- 他の症状も同様に集計
  -- 活動情報の集計
  SUM(CASE WHEN a.sitting_work THEN 1 ELSE 0 END) AS sitting_work_count,
  SUM(CASE WHEN a.frequent_computer_use THEN 1 ELSE 0 END) AS computer_use_count,
  -- バイタルの平均
  AVG(d.systolic_bp) AS avg_systolic_bp,
  AVG(d.diastolic_bp) AS avg_diastolic_bp,
  AVG(d.average_sleep_hours) AS avg_sleep_hours
FROM {{ ref('dim_users') }} u
LEFT JOIN {{ ref('fact_medical_diagnosis') }} d ON u.user_id = d.user_id
LEFT JOIN {{ ref('dim_activities') }} a ON d.questionnaire_id = a.questionnaire_id
GROUP BY 1, 2, 3, 4, 5, 6