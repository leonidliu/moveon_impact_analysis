
create temp table zc_vf as ( select
    vb_voterbase_id,
    vb_voterbase_household_id,
    vb_reg_census_id as vf_reg_fips,
    vb_vf_reg_state as vf_reg_state,
    vb_vf_reg_state || '_' || right(vb_vf_cd_new, 2) as vf_reg_cd,
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
    case when coalesce(vb_reg_address_dpv_confirm_code, '') != 'N' then true::boolean else false::boolean end as mailable,
    case when tsmart_wireless_phone_v2 is not null then tsmart_wireless_phone_v2
        when length(REGEXP_REPLACE(vb_voterbase_phone_wireless, '[^0-9]', '')) = 10  then vb_voterbase_phone_wireless
        when length(REGEXP_REPLACE(vb_voterbase_phone, '[^0-9]', '')) = 10  then vb_voterbase_phone
        when length(REGEXP_REPLACE(vb_vf_phone, '[^0-9]', '')) = 10  then vb_vf_phone
        else null end as vf_best_phone,
    tsmart_wireless_confidence_score_v2 as vf_wireless_confidence,
    vb_voterbase_phone_last_validated,
    vb_voterbase_phone_match_code,
    vb_voterbase_phone_wireless_match_code,
        case
        when
            vf_reg_state
            in ('AZ', 'FL', 'GA', 'MI', 'MN', 'NC', 'NV', 'OH', 'PA', 'TX', 'VA', 'WI')
        then true::boolean
        else false::boolean
    end as in_presidential_state,
    case
        when
            vf_reg_state
            in ('AZ', 'CA', 'FL', 'MI', 'MN', 'MT', 'NV', 'OH', 'PA', 'TX', 'VA', 'WI')
        then true::boolean
        else false::boolean
    end as in_senate_state,
    case
        when vf_reg_state in ('NC', 'NH') then true::boolean else false::boolean
    end as in_sos_or_gov_state,
    case
        when vf_reg_state in ('PA', 'OH', 'AZ', 'WI', 'NV')
        then 1
        when vf_reg_state in ('MI', 'VA', 'MT')
        then 2
        when vf_reg_state in ('MN', 'FL', 'TX', 'CA')
        then 3
        else null
    end as senate_tier,
    case
        when vf_reg_state in ('PA', 'GA', 'AZ', 'WI', 'MI', 'NV', 'OH')
        then 1
        when vf_reg_state in ('NC', 'VA')
        then 2
        when vf_reg_state in ('TX', 'FL', 'MN')
        then 3
        else null
    end as presidential_tier,
    case
        when
            vf_reg_cd in (
                'CA_22',
                'CA_13',
                'CA_27',
                'CA_45',
                'VA_02',
                'NE_02',
                'NY_04',
                'NY_03',
                'NY_17',
                'NY_22',
                'NY_19',
                'AZ_01',
                'AZ_06',
                'NJ_07',
                'OR_05',
                'IL_17',
                'NC_13',
                'CT_05',
                'OR_06',
                'NM_02',
                'CO_08',
                'CA_47',
                'CO_03',
                'MI_10',
                'IA_03',
                'MT_01',
                'WI_03'
            )
        then 1
        when
            vf_reg_cd in (
                'AL_01',
                'AL_02',
                'NV_03',
                'NV_04',
                'NV_01',
                'AK_01',
                'OH_13',
                'TX_34',
                'CA_49',
                'GA_02',
                'CA_41',
                'TX_15',
                'IA_01',
                'CA_03',
                'PA_10',
                'WI_01',
                'IA_02',
                'FL_13',
                'IL_14',
                'PA_12',
                'NJ_03',
                'TX_28',
                'IL_06',
                'IL_13',
                'OR_04',
                'MN_02',
                'PA_17',
                'AZ_04',
                'MI_03',
                'MI_07'
            )
        then 2
        when
            vf_reg_cd in (
                'VT_01',
                'NY_14',
                'KY_03',
                'FL_10',
                'PA_01',
                'NY_01',
                'CA_40',
                'TX_16',
                'IL_03',
                'RI_01',
                'NY_16',
                'MO_01',
                'CA_17',
                'TX_35',
                'CO_07',
                'TX_32',
                'TX_30',
                'MA_07',
                'MI_12',
                'MN_05',
                'WI_02',
                'CO_02',
                'WA_07'
            )
        then 3
        when vf_reg_cd in ('FL_15', 'FL_27', 'FL_28')
        then 4
        else null
    end as house_tier
    from ts.ntl_current
    where vb_voterbase_registration_status = 'Registered'
    AND vb_voterbase_deceased_flag != 'Deceased'
    and left(vb_voterbase_id, 2) = vf_reg_state
    and ts_tsmart_presidential_general_turnout_score between 20 and 80
    and ts_tsmart_partisan_score >= 70
);

drop table if exists stafftemp.exp2024_basefile_20240412;

create table stafftemp.exp2024_basefile_20240412 as (
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
        else 0 end do_not_call
    from zc_vf   bf
    left join derived.do_not_call_numbers_incomplete mo_dnc  on bf.vf_best_phone  = mo_dnc.phone 
    left join stafftemp.aw_twillio_cell_errors tw ON tw.cell = bf.vf_best_phone 
    left join (select 
               distinct substring(cell, 3) as spoke_phone
               from spoke.campaign_contact 
               where error_code in (4304, 4406, 4408, 4482)
                ) spoke_dnc on  spoke_phone = bf.vf_best_phone
    
    where 
            (-- including all vf_reg_statewide targets: presidential, senate, SoS, and gubernatorial races
                vf_reg_state IN ('AZ', 'CA', 'FL', 'GA', 'MI', 'MN', 'MT', 'NC', 'NH', 'NV', 'OH', 'PA', 'TX', 'VA', 'WI') 
                -- This list is all election targeting Tiers: https://docs.google.com/spreadsheets/d/1YwXNPblMZEmVx6Jz4uL8Hoc4mepVImBq29JvkiP70oU/edit#gid=0
                or vf_reg_cd IN (
                    'AK_01','AL_01','AL_02','AZ_01','AZ_04','AZ_06','CA_03','CA_13','CA_17','CA_22','CA_27','CA_40',
                    'CA_41','CA_45','CA_47','CA_49','CO_02','CO_03','CO_07','CO_08','CT_05','FL_10','FL_13','FL_15',
                    'FL_27','FL_28','GA_02','IA_01','IA_02','IA_03','IL_03','IL_06','IL_13','IL_14','IL_17','KY_03',
                    'MA_07','MI_03','MI_07','MI_10','MI_12','MN_02','MN_05','MO_01','MT_01','NC_13','NE_02','NJ_03',
                    'NJ_07','NM_02','NV_01','NV_03','NV_04','NY_01','NY_03','NY_04','NY_14','NY_16','NY_17','NY_19',
                    'NY_22','OH_13','OR_04','OR_05','OR_06','PA_01','PA_10','PA_12','PA_17','RI_01','TX_15','TX_16',
                    'TX_28','TX_30','TX_32','TX_34','TX_35','VA_02','VT_01','WA_07','WI_01','WI_02','WI_03' 
                    )
            )
    --- limiting to at least one vote in last 3 general elections
    and greatest(vh_g2018, vh_g2020, vh_g2022) = 1 
);




/* -- check
with tbl_new as 

(select vb_voterbase_id
from stafftemp.exp2024_basefile_standarized_20240408  
where greatest(young_voter, returning_voter) = 1
    and least(senate_tier, house_tier, presidential_tier) = 1  -- all tier 1 geographies
    and is_callable = 1   -- has phone number in the voter file
    and has_addr = 1  -- has an address in the voter file
)


select 
case when tbl_new.vb_voterbase_id is not null then 1 else 0 end,
case when tbl_old.vb_voterbase_id is not null then 1 else 0 end,
count(*)
from tbl_new
full join dbt_aansari.tier_1_callable tbl_old using(vb_voterbase_id)
group by 1, 2
order by 1, 2d has_addr = 1  -- has an address in the voter file
)


select 
case when tb_new.vb_voterase_id is is not null then 1 else 0 end,
case when tb_old.vb_voterbase_id is is not null then 1 else 0 end,

count(*)
from tbl_new
full join dbt_aansari.tier_1_callable tbl_old using(vb_voterbase_id)
group by 1, 2
order by 1, 2

*/
---IN BOTH: 1,284,679	
--- IN JUST OLD: 163,615
-- IN JUST NEW: 383,017


