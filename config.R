# Configure pins
board <- pins::board_s3(bucket = "tmc-research-projects",
                        prefix = "p080_moveon_impact_analysis/",
                        region = "us-east-1",
                        versioned = F)

# Configure AWS credentials
Sys.setenv("AWS_ACCESS_KEY_ID" = Sys.getenv("TMC_s3_access_key"),
           "AWS_SECRET_ACCESS_KEY" = Sys.getenv("TMC_s3_secret_key"))

# Set S3 bucket
bucket <- "tmc-research-projects"

# Configure Google Sheets authentication
googlesheets4::gs4_auth(email = Sys.getenv("EMAIL"))

# BigQuery authentication
bigrquery::bq_auth(email = Sys.getenv("EMAIL"))

# Connect to scratch_lliu
lliu_con <- DBI:: dbConnect(bigrquery::bigquery(),
                            project = "prj-research-uxrq",
                            billing = "prj-research-uxrq",
                            dataset = "scratch_lliu")

# TS outcome table
ts_outcome_table <- "tmc-data-marts.targetsmart_raw.ntl_20250513_historic"
