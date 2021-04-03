% implements various duration related indicators
% - Average Activity Duration XDUR - sum of durations divided by number of nodes
% - Variance in Activity Duration VA-DUR - sum of differences between durations and average activity durations divided by number of nodes - 1

% example input: >> load('test_data/j301_10_NTP.mat', 'PDM', 'num_modes')
% example usage: >> [XDUR,VADUR] = indicator_duration(PDM, num_modes)
% example output: >> XDUR = 2.7333; VADUR = 2.1333
function [XDUR,VADUR] = indicator_duration(PDM, num_modes)

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

end





