create temp table zc_vf as ( select
    vb_voterbase_id,
    vb_voterbase_household_id,
    vb_reg_census_id as vf_reg_fips,
    vb_vf_reg_state as vf_reg_state,
    vb_vf_reg_state || '-' || coalesce(nullif(right(base.vb_vf_cd_new, 2), ''), '00') as vf_reg_cd,
    --- contact vars: name
    vb_tsmart_first_name,
    vb_tsmart_middle_name,
    vb_tsmart_last_name,
    vb_tsmart_name_suffix,
    -- contact vars: address
    vb_vf_reg_cass_address_full,
    vb_vf_reg_cass_city,
    vb_vf_reg_cass_state,
    vb_vf_reg_cass_zip,
    -- mail vars
    coalesce(nullif(vb_vf_mail_street_name, ''), nullif(vb_tsmart_full_address, ''), vb_vf_reg_cass_address_full) as mail_addr_full,  
    coalesce(nullif(vb_vf_mail_city, ''), nullif(vb_tsmart_city, ''), vb_vf_reg_city) as mail_city,  
    coalesce(nullif(vb_vf_mail_state, ''), nullif(vb_tsmart_state, ''), vb_vf_reg_cass_state) as mail_state,  
    coalesce(nullif(vb_vf_mail_zip5, ''), nullif(vb_tsmart_zip, ''), vb_vf_reg_cass_zip) as mail_zip,  
    --- targeting vars: votehistry
    case when vb_vf_g2012 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0 end as vh_g2012,
    case when vb_vf_g2014 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0 end as vh_g2014,
    case when vb_vf_g2016 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0 end as vh_g2016, 
    case when vb_vf_g2018 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0 end as vh_g2018,
    case when vb_vf_g2020 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0 end as vh_g2020,
    case when vb_vf_g2022 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0 end as vh_g2022,
    cast(vb_vf_registration_date as varchar) as vb_vf_registration_date,
    -- demographic vars
    case when to_date(vb_voterbase_dob, 'YYYYMMDD', FALSE) >= '19090101'
         and to_date(vb_voterbase_dob, 'YYYYMMDD', FALSE) <=  '20041231' 
         then to_date(vb_voterbase_dob, 'YYYYMMDD', FALSE) end as vf_dob,        
    vb_voterbase_age as vf_age,
    vb_voterbase_race as vf_race,
    vb_voterbase_gender as vf_gender,
    ts_tsmart_partisan_score as vf_partisanship,
    ts_tsmart_presidential_general_turnout_score as vf_turnout,
    ts_tsmart_urbanicity as vf_urbanicity,
    ts_tsmart_college_graduate_score as vf_college_score,
    vb_voterbase_marital_status as vf_married,
    -- synthetic vars
    case when vb_vf_reg_cass_address_full is not null then true::boolean else false::boolean end as has_addr,
    case when tsmart_wireless_phone_v2 is not null then tsmart_wireless_phone_v2
        when length(REGEXP_REPLACE(vb_voterbase_phone_wireless, '[^0-9]', '')) = 10  then vb_voterbase_phone_wireless
        when length(REGEXP_REPLACE(vb_voterbase_phone, '[^0-9]', '')) = 10  then vb_voterbase_phone
        when length(REGEXP_REPLACE(vb_vf_phone, '[^0-9]', '')) = 10  then vb_vf_phone
        else null end as vf_best_phone,
    tsmart_wireless_confidence_score_v2 as vf_wireless_confidence,
    vb_voterbase_phone_last_validated,
    vb_voterbase_phone_match_code,
    vb_voterbase_phone_wireless_match_code,
    tier.tier_overall,
    tier.tier_senate,
    tier.tier_presidential,
    tier.tier_house
    from ts.ntl_20240709 base
    left join election_2024.target_tiers tier  on vb_vf_reg_state || '-' || coalesce(nullif(right(vb_vf_cd_new, 2), ''), '00') = tier.house_district
    where vb_voterbase_registration_status = 'Registered'
    AND vb_voterbase_deceased_flag != 'Deceased'
    and left(vb_voterbase_id, 2) = vf_reg_state
    and ts_tsmart_presidential_general_turnout_score between 20 and 80
    and ts_tsmart_partisan_score >= 70
);

create temp table base as (
select bf.*,
    case when  vf_dob  >= '19810101'  and vf_dob <=  '20041231' 
        and vh_g2012 = 0 and vh_g2014 = 0 and vh_g2016 = 0
        then true::boolean else false::boolean end as young_voter,
    case when vh_g2016 = 0 and (vh_g2012 = 1 or vh_g2014 = 1) 
         then true::boolean else false::boolean end as returning_voter,
         case when vf_best_phone is not null
            then true::boolean else false::boolean end as has_phone,
    case when vf_best_phone is not null and vf_wireless_confidence <= 3 
            then true::boolean else false::boolean end as is_callable,
    case 
     when vh_g2022 = 1 then '20221108'
     when vh_g2020 = 1 then '20201103'
     when vh_g2018 = 1 then '20181106'
     end as max_vh,
         case when tw.cell is not null  then 1
        when mo_dnc.phone is not null  then 1 
        when spoke_phone is not null then 1 
        when ph.phone is not null then 1
        when coalesce(prim.primary_phone_is_callable, 'true') != 'true' then 1
         when coalesce(sec.backup_phone_is_callable, 'true') != 'true' then 1
        else 0 end do_not_call
    from zc_vf   bf
    left join derived.bad_phones ph on bf.vb_voterbase_id = ph.voterbase_id and bf.vf_best_phone = ph.phone
    left join derived.election_2024_members_base prim on bf.vb_voterbase_id = prim.voterbase_id and bf.vf_best_phone = prim.primary_phone
    left join derived.election_2024_members_base sec on bf.vb_voterbase_id = sec.voterbase_id and bf.vf_best_phone = sec.backup_phone
    
    left join derived.do_not_call_numbers_incomplete mo_dnc  on bf.vf_best_phone  = mo_dnc.phone 
    left join stafftemp.aw_twillio_cell_errors tw ON tw.cell = bf.vf_best_phone 
    left join (select 
               distinct substring(cell, 3) as spoke_phone
               from spoke.campaign_contact 
               where error_code in (4304, 4406, 4408, 4482)
                ) spoke_dnc on  spoke_phone = bf.vf_best_phone
);

drop table if exists election_2024.exp2024_basefile_20240723;
create table election_2024.exp2024_basefile_20240723 as (
    select * 
    from base
    where 
    greatest(young_voter, returning_voter) = 1
    and greatest(vh_g2018, vh_g2020, vh_g2022) = 1 
    and has_phone = 1 and has_addr = 1 
    and tier_overall = 1
);

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

drop table if exists election_2024.exp2024_deduped_20240723;
create table  election_2024.exp2024_deduped_20240723 as (
 select base.*
 from election_2024.exp2024_basefile_20240723 base
 inner join zc_temp ph using(vb_voterbase_id)
where vh_g2022 = 0 
);

---Check july counts against april: 
select 
case when april.vb_voterbase_id is not null then 1 else 0 end as on_april,
case when may.vb_voterbase_id is not null then 1 else 0 end as on_may,
count(*)
from stafftemp.exp2024_ucg_tier1_to_treat april
full join election_2024.exp2024_deduped_20240723 may using(vb_voterbase_id)
where left(vb_voterbase_id, 2) != 'CA'
group by 1, 2