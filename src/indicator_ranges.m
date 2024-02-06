% calculate indicators ranges
% short: provides lower- and upper bound for all completion modes of the selected indicator
% description: the function uses genetic algorithm to minimize (for lower bound) and maximize (for upper bound) the selected indicator values by varying completion modes (time, resource trade-offs) of each activity


% input #1: PDM (LD + TD/RD containing all modes)
% input #2: number of modes (w)
% input #3: number of renewable resources
% input #4: the selected indicator to get the ranges for

% output: [LB,UB], the lower and upper bound values for the selected indicator

% example #1: >> [LB,UB] = indicator_ranges(PDM,num_modes,num_r_resources,"narlf")
% example output #1: LB = 0.3220; UB = 1.57
% example #2: >> [LB,UB] = indicator_ranges(PDM,num_modes,num_r_resources,"gini")
% example output #2: LB = -4.4483; UB = 3.3805

% intended use: call this function from a wrapper script handling project instances and result reporting

function [LB,UB] = indicator_ranges(PDM,num_modes,num_r_resources,constr,indicator)

num_activities = size(PDM,1); % number of rows gives total number of activities of the (multi)project
n = double(num_activities); % rename to n
w = num_modes; % number of completion modes
r = num_r_resources; % number of renewable resources

    function PDM_mode = select_mode(PDM,w,r,n,mode_selection)
        % extract DSM
        DSM = PDM(:,1:n);
        
        % create dummy CD
        CD = zeros(n,1); % cost is not supported yet
        
        % extract TD for the w-th mode t1 t2 ... tw
        TD = zeros(n,1);
        for i = 1:n
            TD(i) = PDM(i,n+mode_selection(i)); % if it is not an integer, round the index
        end
        
        % extract RD for mode w: r1w1 r1w2 ... r2w1 r2w3 r2w3 ... rrww
        RD = zeros(n,r);
        for i=1:n
            for j=1:r
                RD(i,j) = PDM(i,n+2*w+j*mode_selection(i));
            end
        end
        % construct PDM for the selected mode
        PDM_mode = [DSM,TD,CD,RD]; % merge PDM with the specific modes selected
        
    end

    function x = indicator_wrapper(PDM,w,r,n,mode_selection,indicator)
        
        PDM_mode = select_mode(PDM,w,r,n,mode_selection);
        
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
                [x,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "ru"
                [~,x,~,~,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
                x = mean(x); % use average for optimization
            case "pctr"
                [~,~,x,~,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "dmnd"
                [~,~,~,x,~,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "xdmnd"
                [~,~,~,~,x,~,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "rs"
                [~,~,~,~,~,x,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "a_rs"
                [~,~,~,~,~,RS,~,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
                x = alphadist(RS); % TODO check 0 (NaN)
            case "rc"
                [~,~,~,~,~,~,x,~,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "util" % TODO handle Inf
                [~,~,~,~,~,~,~,x,~,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "xutil" % TODO handle Inf
                [~,~,~,~,~,~,~,~,x,~,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "tcon" % TODO handle Inf
                [~,~,~,~,~,~,~,~,~,x,~,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "xcon" % TODO handle Inf
                [~,~,~,~,~,~,~,~,~,~,x,~,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "ofact"
                [~,~,~,~,~,~,~,~,~,~,~,x,~,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "totofact"
                [~,~,~,~,~,~,~,~,~,~,~,~,x,~,~] = indicators_resource(PDM_mode,r,constr,0);
            case "ufact"
                [~,~,~,~,~,~,~,~,~,~,~,~,~,x,~] = indicators_resource(PDM_mode,r,constr,0);
            case "totufact"
                [~,~,~,~,~,~,~,~,~,~,~,~,~,~,x] = indicators_resource(PDM_mode,r,constr,0);
                               
            % unknown indicator
            otherwise
                disp('Error: indicator not supported!');
                x = -1;
        end
    end

options = optimoptions('ga','Vectorized','off', 'UseParallel',false, 'Display','off');

% set mode selection lower (first modes only) and upper bounds (last modes only)
lb = ones(num_activities,1); % all first mode selected
ub = num_modes*ones(num_activities,1); % all w-th mode selected

fcn_lb = @(x) indicator_wrapper(PDM,w,r,n,x,indicator); % minimize target function
fcn_ub = @(x) -indicator_wrapper(PDM,w,r,n,x,indicator); % maximize target function

intcon = 1:n;
% minimize target function to reach lower bound
opt_modes_lb=ga(fcn_lb,n,[],[],[],[],lb,ub,[],intcon,options); % n decision variables as only one mode is selected for resources and time combinations
LB = indicator_wrapper(PDM,w,r,n,opt_modes_lb,indicator); % recalculate with optimized mode selection

% maximize target function to reach upper bound
opt_modes_ub=ga(fcn_ub,n,[],[],[],[],lb,ub,[],intcon,options); % n decision variables as only one mode is selected for resources and time combinations
UB = indicator_wrapper(PDM,w,r,n,opt_modes_ub,indicator); % recalculate with optimized mode selection

end