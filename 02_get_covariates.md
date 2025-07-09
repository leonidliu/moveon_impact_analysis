Get Voter File Covariates
================
Leo Liu
7/9/25

## Descriptives

    [1] 4608154

    Rows: 4,608,154
    Columns: 33
    $ bq_ts_path                                   <chr> "tmc-data-marts.targetsma…
    $ vb_voterbase_id                              <chr> "AZ-8241405", "OR-4313222…
    $ vb_tsmart_exact_track                        <chr> "Y29458873271212", "N2945…
    $ vb_tsmart_exact_address_track                <chr> "Y000000136753130", "Y000…
    $ tmc_hh_id                                    <blob> <c8, dc, 31, 4f, aa, 5a,…
    $ file_date                                    <chr> "20240409", "20240409", "…
    $ vb_vf_source_state                           <chr> "AZ", "OR", "NE", "GA", "…
    $ vb_tsmart_state                              <chr> "MN", "OR", "NE", "GA", "…
    $ vb_voterbase_registration_status             <chr> "Registered", "Registered…
    $ vb_vf_voter_status                           <chr> "Inactive", "Active", "Ac…
    $ vb_voterbase_dob                             <date> 1993-01-01, 1999-01-01, …
    $ vb_voterbase_gender                          <chr> "Female", "Unknown", "Fem…
    $ vb_voterbase_race                            <chr> "W", "W", "W", "B", "H", …
    $ civis_race                                   <chr> "WHITE", "WHITE", "WHITE"…
    $ vb_vf_party                                  <chr> "Democrat", "No Party", "…
    $ vb_vf_county_name                            <chr> "MARICOPA", "WASHINGTON",…
    $ vb_tsmart_cd                                 <chr> "004", "006", "002", "009…
    $ ts_tsmart_partisan_score                     <dbl> 99.5, 86.2, 89.1, 99.2, 9…
    $ ts_tsmart_presidential_general_turnout_score <dbl> 75.3, 39.7, 39.5, 37.7, 7…
    $ ts_tsmart_ideology_score                     <dbl> 71.6, 54.2, 58.0, 77.8, 8…
    $ ts_tsmart_college_graduate_score             <dbl> 70.8, 33.1, 32.5, 67.6, 6…
    $ ts_tsmart_urbanicity                         <chr> "S3", "U5", "U5", "S4", "…
    $ vb_tsmart_address_deliverability_indicator   <int> 1, 1, 1, 1, 1, 1, 1, 1, 1…
    $ vb_voterbase_mailable_flag                   <chr> "Yes", "Yes", "Yes", "Yes…
    $ vb_voterbase_deceased_flag                   <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_g2022                                  <chr> "E", NA, NA, NA, "A", "A"…
    $ vb_vf_g2020                                  <chr> NA, "Y", "Y", NA, "B", "A…
    $ vb_vf_g2018                                  <chr> NA, "Y", NA, "Y", NA, NA,…
    $ vb_vf_g2016                                  <chr> NA, NA, NA, NA, "B", NA, …
    $ vb_vf_p2022                                  <chr> "E", NA, NA, NA, NA, NA, …
    $ vb_vf_p2020                                  <chr> NA, NA, NA, "Y", "B", NA,…
    $ vb_vf_p2018                                  <chr> NA, NA, NA, NA, NA, NA, N…
    $ vb_vf_p2016                                  <chr> NA, NA, NA, NA, NA, NA, N…

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
                                     vb_vf_p2022 
                                         4101016 
                                     vb_vf_p2020 
                                         3738762 
                                     vb_vf_p2018 
                                         4278095 
                                     vb_vf_p2016 
                                         4268796 
