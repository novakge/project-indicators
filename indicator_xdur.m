% indicator Average Activity Duration XDUR - sum of durations divided by number of nodes

% example input: >> load('test_data/j301_10_NTP.mat', 'PDM', 'num_activities', 'num_modes', 'sim_type')
% example usage: >> xdur = indicator_xdur(PDM, num_activities, num_modes, sim_type)
% example output: >> xdur = 2.7333


function xdur = indicator_xdur(PDM, num_activities, num_modes, sim_type)

% set offset for TD in PDM depending on simulation type e.g. CTP,DTP,NTP
switch sim_type

    case 1 % NTP
        
        TD = PDM(:,num_activities + num_modes); % in case of NTP, duration is a n x 1 column vector next to DSM
        TD = TD; % in case of single mode, do nothing

    case 2 % CTP
        
        TD = PDM(:,num_activities+1:num_activities + num_modes); % in case of CTP, duration is a n x 2 column vector next to DSM with lower/upper range
        TD = mean(TD,2); % TODO: temporarily calculate mean for each row in case of multiple modes
        
    case 3 % DTP
        
        TD = PDM(:,num_activities+1:num_activities + num_modes); % in case of DTP, duration is a n x w column vector next to DSM
        TD = mean(TD,2); % TODO: temporarily calculate mean for each row in case of multiple modes
        
    otherwise
        
        fprintf('Not a valid TP: only 1=NTP, 2=CTP, 3=DTP,  simulation types are supported!\n');

end

xdur = mean(TD); % return calculated value (sum of durations / number of activities)