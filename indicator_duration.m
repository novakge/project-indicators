% implements various duration related indicators
% - Average Activity Duration XDUR - sum of durations divided by number of nodes
% - Variance in Activity Duration VA-DUR - sum of differences between durations and average activity durations divided by number of nodes - 1

% example input: >> load('test_data/j301_10_NTP.mat', 'PDM', 'num_modes', 'sim_type')
% example usage: >> [XDUR,VADUR] = indicator_duration(PDM, num_modes, sim_type)
% example output: >> XDUR = 2.7333; VADUR = 2.1333
function [XDUR,VADUR] = indicator_duration(PDM, num_modes, sim_type)

% remove any zero activity, the corresponding dependencies and demands
DSM = PDM(:,1:size(PDM,1)); % get DSM including zero activities from PDM, number of activities = number of rows in PDM
PDM(diag(DSM)==0,:)=[]; % remove zero activities and their dependencies from PDM
PDM(:,diag(DSM)==0)=[]; % remove all zero activities, its dependencies and demands from PDM
DSM = PDM(:,1:size(PDM,1)); % get DSM without zero activities from PDM after cleanup is done

% get number of non-zero activities
num_activities = size(DSM,1);

% pre-allocate all matrices for speed
XDUR = zeros(1,num_modes);
VADUR = zeros(1,num_modes);

% get TD for all modes
TD = PDM(:,num_activities+1:num_activities + num_modes); % duration is a n x w column vector next to DSM

% pre-calculate all indicators for all modes
for j=1:num_modes
    XDUR(1,j) = mean(TD(:,j)); % calculate xdur value (sum of durations / number of activities)
    VADUR(1,j) = sum((TD(:,j) - XDUR(1,j)).^2) / (num_activities - 1); % return variance of duration
end

% set offset for TD in PDM depending on simulation type e.g. CTP,DTP,NTP
switch sim_type
    
    case 1 % NTP
        % in case of NTP, duration is a n x 1 column vector next to DSM
        % return with first mode's results
        XDUR = XDUR(:,1);
        VADUR = VADUR(:,1);
        
    case 2 % CTP
        % in case of CTP, duration is a n x 2 column vector next to DSM with lower/upper range
        % return with first and last mode's results
        XDUR = [XDUR(:,1),XDUR(:,num_modes)];
        VADUR = [VADUR(:,1),VADUR(:,num_modes)];
        
        
    case 3 % DTP
        % in case of DTP, duration is a n x w column vector next to DSM 
        % return with all modes' results (the default calculation)
        
        
    otherwise
        
        fprintf('Not a valid TP: only 1=NTP, 2=CTP, 3=DTP,  simulation types are supported!\n');
        
end





