with forms as (
    select * from {{ ref('stg_medical_diagnosis_form') }}
),

-- 1. Fctと同じロジックで型変換とスコア計算を行う
logic_added as (
    select 
        user_id,
        questionnaireid,
        cast(created_at as timestamp) as diagnosed_at,
        (
            cast(mss_armpain_most as int64) + 
            cast(mss_legpain_most as int64) + 
            cast(mss_stiffneck_most as int64) +
            cast(mss_lkowerback_most as int64)
        ) as physical_pain_severity_score
    from forms
),

-- 2. 整理されたカラム（diagnosed_at等）を使って順序を付与
visit_events as (
    select
        *,
        row_number() over (partition by user_id order by diagnosed_at) as visit_number_derived
    from logic_added
),

-- 3. 各ユーザーの初診スコアを特定
first_visit_scores as (
    select
        user_id,
        physical_pain_severity_score as initial_score
    from visit_events
    where visit_number_derived = 1
)

-- 4. 最終結合
select
    v.user_id,
    v.questionnaireid,
    v.diagnosed_at,
    v.visit_number_derived,
    v.physical_pain_severity_score as current_score,
    f.initial_score,
    -- 初診時からのスコア改善度（マイナスなら改善）
    (v.physical_pain_severity_score - f.initial_score) as score_improvement
from visit_events v
left join first_visit_scores f on v.user_id = f.user_id