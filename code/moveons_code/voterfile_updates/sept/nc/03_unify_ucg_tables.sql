create temp  table hh_aug as (
    select
       base.vb_tsmart_last_name
            || dedupe.vb_vf_reg_cass_address_full
            || base.vb_vf_reg_cass_city
            || base.vb_vf_reg_cass_state
            || base.vb_vf_reg_cass_zip
            as addr_id,
            base.treat,
            base.vf_reg_cd,
        base.vb_voterbase_id
from election_2024.exp2024_ucg_august base
left join election_2024.exp2024_deduped_20240816 dedupe using(vb_voterbase_id)
);

-- Build unified table for September
drop table if exists election_2024.exp2024_ucg_unified_sept;
create table election_2024.exp2024_ucg_unified_sept as (
    select
    distinct
        coalesce(
            cur.treat,
            prev.treat,
            jul.treat,
            may.treat,
            april.treat
        ) as treat,
        coalesce(
            cur.vb_voterbase_id,
            prev.vb_voterbase_id,
            jul.vb_voterbase_id,
            may.vb_voterbase_id,
            april.vb_voterbase_id
        ) as vb_voterbase_id,
        coalesce(
            cur.addr_id,
            prev.addr_id,
            jul.addr_id,
            may.addr_id,
            april.addr_id
        ) as addr_id,
        coalesce(
            cur.vf_reg_cd,
            prev.vf_reg_cd,
            jul.vf_reg_cd,
            may.vf_reg_cd,
            april.vf_reg_cd
        ) as vf_reg_cd,
        case when cur.treat is not null then 'sept'
            when prev.treat is not null then 'aug'
            when jul.treat is not null then 'jul'
            when may.treat is not null then 'may'
            when april.treat is not null then 'april'
        end as last_month_seen,
        case when cur.treat is not null then 1 else 0 end as on_current

from 
election_2024.exp2024_ucg_sept cur
full join 
hh_aug prev using(vb_voterbase_id)
full join
election_2024.exp2024_ucg_july jul using(vb_voterbase_id)
full join
election_2024.exp2024_ucg_may_all may using(vb_voterbase_id)
full join
stafftemp.exp2024_ucg_tier1_all april using(vb_voterbase_id)
);

grant select on election_2024.exp2024_ucg_unified_sept to redash_default;

select last_month_seen, count(*), count(distinct vb_voterbase_id)
from election_2024.exp2024_ucg_unified_sept
group by 1 order by 1 desc;