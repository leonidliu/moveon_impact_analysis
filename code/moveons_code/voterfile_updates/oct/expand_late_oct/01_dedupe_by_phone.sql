--- Filter out records before deduping to limit false phone duplicate matches
create temp table vtp as (
select
distinct 
voterbase_id as vb_voterbase_id
from 
election_2024.vt_pledges_all vt
where vt.voterbase_id is not null
);

create temp table vt_ph as (
select 
distinct 
right(trim(regexp_replace(vt.phone, '[^0-9]', '')), 10) as phone_cleaned
from election_2024.vt_pledges_all vt
where length(phone_cleaned) = 10
);

create temp table keep_ids as (
    select distinct
        bf.vb_voterbase_id,
        bf.vf_best_phone,
        bf.vf_wireless_confidence,
        bf.vf_phone_last_validated,
        bf.vf_partisanship,
        bf.vf_harris_score,
        bf.vf_biden_score
    from election_2024.exp2024_expanded_base_oct as bf
    left join tmc.av_scores_2024 av on bf.vb_voterbase_id = av.vb_voterbase_id
    left join election_2024.exp2024_ucg_oct hh_prev on bf.addr_id = hh_prev.addr_id
    left join
        stafftemp.excl_trump_ids as excl
        on bf.vb_voterbase_id = excl.vb_voterbase_id
    left join vtp on bf.vb_voterbase_id = vtp.vb_voterbase_id
    left join vt_ph on bf.vf_best_phone = vt_ph.phone_cleaned
    left join stafftemp.excl_do_not_call as dnc
        on
            bf.vf_best_phone = dnc.phone_cleaned
            and (
                bf.vb_voterbase_id = dnc.vb_voterbase_id
                or dnc.vb_voterbase_id is null
            )
    where
        -- tier 1, namely to exclude FL as a ballot state
         (av.gotv_score > 0  or (av.gotv_score is null and bf.vf_harris_score > 50))
        and excl.vb_voterbase_id is null  -- not on the trump id list
        and dnc.phone_cleaned is null -- not on the do not call list
        -- keep only records with a voterbase id because of phone join
        and nullif(bf.vb_voterbase_id, '') is not null
        -- remove any records that have a vt pledge
        and vtp.vb_voterbase_id is null and vt_ph.phone_cleaned is null
        -- not in previous UCG control group
        and (hh_prev.addr_id is null or hh_prev.treat = 1)
);

--- Dedupe By Phone: 
create temp table zc_temp as
(
    select
        vb_voterbase_id,
        row_number() over (
            partition by
                vf_best_phone order by
                case when left(vb_voterbase_id, 2) != 'FL' then 1 else 0 end desc,
                vf_wireless_confidence asc,
                vf_phone_last_validated desc,
                vf_partisanship desc,
                vf_harris_score desc,
                vf_biden_score desc,
                right(vb_voterbase_id, 2)
        ) as phone_priority
    from keep_ids
);

-- Create Dedeuped Table of Callable Surge Voters
drop table if exists election_2024.exp2024_callable_expanded_oct;
create table election_2024.exp2024_callable_expanded_oct as (
    select base.*
    from election_2024.exp2024_expanded_base_oct as base
    inner join zc_temp on base.vb_voterbase_id = zc_temp.vb_voterbase_id
    where zc_temp.phone_priority = 1
);
grant select on election_2024.exp2024_callable_expanded_oct to redash_default;

select 
left(vb_voterbase_id, 2) as state,
count(*) as total,
count(distinct vb_voterbase_id) as unique_total,
count(distinct vf_best_phone) as phone
from election_2024.exp2024_callable_expanded_oct
group by 1
order by 1
;