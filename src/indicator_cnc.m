function cnc = indicator_cnc(DSM)

DSM = triu(DSM); % consider only upper triangle matrix

num_activities = sum(diag(DSM)>0); % number of non-zero activities (diagonal)
num_arcs = numel(DSM(DSM>0)) - num_activities; % number of non-zero arcs (A)

cnc = num_arcs / num_activities; % CNC = total number of precedence relations (arcs) over the total number of project activities (nodes)
