% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicators_resource_test)
% example#2: runtests('indicators_resource_test')

function tests = indicators_resource_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)
% compare some results with literature or own examples
data = load('test_data/j306_9_NTP.mat','PDM','num_r_resources','constr');
testCase.TestData.RES_001 = data.PDM;
testCase.TestData.RES_002 = data.num_r_resources;
testCase.TestData.RES_003 = data.constr;
end

function test_RES_001(testCase)
[RF,RU,PCTR,DMND,XDMND,RS,RC,UTIL,XUTIL,TCON,XCON,OFACT,TOTOFACT,UFACT,TOTUFACT] = indicators_resource(testCase.TestData.RES_001,testCase.TestData.RES_002,testCase.TestData.RES_003);
actSolution = {RF;RU;XDMND;RS;RC;XUTIL;XCON;TOTOFACT;TOTUFACT}; % get results as a cell as dimensions might differ
expSolution = {0.5083;2.0333;5.8168;0.5447;0.3556;0.555;0.0378;0.6302;3.651}; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end