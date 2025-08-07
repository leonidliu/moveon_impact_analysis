create temp table zc_vf as (
    select
        vb_voterbase_id,
        vb_voterbase_household_id,
        vb_reg_census_id as vf_reg_fips,
        vb_vf_reg_state as vf_reg_state,
        vb_tsmart_first_name,
        --- contact vars: name
        vb_tsmart_middle_name,
        vb_tsmart_last_name,
        vb_tsmart_name_suffix,
        vb_vf_reg_cass_address_full,
        -- contact vars: address
        vb_vf_reg_cass_city,
        vb_vf_reg_cass_state,
        vb_vf_reg_cass_zip,
        cast(vb_vf_registration_date as varchar) as vb_vf_registration_date,
        -- mail vars
        --check dpv first
        vb_voterbase_age as vf_age,
        vb_voterbase_race as vf_race,
        vb_voterbase_gender as vf_gender,
        ts_tsmart_partisan_score as vf_partisanship,
        --- targeting vars: votehistry
        ts_tsmart_harris_support_score,
        ts_tsmart_biden_support_score as vf_biden_score,
        ts_tsmart_presidential_general_turnout_score as vf_turnout,
        ts_tsmart_urbanicity as vf_urbanicity,
        ts_tsmart_college_graduate_score as vf_college_score,
        vb_voterbase_marital_status as vf_married,
        vb_vf_earliest_registration_date,
        tier.tier_overall,
        -- demographic vars
        tier.tier_senate,
        tier.tier_presidential,
        tier.tier_house,
        vb_vf_reg_state
        || '-'
        || coalesce(nullif(right(vf.vb_vf_cd_new, 2), ''), '00') as vf_reg_cd,
        coalesce(
            nullif(trim(vb_vf_mail_street), ''),
            nullif(trim(vb_tsmart_full_address), ''),
            vb_vf_reg_cass_address_full
        ) as mail_addr_full,
        coalesce(
            nullif(trim(vb_vf_mail_city), ''),
            nullif(trim(vb_tsmart_city), ''),
            vb_vf_reg_city
        ) as mail_city,
        coalesce(
            nullif(trim(vb_vf_mail_state), ''),
            nullif(trim(vb_tsmart_state), ''),
            vb_vf_reg_cass_state
        ) as mail_state,
        coalesce(
            nullif(trim(vb_vf_mail_zip5), ''),
            nullif(trim(vb_tsmart_zip), ''),
            vb_vf_reg_cass_zip
        ) as mail_zip,
        case
            when vb_vf_g2012 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2012,
        case
            when vb_vf_g2014 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2014,
        case
            when vb_vf_g2016 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2016,
        -- synthetic vars
        case
            when vb_vf_g2018 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2018,
        case
            when vb_vf_g2020 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2020,
        case
            when vb_vf_g2022 in ('P', 'E', 'A', 'M', 'Y', 'Q') then 1 else 0
        end as vh_g2022,
        case
            when
                to_date(vb_voterbase_dob, 'YYYYMMDD', FALSE) >= '19090101'
                and to_date(vb_voterbase_dob, 'YYYYMMDD', FALSE) <= '20041231'
                then to_date(vb_voterbase_dob, 'YYYYMMDD', FALSE)
        end as vf_dob,
        case
            when
                vb_vf_reg_cass_address_full is not NULL
                then TRUE::boolean
            else FALSE::boolean
        end as has_addr,
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
    from ts.ntl_20240910 as vf
    left join ts.cellbase_202408 as ph on vf.vb_voterbase_id = ph.voterbase_id
    left join
        election_2024.target_tiers as tier
        on
            vb_vf_reg_state
            || '-'
            || coalesce(nullif(right(vb_vf_cd_new, 2), ''), '00')
            = tier.house_district
    where vf_reg_state = 'FL' and
        vb_voterbase_registration_status = 'Registered'
        and vb_voterbase_deceased_flag != 'Deceased'
        and left(vb_voterbase_id, 2) = vf_reg_state
        and ts_tsmart_presidential_general_turnout_score between 20 and 80
        and ts_tsmart_partisan_score >= 70
);

create temp table base as (
    with spoke_dnc as (
        select distinct substring(cell, 3) as spoke_phone
        from spoke.campaign_contact
        where error_code in (4304, 4406, 4408, 4482)
    )

    select
        bf.*,
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
            when vf_best_phone is not NULL
                then TRUE::boolean
            else FALSE::boolean
        end as has_phone,
        case
            when vf_best_phone is not NULL and vf_wireless_confidence <= 3
                then TRUE::boolean
            else FALSE::boolean
        end as is_callable,
        case
            when vh_g2022 = 1 then '20221108'
            when vh_g2020 = 1 then '20201103'
            when vh_g2018 = 1 then '20181106'
        end as max_vh,
        case
            when tw.cell is not NULL then 1
            when mo_dnc.phone is not NULL then 1
            when spoke_phone is not NULL then 1
            when ph.phone is not NULL then 1
            when
                coalesce(prim.primary_phone_is_callable, 'true') != 'true'
                then 1
            when coalesce(sec.backup_phone_is_callable, 'true') != 'true' then 1
            else 0
        end as do_not_call
    from zc_vf as bf
    left join
        derived.bad_phones as ph
        on bf.vb_voterbase_id = ph.voterbase_id and bf.vf_best_phone = ph.phone
    left join
        derived.election_2024_members_base as prim
        on
            bf.vb_voterbase_id = prim.voterbase_id
            and bf.vf_best_phone = prim.primary_phone
    left join
        derived.election_2024_members_base as sec
        on
            bf.vb_voterbase_id = sec.voterbase_id
            and bf.vf_best_phone = sec.backup_phone

    left join
        derived.do_not_call_numbers_incomplete as mo_dnc
        on bf.vf_best_phone = mo_dnc.phone
    left join
        stafftemp.aw_twillio_cell_errors as tw
        on bf.vf_best_phone = tw.cell
    left join spoke_dnc on spoke_phone = bf.vf_best_phone
);

drop table if exists election_2024.exp2024_basefile_fl_20240923;
create table election_2024.exp2024_basefile_fl_20240923 as (
    select *
    from base
    where
        greatest(young_voter, returning_voter) = 1
        and greatest(vh_g2018, vh_g2020, vh_g2022) = 1
        and has_phone = 1 and has_addr = 1
);
grant select on election_2024.exp2024_basefile_fl_20240923 to redash_default;