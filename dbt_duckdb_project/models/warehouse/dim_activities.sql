-- models/warehouse/dimensions/dim_activities.sql
{{
  config(
    materialized='table'
  )
}}

SELECT
  questionnaireid AS questionnaire_id,
  activitiesdata.nursing,
  activitiesdata.parenting,
  activitiesdata.caregiving,
  activitiesdata.doingSports AS doing_sports,
  activitiesdata.sittingWork AS sitting_work,
  activitiesdata.standingWork AS standing_work,
  activitiesdata.frequentDriving AS frequent_driving,
  activitiesdata.frequentComputerUse AS frequent_computer_use,
  activitiesdata.liftingHeavyObjects AS lifting_heavy_objects,
  activitiesdata.readingBooksNewspapers AS reading_books_newspapers
FROM {{ source('main', 'medical_diagnosis_form') }}