-- models/diagnosis_summary.sql
{{
  config(
    materialized='table',
    schema="staging"
  )
}}
WITH raw_data AS (
    SELECT 
        -- json_agg 配列を UNNEST して各要素を base という名前で取り出す
        base
    FROM {{ source('source', 'users') }},
    UNNEST(json_agg) AS base
)

SELECT
    -- 全フィールドの展開
    t.base.user_id,
    t.base.user_name,
    t.base.kana,
    t.base.gender,
    t.base.age,
    t.base.birthday,
    t.base.postal_code,
    t.base.address,
    t.base.phone_number,
    t.base.email,
    -- DATE型やBOOLEAN型へのキャストが必要な場合はここで行います
    CAST(t.base.first_treatment_date AS DATE) AS first_treatment_date,
    t.base.acquisition_channel,
    t.base.occupation,
    t.base.family,
    t.base.memo,
    t.base.created_at,
    t.base.updated_at,
    CAST(t.base.visibletochildadmin AS BOOLEAN) AS visibletochildadmin

FROM raw_data AS t