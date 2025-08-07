


--- Dedupe by Phone:
create temp table zc_temp as  
(
select 
vb_voterbase_id,
vf_best_phone, 
row_number() OVER (PARTITION BY vf_best_phone 
                    ORDER BY vf_wireless_confidence, base.vb_voterbase_phone_last_validated desc, 
                             vf_partisanship DESC, ts_tsmart_biden_support_score desc, 
                             right(vb_voterbase_id, 3)
                    ) as phone_priority
from stafftemp.exp2024_basefile_20240412 base
left join ts.ntl_current using(vb_voterbase_id)

where has_phone = 1 and vf_wireless_confidence <= 3  -- has phone number in the voter file
and do_not_call = 0 -- not on the do not call list
);

drop table if exists stafftemp.exp2024_best_phone_20240412;
create table stafftemp.exp2024_best_phone_20240412 as (
select 
vb_voterbase_id,
vf_best_phone
from zc_temp
where phone_priority = 1
order by 1, 2
);



drop table if exists stafftemp.exp2024_deduped_20240412;
create table  stafftemp.exp2024_deduped_20240412 as (
 select base.*, 
  base.vb_tsmart_last_name||base.vb_vf_reg_cass_address_full||base.vb_vf_reg_cass_city||base.vb_vf_reg_cass_state||base.vb_vf_reg_cass_zip as addr_id
 
 from stafftemp.exp2024_basefile_20240412 base
 inner join stafftemp.exp2024_best_phone_20240412 ph using(vb_voterbase_id)
 where 
 greatest(young_voter, returning_voter) = 1
 and least(senate_tier, house_tier, presidential_tier) = 1  -- all tier 1 geographies
 and vh_g2022 = 0
 and mailable = 1
);




select coalesce(nullif(REGEXP_REPLACE(vf_hh_id, '[A-Z/-]', ''), ''), REGEXP_REPLACE(vb_voterbase_id, '[A-Z/-]', '')) as vf_hh_id_num, count(*)
from stafftemp.exp2024_basefile_standarized_20240408
where greatest(young_voter, returning_voter) = 1
    and left(vb_voterbase_id, 2) = vf_reg_state
    and least(senate_tier, house_tier, presidential_tier) = 1  -- all tier 1 geographies
    and is_callable = 1   -- has phone number in the voter file
    and has_addr = 1  -- has an address in the voter file
group by 1 
having count(vf_hh_id_num) >1
order by 2 desc
;


create temp table zc_temp as  
(
select 
vb_voterbase_id,
vh_g2022,
REGEXP_REPLACE(vb_voterbase_id, '[A-Z/-]', '')::int as vb_num,
case when cast(vb_vf_registration_date as varchar) > max_vh and cast(vb_vf_registration_date as varchar) < '20250101' then cast(vb_vf_registration_date as varchar) else cast(max_vh as varchar)  end as max_reg_date
from stafftemp.exp2024_basefile_20240412
where greatest(young_voter, returning_voter) = 1
and vf_turnout between 20 and 80
--and vh_g2022 = 0
    and left(vb_voterbase_id, 2) = vf_reg_state
    and least(senate_tier, house_tier, presidential_tier) = 1  -- all tier 1 geographies
    and is_callable = 1   -- has phone number in the voter file
    and has_addr = 1  -- has an address in the voter file
);


with base as 
(
select vb_voterbase_id, 
vb_num, vh_g2022,
rank() over(partition by vb_num order by max_reg_date desc, vb_tsmart_effective_date desc) as rn
from zc_temp
left join ts.ntl_current using(vb_voterbase_id)
where vb_vf_source_state = vb_tsmart_state
)

select vh_g2022, count(*), count(distinct vb_num)
from base
where rn = 1
group by 1
order by 1
;

select * from spoke.opt_out limit 99;

select substring('abc', 1, 3);
select 'abc'::varbyte;

select * from spoke.campaign_contact limit 1;


select 
case when length(REGEXP_REPLACE(tsmart_wireless_phone_v2, '[^0-9]', '')) = 10  then 1 else 0 end, 
case when tsmart_wireless_phone_v2 is not null and tsmart_wireless_phone_v2 != '' then 1 else 0 end, 
count(*)
from ts.ntl_current
group by 1 , 2order by 3 desc;







--- DEDUPE BY Phone: 

create temp table zc_temp as  
(
select 
vb_voterbase_id,
vf_best_phone, vf_wireless_confidence, vf_partisanship

from stafftemp.exp2024_basefile_20240412
where greatest(young_voter, returning_voter) = 1
and vh_g2022 = 0
    and least(senate_tier, house_tier, presidential_tier) = 1  -- all tier 1 geographies
    and has_phone = 1 and coalesce(vf_wireless_confidence, 1) <= 3  -- has phone number in the voter file
    and do_not_call = 0 -- not on the do not call list

);


with base as 
(
select 
vb_voterbase_id,
vf_wireless_confidence,
vf_partisanship, vb_vf_earliest_registration_date, 
rank() OVER (PARTITION BY vf_best_phone ORDER BY vf_wireless_confidence, vb_voterbase_phone_last_validated desc, vf_partisanship DESC, ts_tsmart_biden_support_score desc) as phone_priority,
row_number() OVER (PARTITION BY vf_best_phone ORDER BY vf_wireless_confidence,vb_voterbase_phone_last_validated desc, 
vf_partisanship DESC, ts_tsmart_biden_support_score desc) as phone2
from zc_temp 
left join ts.ntl_current using(vb_voterbase_id)
)

select phone_priority, phone2, count(*)
from base
--where rn = 1 
group by 1, 2
order by 1, 2;



create temp table zc_temp as  
(
select 
vb_voterbase_id,
vf_wireless_confidence,
vf_partisanship, vb_vf_earliest_registration_date, 
row_number() OVER (PARTITION BY vf_best_phone ORDER BY vf_wireless_confidence,vb_voterbase_phone_last_validated desc, 
vf_partisanship DESC, ts_tsmart_biden_support_score desc, right(vb_voterbase_id, 2)) as phone2
from stafftemp.exp2024_basefile_20240412
left join ts.ntl_current using(vb_voterbase_id)
)


create table stafftemp.exp2024_best_phone_20240412 as 
(

select vb_voterbase_id, vf_best_phone
count(*)
from zc_temp
where phone_priority
group by 1, 2
order by 1, 2
);




create table  stafftemp.exp2024_deduped_20240412 as (
 select base.*
 from stafftemp.exp2024_basefile_20240412 base
 inner join stafftemp.exp2024_best_phone_20240412 ph using(vb_voterbase_id)
 where least(senate_tier, house_tier, presidential_tier) = 1  -- all tier 1 geographies
 and vh_g2022 = 0
);

select 
house_cd||
case when vf_gender = 'Male' then '1' else '0' end as gend_male,
case when vf_turnout between 20 and 40 then 'turnout_20to40' when vf_turnout between 40 and 60 then 'turnout_40to60' else 'vf_turnout_60to80' end as categorical_turnout,
case when vf_partisanship > 85 then 1 else 0 end as partisanship_85plus,
case when vf_race = 'White' then 1 else 0 end as race_white, 
case when 
case when vf_age between 18 and 24 then '18to24' when vf_age between 25 and 34 then '25to34' when vf_age between 35 and 44 then '35to44' when vf_age between 45 and 54 then '45to54' when vf_age between 55 and 64 then '55to64' when vf_age between 65 and 74 then '65to74' else '75plus' end as age_group,


set seed to 203664;
create temp table exp as (
select 
vb_voterbase_id,
vf_reg_cd,
case when young_voter = 1 then '1' else '0' end as born_after_1980, 
case when vf_race = 'White' then'1' else '0'end as race_white, 
case when vf_gender = 'Male' then '1' else '0' end as gend_male,
case when vf_turnout between 20 and 40 then 'turnout_20to40' when vf_turnout between 40 and 60 then 'turnout_40to60' else 'vf_turnout_60to80' end as categorical_turnout,
case when vf_partisanship > 85 then '1' else '0' end as partisanship_85plus,
count(*) over(partition by addr_id) as hh_size,
--left(vb_voterbase_id, 2)||categorical_turnout||partisanship_85plus as strata,
vb_vf_reg_cass_state||round(vf_turnout/10)::varchar||round(vf_partisanship/10)::varchar||born_after_1980 as strata,
addr_id,
rand() as rand_num
from  stafftemp.exp2024_deduped_20240412  
order by 1
);

create temp table tbl_strata as (
select 

vb_voterbase_id, strata, 
count(*) over(partition by strata) as strata_size,
rank() over(partition by strata order by rand_num) as rand_rank, rand_num
from exp
where hh_size = 1
);

drop table if exists  stafftemp.exp2024_individual_assignment;
create table stafftemp.exp2024_individual_assignment as (
select vb_voterbase_id,
strata, strata_size, rand_rank, rand_num,
100*rand_rank/strata_size as stratified_percentile, 
case when 
strata_size = 1 and rand_num > .1 then 1
when strata_size = 1 and rand_num <= .1 then 0
when 1000*rand_rank/strata_size > 100 then 1 
else 0 end as treat
from tbl_strata
);



select
treat, 
count(*) as n_size,
avg(vf_turnout),
avg(vf_partisanship),
avg(vf_college_score),
avg(vf_age),
avg(case when vf_race = 'W' then 100 else 0 end),
avg(case when vf_gender = 'Male' then 100 else 0 end),
avg(strata_size),
avg(1000*case when strata_size = 1 then 1 else 0 end)


from  stafftemp.exp2024_deduped_20240412  

left join stafftemp.exp2024_individual_assignment using(vb_voterbase_id)
group by 1 order by 1;

set seed to 84131;
create temp table exp_addr as (
select 
addr_id,
count(*) as hh_size
from  stafftemp.exp2024_deduped_20240412 
group by 1
having count(*) > 1
order by 1
);

create temp table tbl_strata as (
select 
addr_id, 
hh_size, 
count(*) over(partition by hh_size) as strata_size,
rand() as rand_num,
rank() over(partition by hh_size order by rand_num) as rand_rank
from exp_addr
);

drop table if exists  stafftemp.exp2024_householder_assignment;
create table stafftemp.exp2024_householder_assignment as (
select 
addr_id,
hh_size, 
strata_size,
rand_rank, 
rand_num,
100*rand_rank/strata_size as stratified_percentile, 
case when 
strata_size = 1 and rand_num > .1 then 1
when strata_size = 1 and rand_num <= .1 then 0
when 1000*rand_rank/strata_size > 100 then 1 
else 0 end as treat
from tbl_strata
);

-- check how many households are assigned to treatment
with agg as (
select 
sum(hh_size) as total_ind,
count(distinct addr_id) as total_hh
from stafftemp.exp2024_householder_assignment
)

select
treat,
sum(hh_size) as groupsize_ind,
count(distinct addr_id) as groupsize_hh,
1000*sum(hh_size)/max(total_ind) as frac_ind,
1000*count(distinct addr_id)/max(total_hh) as frac_hh

from stafftemp.exp2024_householder_assignment
left join agg on 1
group by 1
order by 1

-- 18-25 (gen z-y), age 26-35 (gen y/mil), or over 35


-- final assignment
drop table if exists stafftemp.exp2024_ucg_tier1_all;
create table stafftemp.exp2024_ucg_tier1_all as (
select 
coalesce(ind.treat, hh.treat) as treat,
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
    bf.vf_best_phone
from stafftemp.exp2024_deduped_20240412 bf
left join stafftemp.exp2024_individual_assignment ind using(vb_voterbase_id)
left join stafftemp.exp2024_householder_assignment hh using(addr_id) 
order by 1, 2
);

select treat, count(*)
from stafftemp.exp2024_ucg_tier1_all
group by 1;



