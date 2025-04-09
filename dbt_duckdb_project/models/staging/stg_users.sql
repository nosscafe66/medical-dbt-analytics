-- models/diagnosis_summary.sql
SELECT
  *
FROM {{ source('main','users') }}