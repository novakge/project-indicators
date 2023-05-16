% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(ff_test)
% example#2: runtests('ff_test')

function tests = ff_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% load parsed data from *.mat file
data = load('test_data/test_ff_1.mat', 'DSM', 'EFT', 'EST');
testCase.TestData.SLACK_001_1 = data.DSM;
testCase.TestData.SLACK_001_2 = data.EST;
testCase.TestData.SLACK_001_3 = data.EFT;

data = load('test_data/test_ff_2.mat', 'DSM', 'EFT', 'EST');
testCase.TestData.SLACK_002_1 = data.DSM;
testCase.TestData.SLACK_002_2 = data.EST;
testCase.TestData.SLACK_002_3 = data.EFT;

end

function test_SLACK_001(testCase) % Example from http://constructionmanuals.tpub.com/14043/css/Figure-9-22-PDM-network-with-total-and-free-float-calculations-264.htm
FF_act = ff(testCase.TestData.SLACK_001_1, testCase.TestData.SLACK_001_2, testCase.TestData.SLACK_001_3);
FF_exp = [0;5;0;0;2;0;0];
verifyEqual(testCase, FF_act, FF_exp, 'AbsTol',0.001);
end

function test_SLACK_002(testCase) % Example from https://www.engineer4free.com/4/what-is-free-float-free-slack-and-how-to-calculate-it-in-a-network-diagram
FF_act = ff(testCase.TestData.SLACK_002_1, testCase.TestData.SLACK_002_2, testCase.TestData.SLACK_002_3);
FF_exp = [0;0;0;0;6;9;0;0];
verifyEqual(testCase, FF_act, FF_exp, 'AbsTol',0.001);
end


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
