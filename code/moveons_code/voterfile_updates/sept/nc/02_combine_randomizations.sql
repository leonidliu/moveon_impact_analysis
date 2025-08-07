create temp table base as (
    select
        base.*,
        base.vb_tsmart_last_name
        || base.vb_vf_reg_cass_address_full
        || base.vb_vf_reg_cass_city
        || base.vb_vf_reg_cass_state
        || base.vb_vf_reg_cass_zip as addr_id
    from election_2024.exp2024_deduped_nc_20240920 as base
);

-- final assignment
drop table if exists election_2024.exp2024_ucg_nc_sept;
create table election_2024.exp2024_ucg_nc_sept as (
    select
        distinct
        coalesce(
            ind_prev.treat,
            hh_prev.treat,
            ind.treat,
            hh.treat
        ) as treat,
        bf.vb_voterbase_id,
        bf.addr_id,
        bf.vf_reg_cd,
        --- contact vars: name
        bf.vb_tsmart_first_name,
        bf.vb_tsmart_middle_name,
        bf.vb_tsmart_last_name,
        bf.vb_tsmart_name_suffix,
        -- contact vars: address
        bf.vb_vf_reg_cass_address_full,
        bf.vb_vf_reg_cass_city,
        bf.vb_vf_reg_cass_state,
        bf.vb_vf_reg_cass_zip,
        -- contact vars: phone
        bf.vf_best_phone,
        coalesce(mem.voterbase_id is not null, false) as moveon_member
    from base as bf
    left join
        derived.election_2024_members_base as mem
        on bf.vb_voterbase_id = mem.voterbase_id
    left join
        election_2024.exp2024_nc_sept_vf_individual_assignment as ind
        on bf.vb_voterbase_id = ind.vb_voterbase_id
    left join 
        election_2024.exp2024_ucg_unified_sept as ind_prev
        on bf.vb_voterbase_id = ind_prev.vb_voterbase_id
    left join
        election_2024.exp2024_nc_sept_update_householder_assignment as hh
        on bf.addr_id = hh.addr_id
    left join
        election_2024.exp2024_ucg_unified_sept as hh_prev
        on bf.addr_id = hh_prev.addr_id
    order by 1, 2
);

grant select on election_2024.exp2024_ucg_nc_sept to redash_default;

-- check treatment assignment accross households
select
    count(distinct addr_id),
    count(distinct addr_id || treat)
from
    election_2024.exp2024_ucg_nc_sept;


-- check for duplicates
    select
    count(distinct vb_voterbase_id),
    count(distinct vb_voterbase_id || treat)
from
    election_2024.exp2024_ucg_nc_sept;
