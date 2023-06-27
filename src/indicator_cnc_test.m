% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_cnc_test)
% example#2: runtests('indicator_cnc_test')

function tests = indicator_cnc_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

data = load('../test_data/pat1_DSM.mat', 'DSM');
testCase.TestData.CNC_001 = data.DSM;

data = load('../test_data/pat103_DSM.mat', 'DSM');
testCase.TestData.CNC_002 = data.DSM;

data = load('../test_data/pat3_DSM.mat', 'DSM');
testCase.TestData.CNC_003 = data.DSM;

data = load('../test_data/pat9_DSM.mat', 'DSM');
testCase.TestData.CNC_004 = data.DSM;

data = load('../test_data/pat11_DSM.mat', 'DSM');
testCase.TestData.CNC_005 = data.DSM;

end

function test_CNC_001(testCase)
cnc = indicator_cnc(testCase.TestData.CNC_001);
actSolution = cnc;
expSolution = 1.25; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_CNC_002(testCase)
cnc = indicator_cnc(testCase.TestData.CNC_002);
actSolution = cnc;
expSolution = 1.673; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_CNC_003(testCase)
cnc = indicator_cnc(testCase.TestData.CNC_003);
actSolution = cnc;
expSolution = 0.909; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_CNC_004(testCase)
cnc = indicator_cnc(testCase.TestData.CNC_004);
actSolution = cnc;
expSolution = 1.313; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_CNC_005(testCase)
cnc = indicator_cnc(testCase.TestData.CNC_005);
actSolution = cnc;
expSolution = 1.0; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
