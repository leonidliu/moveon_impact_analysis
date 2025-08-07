create temp table base as (
    select
        base.*,
        base.vb_tsmart_last_name
        || base.vb_vf_reg_cass_address_full
        || base.vb_vf_reg_cass_city
        || base.vb_vf_reg_cass_state
        || base.vb_vf_reg_cass_zip as addr_id
    from election_2024.exp2024_deduped_20240723 as base
    left join
       election_2024.exp2024_ucg_may_all as may
        on base.vb_voterbase_id = may.vb_voterbase_id
    left join
        stafftemp.exp2024_ucg_tier1_all as april
        on base.vb_voterbase_id = april.vb_voterbase_id

     left join
       election_2024.exp2024_ucg_may_all as hh_may
        on
            base.vb_tsmart_last_name
            || base.vb_vf_reg_cass_address_full
            || base.vb_vf_reg_cass_city
            || base.vb_vf_reg_cass_state
            || base.vb_vf_reg_cass_zip
            = hh_may.addr_id
    left join
        stafftemp.exp2024_ucg_tier1_all as hh_april
        on
            base.vb_tsmart_last_name
            || base.vb_vf_reg_cass_address_full
            || base.vb_vf_reg_cass_city
            || base.vb_vf_reg_cass_state
            || base.vb_vf_reg_cass_zip
            = hh_april.addr_id
    where coalesce(may.vb_voterbase_id, april.vb_voterbase_id, 
    hh_may.addr_id, hh_april.addr_id) is null
);

set seed to 1113;

create temp table exp as (
    select
        vb_voterbase_id,
        vf_reg_cd,
        case when young_voter = 1 then '1' else '0' end as born_after_1980,
        case when vf_race = 'White' then '1' else '0' end as race_white,
        case when vf_gender = 'Male' then '1' else '0' end as gend_male,
        case
            when vf_turnout between 20 and 40 then 'turnout_20to40' when
                vf_turnout between 40 and 60
                then 'turnout_40to60'
            else 'vf_turnout_60to80'
        end as categorical_turnout,
        case
            when vf_partisanship > 85 then '1' else '0'
        end as partisanship_85plus,
        count(*) over (partition by addr_id) as hh_size,
        --left(vb_voterbase_id, 2)||categorical_turnout||partisanship_85plus as strata,
        vb_vf_reg_cass_state
        || round(vf_turnout / 10)::varchar
        || round(vf_partisanship / 10)::varchar
        || born_after_1980 as strata,
        addr_id,
        rand() as rand_num
    from base
    order by 1
);

create temp table tbl_strata as (
    select

        vb_voterbase_id,
        strata,
        rand_num,
        count(*) over (partition by strata) as strata_size,
        rank() over (partition by strata order by rand_num) as rand_rank
    from exp
    where hh_size = 1
);

drop table if exists election_2024.exp2024_july_vf_individual_assignment;
create table election_2024.exp2024_july_vf_individual_assignment as (
    select
        vb_voterbase_id,
        strata,
        strata_size,
        rand_rank,
        rand_num,
        100 * rand_rank / strata_size as stratified_percentile,
        case when
            strata_size = 1 and rand_num > .1 then 1
        when strata_size = 1 and rand_num <= .1 then 0
        when 1000 * rand_rank / strata_size > 100 then 1
        else 0 end as treat
    from tbl_strata
);
grant select on election_2024.exp2024_july_vf_individual_assignment to redash_default;
