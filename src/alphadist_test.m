% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(alphadist_test)
% example#2: runtests('alphadist_test')

function tests = alphadist_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)
testCase.TestData.AD_001 = [40,40,30,20,20];
testCase.TestData.AD_002 = [35,35,30,30,20];
testCase.TestData.AD_003 = [30,40,50,50,50,50,50,80,80,80,50,60,60,20,30,30,40,50,50,50];
testCase.TestData.AD_004 = [0,0,0];
testCase.TestData.AD_005 = [1,1,1];
testCase.TestData.AD_006 = [1,2,3,4,5,6,7,8,9,10];
end

function test_AD_001(testCase)
ad = alphadist(testCase.TestData.AD_001);
actSolution = ad;
expSolution = 1;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_AD_002(testCase)
ad = alphadist(testCase.TestData.AD_002);
actSolution = ad;
expSolution = 0.667;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_AD_003(testCase)
ad = alphadist(testCase.TestData.AD_003);
actSolution = ad;
expSolution = 0.367;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_AD_004(testCase)
ad = alphadist(testCase.TestData.AD_004);
actSolution = ad;
expSolution = 0;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_AD_005(testCase)
ad = alphadist(testCase.TestData.AD_005);
actSolution = ad;
expSolution = 0;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_AD_006(testCase)
ad = alphadist(testCase.TestData.AD_006);
actSolution = ad;
expSolution = 0.555;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
