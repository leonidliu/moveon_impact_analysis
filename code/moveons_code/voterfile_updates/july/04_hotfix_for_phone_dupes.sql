
--- DEDUPE BY Phone: 
create temp table zc_temp as  
(
select 
vb_voterbase_id,
vf_wireless_confidence,
vf_partisanship,
vb_vf_earliest_registration_date, 
vf_best_phone,
row_number() OVER (PARTITION BY vf_best_phone ORDER BY vf_wireless_confidence,bf.vb_voterbase_phone_last_validated desc, 
vf_partisanship DESC, ts_tsmart_biden_support_score desc, right(vb_voterbase_id, 2)) as phone2
from election_2024.exp2024_basefile_20240723 bf
left join ts.ntl_20240709 using(vb_voterbase_id)
 where is_callable = 1  -- has high quality phone number in the voter file
    and do_not_call = 0 -- not on the do not call list
);

drop table if exists election_2024.exp2024_deduped_20240724;
create table  election_2024.exp2024_deduped_20240724 as (
 select distinct base.vb_voterbase_id, base.vf_best_phone
 from election_2024.exp2024_basefile_20240723 base
 inner join zc_temp ph using(vb_voterbase_id)
where vh_g2022 = 0 
and phone2 = 1
);

-- check fix
select count(*) as total,
count(distinct vb_voterbase_id) as voter_count,
count(distinct vf_best_phone) as phone_count
from election_2024.exp2024_deduped_20240724;
;