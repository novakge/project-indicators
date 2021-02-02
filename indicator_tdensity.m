% indicator Total Activity Density (Johnson) = sum of the maximal number of predecessors minus successors of each activity
function tdensity = indicator_tdensity(DSM)

% todo call standard DSM preprocessor here
num_activities = size(DSM,1); % number of activities (n)

upper_triangle = triu(DSM,1); % consider only upper triangle without activities in diagonal

Pi = sum(upper_triangle,1); % get number of predecessors for each column

Si = sum(upper_triangle,2); % get number of successors for each row


tdensity = sum(max(0,Pi-Si'),2);