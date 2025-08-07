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

set seed to 44879;

create temp table exp_addr as (
    select
        addr_id,
        count(*) as hh_size
    from base
    group by 1
    having count(*) > 1
    order by 1
);

create temp table tbl_strata as (
    select
        addr_id,
        hh_size,
        count(*) over (partition by hh_size) as strata_size,
        rand() as rand_num,
        rank() over (partition by hh_size order by rand_num) as rand_rank
    from exp_addr
);

drop table if exists election_2024.exp2024_july_update_householder_assignment;
create table election_2024.exp2024_july_update_householder_assignment as (
    select
        addr_id,
        hh_size,
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

grant select on election_2024.exp2024_july_update_householder_assignment to redash_default;
