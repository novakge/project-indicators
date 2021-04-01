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
data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_modes', 'sim_type');
testCase.TestData.SLACK_001_1 = data.PDM;
testCase.TestData.SLACK_001_2 = data.num_modes; % 1 for NTP
testCase.TestData.SLACK_001_3 = data.sim_type; % 1 for NTP

% load parsed data from *.mat file
data = load('test_data/j301_10_CTP.mat', 'PDM', 'num_modes', 'sim_type');
testCase.TestData.SLACK_002_1 = data.PDM;
testCase.TestData.SLACK_002_2 = data.num_modes; % 2 for CTP
testCase.TestData.SLACK_002_3 = data.sim_type; % 2 for CTP

% load parsed data from *.mat file
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_modes', 'sim_type');
testCase.TestData.SLACK_003_1 = data.PDM;
testCase.TestData.SLACK_003_2 = data.num_modes; % w for DTP
testCase.TestData.SLACK_003_3 = data.sim_type; % 3 for DTP

% test case considering some zero activities
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_modes', 'sim_type');
testCase.TestData.SLACK_004_1 = [1 1 1 1 0  1  2  3;
                                 0 0 0 1 1  4  5  6;
                                 0 0 1 1 0  7  8  9;
                                 0 0 0 0 1  10 11 12;
                                 0 0 0 0 1  13 14 15];
testCase.TestData.SLACK_004_2 = data.num_modes; % w for DTP
testCase.TestData.SLACK_004_3 = data.sim_type; % 3 for DTP

end

function test_SLACK_001(testCase) % for NTP
[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act] = indicator_slack(testCase.TestData.SLACK_001_1,testCase.TestData.SLACK_001_2,testCase.TestData.SLACK_001_3);
[NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp] = deal(22,0.733,3,0.142,1.047,21,18,0.6,2.333);
verifyEqual(testCase,[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act], [NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp],'AbsTol',0.001)
end

function test_SLACK_002(testCase) % for CTP
[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act] = indicator_slack(testCase.TestData.SLACK_002_1,testCase.TestData.SLACK_002_2,testCase.TestData.SLACK_002_3);
[NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp] = deal([22,22],[0.733,0.733],[3,8.666],[0.142,0.131],[1.0476,0.3333],[21,66],[18,18],[0.6,0.6],[2.333,7.133]);
verifyEqual(testCase,[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act], [NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp],'AbsTol',0.001)
end

function test_SLACK_003(testCase) % for DTP
[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act] = indicator_slack(testCase.TestData.SLACK_003_1,testCase.TestData.SLACK_003_2,testCase.TestData.SLACK_003_3);
[NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp] = deal([22,17,22],[0.733,0.566,0.733],[3,3.533,8.666],[0.142,0.0929,0.131],[1.047,0.447,0.3333],[21,38,66],[18,18,18],[0.6,0.6,0.6],[2.333,4.4,7.133]);
verifyEqual(testCase,[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act], [NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp],'AbsTol',0.001)
end

function test_SLACK_004(testCase) % for DTP
[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act] = indicator_slack(testCase.TestData.SLACK_004_1,testCase.TestData.SLACK_004_2,testCase.TestData.SLACK_004_3);
[NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp] = deal([2,2,2],[0.667,0.667,0.667],[3.333,2.667,2],[0.2564,0.19,0.134],[0.153,0.142,0.133],[13,14,15],[0,0,0],[0,0,0],[0,0,0]);
verifyEqual(testCase,[NSLACK_act,PCTSLACK_act,XSLACK_act,XSLACK_R_act,TOTSLACK_R_act,MAXCPL_act,NFREESLK_act,PCTFREESLK_act,XFREESLK_act], [NSLACK_exp,PCTSLACK_exp,XSLACK_exp,XSLACK_R_exp,TOTSLACK_R_exp,MAXCPL_exp,NFREESLK_exp,PCTFREESLK_exp,XFREESLK_exp],'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end