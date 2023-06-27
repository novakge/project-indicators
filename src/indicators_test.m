% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(indicators_test)
% example#2: runtests('indicators_test')

function tests = indicators_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)
% compare some results with literature or own examples
data = load('../test_data/j306_9_NTP.mat','PDM');
data.DSM = data.PDM(:,1:size(data.PDM,1));
testCase.TestData.IX_001 = data.DSM;

data = load('../test_data/j301_10_NTP.mat','PDM');
data.DSM = data.PDM(:,1:size(data.PDM,1));
testCase.TestData.IX_002 = data.DSM;

data = load('../test_data/j301_10_DTP.mat','PDM');
data.DSM = data.PDM(:,1:size(data.PDM,1));
testCase.TestData.IX_003 = data.DSM;

data = load('../test_data/BY_8_3_73_NTP.mat','PDM');
data.DSM = data.PDM(:,1:size(data.PDM,1));
testCase.TestData.IX_004 = data.DSM;

data = load('../test_data/BY_10_1_14_NTP.mat','PDM');
data.DSM = data.PDM(:,1:size(data.PDM,1));
testCase.TestData.IX_005 = data.DSM;

data = load('../test_data/MPLIB1_Set1_100_NTP.mat','PDM');
data.DSM = data.PDM(:,1:size(data.PDM,1));
testCase.TestData.IX_006 = data.DSM;

data = load('../test_data/pat1_DSM.mat','DSM');
testCase.TestData.IX_007 = data.DSM;

data = load('../test_data/pat103_DSM.mat','DSM');
testCase.TestData.IX_008 = data.DSM;

data = load('../test_data/pat11_DSM.mat','DSM');
testCase.TestData.IX_009 = data.DSM;

data = load('../test_data/pat3_DSM.mat','DSM');
testCase.TestData.IX_010 = data.DSM;

data = load('../test_data/pat9_DSM.mat','DSM');
testCase.TestData.IX_011 = data.DSM;

end

function test_IX_001(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_001);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [30,0.275,0.357,0.011,0.704,0.238]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_002(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_002);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [30,0.241,0.246,0.0243,0.673,0.149]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_003(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_003);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [30,0.241,0.246,0.0243,0.673,0.149]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_004(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_004);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [60,0.033,0.473,0.014,1,0.64]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_005(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_005);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [60,0.0508,0.428,0.0091,0.75,0.565]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_006(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_006);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [360,0.114,00.336,0.0347,0.973,0.402]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_007(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_007);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [12,0.363,0.5,0.052,0.722,0.25]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_008(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_008);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [49,0.291,0.161,0.327,1,0]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_009(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_009);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [6,0.6,0.666,0,0.5,0.166]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_010(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_010);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [11,0.4,0.541,0.0714,1,0.333]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_IX_011(testCase)
[i1,i2,i3,i4,i5,i6]=indicators(testCase.TestData.IX_011);
actSolution = [i1,i2,i3,i4,i5,i6];
expSolution = [16,0.333,0.36,0,0.55,0.48]; % see also results of "Datasets with Parameters and BKS (BVersion 3 - 2017).xlsx"
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
