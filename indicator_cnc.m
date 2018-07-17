function cnc = indicator_cnc(DSM)

DSM = triu(DSM); % consider only upper triangle matrix

num_activities = size(DSM,1); % number of activities (n)
num_arcs = numel(DSM(DSM==1)) - num_activities; % number of arcs (A)

cnc = num_arcs / num_activities; % CNC = total number of precedence relations (arcs) over the total number of project activities (nodes)