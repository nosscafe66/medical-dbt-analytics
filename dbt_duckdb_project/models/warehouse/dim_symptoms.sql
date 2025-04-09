-- models/warehouse/dimensions/dim_symptoms.sql
{{
  config(
    materialized='table'
  )
}}

WITH symptoms_unpivoted AS (
  SELECT
    questionnaireid AS questionnaire_id,
    'armpain' AS symptom_name,
    symptomsdata.armpain.painful AS is_painful,
    symptomsdata.armpain.concerning AS is_concerning
  FROM {{ source('main', 'medical_diagnosis_form') }}
  WHERE symptomsdata.armpain.most = TRUE OR symptomsdata.armpain.painful = TRUE OR symptomsdata.armpain.concerning = TRUE
  
  UNION ALL
  
  SELECT
    questionnaireid AS questionnaire_id,
    'legpain' AS symptom_name,
    symptomsdata.legpain.painful AS is_painful,
    symptomsdata.legpain.concerning AS is_concerning
  FROM {{ source('main', 'medical_diagnosis_form') }}
  WHERE symptomsdata.legpain.most = TRUE OR symptomsdata.legpain.painful = TRUE OR symptomsdata.legpain.concerning = TRUE
  
  -- 他の症状も同様に追加（必要に応じて）
)

SELECT * FROM symptoms_unpivoted