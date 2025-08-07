create temp table hh_prev as (
    select
        addr_id,
        round(avg(treat)) as treat
    from election_2024.exp2024_ucg_unified_late_sept
    group by 1
    order by 1
);

-- final assignment
drop table if exists election_2024.exp2024_ucg_oct;
create table election_2024.exp2024_ucg_oct as (
    select distinct
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
        bf.vf_first_name,
        bf.vf_middle_name,
        bf.vf_last_name,
        bf.vf_suffix,
        -- contact vars: address
        bf.vf_street_addr,
        bf.vf_city,
        bf.vf_state,
        bf.vf_zip,
        -- contact vars: phone
        bf.vf_best_phone,
        coalesce(mem.voterbase_id is not null, false) as moveon_member
    from election_2024.exp2024_callable_surge_voters_oct as bf
    left join
        derived.election_2024_members_base as mem
        on bf.vb_voterbase_id = mem.voterbase_id
    left join
        election_2024.exp2024_oct_vf_individual_assignment as ind
        on bf.vb_voterbase_id = ind.vb_voterbase_id
    left join
        election_2024.exp2024_ucg_unified_late_sept as ind_prev
        on bf.vb_voterbase_id = ind_prev.vb_voterbase_id
    left join
        election_2024.exp2024_oct_update_householder_assignment as hh
        on bf.addr_id = hh.addr_id
    left join
        hh_prev
        on bf.addr_id = hh_prev.addr_id
    order by 1, 2
);

grant select on election_2024.exp2024_ucg_oct to redash_default;

-- check treatment assignment accross households
select
    count(distinct vb_voterbase_id) as unique_voters,
    count(distinct vb_voterbase_id || treat) as unique_total
from
    election_2024.exp2024_ucg_oct;
