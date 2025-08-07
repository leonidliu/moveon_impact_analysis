create temp table ddx as (

    select person_id as vb_voterbase_id
    from tmc_ddx.cln_ddx__survey_response
    where
        exchange_survey_question_response_name
        = '5 - Strong Donald Trump'
        and person_id is not null

);

create temp table av as (
    select vb_voterbase_id
    from tmc.av_scores_2024
    where
        gotv_score < 0
        and vb_voterbase_id is not null
);

create temp table mo as (
    select vb_voterbase_id
    from stafftemp.contacts
    where
        coalesce(support_trump, old_support_trump) = 1
        and vb_voterbase_id is not null
);

drop table if exists stafftemp.excl_trump_ids;
create table stafftemp.excl_trump_ids as (
    select distinct
        coalesce(
            ddx.vb_voterbase_id, av.vb_voterbase_id, mo.vb_voterbase_id
        ) as vb_voterbase_id,
        case
            when ddx.vb_voterbase_id is not null then 1 else 0
        end as source_on_ddx,
        case
            when av.vb_voterbase_id is not null then 1 else 0
        end as source_on_av,
        case
            when mo.vb_voterbase_id is not null then 1 else 0
        end as source_on_mo
    from ddx
    full join av on ddx.vb_voterbase_id = av.vb_voterbase_id
    full join
        mo
        on
            coalesce(ddx.vb_voterbase_id, av.vb_voterbase_id)
            = mo.vb_voterbase_id
    order by 1
);
grant select on stafftemp.excl_trump_ids to redash_default;

-- checks:
select
    count(*) as total,
    count(distinct vb_voterbase_id) as unique_total,
    sum(source_on_av) as av_total,
    sum(source_on_ddx) as ddx_total,
    sum(source_on_mo) as mo_total
from stafftemp.excl_trump_ids;
