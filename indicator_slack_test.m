% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_slack_test)
% example#2: runtests('indicator_slack_test')

function tests = indicator_slack_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% load parsed data from *.mat file
data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.SLACK_001_1 = data.PDM;
testCase.TestData.SLACK_001_2 = data.num_activities;
testCase.TestData.SLACK_001_3 = data.num_modes; % 1 for NTP
testCase.TestData.SLACK_001_4 = data.sim_type; % 1 for NTP

% load parsed data from *.mat file
data = load('test_data/j301_10_CTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.SLACK_002_1 = data.PDM;
testCase.TestData.SLACK_002_2 = data.num_activities;
testCase.TestData.SLACK_002_3 = data.num_modes; % 2 for CTP
testCase.TestData.SLACK_002_4 = data.sim_type; % 2 for CTP

% load parsed data from *.mat file
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.SLACK_003_1 = data.PDM;
testCase.TestData.SLACK_003_2 = data.num_activities;
testCase.TestData.SLACK_003_3 = data.num_modes; % w for DTP
testCase.TestData.SLACK_003_4 = data.sim_type; % 3 for DTP

end

function test_SLACK_001(testCase) % for NTP
[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act] = indicator_slack(testCase.TestData.SLACK_001_1,testCase.TestData.SLACK_001_2,testCase.TestData.SLACK_001_3,testCase.TestData.SLACK_001_4);
[NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp] = deal(22,0.733,3,0.142,1.047,21,18,0.6,2.333);
verifyEqual(testCase,[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act], [NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp],'AbsTol',0.001)
end

function test_SLACK_002(testCase) % for CTP
[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act] = indicator_slack(testCase.TestData.SLACK_002_1,testCase.TestData.SLACK_002_2,testCase.TestData.SLACK_002_3,testCase.TestData.SLACK_002_4);
[NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp] = deal(22,0.733,3,0.142,4.285,21,19,0.633,Inf);
verifyEqual(testCase,[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act], [NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp],'AbsTol',0.001)
end

function test_SLACK_003(testCase) % for DTP
[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act] = indicator_slack(testCase.TestData.SLACK_003_1,testCase.TestData.SLACK_003_2,testCase.TestData.SLACK_003_3,testCase.TestData.SLACK_003_4);
[NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp] = deal(22,0.733,3,0.142,4.285,21,19,0.633,Inf);
verifyEqual(testCase,[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act], [NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp],'AbsTol',0.001)
end


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end