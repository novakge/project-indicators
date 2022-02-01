% Resource related indicator: (N)ARLF (Normalised) Average Resource Load Factor
% input #1: PSM superset (Project Scheduling Matrix) for the renewable resources with (already decided), single mode (out of all available modes)
% input #2: number of renewable resources
% input #3: number of activities (gives structure of PDM superset and number of projects)
% input #4: release dates, the time before the projects cannot start
% example #1: >> [arlf,narlf,narlf_] = indicator_narlf(PSM, num_activities, num_r_resources, {release_dates})
% example #2: >> [arlf,narlf,narlf_] = indicator_narlf(PSM, 4, [3,5,4], [0,0,0])
% example #3: >> [arlf,narlf,narlf_] = indicator_narlf(PSM, 4, [3,5,4])

% ARLF
% description: value < 0 means resources are distributed front loaded, if > 0 resources are back loaded
% r_ilk = demand of resource type k for task_i in project_l
% K_il = number of resource types for task_i in project_l
% N_l = number of tasks in project_l
% original equation: 1 / CP_l * sum(t=1...CP_l) sum(k=1...K_il) sum(i=1...N_l) [ Z_ilt * X_ilt * (r_ilk / K_il) ]
% Z_ilt =  { -1 if t <= CP_l/2
%          { +1 if t >  CP_l/2
% X_ilt =  { 1 if task_i of project_l is active at time t
%          { 0 if task_i of project_l is inactive at time t
% the ARLF of the multiproject/portfolio is obtained by averaging over all projects, i.e. divide by number of projects

% NARLF by Browning & Yassine (2010b).
% Improved version of ARLF, where critical paths of the individual projects are considered (CP_max) to decide if the resources are distributed in the first or in the second half of the projects.
% Result is normalised over the CP of the multiproject/portfolio.

% NARLF' by Van Eynde & Vanhoucke (2020) is an improved version
% Similar to NARLF but considers the first or second half of the whole critical path duration instead of the individual projects critical path duration.

% Remark: flexible activities must be handled before calling this indicator

function [arlf,narlf,narlf_] = indicator_narlf(PSM, num_activities, num_r_resources, release_dates)

% check (multi)project size based on num_activities
num_projects = numel(num_activities);

% get total number of activities
n = size(PSM,1);

% get number of renewable resources
r = num_r_resources; % TODO: handle variable resource sizes

% check if release_dates was provided as argument, if not, initialize with zeros for all projects
if ~exist('release_dates', 'var')
    release_dates = zeros(1,num_projects);
end
    
% pre-calculate start-end offset of each project based on number of activities
prj_starts = cumsum([1,num_activities(1:end-1)]); % starting with 1 for the first project, ignoring last entry
prj_ends = cumsum(num_activities(1:end));

% get single DSMs from the PSM superset
DSM_all = {};
for j = 1:num_projects
    DSM_all{j} = PSM(prj_starts(j):prj_ends(j),prj_starts(j):prj_ends(j)); % get single DSMs for all project
end

% get single RDs and TDs from the PSM superset
RD_all = {};
TD_all = {};
for j = 1:num_projects
    RD_all{j} = PSM(prj_starts(j):prj_ends(j),n+2+1:n+2+r); % get single (n x r) resource domain matrices for all projects
    TD_all{j} = PSM(prj_starts(j):prj_ends(j),n+1); % get single (n x 1) time domain matrices for all projects
end

% get DSM superset from PSM/PDM superset
DSM_set = PSM(:,1:n); % get superset (n x n) design structure matrices
TD_set  = PSM(:,n+1); % get superset (n x 1) time domain matrices
RD_set  = PSM(:,n+2+1:n+2+r); % get superset (n x 1) resource domain matrices

% calculate TPT (duration) as the length of the critical path (CP) and EST as earliest start schedule (time-only analysis)
TPT_set = [];
EST_set = [];

% calculate TPT for each project for the old (N)ARLF version and for non-zero release dates
TPT_all = {};
for j = 1:num_projects % for each project
    [TPT_all{j},EST_all{j}] = tptfast(DSM_all{j},TD_all{j});
    EST2{j} = EST_all{j} + release_dates(j); % consider release date of projects
    TPT_all{j} = TPT_all{j} + release_dates(j);
end

% create multiproject TPT and EST from individual projects
EST_set = cat(1,EST_all{:});
EST2_set = cat(1,EST2{:});
[TPT_set,~,~] = tptsst(DSM_set,TD_set,EST_set);


% ARLF original version
arlf_all = {}; % pre-allocate storage for ARLF values
for j=1:num_projects % for each project
    
    res_profile = zeros(1,TPT_all{j}); % initialize row vector for resource profile(s) for the actual project
    
    for k=1:num_r_resources % for all resources
        
        for i=1:num_activities(j) % for all tasks
            
            for t=EST_all{j}(i)+1:EST_all{j}(i)+TD_all{j}(i) % non-zero indexing e.g. if EST=0; TD=0 is skipped
                
                % ARLF original version
                
                if (t <= (release_dates(j) + TPT_all{j}/2)) % t is in first half, consider as negative
                    % remark: +1 for non-zero release dates not used here
                    % remark: rounding up TPT_j/2 is not used here as in Van Eynde (2020)
                    res_profile(t) = res_profile(t) + RD_all{j}(i,k) * (-1); % subtract resource demand(s) of task_i;
                else % t is in second half, consider as positive
                    res_profile(t) = res_profile(t) + RD_all{j}(i,k); % add resource demand(s) of task_i;
                end
            end 
        end
    end

    arlf_all{j} = sum(res_profile,'all') / double(r) / TPT_all{j}; % sum up resource profile for current project
    
end

% NARLF original version
resource_profile = zeros(1,TPT_set); % pre-allocate a row vector for resource profile(s), for all tasks
for j=1:num_projects % for each project
    for k=1:num_r_resources % for all resources
        for i=1:num_activities(j) % for all tasks
            for t=EST_all{j}(i)+1:EST_all{j}(i)+TD_all{j}(i) % non-zero indexing e.g. if EST=0; TD=0 is skipped
                
                % NARLF original version
                
                if (t <= (release_dates(j) + ceil(TPT_all{j}/2) + 1)) % t is in first half, consider as negative; +1 for non-zero release dates
                    % remark: rounding up TPT/2 is not defined in the original equation (Browning et al., 2010), but used here to align with existing results in literature (Van Eynde, 2020). 
                    resource_profile(t) = resource_profile(t) + RD_all{j}(i,k) * (-1); % subtract resource demand(s) of task_i;
                else % t is in second half, consider as positive
                    resource_profile(t) = resource_profile(t) + RD_all{j}(i,k); % add resource demand(s) of task_i;
                end
            end
        end
    end
end


% NARLF' improved version (here as NARLF_)
% build complete resource profile as checking EST is not accurate enough
resource_profile_ = zeros(1,TPT_set); % pre-allocate a row vector for resource profile(s), for all tasks
for k=1:num_r_resources % for all resources
    for i=1:n % for all tasks
        for t=EST_set(i)+1:EST_set(i)+TD_set(i) % non-zero indexing e.g. if EST=0; TD=0 is skipped

            if (t <= min(release_dates) + 1 + ceil(TPT_set/2)) % t is in first half, consider as negative; +1 for non-zero release dates
                resource_profile_(t) = resource_profile_(t) + RD_set(i,k) * (-1); % subtract resource demand(s) of task_i;
            else % t is in second half, consider as positive
                resource_profile_(t) = resource_profile_(t) + RD_set(i,k); % add resource demand(s) of task_i;
            end
            
        end
    end
end

% hint: to debug the detailed resource function table, change "resource_profile = zeros(n,TPT)" and in the loop, use "resource_profile(i,t)" instead of the aggregated row vector of resource profiles

% ARLF
arlf = sum(cell2mat(arlf_all),'all') / (num_projects);

% original NARLF
narlf = sum(resource_profile,'all') / (num_projects * max(cell2mat(TPT_all)) * double(r));

% improved NARLF'
narlf_ = sum(resource_profile_,'all') / (num_projects * TPT_set * double(r));

% check for NaN, Inf aftwerards and notify user
if ( isinf(narlf) || isnan(narlf) )
   warning('Warning: Inf or NaN value detected for indicator! (zero TPT?)\n');
end