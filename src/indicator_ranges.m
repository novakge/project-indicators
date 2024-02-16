% calculate indicators ranges
% short: provides lower- and upper bound for all completion modes of the selected indicator
% description: the function uses genetic algorithm to minimize (for lower bound) and maximize (for upper bound) the selected indicator values by varying completion modes (time, resource trade-offs) of each activity


% input #1: PDM (LD + TD/RD containing all modes)
% input #2: number of modes (w)
% input #3: number of renewable resources
% input #4: the selected indicator to get the ranges for

% output: [LB,UB,LBmodes,UBmodes], the lower and upper bound values for the selected indicator and their optimized mode selection vectors

% example #1: >> [LB,UB,LBmodes,UBmodes] = indicator_ranges(PDM,num_modes,num_r_resources,"narlf")
% example output #1: LB = 0.3220; UB = 1.57; ..., ...
% example #2: >> [LB,UB,LBmodes,UBmodes] = indicator_ranges(PDM,num_modes,num_r_resources,"gini")
% example output #2: LB = -4.4483; UB = 3.3805; [1,2,3,1,2,2,...,3,1], [3,2,2,4,3,2,1,...,3,4]

% intended use: call this function from a wrapper script handling project instances and result reporting

function [LB,UB,LBmodes,UBmodes] = indicator_ranges(PDM,num_modes,num_r_resources,constraints,indicator)

% setup constants for simulation
rng default; % for reproducibility

% simplify names of constants from instance
num_activities = size(PDM,1); % number of rows gives total number of activities of the (multi)project
n = double(num_activities); % rename to n
w = num_modes; % number of completion modes
r = num_r_resources; % number of renewable resources

% problem with integer constraints
intcon = 1:n;

    function x = indicator_wrapper(PDM,w,r,n,mode_selection,indicator)

        PDM_mode = pdm_mode(PDM,w,r,n,mode_selection);

        % call indicator to be optimized

        switch indicator
            % logical indicators are not affected by completion mode(s)
            % ...

            % time related indicators
            % ...
            case "xdur"
                [x,~] = indicator_duration(PDM_mode, 1); % w=1 as mode is already selected
            case "vadur"
                [~,x] = indicator_duration(PDM_mode, 1);
            case "nslack"
                [x,~,~,~,~,~,~,~,~] = indicator_slack(PDM_mode,1); % w=1 as mode is already selected
            case "pctslack"
                [~,x,~,~,~,~,~,~,~] = indicator_slack(PDM_mode,1);
            case "xslack"
                [~,~,x,~,~,~,~,~,~] = indicator_slack(PDM_mode,1);
            case "xslack_r"
                [~,~,~,x,~,~,~,~,~] = indicator_slack(PDM_mode,1);
            case "totslack_r"
                [~,~,~,~,x,~,~,~,~] = indicator_slack(PDM_mode,1);
            case "maxcpl"
                [~,~,~,~,~,x,~,~,~] = indicator_slack(PDM_mode,1);
            case "nfreeslk"
                [~,~,~,~,~,~,x,~,~] = indicator_slack(PDM_mode,1);
            case "pctfreeslk"
                [~,~,~,~,~,~,~,x,~] = indicator_slack(PDM_mode,1);
            case "xfreeslk"
                [~,~,~,~,~,~,~,~,x] = indicator_slack(PDM_mode,1);

                % resource related indicators
                % ...
            case "gini"
                x = indicator_gini(PDM_mode,r);
            case "narlf"
                [~,~,x] = indicator_narlf(PDM_mode,n,r,0); % arlf, narlf ignored, NARLF_ calcualted with relase dates = 0
            case "rf"
                [x,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "ru"
                [~,x,~,~,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "pctr"
                [~,~,x,~,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "dmnd"
                [~,~,~,x,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "xdmnd"
                [~,~,~,~,x,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
            case "rs"
                [~,~,~,~,~,x,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "a_rs"
                [~,~,~,~,~,RS,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = alphadist(RS); % TODO check 0 (NaN)
            case "rc"
                [~,~,~,~,~,~,x,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "util" % TODO handle Inf
                [~,~,~,~,~,~,~,x,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "xutil" % TODO handle Inf
                [~,~,~,~,~,~,~,~,x,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
            case "tcon" % TODO handle Inf
                [~,~,~,~,~,~,~,~,~,x,~,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "xcon" % TODO handle Inf
                [~,~,~,~,~,~,~,~,~,~,x,~,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "ofact"
                [~,~,~,~,~,~,~,~,~,~,~,x,~,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "totofact"
                [~,~,~,~,~,~,~,~,~,~,~,~,x,~,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "ufact"
                [~,~,~,~,~,~,~,~,~,~,~,~,~,x,~] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization
            case "totufact"
                [~,~,~,~,~,~,~,~,~,~,~,~,~,~,x] = indicators_resource(PDM_mode,r,constraints,0);
                x = mean(x,'all'); % use average for optimization

                % unknown indicator
            otherwise
                disp('Error: indicator not supported!');
                x = -1;
        end
    end

options = optimoptions('ga', 'Vectorized','off', 'Display','off', 'UseParallel',true, 'CrossoverFcn',{@crossoverscattered}, 'MutationFcn',{@mutationgaussian});
% options.CrossoverFraction = 0; % no crossover
% options.CrossoverFraction = 1; % no mutation

% init mode selection lower (first modes only) and upper bounds (last modes only)
lb = ones(num_activities,1); % all first mode selected
ub = num_modes*ones(num_activities,1); % all w-th mode selected

targetfcn_lb = @(x) indicator_wrapper(PDM,w,r,n,x,indicator); % minimize target function
targetfcn_ub = @(x) -indicator_wrapper(PDM,w,r,n,x,indicator); % maximize target function

LB = 0; % init lower bound
UB = 0; % init upper bound
LBtime = 0; % init lower bound timer
UBtime = 0; % init lower bound timer
LBmodes = 0; % init lower bound optimized mode selection
UBmodes = 0; % init upper bound optimized mode selection

% minimize target function to reach lower bound
tic
try
    LBmodes=ga(targetfcn_lb,n,[],[],[],[],lb,ub,[],intcon,options); % n decision variables as only one mode is selected for resources and time combinations
catch
    LB = -1; % not found or error
end
LB = indicator_wrapper(PDM,w,r,n,LBmodes,indicator); % recalculate with optimized mode selection
LBtime = toc; % for debug

% maximize target function to reach upper bound
tic
try
    UBmodes=ga(targetfcn_ub,n,[],[],[],[],lb,ub,[],intcon,options); % n decision variables as only one mode is selected for resources and time combinations
catch
    UB = -1; % not found or error
end
UB = indicator_wrapper(PDM,w,r,n,UBmodes,indicator); % recalculate with optimized mode selection
UBtime = toc; % for debug


end