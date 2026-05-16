-- models/stg_symptom_surveys.sql
{{
  config(
    materialized='table',
    schema="staging"
  )
}}
WITH raw_data AS (
    SELECT
        base
    FROM {{ source('source', 'symptom_improvement_surveys') }},
    UNNEST(json_agg) AS base
)
SELECT
    t.base.id AS survey_id,
    t.base.user_id,
    t.base.questionnaire_id,
    t.base.pain_level,
    t.base.mental_state,
    t.base.overall_satisfaction,
    t.base.energy_level,
    t.base.sleep_quality,
    t.base.mobility_level,
    t.base.next_treatment_needed,
    t.base.additional_concerns,
    CAST(t.base.survey_date AS DATE) AS survey_date,
    CAST(t.base.created_at AS TIMESTAMP) AS created_at,
    CAST(t.base.updated_at AS TIMESTAMP) AS updated_at
FROM
    raw_data AS t