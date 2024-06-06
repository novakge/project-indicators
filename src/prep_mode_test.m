% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(prep_mode_test)
% example#2: runtests('prep_mode_test')

function tests = prep_mode_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff
end

% setup test cases
function setup(testCase)

% prepare use cases
% [DSM][TD][CD][R1W1,R1W2,...RrWw]
% n,w,r ...
end

function test_PREP_001(testCase)
% simple, no change expected
PDM = [0, 1, 2, 3];
r=1;w=1;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_002(testCase)
% no change with increasing content
PDM = [0, 1, 2, 3,4];
r=2;w=1;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_003(testCase)
% no change with increasing content
PDM = [0, 1,2, 3,4, 5,6];
r=1;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_004(testCase)
% no change with increasing content
PDM = [0, 1,2,3, 3,4,5, 6,7,8];
r=1;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_005(testCase)
% no change with increasing content
PDM = [0, 1,2, 3,4, 5,6, 8,9];
r=2;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_006(testCase)
% no change with increasing content
PDM = [0, 1,2,3, 4,5,6, 7,8,9, 10,11,12, 13,14,15];
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_007(testCase)
% no change with equal or greater resource but not equal time
PDM = [0, 2,1, -1,-1, 5,6, 5,6];
r=2;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_008(testCase)
% no change with equal time but different resource
PDM = [0, 2,2, -1,-1, 6,5, 5,6];
r=2;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_009(testCase)
% equal time and equal resource, order "A", lower expected
PDM = [0, 1,1, -2,-2, 2,1, 2,1];
r=2;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0, -2,0, 1,0, 1,0];
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_010(testCase)
% equal time and equal resource, order "B", lower expected
PDM = [0, 1,1, -2,-2, 1,2, 1,2];
r=2;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0, -2,0, 1,0, 1,0];
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_011(testCase)
% no change with equal time but different resource
% no change with equal or greater resource but not equal time
PDM = [0, 2,1, 5,6, 5,6, 5,6, 5,6, ...
       0, 2,2, -1,-1, 6,5, 5,6];
r=2;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = PDM;
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_012(testCase)
% equal time -> higher resource removed
PDM = [0, 1,1, -2,-2, 1,3, 1,2];
r=2;w=2;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0, -2,0, 1,0, 1,0];
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_013(testCase)
% equal time -> higher resource removed
PDM = [0, 1,1,1, 8,8,8,    1,2,3 1,2,3 1,2,3];
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0,0, 8,0,0,   1,0,0 1,0,0 1,0,0];
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_014(testCase)
% equal time -> higher resource removed
PDM = [0, 1,1,1, 8,8,8,    1,2,2 1,2,3 1,2,3];
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0,0, 8,0,0,   1,0,0 1,0,0 1,0,0]; % keep mode1 for all resources, as others are equal or higher
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_015(testCase)
% equal time -> higher resource removed
PDM = [0, 1,1,1, 8,8,8,    1,2,2 1,2,2 1,2,2];
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0,0, 8,0,0,   1,0,0 1,0,0 1,0,0]; % keep mode1 for all resources, as others are higher
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_016(testCase)
% equal time -> higher resource removed
PDM = [0, 1,1,1, 8,8,8,    3,2,2, 3,2,2 3,2,2];
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0,0, 8,0,0,   2,0,0 2,0,0 2,0,0]; % keep mode2 for all resources, as others are higher
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_017(testCase)
% equal time -> equal or higher resource removed
PDM = [0,1,1,1,8,8,8,    3,2,2,    3,2,2    3,2,3];
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0,0, 8,0,0,   2,0,0    2,0,0    2,0,0]; % keep mode2 for all resources, as others are higher or equal
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

function test_PREP_018(testCase)
% equal time -> equal or higher resource removed
PDM = [0, 1,1,1, 8,8,8,    3,2,3,    3,2,2    3,1,4];
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,0,0, 8,0,0,   2,0,0    2,0,0    1,0,0]; % remove mode1 for all resources, as others are higher or equal
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

% test greater or equal time with less or equal resource
function test_PREP_019(testCase)
% equal or higher time -> equal or higher resource removed
PDM = [0, 3,1,2, 8,8,8,    2,3,2,    2,3,2    2,3,2];
% mode1 is higher time and equal res than mode2 and higher res than mode3 -> remove
% mode2 is lower time and higher resource than mode1 and mode2 -> keep
% mode3 is lower time than mode1, higher time than mode2, but res are lower than mode2 -> keep
r=3;w=3;
actSolution = prep_mode(PDM, r, w);
expSolution = [0, 1,2,0, 8,8,0,   3,2,0    3,2,0    3,2,0]; % remove mode1 for all resources, as others are higher or equal
verifyEqual(testCase,actSolution,expSolution,'AbsTol',0.001)
end

% more complex / full enumeration examples

function teardown(testCase)
% reset local stuff after test
end

function teardownOnce(testCase)
% reset global stuff after test
end
