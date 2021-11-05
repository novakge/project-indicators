% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_gini_test)
% example#2: runtests('indicator_gini_test')

function tests = indicator_gini_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

data = load('test_data/MPLIB1_Set1_100_NTP.mat', 'PDM', 'num_r_resources');
testCase.TestData.GINI_001 = data.PDM;
testCase.TestData.GINI_002 = data.num_r_resources;

data = load('test_data/BY_8_3_73_NTP.mat', 'PDM', 'num_r_resources');
testCase.TestData.GINI_003 = data.PDM;
testCase.TestData.GINI_004 = data.num_r_resources;

data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_r_resources');
testCase.TestData.GINI_005 = data.PDM;
testCase.TestData.GINI_006 = data.num_r_resources;
end

function test_GINI_001(testCase)
gini = indicator_gini(testCase.TestData.GINI_001, testCase.TestData.GINI_002);
actSolution = gini;
expSolution = 0.378;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_GINI_002(testCase)
gini = indicator_gini(testCase.TestData.GINI_003, testCase.TestData.GINI_004);
actSolution = gini;
expSolution = 0.49;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end


function test_GINI_003(testCase)
gini = indicator_gini(testCase.TestData.GINI_005, testCase.TestData.GINI_006);
actSolution = gini;
expSolution = 0.532;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end