% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(fsg_test)
% example#2: runtests('fsg_test')

function tests = fsg_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff

% constants
testCase.TestData.dir_in = '../data/_structures_test/';
testCase.TestData.dir_in_sub = '../data/_structures_test/test_instances/';
testCase.TestData.dir_out = '../results/structures/test_instances_gen/';
testCase.TestData.test_file = 'MPLIB2_Set4_999_DTP.mat';

% prepare directory structure
[~,~] = mkdir(testCase.TestData.dir_in_sub); % create temporary directory for test inputs
[~,~] = mkdir(testCase.TestData.dir_out); % create temporary directory for test results
copyfile(strcat('../test_data/',testCase.TestData.test_file), strcat(testCase.TestData.dir_in_sub,testCase.TestData.test_file)); % copy inputs with a unique name

rng(123); % fix random seed for reproducibility
end

% setup test cases
function setup(testCase)
% load all data from parsed *.mat file
data = load('../test_data/MPLIB2_Set4_999_DTP.mat');
testCase.TestData.ORIG_001_1 = data.PDM;

% do the generation of flexible structures once
fsg(testCase.TestData.dir_in); 
end

function test_FSG_001(testCase) % formal check of generated instances
% check number of files according to equation
act = numel(dir(strcat(testCase.TestData.dir_out,'*.*')));
exp = 2+13; % pre-calculated by equation, including "." and ".."

verifyEqual(testCase, act, exp, 'AbsTol', 0.001);
end


function test_FSG_002(testCase)
% check naming convention of files, without order and mode
filenames = {dir(strcat(testCase.TestData.dir_out,'*.*')).name};

act = "ok";
exp = "ok";

if ~any(contains(filenames, '_maximal_fp0_mode')) || ...
   ~any(contains(filenames, '_maximin_fp1_mode')) || ...
   ~any(contains(filenames, '_maximin_fp2_mode')) || ...
   ~any(contains(filenames, '_maximin_fp3_mode')) || ...
   ~any(contains(filenames, '_maximin_fp4_mode')) || ...
   ~any(contains(filenames, '_minimal_fp1_mode')) || ...
   ~any(contains(filenames, '_minimal_fp2_mode')) || ...
   ~any(contains(filenames, '_minimal_fp3_mode')) || ...
   ~any(contains(filenames, '_minimal_fp4_mode')) || ...
   ~any(contains(filenames, '_minimax_fp1_mode')) || ...
   ~any(contains(filenames, '_minimax_fp2_mode')) || ...
   ~any(contains(filenames, '_minimax_fp3_mode')) || ...
   ~any(contains(filenames, '_minimax_fp4_mode'))
exp = "nok";
end

verifyEqual(testCase, act, exp, 'AbsTol', 0.001);
end

% function test_FSG_003(testCase)
% check file content variables exist
% check file content flexible structure type with name
% check file content flexible structure type with flexibility level
% (0=maximal, >0 not maximal)
% etc.

% data = load(strcat(testCase.TestData.dir_out,'_gen',''));
% testCase.TestData.FSG_001_1 = data.PDM;

% act = 0;
% exp = 0;
% verifyEqual(testCase, act, exp, 'AbsTol', 0.001);

% end

% ... add further tests here

function teardown(testCase)
% reset local stuff after test in reverse order
end

function teardownOnce(testCase)
% reset global stuff after test in reverse order
delete(strcat(testCase.TestData.dir_in_sub,testCase.TestData.test_file)); % delete input files
[~,~] = rmdir(testCase.TestData.dir_in_sub); % delete temporary directory for test inputs
[~,~] = rmdir(testCase.TestData.dir_in); % delete temporary directory for test inputs
[~,~] = rmdir(testCase.TestData.dir_out, 's'); % delete temporary directory and all files of test results
rng('default'); % reset random seed after test
end
