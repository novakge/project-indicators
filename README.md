# project-indicators
Calculate project summary indicators related to structure, duration and resources (cost and quality).
Generate flexible project structures.

0. Table of Contents

1. About/Goal/description
 
 Calculate various (multi)project summary indicators related to structure, duration and resources (cost and quality).
 
 Generate flexible project structures from existing datasets including supplementary tasks and flexible dependencies with their indicators results stored in a CSV format.

2. Prerequisites
 
 Mathworks MATLAB R2017a
 
 Matrix-based instances produced by [project-parser](https://github.com/novakge/project-parsers) tool

3. Installation instructions 
 
 Copy the files to Matlab working directory
 
3.1 Folders
```
├                         <- Root directory
├── data                  <- Contains the matrix-based datasets to process
│   ├── e.g. j30          <- Folder of example dataset containing matrix-formatted instances
│   ├── e.g. mmlib50      <- ...
│   ├── ...               <- ...
├── doc                   <- Contains additional documentation, information etc.
├── src                   <- Code directory for matlab source files
├── test_data             <- Directory for test related datasets, mat files etc.
├── results               <- Directory for results and output
│   ├── e.g. j30_out      <- Example output folder containing the generated flexible instances (optional)
```

4. Features and examples

4.1 Calculate indicators (summary measures)
   
   Calculate indicators for a given data instance
    
    input: existing folder containing matrix-based project instances produced by "project-parsers" tool, e.g. j301_10_NTP.mat
    
    example: >> load('test_data/j301_10_NTP.mat', 'PDM', 'num_modes') % load variables from a MAT container
    
    example: >> [NSLACK, PCTSLACK, ~, ~] = indicator_slack(PDM, num_modes) % calculate some of the time-related indicators, ignore with "~"
    
    output: [NSLACK, PCTSLACK] variables (array) contain the calculated indicator values, e.g., NSLACK = 22, PCTSLACK = 0.73

4.2 Generate flexible structures and calculate all indicators
    
   It is also possible to batch process all datasets, generate all flexible structures and calculcate their indicators.
    
    input: existing data folder containing the already parsed matrix-based .mat files by "project-parsers" tool
    
    example: >> indicators_all
    
    output: The output files are stored in the folder ../results/ including the MAT files of flexible instances with a filename pattern ’<instance-name>_fp<#>_mode<#>.mat’,
            and ’results-<current-date>.csv’ containing all calculated indicator values. The number after ’fp’ shows the flexibility parameter 0-40% of the instance.

5. Tests

 Each folder contains the relevant unit tests for the indicators.
 To run the corresponding unit tests:

    examples: >> results = run(indicators_test) or equivalent >> runtests('indicators_test')

    examples: >> results = run(indicators_resource_test) or equivalent >> runtests('indicators_resource_test')

   Note: ../test_data contains the necessary input files for the provided unit tests.

6. Other documents and files
 

7. Changelog (README.md, this file)

 - 1.0 initial revision: documenting purpose, use, and examples


8. Links, useful docs
 - Already available results for cross-comparison (Vanhoucke et al., 2016): http://www.projectmanagement.ugent.be/sites/default/files/files/datasets/AboutData.zip
 - Summary excel with indicators (Vanhoucke et al., 2016): http://www.projectmanagement.ugent.be/sites/default/files/files/datasets/Datasets%20with%20Parameters%20and%20BKS.xlsx

9. Authors
 
Gergely Novák, Zsolt Tibor Kosztyán, 2018-2023

10. Contribution

Please contact before making a pull request.

11. License

This project is licensed under the terms of the GNU General Public License v3.0.
