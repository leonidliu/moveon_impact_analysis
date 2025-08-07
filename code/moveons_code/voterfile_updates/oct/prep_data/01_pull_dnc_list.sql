drop table if exists stafftemp.excl_do_not_call;
create table stafftemp.excl_do_not_call as (
    select distinct
        vb_voterbase_id,
        phone_cleaned,
        call_source
    from
    -- ddx
        (
            select distinct
                ddx.person_id as vb_voterbase_id,
                right(
                    trim(regexp_replace(ddx.phone_number, '[^0-9]', '')), 10
                ) as phone_cleaned,
                'ddx' as call_source

            from tmc_ddx.cln_ddx__contact_attempt as ddx
            where
                ddx.datetime_canvassed_window_start > '2024-01-01'
                and nullif(vb_voterbase_id, '') is not null
                and length(phone_cleaned) = 10
        )

    union distinct
    --- tw
    (
        select distinct
            null as vb_voterbase_id,
            right(
                trim(regexp_replace(tw.cell, '[^0-9]', '')), 10
            ) as phone_cleaned,
            'tw' as call_source
        from stafftemp.aw_twillio_cell_errors as tw
        where length(phone_cleaned) = 10
    )
    union distinct
    --- mo
    (
        select distinct
            null as vb_voterbase_id,
            right(
                trim(regexp_replace(mo_dnc.phone, '[^0-9]', '')), 10
            ) as phone_cleaned,
            'mo_incompletes' as call_source
        from derived.do_not_call_numbers_incomplete as mo_dnc
        where length(phone_cleaned) = 10
    )
    union distinct
    --- spoke
    (
        select distinct
            null as vb_voterbase_id,
            right(
                trim(regexp_replace(substring(spk.cell, 3), '[^0-9]', '')), 10
            ) as phone_cleaned,
            'spoke' as call_source
        from spoke.campaign_contact as spk
        where
            spk.error_code in (4304, 4406, 4408, 4482)
            and length(phone_cleaned) = 10
    )
    union distinct

    --- bad_phones
    (
        select distinct
            bph.voterbase_id as vb_voterbase_id,
            right(
                trim(regexp_replace(bph.phone, '[^0-9]', '')), 10
            ) as phone_cleaned,
            'mo_bad_phones' as call_source
        from derived.bad_phones as bph
        where
            nullif(vb_voterbase_id, '') is not null
            and length(phone_cleaned) = 10
    )
    union distinct
    --- primary phone
    (
        select distinct
            prim.voterbase_id as vb_voterbase_id,
            right(
                trim(regexp_replace(prim.primary_phone, '[^0-9]', '')), 10
            ) as phone_cleaned,
            'mo_primary' as call_source
        from derived.election_2024_members_base as prim
        where
            nullif(vb_voterbase_id, '') is not null
            and length(phone_cleaned) = 10
            and coalesce(prim.primary_phone_is_callable, 'true') != 'true'
    )
    union distinct

    --- backup phone
    (
        select distinct
            sec.voterbase_id as vb_voterbase_id,
            right(
                trim(regexp_replace(sec.backup_phone, '[^0-9]', '')), 10
            ) as phone_cleaned,
            'mo_backup' as call_source
        from derived.election_2024_members_base as sec
        where
            nullif(vb_voterbase_id, '') is not null
            and length(phone_cleaned) = 10
            and coalesce(sec.backup_phone_is_callable, 'true') != 'true'
    )
    order by 1, 2
);
grant select on stafftemp.excl_do_not_call to redash_default;

-- checks
select
    call_source,
    count(*) as row_total,
    count(distinct vb_voterbase_id) as unique_voter_ids,
    count(distinct phone_cleaned) as unique_phones,
    count(
        distinct coalesce(vb_voterbase_id, '') || phone_cleaned
    ) as unique_phone_voter_ids
from
    stafftemp.excl_do_not_call
group by 1
order by 2 desc;
