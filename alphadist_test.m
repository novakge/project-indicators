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


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end