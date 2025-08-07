--- get previous randomizations
create temp table base as (
    select base.*
    from election_2024.exp2024_callable_surge_oct as base
    left join election_2024.exp2024_ucg_unified_late_sept as prev
        on base.vb_voterbase_id = prev.vb_voterbase_id
    left join election_2024.exp2024_ucg_unified_late_sept as hh_prev
        on base.addr_id = hh_prev.addr_id
    where coalesce(
        prev.vb_voterbase_id, hh_prev.addr_id
    ) is null
);

--- Randomize for this month
set seed to 55464;
create temp table exp as (
    select
        base.vb_voterbase_id,
        base.vf_reg_cd,
        case when base.young_voter = 1 then '1' else '0' end as born_after_1980,
        case
            when lower(base.vf_race) in ('white', 'w') then '1' else '0'
        end as race_white,
        case when base.vf_gender = 'Male' then '1' else '0' end as gend_male,
        case
            when
                base.vf_turnout_score between 20 and 40
                then 'turnout_20to40' when
                base.vf_turnout_score between 40 and 60
                then 'turnout_40to60'
            else 'vf_turnout_60to80'
        end as categorical_turnout,
        case
            when base.vf_partisanship > 85 then '1' else '0'
        end as partisanship_85plus,
        count(*) over (partition by base.addr_id) as hh_size,
        base.vf_reg_state
        || round(base.vf_turnout_score / 10)::varchar
        || round(base.vf_partisanship / 10)::varchar
        || born_after_1980 as strata,
        base.addr_id,
        rand() as rand_num
    from base
    order by 1
);

create temp table tbl_strata as (
    select
        exp.vb_voterbase_id,
        exp.strata,
        exp.rand_num,
        count(*) over (partition by exp.strata) as strata_size,
        rank() over (partition by exp.strata order by rand_num) as rand_rank
    from exp
    where exp.hh_size = 1
);

drop table if exists election_2024.exp2024_oct_vf_individual_assignment;
create table election_2024.exp2024_oct_vf_individual_assignment as (
    select
        tbl_strata.vb_voterbase_id,
        tbl_strata.strata,
        tbl_strata.strata_size,
        tbl_strata.rand_rank,
        tbl_strata.rand_num,
        100
        * tbl_strata.rand_rank
        / tbl_strata.strata_size as stratified_percentile,
        case when
            tbl_strata.strata_size = 1 and tbl_strata.rand_num > .1 then 1
        when tbl_strata.strata_size = 1 and tbl_strata.rand_num <= .1 then 0
        when 1000 * tbl_strata.rand_rank / tbl_strata.strata_size > 100 then 1
        else 0 end as treat
    from tbl_strata
);
grant select
on election_2024.exp2024_oct_vf_individual_assignment
to redash_default;


create temp table exp_addr as (
    select
        base.addr_id,
        count(*) as hh_size
    from base
    group by 1
    having count(*) > 1
    order by 1
);

create temp table hh_strata as (
    select
        exp_addr.addr_id,
        exp_addr.hh_size,
        count(*) over (partition by hh_size) as strata_size,
        rand() as rand_num,
        rank() over (partition by hh_size order by rand_num) as rand_rank
    from exp_addr
);

drop table if exists election_2024.exp2024_oct_update_householder_assignment;
create table election_2024.exp2024_oct_update_householder_assignment as (
    select
        hh_strata.addr_id,
        hh_strata.hh_size,
        hh_strata.strata_size,
        hh_strata.rand_rank,
        hh_strata.rand_num,
        100
        * hh_strata.rand_rank
        / hh_strata.strata_size as stratified_percentile,
        case when
            hh_strata.strata_size = 1 and hh_strata.rand_num > .1 then 1
        when hh_strata.strata_size = 1 and hh_strata.rand_num <= .1 then 0
        when 1000 * hh_strata.rand_rank / hh_strata.strata_size > 100 then 1
        else 0 end as treat
    from hh_strata
);

grant select
on election_2024.exp2024_oct_update_householder_assignment
to redash_default;
