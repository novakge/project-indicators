% indicator Average Activity Density (Patterson) = sum of the maximal number of predecessors minus successors of each activity divided by the number of activities 
function xdensity = indicator_xdensity(DSM)

num_activities = sum(diag(DSM)>0); % number of non-zero activities (diagonal)

upper_triangle = triu(DSM,1); % consider only upper triangle (non-zero precedence relations)

Pi = sum(upper_triangle~=0,1); % get number of non-zero predecessors for each column

Si = sum(upper_triangle~=0,2); % get number of non-zero successors for each row


xdensity = (sum(max(0,Pi-Si'),2))/num_activities; % t-density / n
