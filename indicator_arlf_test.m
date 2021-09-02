% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_arlf_test)
% example#2: runtests('indicator_arlf_test')

function tests = indicator_arlf_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% load parsed data from *.mat file
data = load('test_data/j301_10_NTP.mat', 'PDM', 'num_r_resources');
PSM = data.PDM;
testCase.TestData.ARLF_001_1 = PSM;
testCase.TestData.ARLF_001_2 = data.num_r_resources; % 2 resources

% project 1 example from literature: Kurtulus, I. (1985). Multiproject scheduling: Analysis of scheduling strategies under unequal delay penalties. Journal of Operations Management, 5(3), 291–307. doi:10.1016/0272-6963(85)90015-4 
% CD is n/a (=NaN)
testCase.TestData.ARLF_002_1 = [1,1,1,1,1,0,0,NaN,0;
                                0,1,0,0,0,1,2,NaN,1;
                                0,0,1,0,0,1,3,NaN,2;
                                0,0,0,1,0,1,1,NaN,1;
                                0,0,0,0,1,1,3,NaN,3;
                                0,0,0,0,0,1,0,NaN,0];
testCase.TestData.ARLF_002_2 = 1; % 1 renewable resource

% project 2 example from literature: Kurtulus, I. (1985). Multiproject scheduling: Analysis of scheduling strategies under unequal delay penalties. Journal of Operations Management, 5(3), 291–307. doi:10.1016/0272-6963(85)90015-4 
% CD is n/a (=NaN)
testCase.TestData.ARLF_003_1 = [1,1,0,0,0,0,0,NaN,0;
                                0,1,1,1,1,0,3,NaN,1;
                                0,0,1,0,0,1,1,NaN,2;
                                0,0,0,1,0,1,3,NaN,3;
                                0,0,0,0,1,1,2,NaN,1;
                                0,0,0,0,0,1,0,NaN,0];
testCase.TestData.ARLF_003_2 = 1; % 1 renewable resource

% own example #1 with a flexible structure
%                              [ DSM         ][TD][CD ][RD ]
testCase.TestData.ARLF_004_1 = [1,1,0  ,0,0,0,1   ,NaN ,0,3;
                                0,1,0.8,0,0,0,4   ,NaN ,1,4;
                                0,0, 0 ,0,0,0,5   ,NaN ,2,1;
                                0,0,0  ,1,0,1,1   ,NaN ,2,0;
                                0,0,0  ,0,1,1,2   ,NaN ,2,1;
                                0,0,0  ,0,0,1,0   ,NaN ,1,1];
testCase.TestData.ARLF_004_2 = 2; % 2 renewable resources
end

function test_ARLF_001(testCase) % NTP
[ARLF_act] = indicator_arlf(testCase.TestData.ARLF_001_1,testCase.TestData.ARLF_001_2);
ARLF_exp = -13.0476;
verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
end

function test_ARLF_002(testCase)
[ARLF_act] = indicator_arlf(testCase.TestData.ARLF_002_1,testCase.TestData.ARLF_002_2);
ARLF_exp = 1.334;
verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
end

function test_ARLF_003(testCase)
[ARLF_act] = indicator_arlf(testCase.TestData.ARLF_003_1,testCase.TestData.ARLF_003_2);
ARLF_exp = 1.667;
verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
end

function test_ARLF_004(testCase)
[ARLF_act] = indicator_arlf(testCase.TestData.ARLF_004_1,testCase.TestData.ARLF_004_2);
ARLF_exp = -0.4;
verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end