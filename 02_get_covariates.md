Get Voter File Covariates
================
Leo Liu
7/18/25

## Descriptives

    [1] 4608154

    Rows: 4,608,154
    Columns: 36
    $ bq_ts_path                                   <chr> "tmc-data-marts.targetsma…
    $ vb_voterbase_id                              <chr> "OH-13999858", "NC-552376…
    $ vb_tsmart_exact_track                        <chr> "N29459H6LQBXOKIUF5FE", "…
    $ vb_tsmart_exact_address_track                <chr> "Y000000218376148", "Y000…
    $ tmc_hh_id                                    <blob> <d6, a8, 49, fc, d2, 0e,…
    $ file_date                                    <chr> "20240409", "20240409", "…
    $ vb_vf_source_state                           <chr> "OH", "NC", "NC", "PA", "…
    $ vb_tsmart_state                              <chr> "OH", "NC", "NC", "PA", "…
    $ vb_vf_reg_state                              <chr> "OH", "NC", "NC", "PA", "…
    $ vb_vf_cd                                     <chr> "003", "007", "003", "005…
    $ vb_voterbase_registration_status             <chr> "Registered", "Registered…
    $ vb_vf_voter_status                           <chr> "Active", "Inactive", "Ac…
    $ vb_voterbase_dob                             <date> 2002-01-11, 1990-01-01, …
    $ vb_voterbase_gender                          <chr> "Unknown", "Male", "Femal…
    $ vb_voterbase_race                            <chr> "W", "H", "B", "W", "W", …
    $ civis_race                                   <chr> "AFAM", "HISPANIC", "AFAM…
    $ vb_vf_party                                  <chr> "Unaffiliated", "Unaffili…
    $ vb_vf_county_name                            <chr> "FRANKLIN", "NEW HANOVER"…
    $ vb_tsmart_cd                                 <chr> "003", "007", "003", "005…
    $ ts_tsmart_partisan_score                     <dbl> 99.7, 94.8, 99.2, 99.7, 9…
    $ ts_tsmart_presidential_general_turnout_score <dbl> 84.9, 47.1, 52.8, 88.8, 5…
    $ ts_tsmart_ideology_score                     <dbl> 63.2, 52.7, 80.2, 74.1, 7…
    $ ts_tsmart_college_graduate_score             <dbl> 47.5, 36.2, 12.7, 72.1, 3…
    $ ts_tsmart_urbanicity                         <chr> "U5", "S4", "S3", "U5", "…
    $ vb_tsmart_address_deliverability_indicator   <int> 1, 1, 1, 1, 1, 1, 1, 1, 1…
    $ vb_voterbase_mailable_flag                   <chr> "Yes", "Yes", "Yes", "Yes…
    $ vb_voterbase_deceased_flag                   <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_g2022                                  <chr> "Y", NA, NA, "P", "P", "Y…
    $ vb_vf_g2020                                  <chr> "Y", "P", "E", "M", "B", …
    $ vb_vf_g2018                                  <chr> NA, NA, NA, "R", NA, "Y",…
    $ vb_vf_g2016                                  <chr> NA, NA, NA, "R", NA, NA, …
    $ vb_vf_g2012                                  <chr> NA, NA, NA, NA, NA, NA, "…
    $ vb_vf_p2022                                  <chr> "Y", NA, NA, "P", NA, NA,…
    $ vb_vf_p2020                                  <chr> NA, NA, NA, "M", NA, "Y",…
    $ vb_vf_p2018                                  <chr> NA, NA, NA, "R", NA, NA, …
    $ vb_vf_p2016                                  <chr> NA, NA, NA, NA, NA, NA, "…

                                      bq_ts_path 
                                               0 
                                 vb_voterbase_id 
                                               0 
                           vb_tsmart_exact_track 
                                           58022 
                   vb_tsmart_exact_address_track 
                                           58022 
                                       tmc_hh_id 
                                           58038 
                                       file_date 
                                           58022 
                              vb_vf_source_state 
                                           58022 
                                 vb_tsmart_state 
                                           58032 
                                 vb_vf_reg_state 
                                           58031 
                                        vb_vf_cd 
                                           59170 
                vb_voterbase_registration_status 
                                           58022 
                              vb_vf_voter_status 
                                           58022 
                                vb_voterbase_dob 
                                           68829 
                             vb_voterbase_gender 
                                           58022 
                               vb_voterbase_race 
                                           58022 
                                      civis_race 
                                          242844 
                                     vb_vf_party 
                                           58022 
                               vb_vf_county_name 
                                           58022 
                                    vb_tsmart_cd 
                                          112430 
                        ts_tsmart_partisan_score 
                                           58022 
    ts_tsmart_presidential_general_turnout_score 
                                           58022 
                        ts_tsmart_ideology_score 
                                           59859 
                ts_tsmart_college_graduate_score 
                                           59859 
                            ts_tsmart_urbanicity 
                                           59953 
      vb_tsmart_address_deliverability_indicator 
                                           58022 
                      vb_voterbase_mailable_flag 
                                           58022 
                      vb_voterbase_deceased_flag 
                                         4608154 
                                     vb_vf_g2022 
                                         2618902 
                                     vb_vf_g2020 
                                         1002209 
                                     vb_vf_g2018 
                                         2918696 
                                     vb_vf_g2016 
                                         3663510 
                                     vb_vf_g2012 
                                         3300993 
                                     vb_vf_p2022 
                                         4101016 
                                     vb_vf_p2020 
                                         3738762 
                                     vb_vf_p2018 
                                         4278095 
                                     vb_vf_p2016 
                                         4268796 
