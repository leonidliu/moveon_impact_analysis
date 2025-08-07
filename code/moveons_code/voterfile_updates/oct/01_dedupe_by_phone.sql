--- Filter out records before deduping to limit false phone duplicate matches
create temp table keep_ids as (
    select distinct
        bf.vb_voterbase_id,
        bf.vf_best_phone,
        bf.vf_wireless_confidence,
        bf.vf_phone_last_validated,
        bf.vf_partisanship,
        bf.vf_harris_score,
        bf.vf_biden_score
    from election_2024.exp2024_base_surge_voters_oct as bf
    left join
        stafftemp.excl_trump_ids as excl
        on bf.vb_voterbase_id = excl.vb_voterbase_id
    left join stafftemp.excl_do_not_call as dnc
        on
            bf.vf_best_phone = dnc.phone_cleaned
            and (
                bf.vb_voterbase_id = dnc.vb_voterbase_id
                or dnc.vb_voterbase_id is null
            )
    where
        -- has high quality phone number in the voter file
        bf.vf_wireless_confidence <= 3
        -- tier 1, namely to exclude FL as a ballot state
        and bf.tier_overall = 1
        and excl.vb_voterbase_id is null  -- not on the trump id list
        and dnc.phone_cleaned is null -- not on the do not call list
        -- keep only records with a voterbase id because of phone join
        and nullif(bf.vb_voterbase_id, '') is not null
);

--- Dedupe By Phone: 
create temp table zc_temp as
(
    select
        vb_voterbase_id,
        row_number() over (
            partition by
                vf_best_phone order by
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
drop table if exists election_2024.exp2024_callable_surge_oct;
create table election_2024.exp2024_callable_surge_oct as (
    select base.*
    from election_2024.exp2024_base_surge_voters_oct as base
    inner join zc_temp on base.vb_voterbase_id = zc_temp.vb_voterbase_id
    where zc_temp.phone_priority = 1
);
grant select on election_2024.exp2024_callable_surge_oct to redash_default;
