% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_c_test)
% example#2: runtests('indicator_c_test')

function tests = indicator_c_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% Example from Bashir, H. A. (2010). Removal of Redundant Relationships in an AON Project Network for Evaluating Schedule Complexity. Journal of Construction Engineering and Management, 136(7), 787–793. doi:10.1061/(asce)co.1943-7862.0000181 
data = [1 1 1 0 0,
        0 1 0 1	0,
        0 0 1 1	0,
        0 0 0 1	1,
        0 0 0 0	1];

testCase.TestData.C_001 = data;

% 1st Example from Khan, M., & Siddiqui, M. (2010). Quantitative quality assessment of network-based schedules. In Proceeding of the international Conference on Computing in Civil and Building Engineering.
data = [1 1 1 0 0 0 0 0,
        0 1 0 0 0 0 0 1,
        0 0 1 1 0 0 0 0,
        0 0 0 1 1 0 0 0,
        0 0 0 0 1 1 0 0,
        0 0 0 0 0 1 1 0,
        0 0 0 0 0 0 1 1,
        0 0 0 0 0 0 0 1];
testCase.TestData.C_002 = data;


data = load('test_data/pat3_DSM.mat', 'DSM');
testCase.TestData.C_003 = data.DSM;

data = load('test_data/pat9_DSM.mat', 'DSM');
testCase.TestData.C_004 = data.DSM;

data = load('test_data/pat11_DSM.mat', 'DSM');
testCase.TestData.C_005 = data.DSM;

% 2nd Example from Khan, M., & Siddiqui, M. (2010). Quantitative quality assessment of network-based schedules. In Proceeding of the international Conference on Computing in Civil and Building Engineering.
data = [1,1,1,0,0,1,0,0,0,1,0,0;
        0,1,0,0,0,0,0,0,0,0,0,1;
        0,0,1,1,0,0,0,0,0,0,0,0;
        0,0,0,1,1,1,0,0,0,0,0,0;
        0,0,0,0,1,0,1,1,1,0,0,0;
        0,0,0,0,0,1,1,0,0,0,0,0;
        0,0,0,0,0,0,1,1,0,0,0,0;
        0,0,0,0,0,0,0,1,1,0,0,1;
        0,0,0,0,0,0,0,0,1,0,0,1;
        0,0,0,0,0,0,0,0,0,1,1,0;
        0,0,0,0,0,0,0,0,0,0,1,1;
        0,0,0,0,0,0,0,0,0,0,0,1];
testCase.TestData.C_006 = data;

end

function test_C_001(testCase)
c = indicator_c(testCase.TestData.C_001);
actSolution = c;
expSolution = 0.5503;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_C_002(testCase)
c = indicator_c(testCase.TestData.C_002);
actSolution = c;
expSolution = 0.1615;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_C_003(testCase)
c = indicator_c(testCase.TestData.C_003);
actSolution = c;
expSolution = 0;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_C_004(testCase)
c = indicator_c(testCase.TestData.C_004);
actSolution = c;
expSolution = 0.232;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_C_005(testCase)
c = indicator_c(testCase.TestData.C_005);
actSolution = c;
expSolution = 0.310;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_C_006(testCase)
c = indicator_c(testCase.TestData.C_006);
actSolution = c;
expSolution = 0.415;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end