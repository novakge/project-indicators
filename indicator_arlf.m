% resource related indicator: ARLF (Average Resource Load Factor)
% input 1: PSM (Project Scheduling Matrix) for the renewable resources with (already decided), single mode (out of all available modes)
% input 2: number of renewable resources
% example 1: >> arlf = indicator_arlf(PSM,2)
% example 2: >> arlf = indicator_arlf(PSM,num_r_resources)

% ARLF_l
% description: value < 0 means resources are distributed front loaded, if > 0 resources are back loaded
% r_ilk = demand of resource type k for task_i in project_l
% K_il = number of resource types for task_i in project_l
% N_l = number of tasks in project_l
% original equation: 1 / CP_l * sum(t=1...CP_l) sum(k=1...K_il) sum(i=1...N_l) [ Z_ilt * X_ilt * (r_ilk / K_il) ]
% Z_ilt =  { -1 if t <= CP_l/2
%          { +1 if t >  CP_l/2
% X_ilt =  { 1 if task_i of project_l is active at time t
%          { 0 if task_i of project_l is inactive at time t

% TODO NARLF
% Normalized Average Resource Loading Factor (NARLF)
% Similarly, but divide (num_projects * TPT_max) for all projects instead of only TPT_l
% This formulation normalizes the ARLF over the problem's critical path duration rather than over each individual project's CP duration

% TODO VA-NARLF
% Variance of Normalized Average Resource Loading Factor (NARLF)


function arlf = indicator_arlf(PSM, num_r_resources)

% remove zero tasks, their dependencies and demands
DSM = PSM(:,1:size(PSM,1)); % get DSM including zero activities from PDM, number of activities = number of rows in PDM
PSM(diag(DSM)==0,:)=[]; % remove zero activities and their dependencies from PDM
PSM(:,diag(DSM)==0)=[]; % remove all zero activities, its dependencies and demands from PDM
DSM = PSM(:,1:size(PSM,1)); % get DSM without zero activities from PDM after cleanup is done

% number of modes = w is 1 (one) after the PDM has been decided so the PSM has been defined
% w = 1;

% get number of (non-zero) activities
n = size(PSM,1);

% get number of renewable resources
r = num_r_resources;

RD=PSM(:,n+2+1:n+2+r); % resource domain, a (n x r) matrix
TD=PSM(:,n+1); % time domain, a (n x 1) vector

% calculate total project time TPT (duration) as the length of the critical path (CP) and EST as earliest start schedule, called time-only analysis)
[TPT,EST]=tptfast(DSM,TD);

resource_profile = zeros(n,TPT); % pre-allocate a row vector for resource profile(s), for all tasks

% build complete resource profile (not accurate enough to simply check the EST of a task)
for k=1:num_r_resources % for all resources
    for i=1:n % for all tasks
        for t=EST(i)+1:EST(i)+TD(i) % avoid zero indexing e.g. if EST=0; TD=0 is skipped
            if (t <= TPT/2) % t in first half, consider as negative. note: some authors calculate differently, Kurtulus (1985) with TPT/2, Browning (2010) with TPT/2+1
                resource_profile(i,t) = resource_profile(i,t) + RD(i,k) * (-1); % substract resource demand(s) of task_i;
            else % t in second half, consider as positive
                resource_profile(i,t) = resource_profile(i,t) + RD(i,k); % add resource demand(s) of task_i;
            end
        end
    end
end

% hint: when no debug needed (detailed resource function table), "resource_profile = zeros(1,TPT)" and in the loop, "resource_profile(t)" can be used for an aggregate row vector of resource profiles
% resource_profile

arlf = sum(resource_profile,'all') / TPT * double(r);

% check for NaN, Inf aftwerards and notify user
if ( isinf(arlf) || isnan(arlf) )
   warning('Warning: Inf or NaN value detected for indicator! (zero TPT?)\n');
end