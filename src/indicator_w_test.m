% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example #1: results = run(indicator_w_test)
% example #2: runtests('indicator_w_test')

function tests = indicator_w_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)
%% compare some results with literature
testCase.TestData.W_PDM_001 = [1,0,1,0;0,1,1,1;0,0,1,0;0,0,0,1]; % literature example, reference(s): Van Eynde et al. (2023). "On the summary measures for the resource-constrained project scheduling problem."
% exp. result: W = 0.3333

testCase.TestData.W_PDM_002 = [1,1,0,0,0,0,0;0,1,1,0,0,0,0;0,0,1,0,0,0,1;0,0,0,1,1,0,0;0,0,0,0,1,1,0;0,0,0,0,0,1,1;0,0,0,0,0,0,1]; % literature example, reference(s): Van Eynde et al. (2023). "On the summary measures for the resource-constrained project scheduling problem."
% exp. result: W = 0.5

testCase.TestData.W_PDM_003 = [1,1,0,0,0,0,0;0,1,1,0,0,0,1;0,0,1,0,0,0,0;0,0,0,1,0,0,0;0,0,0,0,1,0,0;0,0,0,0,0,1,0;0,0,0,0,0,0,1]; % literature example, reference(s): Van Eynde et al. (2023). "On the summary measures for the resource-constrained project scheduling problem."
% exp. result: W = 0.1667

%% further special cases to handle:
testCase.TestData.W_PDM_004 = [0,0,0,0,2,3;0,0,0,0,4,5;0,0,0,0,1,6;0,0,0,0,7,8]; % has zero task, zero dependency, and dummy TD,CD to test
% 0 activity, x dependency -> W = 0

testCase.TestData.W_PDM_005 = [0,0,0,0,2,3;0,1,0,0,4,5;0,0,0,0,1,6;0,0,0,1,7,8];
% x activity, 0 dependency -> W = 1

testCase.TestData.W_PDM_006 = [0,1,0,0,2,3;0,1,1,1,4,5;0,0,0,1,1,6;0,0,0,0,7,8];
% 1 activity, x dependency -> W = 1

%% validation with other realization
testCase.TestData.W_PDM_007 = [1,1,0,0,1,0,0,1;0,1,0,0,1,0,0,1;0,0,1,0,0,0,1,0;0,0,0,1,0,1,0,0;0,0,0,0,1,0,0,1;0,0,0,0,0,1,0,0;0,0,0,0,0,0,1,0;0,0,0,0,0,0,0,1];
% W = 0.2857
end

function test_W_001(testCase)
act=indicator_w(testCase.TestData.W_PDM_001);
exp=0.3333;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_W_002(testCase)
act=indicator_w(testCase.TestData.W_PDM_002);
exp=0.5;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_W_003(testCase)
act=indicator_w(testCase.TestData.W_PDM_003);
exp=0.1667;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_W_004(testCase)
act=indicator_w(testCase.TestData.W_PDM_004);
exp=0;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_W_005(testCase)
act=indicator_le(testCase.TestData.W_PDM_005);
exp=1;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_W_006(testCase)
act=indicator_w(testCase.TestData.W_PDM_006);
exp=1;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function test_W_007(testCase)
act=indicator_w(testCase.TestData.W_PDM_007);
exp=0.2857;
verifyEqual(testCase,act,exp,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
