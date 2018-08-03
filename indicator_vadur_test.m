% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_vadur_test)
% example#2: runtests('indicator_vadur_test')

function tests = indicator_vadur_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

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
testCase.TestData.VADUR_003_4 = data.sim_type; % w for DTP

end

function test_VADUR_001(testCase) % for NTP
actSolution = indicator_vadur(testCase.TestData.VADUR_001_1,testCase.TestData.VADUR_001_2,testCase.TestData.VADUR_001_3,testCase.TestData.VADUR_001_4);
expSolution = 2.1333;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_VADUR_002(testCase) % for CTP
actSolution = indicator_vadur(testCase.TestData.VADUR_002_1,testCase.TestData.VADUR_002_2,testCase.TestData.VADUR_002_3,testCase.TestData.VADUR_002_4);
expSolution = 2.4777;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_VADUR_003(testCase) % for DTP
actSolution = indicator_vadur(testCase.TestData.VADUR_003_1,testCase.TestData.VADUR_003_2,testCase.TestData.VADUR_003_3,testCase.TestData.VADUR_003_4);
expSolution = 2.678;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end