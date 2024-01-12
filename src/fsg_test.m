% https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html
% example#1: results = run(fsg_test)
% example#2: runtests('fsg_test')
function tests = fsg_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
% setup global stuff

% data template (name,type,size_min,size_max,value_range)
testCase.TestData.var_data = { ...
    'constr','double',          [1,3], [1,Inf],   [-1,Inf];  ... % [Ct=1,Cc=1,{Cq=1},{Cr=r},Cs=1]
    'sim_type','double',        [1,1], [1,1],     [1,3];     ... % 1, 2, 3
    'struct_type','string',     [1,1], [1,1],     [0,7];     ... % maximal, maximin, minimax, minimal
    'release_dates','double',   [1,1], [1,Inf],   [0,Inf];   ... % 0...n,...,0...n
    'num_projects','double',    [1,1], [1,1],     [1,Inf];   ... % 1...n
    'num_activities','double',  [1,1], [1,Inf],   [1,Inf];   ... % 1...n,...,1...n
    'num_r_resources','double', [1,1], [1,Inf],   [0,Inf];   ... % 0...n
    'num_modes','double',       [1,1], [1,1],     [1,Inf];   ... % 1...w
    'PDM','double',             [1,1], [Inf,Inf], [0,Inf];   ... % 0...
    'mode','double',            [1,1], [1,1],     [1,Inf];   ... % 1...w
    'fr','double',              [1,1], [1,1],     [0.0,1.0]; ... % 0.0...1.0
    'sr','double',              [1,1], [1,1],     [0.0,1.0]; ... % 0.0...1.0
    'fp','double',              [1,1], [1,1],     [0.0,0.4]; ... % 0, 0.1, 0.2, 0.3, 0.4
    };

testCase.TestData.var_count = length(testCase.TestData.var_data);

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

% load all data from parsed *.mat file
data = load('../test_data/MPLIB2_Set4_999_DTP.mat');
testCase.TestData.instance = data;

% do the generation of flexible structures once
fsg(testCase.TestData.dir_in);

% store generated filenames
testCase.TestData.filenames = {dir(strcat(testCase.TestData.dir_out,'*.*')).name};
testCase.TestData.filenames = testCase.TestData.filenames(3:end); % remove "." and ".."

end

% setup test cases
function setup(testCase)
% runs every test case
end

%% check files of generated instances
% check number of files according to equation
function test_FSG_001(testCase)

act = numel(dir(strcat(testCase.TestData.dir_out,'*.*')));
exp = 2+13; % pre-calculated by equation, including "." and ".."

verifyEqual(testCase, act, exp, 'AbsTol', 0.001);

end

% check naming convention of files, without order and mode
function test_FSG_002(testCase)

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

%% check variables of files
% check number of variables (and if not empty)
function test_FSG_003(testCase)

for i = 1:numel(testCase.TestData.filenames) % go through files
    act = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i)))); % load file
    act = length(struct2cell(act)); % convert to cell
    exp = testCase.TestData.var_count; % get expected number of variables
    
    verifyEqual(testCase, act, exp, 'AbsTol', 0.001);
end
end

% check if variable names are correct
function test_FSG_004(testCase)

for i = 1:numel(testCase.TestData.filenames) % go through files
    act = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i)))); % load file
    varnames = testCase.TestData.var_data(:,1);
    act = ~ismember(fieldnames(act),varnames); % compare with template
    act = any(act); % evaluate all variables
    exp = false; % no mismatch expected
    verifyEqual(testCase, act, exp, 'AbsTol', 0.001);
end
end

% check variables not empty
function test_FSG_005(testCase)
import matlab.unittest.constraints.IsEmpty

for i = 1:numel(testCase.TestData.filenames) % go through files
    act = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i))));
    act = struct2cell(act);
    for j = 1:length(act)
        testCase.verifyThat(act{j},~IsEmpty);
    end
end
end

% check variable types
function test_FSG_006(testCase)

for i = 1:numel(testCase.TestData.filenames) % go through files
    act = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i))));
    for j = 1:length(act)
        act = class(act.(testCase.TestData.var_data{j,1})); % get class of selected variable
        exp = char(testCase.TestData.var_data(j,2)); % compare with template
        verifyEqual(testCase, act, exp, 'AbsTol', 0.001);
    end
end
end

% check variable size ranges [min,max]
function test_FSG_007(testCase)

for i = 1:numel(testCase.TestData.filenames) % go through files
    
    act = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i))));
    
    for j = 1:length(testCase.TestData.var_data)
        varsize = size(act.(testCase.TestData.var_data{j,1})); % get size of selected variable
        
        min_range = testCase.TestData.var_data{j,3}; % get defined min range
        max_range = testCase.TestData.var_data{j,4}; % get defined max range
        
        exp = false; % start ok
        
        if any(varsize < min_range) % size lower than minimum
            exp = true; % failed
        end
        if any(varsize > max_range) % size higher than maximum
            exp = true; % failed
        end
        
        verifyEqual(testCase, false, exp, 'AbsTol', 0.001);
    end
end
end

% check variable value ranges [min,max] for outliers
function test_FSG_008(testCase)
for i = 1:numel(testCase.TestData.filenames) % go through files
    
    act = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i))));
    
    for j = 1:length(testCase.TestData.var_data)
        var_values = act.(testCase.TestData.var_data{j,1}); % get values of selected variable
        var_ranges = testCase.TestData.var_data{j,5}; % get defined min range
        
        exp = false; % start ok
        
        if isnumeric(var_values) % strings etc. cannot be safely compared for range
            
            if min(min(var_values)) < var_ranges(1) % value lower than minimum
                exp = true; % failed
            end
            if max(max(var_values)) > var_ranges(2) % value higher than maximum
                exp = true; % failed
            end
        end
        verifyEqual(testCase, false, exp, 'AbsTol', 0.001);
    end
end
end

% check invalid values, NaN, Inf, -Inf, []
function test_FSG_009(testCase)
for i = 1:numel(testCase.TestData.filenames) % go through files
    
    act = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i))));
    
    for j = 1:length(testCase.TestData.var_data)
        var_values = act.(testCase.TestData.var_data{j,1}); % get values of selected variable
        
        exp = false; % start ok
        
        if isnumeric(var_values) % skip strings etc.
            
            if any(isnan(var_values)) % NaN
                exp = true; % failed
            end
            if any(isinf(var_values)) % Inf, -Inf
                exp = true; % failed
            end
            if any(isempty(var_values)) % []
                exp = true; % failed
            end
            % duplicates are allowed
            % outliers are allowed
        end
        verifyEqual(testCase, false, exp, 'AbsTol', 0.001);
    end
end
end

% check matrix size based on other variables
function test_FSG_010(testCase)
import matlab.unittest.constraints.IsLessThanOrEqualTo
import matlab.unittest.constraints.IsGreaterThanOrEqualTo

for i = 1:numel(testCase.TestData.filenames) % go through files
    
    vars = load(string(strcat(testCase.TestData.dir_out,testCase.TestData.filenames(1,i))));
    
    n = sum(vars.num_activities); % get number of activities
    w = vars.mode;  % get actual mode
    r = vars.num_r_resources; % get number of renewable resources
    
    verifyEqual(testCase, size(vars.PDM,2), (n+w*r+2), 'AbsTol', 0.001); % check col size
    verifyEqual(testCase, size(vars.PDM,1), (n), 'AbsTol', 0.001); % check row size
    
    
    testCase.verifyThat(size(vars.constr,2),IsLessThanOrEqualTo((2+r+1+(1)))); % check constr size: [Ct=1,Cc=1,{Cq=1},{Cr=r},Cs=1]
    testCase.verifyThat(size(vars.constr,2),IsGreaterThanOrEqualTo((2+r+1))); % check constr size: [Ct=1,Cc=1,{Cq=1},{Cr=r},Cs=1]

end
end

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
