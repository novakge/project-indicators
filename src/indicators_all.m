% wrapper script to batch run all (multi)project indicators for the
% different flexibility factors and generate results summary report

clear % clear all obsolete variables

fprintf('Generating flexible structures...');
fsg % generate all flexible structures

fprintf('Calculating indicators, generating report...');
report_indicators % calculate all indicators and generate results report

fprintf('Finished.\n');