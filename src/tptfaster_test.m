% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(tptfaster_test)
% example#2: runtests('tptfaster_test')

function tests = tptfaster_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% load some instances to compare
data = load('../test_data/MPLIB1_Set1_100_NTP.mat', 'PDM');
testCase.TestData.TPTFASTER001_1 = data.PDM(:,1:size(data.PDM,1)); % extract DSM
testCase.TestData.TPTFASTER001_2 = data.PDM(:,size(data.PDM,1)+1); % extract TD (first mode)

data = load('../test_data/RG300_480_NTP.mat', 'PDM');
testCase.TestData.TPTFASTER002_1 = data.PDM(:,1:size(data.PDM,1)); % extract DSM
testCase.TestData.TPTFASTER002_2 = data.PDM(:,size(data.PDM,1)+1); % extract TD (first mode)

data = load('../test_data/MPLIB2_Set4_999_DTP.mat', 'PDM');
testCase.TestData.TPTFASTER003_1 = data.PDM(:,1:size(data.PDM,1)); % extract DSM
testCase.TestData.TPTFASTER003_2 = data.PDM(:,size(data.PDM,1)+1); % extract TD (first mode)

end

function test_TPTFASTER_001(testCase)
tic
[TPT,EST,EFT,LST,LFT] = tptfast(testCase.TestData.TPTFASTER001_1,testCase.TestData.TPTFASTER001_2); % original, reference calculation
toc
tic
[TPT2,EST2,EFT2,LST2,LFT2] = tptfaster(testCase.TestData.TPTFASTER001_1,testCase.TestData.TPTFASTER001_2); % optimized version
toc
expSolution = {TPT;EST;EFT;LST;LFT}; % get reference version's results as cell
actSolution = {TPT2;EST2;EFT2;LST2;LFT2}; % get optimized version's results as cell
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_TPTFASTER_002(testCase)
tic
[TPT,EST,EFT,LST,LFT] = tptfast(testCase.TestData.TPTFASTER002_1,testCase.TestData.TPTFASTER002_2); % original, reference calculation
toc
tic
[TPT2,EST2,EFT2,LST2,LFT2] = tptfaster(testCase.TestData.TPTFASTER002_1,testCase.TestData.TPTFASTER002_2); % optimized version
toc
expSolution = {TPT;EST;EFT;LST;LFT}; % get reference version's results as cell
actSolution = {TPT2;EST2;EFT2;LST2;LFT2}; % get optimized version's results as cell
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_TPTFASTER_003(testCase)
tic
[TPT,EST,EFT,LST,LFT] = tptfast(testCase.TestData.TPTFASTER003_1,testCase.TestData.TPTFASTER003_2); % original, reference calculation
toc
tic
[TPT2,EST2,EFT2,LST2,LFT2] = tptfaster(testCase.TestData.TPTFASTER003_1,testCase.TestData.TPTFASTER003_2); % optimized version
toc
expSolution = {TPT;EST;EFT;LST;LFT}; % get reference version's results as cell
actSolution = {TPT2;EST2;EFT2;LST2;LFT2}; % get optimized version's results as cell
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end


function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
