% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example #1: results = run(indicator_le_test)
% example #2: runtests('indicator_le_test')

function tests = indicator_le_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)
%% compare some results with literature
testCase.TestData.LE_PDM_001 = [1,0,1,0;0,1,1,1;0,0,1,0;0,0,0,1]; % literature example, reference(s): Van Eynde et al. (2023). "On the summary measures for the resource-constrained project scheduling problem."
% exp. result: LE = log10(5) / log10(24) = ~0.51

testCase.TestData.LE_PDM_002 = [1,1,0,0;0,1,0,0;0,0,1,1;0,0,0,1]; % literature example, reference(s): Soliman et al. (2010). "Supporting ranking queries on uncertain and incomplete data."
% exp. result: 1234, 1324, 1342, 3124, 3142, 3412, all of which have 1 before 2 and 3 before 4 => 6

%% further special cases to handle:
testCase.TestData.LE_PDM_003 = [0,0,0,0,2,3;0,0,0,0,4,5;0,0,0,0,1,6;0,0,0,0,7,8]; % has zero task, zero dependency, and dummy TD,CD to test
% 0 activity, x dependency -> # linear extensions = 0; LE = 0;

testCase.TestData.LE_PDM_004 = [0,0,0,0,2,3;0,1,0,0,4,5;0,0,0,0,1,6;0,0,0,1,7,8];
% x activity, 0 dependency -> # linear extensions = x!; LE = 1;

testCase.TestData.LE_PDM_005 = [0,1,0,0,2,3;0,1,1,1,4,5;0,0,0,1,1,6;0,0,0,0,7,8];
% 1 activity, x dependency -> # linear extensions = 1; LE = 1;

%% validation with other realization
testCase.TestData.LE_PDM_006 = [1,1,1,1,0,3,3;0,1,1,1,1,5,12;0,0,1,0,0,6,6;0,0,0,1,0,8,8;0,0,0,0,1,0,67];
% 5 activity, 6 linear extensions, LE = log(6) / log(factorial(5)=120) -> 0.3743
end

function test_LE_001(testCase)
act=indicator_le(testCase.TestData.LE_PDM_001);
exp=0.5064;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_LE_002(testCase)
act=indicator_le(testCase.TestData.LE_PDM_002);
exp=0.5637;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_LE_003(testCase)
act=indicator_le(testCase.TestData.LE_PDM_003);
exp=0;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_LE_004(testCase)
act=indicator_le(testCase.TestData.LE_PDM_004);
exp=1;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_LE_005(testCase)
act=indicator_le(testCase.TestData.LE_PDM_005);
exp=1;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_LE_006(testCase)
act=indicator_le(testCase.TestData.LE_PDM_006);
exp=0.3743;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end