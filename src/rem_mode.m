% rem_mode is a helper function to remove a mode from TD,CD,RD
function PDM = rem_mode(pdm, task, mode_to_remove, num_r_resources, num_modes)

% input #1 PDM matrix and its submatrices
% input #2 task to remove from
% input #3 execution mode to remove
% input #4 number of resources
% input #5 number of execution modes
% output: PDM, a matrix without the specified mode for the given task, mode orders are not respected (left-shifted)

% example #1
% PDM = [1,0,0,0, 11,12,13,14, 15,16,17,18,    111,122,131,141,    211,221,231,241,    311,321,331,341;
%        0,1,0,0, 21,22,23,24, 25,26,27,28,    112,122,132,142,    212,222,232,242,    312,322,332,342;
%        0,0,1,0, 31,32,33,34, 35,36,37,38,    113,123,133,143,    213,223,233,243,    313,323,333,343;
%        0,0,0,1, 41,42,43,44, 45,46,47,48,    114,124,134,144,    214,224,234,244,    314,324,334,344];

% >> result = rem_mode(PDM, 1, 2, 3, 4); % remove mode #2 of task #1 from all 3 renewable resources and their 4 modes

% << result = [1,0,0,0, 11,13,14,0,  15,17,18,0,     111,131,141,0,    211,231,241,0,        311,331,341,0;
%              0,1,0,0, 21,22,23,24, 25,26,27,28,    112,122,132,142,    212,222,232,242,    312,322,332,342;
%              0,0,1,0, 31,32,33,34, 35,36,37,38,    113,123,133,143,    213,223,233,243,    313,323,333,343;
%              0,0,0,1, 41,42,43,44, 45,46,47,48,    114,124,134,144,    214,224,234,244,    314,324,334,344];

% prepare local vars
n = size(pdm,1);
r = num_r_resources;
w = num_modes;

% extract submatrices
CD = pdm(:,n+w+1:n+2*w);
TD = pdm(:,n+1:n+w);
RD = pdm(:,n+2*w+1:n+2*w+w*r);

% remove mode from submatrices
TD(task, mode_to_remove:end) = [TD(task, mode_to_remove+1:end) 0]; % remove and left-shift, fill with 0
CD(task, mode_to_remove:end) = [CD(task, mode_to_remove+1:end) 0]; % similarly

for res=1:r
    RD(task, res*w-w+mode_to_remove:res*w-w+w) = [RD(task, res*w-w+mode_to_remove+1:res*w-w+w) 0];
end

% (re)construct matrix
PDM = [pdm(:,1:n) TD CD RD];
