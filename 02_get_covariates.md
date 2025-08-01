Get Voter File Covariates
================
Leo Liu
8/1/25

## Descriptives

    [1] 4608154

    Rows: 4,608,154
    Columns: 36
    $ bq_ts_path                                   <chr> "tmc-data-marts.targetsma…
    $ vb_voterbase_id                              <chr> "MI-15013721", "CA-466043…
    $ vb_tsmart_exact_track                        <chr> "N29457FWXQEWNA0T0SHU", "…
    $ vb_tsmart_exact_address_track                <chr> "Y000000082956991", "Y000…
    $ tmc_hh_id                                    <blob> <d8, c4, 7f, 0a, cb, 6b,…
    $ file_date                                    <chr> "20240514", "20240514", "…
    $ vb_vf_source_state                           <chr> "MI", "CA", "OR", "MI", "…
    $ vb_tsmart_state                              <chr> "MI", "CA", "OR", "MI", "…
    $ vb_vf_reg_state                              <chr> "MI", "CA", "OR", "MI", "…
    $ vb_vf_cd                                     <chr> "011", "045", "005", "002…
    $ vb_voterbase_registration_status             <chr> "Registered", "Registered…
    $ vb_vf_voter_status                           <chr> "Active", "Active", "Acti…
    $ vb_voterbase_dob                             <date> 1998-01-01, 2000-09-03, …
    $ vb_voterbase_gender                          <chr> "Female", "Male", "Unknow…
    $ vb_voterbase_race                            <chr> "W", "H", "W", "W", "W", …
    $ civis_race                                   <chr> "WHITE", "HISPANIC", "WHI…
    $ vb_vf_party                                  <chr> "Unaffiliated", "No Party…
    $ vb_vf_county_name                            <chr> "OAKLAND", "ORANGE", "DES…
    $ vb_tsmart_cd                                 <chr> "011", "045", "005", "002…
    $ ts_tsmart_partisan_score                     <dbl> 86.6, 72.1, 99.4, 99.1, 9…
    $ ts_tsmart_presidential_general_turnout_score <dbl> 41.1, 52.0, 43.6, 86.8, 4…
    $ ts_tsmart_ideology_score                     <dbl> 63.0, 86.6, 57.1, 63.2, 7…
    $ ts_tsmart_college_graduate_score             <dbl> 16.6, 24.2, 26.3, 17.7, 4…
    $ ts_tsmart_urbanicity                         <chr> "U5", "U6", "S4", "R1", "…
    $ vb_tsmart_address_deliverability_indicator   <int> 1, 1, 1, 1, 1, 1, 1, 1, 1…
    $ vb_voterbase_mailable_flag                   <chr> "Yes", "Yes", "Yes", "Yes…
    $ vb_voterbase_deceased_flag                   <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_g2022                                  <chr> NA, "A", NA, "P", NA, "R"…
    $ vb_vf_g2020                                  <chr> "P", NA, "Y", "A", "A", "…
    $ vb_vf_g2018                                  <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_g2016                                  <chr> NA, NA, NA, NA, NA, "R", …
    $ vb_vf_g2012                                  <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_p2022                                  <chr> NA, NA, NA, "P", NA, NA, …
    $ vb_vf_p2020                                  <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_p2018                                  <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_p2016                                  <chr> NA, NA, NA, NA, NA, NA, N…

                                      bq_ts_path 
                                               0 
                                 vb_voterbase_id 
                                               0 
                           vb_tsmart_exact_track 
                                           53965 
                   vb_tsmart_exact_address_track 
                                           53965 
                                       tmc_hh_id 
                                           54005 
                                       file_date 
                                           53965 
                              vb_vf_source_state 
                                           53965 
                                 vb_tsmart_state 
                                           53999 
                                 vb_vf_reg_state 
                                           53998 
                                        vb_vf_cd 
                                           55112 
                vb_voterbase_registration_status 
                                           53965 
                              vb_vf_voter_status 
                                           53965 
                                vb_voterbase_dob 
                                           64772 
                             vb_voterbase_gender 
                                           53965 
                               vb_voterbase_race 
                                           53965 
                                      civis_race 
                                          244837 
                                     vb_vf_party 
                                           53965 
                               vb_vf_county_name 
                                           53965 
                                    vb_tsmart_cd 
                                          107151 
                        ts_tsmart_partisan_score 
                                           53965 
    ts_tsmart_presidential_general_turnout_score 
                                           53965 
                        ts_tsmart_ideology_score 
                                           61842 
                ts_tsmart_college_graduate_score 
                                           61842 
                            ts_tsmart_urbanicity 
                                           55892 
      vb_tsmart_address_deliverability_indicator 
                                           53965 
                      vb_voterbase_mailable_flag 
                                           53965 
                      vb_voterbase_deceased_flag 
                                         4608154 
                                     vb_vf_g2022 
                                         2619006 
                                     vb_vf_g2020 
                                         1004079 
                                     vb_vf_g2018 
                                         2919354 
                                     vb_vf_g2016 
                                         3663859 
                                     vb_vf_g2012 
                                         3301495 
                                     vb_vf_p2022 
                                         4102796 
                                     vb_vf_p2020 
                                         3739094 
                                     vb_vf_p2018 
                                         4278179 
                                     vb_vf_p2016 
                                         4268998 
