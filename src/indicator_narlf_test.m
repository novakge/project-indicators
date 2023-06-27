% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_narlf_test)
% example#2: runtests('indicator_narlf_test')

function tests = indicator_narlf_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% load parsed data from *.mat file
data = load('../test_data/BY_10_1_14_NTP.mat', 'PDM', 'num_activities', 'num_r_resources');
PSM = data.PDM;
testCase.TestData.NARLF_001_1 = PSM;
testCase.TestData.NARLF_001_2 = data.num_activities;
testCase.TestData.NARLF_001_3 = data.num_r_resources;
testCase.TestData.NARLF_002_1 = testCase.TestData.NARLF_001_1;
testCase.TestData.NARLF_002_2 = testCase.TestData.NARLF_001_2;
testCase.TestData.NARLF_002_3 = testCase.TestData.NARLF_001_3;

% load parsed data from *.mat file
data = load('../test_data/BY_8_3_73_NTP.mat', 'PDM', 'num_activities', 'num_r_resources');
PSM = data.PDM;
testCase.TestData.NARLF_003_1 = PSM;
testCase.TestData.NARLF_003_2 = data.num_activities;
testCase.TestData.NARLF_003_3 = data.num_r_resources;

testCase.TestData.NARLF_004_1 = testCase.TestData.NARLF_003_1;
testCase.TestData.NARLF_004_2 = testCase.TestData.NARLF_003_2;
testCase.TestData.NARLF_004_3 = testCase.TestData.NARLF_003_3;



% load parsed data from *.mat file
data = load('../test_data/j301_10_NTP.mat', 'PDM', 'num_activities', 'num_r_resources');
PSM = data.PDM;
testCase.TestData.ARLF_001_1 = PSM;
testCase.TestData.ARLF_001_2 = data.num_activities; % activities
testCase.TestData.ARLF_001_3 = data.num_r_resources; % resources

% project 1 example from literature: Kurtulus, I. (1985). Multiproject scheduling: Analysis of scheduling strategies under unequal delay penalties. Journal of Operations Management, 5(3), 291–307. doi:10.1016/0272-6963(85)90015-4 
% CD is n/a (=NaN)
testCase.TestData.ARLF_002_1 = [1,1,1,1,1,0,0,NaN,0;
                                0,1,0,0,0,1,2,NaN,1;
                                0,0,1,0,0,1,3,NaN,2;
                                0,0,0,1,0,1,1,NaN,1;
                                0,0,0,0,1,1,3,NaN,3;
                                0,0,0,0,0,1,0,NaN,0];

testCase.TestData.ARLF_002_2 = 6; % 6 activities
testCase.TestData.ARLF_002_3 = 1; % 1 renewable resource


% project 2 example from literature: Kurtulus, I. (1985). Multiproject scheduling: Analysis of scheduling strategies under unequal delay penalties. Journal of Operations Management, 5(3), 291–307. doi:10.1016/0272-6963(85)90015-4 
% CD is n/a (=NaN)
testCase.TestData.ARLF_003_1 = [1,1,0,0,0,0,0,NaN,0;
                                0,1,1,1,1,0,3,NaN,1;
                                0,0,1,0,0,1,1,NaN,2;
                                0,0,0,1,0,1,3,NaN,3;
                                0,0,0,0,1,1,2,NaN,1;
                                0,0,0,0,0,1,0,NaN,0];
testCase.TestData.ARLF_003_2 = 6; % 6 activities
testCase.TestData.ARLF_003_3 = 1; % 1 renewable resource


% own example #1 with a flexible structure
%                              [ DSM         ][TD][CD ][RD ]
% testCase.TestData.ARLF_004_1 = [1,1,0  ,0,0,0,1   ,NaN ,0,3;
%                                0,1,0.8,0,0,0,4   ,NaN ,1,4;
%                                0,0, 0 ,0,0,0,5   ,NaN ,2,1;
%                                0,0,0  ,1,0,1,1   ,NaN ,2,0;
%                                0,0,0  ,0,1,1,2   ,NaN ,2,1;
%                                0,0,0  ,0,0,1,0   ,NaN ,1,1];
% testCase.TestData.ARLF_004_2 = 2; % 2 renewable resources
% testCase.TestData.ARLF_004_3 = 6; % 6 activities


end

% NARLF / NARLF_ tests
function test_NARLF_001(testCase) % NTP
[~,NARLF_act,~] = indicator_narlf(testCase.TestData.NARLF_001_1,testCase.TestData.NARLF_001_2,testCase.TestData.NARLF_001_3);
NARLF_exp = -9.453;
verifyEqual(testCase,NARLF_act,NARLF_exp,'AbsTol',0.001)
end

function test_NARLF_002(testCase) % NTP
[~,~,NARLF_act] = indicator_narlf(testCase.TestData.NARLF_002_1,testCase.TestData.NARLF_002_2,testCase.TestData.NARLF_002_3);
NARLF_exp = -12.223;
verifyEqual(testCase,NARLF_act,NARLF_exp,'AbsTol',0.001)
end

function test_NARLF_003(testCase) % NTP
[~,NARLF_act,~] = indicator_narlf(testCase.TestData.NARLF_003_1,testCase.TestData.NARLF_003_2,testCase.TestData.NARLF_003_3);
NARLF_exp = -13;
verifyEqual(testCase,NARLF_act,NARLF_exp,'AbsTol',0.001)
end

function test_NARLF_004(testCase) % NTP
[~,~,NARLF_act] = indicator_narlf(testCase.TestData.NARLF_004_1,testCase.TestData.NARLF_004_2,testCase.TestData.NARLF_004_3);
NARLF_exp = -14.342;
verifyEqual(testCase,NARLF_act,NARLF_exp,'AbsTol',0.001)
end

% ARLF tests

function test_ARLF_001(testCase) % NTP
[ARLF_act,~,~] = indicator_narlf(testCase.TestData.ARLF_001_1,testCase.TestData.ARLF_001_2,testCase.TestData.ARLF_001_3);
ARLF_exp = -4.404;
verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
end

function test_ARLF_002(testCase)
[ARLF_act,~,~] = indicator_narlf(testCase.TestData.ARLF_002_1,testCase.TestData.ARLF_002_2,testCase.TestData.ARLF_002_3);
ARLF_exp = 1.334;
verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
end

function test_ARLF_003(testCase)
[ARLF_act,~,~] = indicator_narlf(testCase.TestData.ARLF_003_1,testCase.TestData.ARLF_003_2,testCase.TestData.ARLF_003_3);
ARLF_exp = 1.667;
verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
end

%function test_ARLF_004(testCase)
%[ARLF_act,~,~] = indicator_narlf(testCase.TestData.ARLF_004_1,testCase.TestData.ARLF_004_2,testCase.TestData.ARLF_004_3);
%ARLF_exp = -0.1;
%verifyEqual(testCase,ARLF_act,ARLF_exp,'AbsTol',0.001)
%end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
