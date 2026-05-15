-- models/staging/stg_medical_diagnosis_form.sql
{{
  config(
    materialized='table',
    schema="staging"
  )
}}
{% set symptoms = [
    'armpain', 'legpain', 'malaise', 'vertigo', 'diarrhea', 'hayfever', 'insomnia', 
    'kneepain', 'meadache', 'tinnitus', 'b1ackpain', 'dizziness', 'stiffneck', 
    'stiffness', 'arrhythmia', 'eyefatigue', 'hotFlashes', 'lkowerback', 
    'numbnessin', 'buttockpain', 'numbnessarm', 'shortnessof', 'stomachpain', 
    'swollenlegs', 'constipation', 'irritability', 'palpitations', 'abdominalpain', 
    'backstiffness', 'menstrualpain', 'sensitivityto', 'nasalcongestion', 
    'f1requenturination', 'menstrualirregularity'
] %}

WITH raw_data AS (
  SELECT 
      base
  FROM {{ source('source', 'medical_diagnosis_form') }},
  UNNEST(json_agg) AS base
)

SELECT
    -- 基本フィールド
    t.base.user_id,
    t.base.referrer,
    t.base.questionnaireid,
    t.base.patientNumber,
    t.base.mainComplaint,
    t.base.mentalComplaints,
    t.base.treatment_memo,
    t.base.repliconVaccine,
    t.base.fortunemessage_memo,
    t.base.chakraerror_memo,
    t.base.rooterror_memo,
    t.base.marked_image_name,
    t.base.created_at,
    t.base.updated_at,
    t.base.marked_image_path,

    -- most_severe_symptom (STRUCT)
    {% for s in symptoms %}
    t.base.most_severe_symptom.{{ s }}.most AS mss_{{ s }}_most,
    t.base.most_severe_symptom.{{ s }}.painful AS mss_{{ s }}_painful,
    t.base.most_severe_symptom.{{ s }}.concerning AS mss_{{ s }}_concerning,
    {% endfor %}

    -- symptomsdata (STRUCT)
    {% for s in symptoms %}
    t.base.symptomsdata.{{ s }}.most AS sd_{{ s }}_most,
    t.base.symptomsdata.{{ s }}.painful AS sd_{{ s }}_painful,
    t.base.symptomsdata.{{ s }}.concerning AS sd_{{ s }}_concerning,
    {% endfor %}

    -- additionalinfo (STRUCT)
    t.base.additionalinfo.smoking,
    t.base.additionalinfo.appetite,
    t.base.additionalinfo.drinking,
    t.base.additionalinfo.systolicBP,
    t.base.additionalinfo.diastolicBP,
    t.base.additionalinfo.averageSleep,
    t.base.additionalinfo.pregnancyWeek,
    t.base.additionalinfo.smokingAmount,
    t.base.additionalinfo.pregnancyStatus,

    -- activitiesdata (STRUCT)
    t.base.activitiesdata.nursing,
    t.base.activitiesdata.parenting,
    t.base.activitiesdata.caregiving,
    t.base.activitiesdata.doingSports,
    t.base.activitiesdata.sittingWork,
    t.base.activitiesdata.standingWork,
    t.base.activitiesdata.frequentDriving,
    t.base.activitiesdata.frequentComputerUse,
    t.base.activitiesdata.liftingHeavyObjects,
    t.base.activitiesdata.readingBooksNewspapers,

    -- pastmedicalhistory (STRUCT)
    t.base.pastmedicalhistory.lastName,
    t.base.pastmedicalhistory.firstName,
    t.base.pastmedicalhistory.dateOfBirth,
    t.base.pastmedicalhistory.medicalIssues,
    t.base.pastmedicalhistory.hasOtherConcerns,
    t.base.pastmedicalhistory.otherConcernsDetails,

    -- 配列型 (REPEATED) の展開
    TO_JSON_STRING(t.base.diagnosesdata) AS diagnosesdata_json,
    TO_JSON_STRING(t.base.marks) AS marks_json,
    TO_JSON_STRING(t.base.chakura_marks) AS chakura_marks_json

FROM raw_data AS t