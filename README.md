# MoveOn Impact Analysis

This project analyzes the 2024 voter turnout project conducted by MoveOn. MoveOn designed and implemented the experiment so this repo focuses on the analysis only. The final report on this project can be found [here](https://docs.google.com/document/d/1jdJ1HHNmsx0G4aHz1agxkLeffdw5chviEJNPcSV7AVc/edit?tab=t.0).

The data is stored in S3 in the `tmc-research-projects` at `p080_moveon_impact_analysis`.

All relevant code that we wrote as part of this project is in the `code/analysis` directory. Everyting else in the `code` folder is either code that MoveOn wrote and shared with us to help explain how they did the randomization, or some initial code that we wrote to try to figure out what was going on with the data they shared but is no longer relevant for any of the actual analysis that we performed. All code in the `code/analysis` folder should be run in order if you are trying to recreate things. Several of those code files rely on environmental variables so you should ensure that you have access to the s3 bucket and that your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are saved in your Renviron file.

Andy and Leo collaborated on this project. After this project ends, the code will be archived in the TMC Research repo.
