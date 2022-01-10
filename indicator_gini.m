% Gini coefficient shows how total work content (resource demand * duration) are distributed among tasks
% input 1: PDM with renewable resources and a selected single mode
% input 2: number of renewable resources
% example: >> gini = indicator_gini(PDM, num_r_resources)

function gini = indicator_gini(PDM, num_r_resources)

% TODO handle flexibility in multiproject case
% remove zero tasks, their dependencies and demands
% DSM = PDM(:,1:size(PDM,1)); % get DSM including zero activities from PDM, number of activities = number of rows in PDM
% PDM(diag(DSM)==0,:)=[]; % remove zero activities and their dependencies from PDM
% PDM(:,diag(DSM)==0)=[]; % remove all zero activities, its dependencies and demands from PDM
% DSM = PDM(:,1:size(PDM,1)); % get DSM without zero activities from PDM after cleanup is done

n = size(PDM,1); % number of rows gives total number of activities of the (multi)project
r = num_r_resources; % rename only

% TODO handle case when number of resources are varied amongst projects

RD = PDM(:,n+2+1:n+2+r); % extract resource domain, a (n x r) matrix

TD = PDM(:,n+1); % extract time domain, a (n x 1) vector

work_content = zeros(n,r); % pre-allocate / reset vector for RD*TD values

for j=1:r % go through each resource type
    work_content(:,j) = RD(:,j) .* TD(:,1); % multiply resource demands with durations
end

work_content = sum(work_content,2); % sum up RD * TD for all resource types
work_content = sort(work_content); % sort rows in ascending order

freq = (n:-1:1)'; % create "n+1-i" column vector in advance to simplify calculation

% equation details: https://en.wikipedia.org/wiki/Gini_coefficient
gini = n + 1 - 2 * ( sum(work_content .* freq) ./ sum(work_content,1) );
gini = gini/n;