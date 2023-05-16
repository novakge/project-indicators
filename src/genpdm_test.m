% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(genpdm_test)
% example#2: runtests('genpdm_test')

function tests = genpdm_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% test case considering non-zero activities
                                %[LD TD CD RD]
testCase.TestData.GENPDM_001 = [1, 0, 0, 0]; % n=1
                                %[ LD   TD CD RD]
testCase.TestData.GENPDM_002 = [1, 1, 0, 0, 0;
                                0, 1, 0, 0, 0]; % n=2

testCase.TestData.GENPDM_003 = [1, 1, 1, 0, 0, 0; % n=max
                                0, 1, 1, 0, 0, 0;
                                0, 0, 1, 0, 0, 0];

end

function test_GENPDM_001(testCase)
[PDM,num_activities,~,~,~] = genpdm(1,1,1,1,1,1,[0,1],[0,1]);
actSolution = PDM;
expSolution = testCase.TestData.GENPDM_001;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_GENPDM_002(testCase)
[PDM,num_activities,~,~,~] = genpdm(7,1,1,2,1,1,[0,1],[0,1]);
actSolution = PDM;
expSolution = testCase.TestData.GENPDM_002;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_GENPDM_003(testCase)
[PDM,num_activities,~,~,~] = genpdm(63,1,1,3,1,1,[0,1],[0,1]);
actSolution = PDM;
expSolution = testCase.TestData.GENPDM_003;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
