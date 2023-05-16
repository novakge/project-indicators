% indicator Total Activity Density (Johnson) = sum of the maximal number of predecessors minus successors of each activity
function tdensity = indicator_tdensity(DSM)

upper_triangle = triu(DSM,1); % consider only upper triangle (non-zero precedence relations)

Pi = sum(upper_triangle~=0,1); % get number of non-zero predecessors for each column

Si = sum(upper_triangle~=0,2); % get number of non-zero successors for each row


tdensity = sum(max(0,Pi-Si'),2);
