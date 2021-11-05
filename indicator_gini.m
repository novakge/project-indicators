% Gini coefficient shows how total work content (resource demand * duration) are distributed among tasks
% input 1: PDM with renewable resources and single mode
% input 2: number of renewable resources
% example 1: >> gini = indicator_gini(PDM , 4)

function gini = indicator_gini(PDM, num_r_resources)

% TODO handle flexibility in multiproject case
% remove zero tasks, their dependencies and demands
% DSM = PDM(:,1:size(PDM,1)); % get DSM including zero activities from PDM, number of activities = number of rows in PDM
% PDM(diag(DSM)==0,:)=[]; % remove zero activities and their dependencies from PDM
% PDM(:,diag(DSM)==0)=[]; % remove all zero activities, its dependencies and demands from PDM
% DSM = PDM(:,1:size(PDM,1)); % get DSM without zero activities from PDM after cleanup is done

% check if input is a multiproject (cell)
if iscell(PDM)
    num_projects = size(PDM,1);
%     for i=1:num_projects
%         num_activities(1,i) = size(PDM{i},1);
%     end
    num_activities = size(PDM{1},1);
else
    num_projects = 1;
    num_activities = size(PDM,1);
end

n = num_activities; % copy
% TODO handle variable task sizes
r = num_r_resources; % copy
% TODO handle variable resource sizes
all_values = [];

for prj=1:num_projects % for all projects
    
    if iscell(PDM) % is a multiproject cell
        PDM_temp = cell2mat(PDM(prj)); % copy actual project
    else
        PDM_temp = PDM;
    end
    
    RD = PDM_temp(:,n+2+1:n+2+r); % extract resource domain, a (n x r) matrix
    
    TD = PDM_temp(:,n+1); % extract time domain, a (n x 1) vector
    
    value = zeros(n,r); % pre-allocate / reset vector for RD*TD values
    
    for j=1:r % go through each resource type
        value(:,j) = RD(:,j) .* TD(:,1); % multiply resource demands with durations
    end
    
    value = sum(value,2); % sum up RD * TD for all resource types
    
    all_values = [all_values; value]; % put result to the end of the actual column vector
end

all_values = sort(all_values); % sort rows in ascending order
num_values = num_projects*num_activities; % calculate all elements
freq = (num_values:-1:1)'; % create "n+1-i" column vector in advance to simplify calculation

% equation details: https://en.wikipedia.org/wiki/Gini_coefficient
gini = num_values + 1 - 2*( sum(all_values .* freq) ./ sum(all_values,1) );
gini = gini/num_values;