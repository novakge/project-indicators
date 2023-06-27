% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicator_os_test)
% example#2: runtests('indicator_os_test')

function tests = indicator_os_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% compare some results with literature
data = load('../test_data/pat1_DSM.mat', 'DSM');
testCase.TestData.OS_001 = data.DSM;

data = load('../test_data/pat103_DSM.mat', 'DSM');
testCase.TestData.OS_002 = data.DSM;

data = load('../test_data/pat3_DSM.mat', 'DSM');
testCase.TestData.OS_003 = data.DSM;

data = load('../test_data/pat9_DSM.mat', 'DSM');
testCase.TestData.OS_004 = data.DSM;

data = load('../test_data/pat11_DSM.mat', 'DSM');
testCase.TestData.OS_005 = data.DSM;

% no connections case
testCase.TestData.OS_006 = [1,0,0
                            0,1,0
                            0,0,1];

% complete upper triangle matrix case
testCase.TestData.OS_007 = [1,1,1
                            0,1,1
                            0,0,1];
                        
% ignore lower triangle case
testCase.TestData.OS_008 = [1,0,0
                            1,1,0
                            1,1,1];
% not a binary DSM case
testCase.TestData.OS_009 = [1.0, 0.1, 0.6
                            0.2, 0.4, 0.5
                            0.5, 0.1, 0.9];
                        
% serial case
testCase.TestData.OS_010 = [1,1,0,0
                            0,1,1,0
                            0,0,1,1
                            0,0,0,1];
                        
% parallel case
testCase.TestData.OS_011 = [1,0,0,1
                            0,1,0,1
                            0,0,1,1
                            0,0,0,1];
                        
end

function test_OS_001(testCase)
os = indicator_os(testCase.TestData.OS_001);
actSolution = os;
expSolution = 0.47; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_002(testCase)
os = indicator_os(testCase.TestData.OS_002);
actSolution = os;
expSolution = 0.766; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_003(testCase)
os = indicator_os(testCase.TestData.OS_003);
actSolution = os;
expSolution = 0.4; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_004(testCase)
os = indicator_os(testCase.TestData.OS_004);
actSolution = os;
expSolution = 0.392; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_005(testCase)
os = indicator_os(testCase.TestData.OS_005);
actSolution = os;
expSolution = 0.733; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017.xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_006(testCase)
actSolution = indicator_os(testCase.TestData.OS_006);
expSolution = 0;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_007(testCase)
actSolution = indicator_os(testCase.TestData.OS_007);
expSolution = 1;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_008(testCase)
actSolution = indicator_os(testCase.TestData.OS_008);
expSolution = 0;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_009(testCase)
actSolution = indicator_os(testCase.TestData.OS_009);
expSolution = 1;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_010(testCase)
actSolution = indicator_os(testCase.TestData.OS_010);
expSolution = 1;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_OS_011(testCase)
actSolution = indicator_os(testCase.TestData.OS_011);
expSolution = 0.5;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
