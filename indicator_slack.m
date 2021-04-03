% implements various slack related indicators

% example input: >> load('test_data/j301_10_NTP.mat', 'PDM', 'num_modes')
% example usage: >> [NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK] = indicator_slack(PDM, num_modes)
% example output: >> NSLACK = 8 ... XFREESLK = 2.67

function [NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK] = indicator_slack(PDM, num_modes)

% remove any zero activity, the corresponding dependencies and demands
DSM = PDM(:,1:size(PDM,1)); % get DSM including zero activities from PDM, number of activities = number of rows in PDM
PDM(diag(DSM)==0,:)=[]; % remove zero activities and their dependencies from PDM
PDM(:,diag(DSM)==0)=[]; % remove all zero activities, its dependencies and demands from PDM
DSM = PDM(:,1:size(PDM,1)); % get DSM without zero activities from PDM after cleanup is done

% get number of non-zero activities
num_activities = size(DSM,1);

DSM = triu(DSM); % consider only upper triangle matrix

% get TD for all modes
TD = PDM(:,num_activities+1:num_activities + num_modes); % duration is a n x w column vector next to DSM

% pre-allocate all matrices for speed
TPT = zeros(1,num_modes);
EST = zeros(num_activities,num_modes);
EFT = zeros(num_activities,num_modes);
LST = zeros(num_activities,num_modes);
LFT = zeros(num_activities,num_modes);
TF = zeros(num_activities,num_modes);
NSLACK = zeros(1,num_modes);
PCTSLACK = zeros(1,num_modes);
XSLACK = zeros(1,num_modes);
MAXCPL = zeros(1,num_modes);
TOTSLACK_R = zeros(1,num_modes);
XSLACK_R = zeros(1,num_modes);
FF = zeros(num_activities,num_modes);
NFREESLK = zeros(1,num_modes);
PCTFREESLK = zeros(1,num_modes);
XFREESLK = zeros(1,num_modes);

% pre-calculate all indicators for all modes
for j=1:num_modes
    
    TD_temp = TD(:,j); % select the actual mode of duration from column 'w'
    [TPT(:,j),EST(:,j),EFT(:,j),LST(:,j),LFT(:,j)]=tptfast(double(DSM),double(TD_temp)); % store the results for each mode
    TF(:,j) = LST(:,j) - EST(:,j); % calculate total float (slack) for each activity (Late Start Date - Late Finish Date)
    NSLACK(1,j) = sum(TF(:,j)>0); % return calculated value (number of activities with positive total float)
    PCTSLACK(1,j) = NSLACK(1,j) / double(num_activities); % percent of activities with positive total float (slack)
    XSLACK(1,j) = mean(TF(:,j)); % average total float (slack)
    MAXCPL(1,j) = TPT(1,j); % or max(EFT)
    TOTSLACK_R(1,j) = sum(TF(:,j)>0) / MAXCPL(1,j); % total float (slack) ratio
    XSLACK_R(1,j) = XSLACK(1,j) / MAXCPL(1,j); % average float (slack) ratio
    FF(:,j) = ff(DSM,EST(:,j),EFT(:,j)); % calculate free float for all tasks and all modes
    NFREESLK(1,j) = sum(FF(:,j)>0); % number of activities with positive free float
    PCTFREESLK(1,j) = NFREESLK(1,j) / double(num_activities); % percent of activities with positive free float (slack)
    XFREESLK(1,j) = mean(FF(:,j)); % average free float per activity (slack)
    
end

end