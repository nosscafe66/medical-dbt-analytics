-- models/warehouse/facts/fact_medical_diagnosis.sql
{{
  config(
    materialized='table'
  )
}}

SELECT
  user_id,
  questionnaireid AS questionnaire_id,
  referrer,
  mainComplaint AS main_complaint,
  mentalComplaints AS mental_complaints,
  treatment_memo,
  CAST(created_at AS TIMESTAMP) AS diagnosis_date,
  CAST(updated_at AS TIMESTAMP) AS updated_at,
  -- 構造体データから主要な症状を抽出
  CASE WHEN symptomsdata.armpain.most = TRUE THEN 'armpain' 
       WHEN symptomsdata.legpain.most = TRUE THEN 'legpain'
       WHEN symptomsdata.malaise.most = TRUE THEN 'malaise'
       -- 他の症状も同様に追加
       ELSE 'other' END AS primary_symptom,
  -- 追加情報の展開
  additionalinfo.smoking,
  additionalinfo.drinking,
  CASE 
  WHEN additionalinfo.systolicBP = '' THEN NULL 
  ELSE CAST(additionalinfo.systolicBP AS INTEGER) 
END AS systolic_bp,
  CASE 
  WHEN additionalinfo.diastolicBP = '' THEN NULL 
  ELSE CAST(additionalinfo.diastolicBP AS INTEGER) 
END AS diastolic_bp,
  CASE 
  WHEN additionalinfo.averageSleep = '' THEN NULL 
  ELSE CAST(additionalinfo.averageSleep AS FLOAT) 
END AS average_sleep_hours,
  additionalinfo.pregnancyStatus AS pregnancy_status,
  CASE 
  WHEN additionalinfo.pregnancyWeek = '' THEN NULL 
  ELSE CAST(additionalinfo.pregnancyWeek AS INTEGER) 
END AS pregnancy_week,
  patientNumber AS patient_number
FROM {{ source('main', 'medical_diagnosis_form') }}