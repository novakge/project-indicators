% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(pdm_mode_test)
% example#2: runtests('pdm_mode_test')

function tests = pdm_mode_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% load instances to test (single for regression and multi for test)
data = load('../test_data/MPLIB1_Set1_100_NTP.mat', 'PDM');
testCase.TestData.PDM_MODE001 = data.PDM; % extract DSM

data = load('../test_data/MPLIB2_Set4_999_DTP.mat', 'PDM');
testCase.TestData.PDM_MODE002 = data.PDM; % extract DSM

end

function test_PDM_MODE_001(testCase)
tic
testCase.TestData.PDM_MODE001;
expSolution = 0;
actSolution = 0;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
toc
end

function test_PDM_MODE_002(testCase)
tic
testCase.TestData.PDM_MODE002;
expSolution = 0;
actSolution = 0;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
toc
end

function test_PDM_MODE_003(testCase)
tic
w=3;
r=3;
n=3;
mode_selection= [1;2;3];
                                % DSM   TD1 TD2 TDw   CDw    R1W1 R1W2 R1W3 R2W1 R2W2 R2W3 ... RrWw
testCase.TestData.PDM_MODE003 = [1,0,0, 10, 20, 30, 0, 0, 0, 71, 72, 73, 81, 82, 83, 91, 92, 93 ; ...
                                 0,1,0, 40, 50, 60, 0, 0, 0, 74, 75, 76, 84, 85, 86, 94, 95, 96 ; ...
                                 0,0,1, 70, 80, 90, 0, 0, 0, 77, 78, 79, 87, 88, 89, 97, 98, 99 ;];

actSolution  = pdm_mode(testCase.TestData.PDM_MODE003,w,r,n,mode_selection);

expSolution                   = [1,0,0, 10, 0, 71, 81, 91 ; ...
                                 0,1,0, 50, 0, 75, 85, 95 ; ...
                                 0,0,1, 90, 0, 79, 89, 99 ;];

verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
toc
end


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
