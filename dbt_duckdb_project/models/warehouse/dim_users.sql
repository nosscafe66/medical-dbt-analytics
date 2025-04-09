-- models/warehouse/dimensions/dim_users.sql
{{
  config(
    materialized='table'
  )
}}

SELECT
  user_id,
  user_name,
  kana,
  gender,
  age,
  CAST(birthday AS DATE) AS birthdate,
  postal_code,
  address,
  phone_number,
  email,
  first_treatment_date,
  acquisition_channel,
  occupation,
  family,
  memo,
  CAST(created_at AS TIMESTAMP) AS created_at,
  CAST(updated_at AS TIMESTAMP) AS updated_at
FROM {{ source('main', 'users') }}