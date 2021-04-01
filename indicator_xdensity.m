% indicator Average Activity Density (Patterson) = sum of the maximal number of predecessors minus successors of each activity divided by the number of activities 
function xdensity = indicator_xdensity(DSM)

% todo call standard DSM preprocessor here
num_activities = sum(diag(DSM)>0); % number of activities (non-zero values in the diagonal)

upper_triangle = triu(DSM,1); % consider only upper triangle without activities in diagonal

Pi = sum(upper_triangle,1); % get number of predecessors for each column

Si = sum(upper_triangle,2); % get number of successors for each row


xdensity = (sum(max(0,Pi-Si'),2))/num_activities; % t-density / n