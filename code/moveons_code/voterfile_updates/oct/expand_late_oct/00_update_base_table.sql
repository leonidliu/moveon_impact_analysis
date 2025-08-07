
create temp table past_gotv_calls as (
    select 
    distinct 
    coalesce(ph.voterbase_id, itt.vb_voterbase_id) as vb_voterbase_id
    from election_2024.phones_attempted ph
    full join stafftemp.exp2024_phones_base_late_oct itt on ph.voterbase_id = itt.vb_voterbase_id
    where ph.contact_at >= '2024-10-05' or itt.vb_voterbase_id is not null
);

-- automate table name and vf date
drop table if exists election_2024.exp2024_expanded_base_oct;
create table election_2024.exp2024_expanded_base_oct as (
    select
    -- ids
        vf.vb_voterbase_id,
        vf.vb_voterbase_household_id,
        vb_vf_reg_state as vf_reg_state,
         vf.vb_tsmart_last_name
            || vf.vb_vf_reg_cass_address_full
            || vf.vb_vf_reg_cass_city
            || vf.vb_vf_reg_cass_state
            || vf.vb_vf_reg_cass_zip
            as addr_id,
    -- name vars
        vf.vb_tsmart_first_name as vf_first_name,
        vf.vb_tsmart_middle_name as vf_middle_name,
        vf.vb_tsmart_last_name as vf_last_name,
        vf.vb_tsmart_name_suffix as vf_suffix,
    -- address
        vf.vb_vf_reg_cass_address_full as vf_street_addr,
        vf.vb_vf_reg_cass_city as vf_city,
        vf.vb_vf_reg_cass_state as vf_state,
        vf.vb_vf_reg_cass_zip as vf_zip,
        vf.vb_reg_census_id as vf_fips,
    -- vf vars
        cast(vf.vb_vf_registration_date as varchar) as vf_reg_date,
        vf.vb_voterbase_age as vf_age,
        vf.vb_voterbase_race as vf_race,
        vf.vb_voterbase_gender as vf_gender,
        vf.ts_tsmart_partisan_score as vf_partisanship,
        vf.ts_tsmart_harris_support_score as vf_harris_score,
        vf.ts_tsmart_biden_support_score as vf_biden_score,
        vf.ts_tsmart_presidential_general_turnout_score as vf_turnout_score,
        vf.vb_vf_earliest_registration_date as vf_first_reg_date,
        tier.tier_overall,
        tier.tier_senate,
        tier.tier_presidential,
        tier.tier_house,
        tier.ballot_state,
        vf_reg_state
        || '-'
        || coalesce(nullif(right(vf.vb_vf_cd_new, 2), ''), '00') as vf_reg_cd,
        coalesce(
            nullif(trim(vf.vb_vf_mail_street), ''),
            nullif(trim(vf.vb_tsmart_full_address), ''),
            vf.vb_vf_reg_cass_address_full
        ) as mail_street_addr,
        coalesce(
            nullif(trim(vf.vb_vf_mail_city), ''),
            nullif(trim(vf.vb_tsmart_city), ''),
            vf.vb_vf_reg_city
        ) as mail_city,
        coalesce(
            nullif(trim(vf.vb_vf_mail_state), ''),
            nullif(trim(vf.vb_tsmart_state), ''),
            vf.vb_vf_reg_cass_state
        ) as mail_state,
        coalesce(
            nullif(trim(vf.vb_vf_mail_zip5), ''),
            nullif(trim(vf.vb_tsmart_zip), ''),
            vf.vb_vf_reg_cass_zip
        ) as mail_zip,
        -- VH
        case
            when vf.vb_vf_g2012 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2012,
        case
            when vf.vb_vf_g2014 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2014,
        case
            when vf.vb_vf_g2016 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2016,
        case
            when vf.vb_vf_g2018 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2018,
        case
            when vf.vb_vf_g2020 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2020,
        case
            when vf.vb_vf_g2022 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2022,
        case
            when
                to_date(vf.vb_voterbase_dob, 'YYYYMMDD', FALSE) >= '19090101'
                and to_date(vf.vb_voterbase_dob, 'YYYYMMDD', FALSE)
                <= '20041231'
                then to_date(vf.vb_voterbase_dob, 'YYYYMMDD', FALSE)
        end as vf_dob,
        case
            when
                vf_street_addr is not NULL
                then TRUE::boolean
            else FALSE::boolean
        end as has_addr,
        case
            when
                vf_dob >= '19810101' and vf_dob <= '20041231'
                and vh_g2012 = 0 and vh_g2014 = 0 and vh_g2016 = 0
                then TRUE::boolean
            else FALSE::boolean
        end as young_voter,
        case
            when vh_g2016 = 0 and (vh_g2012 = 1 or vh_g2014 = 1)
                then TRUE::boolean
            else FALSE::boolean
        end as returning_voter,
        case
            when
                ph.tsmart_wireless_phone_v2 is not NULL
                then ph.tsmart_wireless_phone_v2
            when
                vf.tsmart_wireless_phone_v2 is not NULL
                then vf.tsmart_wireless_phone_v2
            when
                length(
                    regexp_replace(vf.vb_voterbase_phone_wireless, '[^0-9]', '')
                )
                = 10
                then vf.vb_voterbase_phone_wireless
            when
                length(regexp_replace(vf.vb_voterbase_phone, '[^0-9]', '')) = 10
                then vf.vb_voterbase_phone
            when
                length(regexp_replace(vf.vb_vf_phone, '[^0-9]', '')) = 10
                then vf.vb_vf_phone
        end as vf_best_phone,
        coalesce(
            ph.tsmart_wireless_confidence_score_v2,
            vf.tsmart_wireless_confidence_score_v2
        ) as vf_wireless_confidence,
        coalesce(
            ph.source1_last_received_date_v2,
            vf.vb_voterbase_phone_last_validated
        ) as vf_phone_last_validated,
     case when greatest(young_voter, returning_voter) = 1
        and greatest(vh_g2018, vh_g2020, vh_g2022) = 1 then 1 else 0 end as likely_surge_voter,
case 
when coalesce(vb_firsttimeseen_voterid::varchar, vb_vf_earliest_registration_date::varchar, vb_vf_registration_date::varchar, '2024-01-01') <= '2023-01-01' then 0
when coalesce(nullif(vb_vf_p2024, ''),
 nullif(vf.vb_vf_g2022, ''), nullif(vf.vb_vf_g2020, ''),
 nullif(vf.vb_vf_g2018, ''), nullif(vf.vb_vf_g2016, ''),
 nullif(vf.vb_vf_g2014, ''), nullif(vf.vb_vf_g2012, '')
     ) is not null then 0
when coalesce("vb.voterbase_registration_status", 'Unregistered') = 'Registered' then 0 
else 1 end as first_time_reg
    from ts.ntl_20241008 as vf
    left join election_2024.exp2024_ucg_oct ucg on vf.vb_voterbase_id = ucg.vb_voterbase_id
    left join past_gotv_calls on vf.vb_voterbase_id = past_gotv_calls.vb_voterbase_id
    left join
        election_2024.target_tiers as tier
        on
            vf.vb_vf_reg_state
            || '-'
            || coalesce(nullif(right(vf.vb_vf_cd_new, 2), ''), '00')
            = tier.house_district
    left join ts.cellbase_202408 as ph on vf.vb_voterbase_id = ph.voterbase_id
    left join ts.ntl_202207 vf_prev on vf.vb_voterbase_id = vf_prev."vb.voterbase_id"
    where
        -- cur reg
        vf.vb_voterbase_registration_status = 'Registered'
        and vf.vb_voterbase_deceased_flag != 'Deceased'
        and left(vf.vb_voterbase_id, 2) = vf.vb_vf_reg_state
        -- HQ phone
        and vf_wireless_confidence <= 3
        -- pres / senate / ballot for overall
        and  left(vf.vb_voterbase_id, 2) in ('AZ', 'NV', 'MI', 'PA', 'WI', 'GA', 'NC', 'OH', 'FL')
        -- FTR
        and (first_time_reg = 1 or likely_surge_voter = 1)    
        -- Not on previous UCG file or GOTV calls
        and ucg.vb_voterbase_id is null and past_gotv_calls.vb_voterbase_id is null 
);
grant select on election_2024.exp2024_expanded_base_oct to redash_default;


-- check counts: 
select first_time_reg, likely_surge_voter, count(*) 
from election_2024.exp2024_expanded_base_oct
left join tmc.av_scores_2024 av using(vb_voterbase_id)
where  (av.gotv_score >0 or av.gotv_score is null)
group by 1, 2
order by 1, 2;
