% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_duration_test)
% example#2: runtests('indicator_duration_test')

function tests = indicator_duration_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% load parsed data from *.mat file
data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.XDUR_001_1 = data.PDM;
testCase.TestData.XDUR_001_2 = data.num_activities;
testCase.TestData.XDUR_001_3 = data.num_modes; % 1 for NTP
testCase.TestData.XDUR_001_4 = data.sim_type; % 1 for NTP

% load parsed data from *.mat file
data = load('test_data/j301_10_CTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.XDUR_002_1 = data.PDM;
testCase.TestData.XDUR_002_2 = data.num_activities;
testCase.TestData.XDUR_002_3 = data.num_modes; % 2 for CTP
testCase.TestData.XDUR_002_4 = data.sim_type; % 2 for CTP

% load parsed data from *.mat file
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.XDUR_003_1 = data.PDM;
testCase.TestData.XDUR_003_2 = data.num_activities;
testCase.TestData.XDUR_003_3 = data.num_modes; % 3 for DTP
testCase.TestData.XDUR_003_4 = data.sim_type; % 3 for DTP 

% load parsed data from *.mat file
data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.VADUR_001_1 = data.PDM;
testCase.TestData.VADUR_001_2 = data.num_activities;
testCase.TestData.VADUR_001_3 = data.num_modes; % 1 for NTP
testCase.TestData.VADUR_001_4 = data.sim_type; % 1 for NTP

% load parsed data from *.mat file
data = load('test_data/j301_10_CTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.VADUR_002_1 = data.PDM;
testCase.TestData.VADUR_002_2 = data.num_activities;
testCase.TestData.VADUR_002_3 = data.num_modes; % 2 for CTP
testCase.TestData.VADUR_002_4 = data.sim_type; % 2 for CTP

% load parsed data from *.mat file
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type');
testCase.TestData.VADUR_003_1 = data.PDM;
testCase.TestData.VADUR_003_2 = data.num_activities;
testCase.TestData.VADUR_003_3 = data.num_modes; % w for DTP
testCase.TestData.VADUR_003_4 = data.sim_type; % 3 for DTP

end

function test_XDUR_001(testCase) % for NTP
[XDUR_act,~] = indicator_duration(testCase.TestData.XDUR_001_1,testCase.TestData.XDUR_001_2,testCase.TestData.XDUR_001_3,testCase.TestData.XDUR_001_4);
XDUR_exp = 2.7333;
verifyEqual(testCase,XDUR_act,XDUR_exp,'AbsTol',0.001)
end

function test_XDUR_002(testCase) % for CTP
[XDUR_act,~] = indicator_duration(testCase.TestData.XDUR_002_1,testCase.TestData.XDUR_002_2,testCase.TestData.XDUR_002_3,testCase.TestData.XDUR_002_4);
XDUR_exp = [2.733,8.033];
verifyEqual(testCase,XDUR_act,XDUR_exp,'AbsTol',0.001)
end

function test_XDUR_003(testCase) % for DTP
[XDUR_act,~] = indicator_duration(testCase.TestData.XDUR_003_1,testCase.TestData.XDUR_003_2,testCase.TestData.XDUR_003_3,testCase.TestData.XDUR_003_4);
XDUR_exp = [2.7333,4.866,8.0329];
verifyEqual(testCase,XDUR_act,XDUR_exp,'AbsTol',0.001)
end 


function test_VADUR_001(testCase) % for NTP
[~,VADUR_act] = indicator_duration(testCase.TestData.VADUR_001_1,testCase.TestData.VADUR_001_2,testCase.TestData.VADUR_001_3,testCase.TestData.VADUR_001_4);
VADUR_exp = 2.1333;
verifyEqual(testCase,VADUR_act,VADUR_exp,'AbsTol',0.001)
end

function test_VADUR_002(testCase) % for CTP
[~,VADUR_act] = indicator_duration(testCase.TestData.VADUR_002_1,testCase.TestData.VADUR_002_2,testCase.TestData.VADUR_002_3,testCase.TestData.VADUR_002_4);
VADUR_exp = [2.1333,5.0678]
verifyEqual(testCase,VADUR_act,VADUR_exp,'AbsTol',0.001)
end

function test_VADUR_003(testCase) % for DTP
[~,VADUR_act] = indicator_duration(testCase.TestData.VADUR_003_1,testCase.TestData.VADUR_003_2,testCase.TestData.VADUR_003_3,testCase.TestData.VADUR_003_4);
VADUR_exp = [2.1333,4.395,5.0678]
verifyEqual(testCase,VADUR_act,VADUR_exp,'AbsTol',0.001)
end


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end