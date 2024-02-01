% number of linear extensions (LE) indicator (network logic / topology)
% equation details: https://en.wikipedia.org/wiki/Linear_extension
% input: DSM (or PDM) matrix
% example #1: >> LE = indicator_le(PDM)
% example #2: >> LE = indicator_le(DSM)
% example #3 input:  LE = indicator_le([1,0,1,0;0,1,1,1;0,0,1,0;0,0,0,1])
% example #3 output: LE = 0.5064
% Reference(s): Van Eynde et al. (2023). "On the summary measures for the resource-constrained project scheduling problem."

function LE = indicator_le(PDM)

% pre-process DSM
dsm = PDM(:,1:size(PDM,1),1); % extract DSM from PDM
dsm(diag(dsm)==0,:) = 0; % remove all successors of empty tasks
dsm(:,diag(dsm)==0) = 0; % remove all predecessors of empty tasks
dsm = dsm(diag(dsm)==1,diag(dsm)==1); % remove empty tasks and their dependencies
dsm = triu(dsm,1); % consider upper triangle with dependencies only (=adjacency matrix)

n = size(dsm,1); % number of rows gives total number of activities of the (multi)project

if n>19
    warning("problem size ~20 might take a long time to process! (#P hard)");
end

le = 0; % initialize linear extension count
in_degrees = sum(dsm, 1); % calculate number of predecessors for all tasks
visited = zeros(1,n); % for visited flags
count = 0;

% recursive function to count linear extensions
    function linearextensions(count)
        
        for vertex=1:n % check all tasks
            
            if in_degrees(vertex) == 0 && ~visited(vertex)
                
                % if vertex has zero predecessors and not visited yet
                task_ids = find(dsm(vertex,:)); % find successor tasks
                in_degrees(task_ids) = in_degrees(task_ids) - 1; % current task and dependencies are removed, update successors in-degree
                visited(vertex) = 1; % mark as visited
                
                count = count + 1; % processed
                
                % recurse
                linearextensions(count);
                
                % backtrack
                in_degrees(task_ids) = in_degrees(task_ids) + 1; % restore in_degree
                visited(vertex) = 0; % remove visited flag
                count = count - 1;
                
            end
        end
        
        if count==n
            le = le + 1; % a linear extension
        end
    end

% start the recursion
linearextensions(count);

if n == 0 % no tasks, no linear extensions
    LE = 0;
else % if there is at least 1 task
    if sum(triu(dsm,1),'all') == 0 % no dependencies, linear extension is n factorial
        le = factorial(n);
    end
    
    if le == 1 % if there is only 1 task, avoid division with 0
        LE = le/factorial(n); % avoid log10(1)=0 -> 0/0 = NaN
    else % if more than 1 task
        LE = max(0, log10(le) / log10(factorial(n))); % limit to [0,1] range (avoid possible -Inf)
    end
end

end