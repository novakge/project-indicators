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
data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_modes');
testCase.TestData.XDUR_001_1 = data.PDM;
testCase.TestData.XDUR_001_2 = data.num_modes; % 1 for NTP

% load parsed data from *.mat file
data = load('test_data/j301_10_CTP.mat', 'PDM', 'num_modes');
testCase.TestData.XDUR_002_1 = data.PDM;
testCase.TestData.XDUR_002_2 = data.num_modes; % 2 for CTP

% load parsed data from *.mat file
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_modes');
testCase.TestData.XDUR_003_1 = data.PDM;
testCase.TestData.XDUR_003_2 = data.num_modes; % w for DTP

% test case considering some zero activities
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_modes');
testCase.TestData.XDUR_004_1 = [1 1 1 1 0  1  2  3;
                                0 0 0 1 1  4  5  6;
                                0 0 1 1 0  7  8  9;
                                0 0 0 0 1  10 11 12;
                                0 0 0 0 1  13 14 15];
testCase.TestData.XDUR_004_2 = data.num_modes; % w for DTP

% load parsed data from *.mat file
data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_modes');
testCase.TestData.VADUR_001_1 = data.PDM;
testCase.TestData.VADUR_001_2 = data.num_modes; % 1 for NTP

% load parsed data from *.mat file
data = load('test_data/j301_10_CTP.mat', 'PDM', 'num_modes');
testCase.TestData.VADUR_002_1 = data.PDM;
testCase.TestData.VADUR_002_2 = data.num_modes; % 2 for CTP

% load parsed data from *.mat file
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_modes');
testCase.TestData.VADUR_003_1 = data.PDM;
testCase.TestData.VADUR_003_2 = data.num_modes; % w for DTP

% test case considering some zero activities
data = load('test_data/j301_10_DTP.mat', 'PDM', 'num_modes');
testCase.TestData.VADUR_004_1 = [1 1 1 1 0  1  2  3;
                                 0 0 0 1 1  4  5  6;
                                 0 0 1 1 0  7  8  9;
                                 0 0 0 0 1  10 11 12;
                                 0 0 0 0 1  13 14 15];
testCase.TestData.VADUR_004_2 = data.num_modes; % w for DTP

end

function test_XDUR_001(testCase) % for NTP
[XDUR_act,~] = indicator_duration(testCase.TestData.XDUR_001_1,testCase.TestData.XDUR_001_2);
XDUR_exp = 2.7333;
verifyEqual(testCase,XDUR_act,XDUR_exp,'AbsTol',0.001)
end

function test_XDUR_002(testCase) % for CTP
[XDUR_act,~] = indicator_duration(testCase.TestData.XDUR_002_1,testCase.TestData.XDUR_002_2);
XDUR_exp = [2.733,8.033];
verifyEqual(testCase,XDUR_act,XDUR_exp,'AbsTol',0.001)
end

function test_XDUR_003(testCase) % for DTP
[XDUR_act,~] = indicator_duration(testCase.TestData.XDUR_003_1,testCase.TestData.XDUR_003_2);
XDUR_exp = [2.7333,4.866,8.0329];
verifyEqual(testCase,XDUR_act,XDUR_exp,'AbsTol',0.001)
end 

function test_XDUR_004(testCase) % for DTP
[XDUR_act,~] = indicator_duration(testCase.TestData.XDUR_004_1,testCase.TestData.XDUR_004_2);
XDUR_exp = [7,8,9];
verifyEqual(testCase,XDUR_act,XDUR_exp,'AbsTol',0.001)
end 


function test_VADUR_001(testCase) % for NTP
[~,VADUR_act] = indicator_duration(testCase.TestData.VADUR_001_1,testCase.TestData.VADUR_001_2);
VADUR_exp = 2.1333;
verifyEqual(testCase,VADUR_act,VADUR_exp,'AbsTol',0.001)
end

function test_VADUR_002(testCase) % for CTP
[~,VADUR_act] = indicator_duration(testCase.TestData.VADUR_002_1,testCase.TestData.VADUR_002_2);
VADUR_exp = [2.1333,5.0678];
verifyEqual(testCase,VADUR_act,VADUR_exp,'AbsTol',0.001)
end

function test_VADUR_003(testCase) % for DTP
[~,VADUR_act] = indicator_duration(testCase.TestData.VADUR_003_1,testCase.TestData.VADUR_003_2);
VADUR_exp = [2.1333,4.395,5.0678];
verifyEqual(testCase,VADUR_act,VADUR_exp,'AbsTol',0.001)
end

function test_VADUR_004(testCase) % for DTP
[~,VADUR_act] = indicator_duration(testCase.TestData.VADUR_004_1,testCase.TestData.VADUR_004_2);
VADUR_exp = [36,36,36];
verifyEqual(testCase,VADUR_act,VADUR_exp,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
