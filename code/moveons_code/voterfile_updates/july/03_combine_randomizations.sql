create temp table base as (
    select
        base.*,
        base.vb_tsmart_last_name
        || base.vb_vf_reg_cass_address_full
        || base.vb_vf_reg_cass_city
        || base.vb_vf_reg_cass_state
        || base.vb_vf_reg_cass_zip as addr_id
    from election_2024.exp2024_deduped_20240723 as base
);



-- final assignment
drop table if exists election_2024.exp2024_ucg_july_all;
create table election_2024.exp2024_ucg_july_all as (
    select
        coalesce(
        ind_april.treat,
         hh_april.treat,
        ind_may.treat,
        hh_may.treat,
        ind.treat,
        hh.treat) as treat,
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
        stafftemp.exp2024_ucg_may_all as ind_may
        on bf.vb_voterbase_id = ind_may.vb_voterbase_id
    left join
        stafftemp.exp2024_ucg_tier1_all as ind_april
        on bf.vb_voterbase_id = ind_april.vb_voterbase_id
    left join
        election_2024.exp2024_july_vf_individual_assignment as ind
        on bf.vb_voterbase_id = ind.vb_voterbase_id
    left join
        stafftemp.exp2024_ucg_may_all as hh_may
        on bf.addr_id = hh_may.addr_id
    left join
        stafftemp.exp2024_ucg_tier1_all as hh_april
        on bf.addr_id = hh_april.addr_id
    left join
        election_2024.exp2024_july_update_householder_assignment as hh
        on bf.addr_id = hh.addr_id
    order by 1, 2
);

grant select on election_2024.exp2024_ucg_july_all to redash_default;


select count(distinct addr_id), count(distinct addr_id||treat)
from 
election_2024.exp2024_ucg_july_all
;