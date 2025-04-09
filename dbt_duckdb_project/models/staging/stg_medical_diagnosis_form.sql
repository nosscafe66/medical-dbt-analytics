-- models/diagnosis_summary.sql
SELECT
  *
FROM {{ source('main','medical_diagnosis_form') }}