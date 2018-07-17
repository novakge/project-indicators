function os = indicator_os(DSM)

DSM = triu(DSM); % consider only upper triangle matrix

num_activities = size(DSM,1); % number of activities (n)

T = DSM ^ (num_activities-1); % compute transitive closure with matrix multiplication

num_arcs_all = numel(T(T>0)) - num_activities; % number of arcs + transitive arcs

num_arcs_possible = (num_activities * (num_activities - 1)) / 2; % theoretical maximum number of arcs (n * ( n-1 )) / 2

os = num_arcs_all / num_arcs_possible; % OS =  number of precedence relations (including the transitive ones) divided by the theoretical maximum number of precedence relations