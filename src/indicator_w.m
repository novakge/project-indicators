%% Width (W) indicator (network logic / topology)
% input: DSM (or PDM) matrix
% example #1: >> W = indicator_w(PDM)
% example #2: >> W = indicator_w(DSM)
% example #3 input:  W = indicator_w([1,0,1,0;0,1,1,1;0,0,1,0;0,0,0,1])
% example #3 output: W = 0.3333

% Reference(s):
% - Van Eynde et al. (2023). "On the summary measures for the resource-constrained project scheduling problem."
% - Dilworth (1950). "The structure of relatively complemented lattices."

function W = indicator_w(PDM)

%% pre-process PDM (DSM)
dsm = PDM(:,1:size(PDM,1),1); % extract DSM from PDM
dsm(diag(dsm)==0,:) = 0; % remove all successors of empty tasks
dsm(:,diag(dsm)==0) = 0; % remove all predecessors of empty tasks
dsm = dsm(diag(dsm)==1,diag(dsm)==1); % remove empty tasks and their dependencies
dsm = triu(dsm,1); % consider upper triangle with dependencies only (=adjacency matrix)

%% set up constants
n = size(dsm,1); % number of rows gives total number of activities of the (multi)project
chain_lengths = zeros(1, n); % initialize chain lengths array

%% iterate through vertices in the topological order
for vertex = 1:n

    % find successor(s) of the current task
    successor_ids = find(dsm(vertex, :));

    % update chain length for the current vertex
    for j = 1:numel(successor_ids)
        successor = successor_ids(j);
        chain_lengths(successor) = max(chain_lengths(successor), chain_lengths(vertex)) + 1;
    end
end

%% caulcate Dilworth's width
W = max(chain_lengths); % width is the maximum chain length
W = max(0, (W-1) / (n-1)); % calculate equation

%% handle special cases
if n > 1 % more tasks (check zero dependencies)
    if sum(dsm,'all') == 0 % no dependencies, width equals to number of tasks
        W = 1;
    end
end

if n == 0 % no tasks (no dependencies)
    W = 0;
end

if n == 1 % one task (no dependencies)
    W = 1;
end


end
