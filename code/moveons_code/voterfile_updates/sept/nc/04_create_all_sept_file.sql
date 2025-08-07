drop table if exists election_2024.exp2024_ucg_all_sept;
create table election_2024.exp2024_ucg_all_sept as
(
    select *
    from
        (
            select *
            from election_2024.exp2024_ucg_sept
        )
    union distinct
    (
        select *
        from election_2024.exp2024_ucg_nc_sept
    )

    order by vb_voterbase_id
);
grant select on election_2024.exp2024_ucg_all_sept to redash_default;
