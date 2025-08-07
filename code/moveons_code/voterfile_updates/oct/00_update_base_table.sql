-- automate table name and vf date
drop table if exists election_2024.exp2024_base_surge_voters_oct;
create table election_2024.exp2024_base_surge_voters_oct as (
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
        ) as vf_phone_last_validated
    from ts.ntl_20241008 as vf
    left join
        election_2024.target_tiers as tier
        on
            vf.vb_vf_reg_state
            || '-'
            || coalesce(nullif(right(vf.vb_vf_cd_new, 2), ''), '00')
            = tier.house_district
    left join ts.cellbase_202408 as ph on vf.vb_voterbase_id = ph.voterbase_id
    where
        -- cur reg
        vf.vb_voterbase_registration_status = 'Registered'
        and vf.vb_voterbase_deceased_flag != 'Deceased'
        and left(vf.vb_voterbase_id, 2) = vf.vb_vf_reg_state
        -- contactable
        and (
            vf.vb_vf_reg_cass_address_full is not NULL
            or vf_best_phone is not NULL
        )
        -- very likely dem
        and vf.ts_tsmart_partisan_score >= 70
        -- likely gotv
        and vf.ts_tsmart_presidential_general_turnout_score between 20 and 80
        -- tier 1 or FL ballot states
        and (tier.tier_overall = 1 or tier.ballot_state = 1)
        -- surge def: young/returning, voted in 1+ of 3 general elections
        and greatest(young_voter, returning_voter) = 1
        and greatest(vh_g2018, vh_g2020, vh_g2022) = 1
);
grant select on election_2024.exp2024_base_surge_voters_oct to redash_default;
