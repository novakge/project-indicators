% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_tdensity_test)
% example#2: runtests('indicator_tdensity_test')

function tests = indicator_tdensity_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

data = load('../test_data/pat1_DSM.mat', 'DSM');
testCase.TestData.TDENSITY_001 = data.DSM;

data = load('../test_data/pat103_DSM.mat', 'DSM');
testCase.TestData.TDENSITY_002 = data.DSM;

data = load('../test_data/pat3_DSM.mat', 'DSM');
testCase.TestData.TDENSITY_003 = data.DSM;

data = load('../test_data/pat9_DSM.mat', 'DSM');
testCase.TestData.TDENSITY_004 = data.DSM;

data = load('../test_data/pat11_DSM.mat', 'DSM');
testCase.TestData.TDENSITY_005 = data.DSM;

end

function test_TDENSITY_001(testCase)
tdensity = indicator_tdensity(testCase.TestData.TDENSITY_001);
actSolution = tdensity;
expSolution = 8;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_TDENSITY_002(testCase)
tdensity = indicator_tdensity(testCase.TestData.TDENSITY_002);
actSolution = tdensity;
expSolution = 26;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_TDENSITY_003(testCase)
tdensity = indicator_tdensity(testCase.TestData.TDENSITY_003);
actSolution = tdensity;
expSolution = 4;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_TDENSITY_004(testCase)
tdensity = indicator_tdensity(testCase.TestData.TDENSITY_004);
actSolution = tdensity;
expSolution = 11;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_TDENSITY_005(testCase)
tdensity = indicator_tdensity(testCase.TestData.TDENSITY_005);
actSolution = tdensity;
expSolution = 3;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
