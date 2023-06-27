% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_xdensity_test)
% example#2: runtests('indicator_xdensity_test')

function tests = indicator_xdensity_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

data = load('../test_data/pat1_DSM.mat', 'DSM');
testCase.TestData.XDENSITY_001 = data.DSM;

data = load('../test_data/pat103_DSM.mat', 'DSM');
testCase.TestData.XDENSITY_002 = data.DSM;

data = load('../test_data/pat3_DSM.mat', 'DSM');
testCase.TestData.XDENSITY_003 = data.DSM;

data = load('../test_data/pat9_DSM.mat', 'DSM');
testCase.TestData.XDENSITY_004 = data.DSM;

data = load('../test_data/pat11_DSM.mat', 'DSM');
testCase.TestData.XDENSITY_005 = data.DSM;

end

function test_XDENSITY_001(testCase)
xdensity = indicator_xdensity(testCase.TestData.XDENSITY_001);
actSolution = xdensity;
expSolution = 0.666;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_XDENSITY_002(testCase)
xdensity = indicator_xdensity(testCase.TestData.XDENSITY_002);
actSolution = xdensity;
expSolution = 0.53;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_XDENSITY_003(testCase)
xdensity = indicator_xdensity(testCase.TestData.XDENSITY_003);
actSolution = xdensity;
expSolution = 0.363;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_XDENSITY_004(testCase)
xdensity = indicator_xdensity(testCase.TestData.XDENSITY_004);
actSolution = xdensity;
expSolution = 0.687;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_XDENSITY_005(testCase)
xdensity = indicator_xdensity(testCase.TestData.XDENSITY_005);
actSolution = xdensity;
expSolution = 0.5;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
