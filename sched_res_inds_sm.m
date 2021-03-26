% RESOURCE INDICATORS for an earliest start SCHEDULE 

% Prerequisites: (invoked in this function) 
% tptfast.m     [TPT,EST,EFT,LST,LFT]=tptfast(DSM,T)
% resfunc.m [BP,RESFUNC]=resfunc(DSM,SST,T,R)
% ------------------------------------------------------------------------

% RS: resource strength for each resource type, i.e. 
% RS_{k}=\frac{a_{k}-r_{k}^{min}}{r_{k}^{max}-r_{k}^{min}}
% a_{k}: total availability of renewable resource type k
% r_{k}^{min} equals to max(r_{ik}) i=1,...,n (the highest individual resource demand); r_{k}^{max} denotes the peak
% demand of resource type k in the precedence preserving the earliest start
% schedule

% UTIL:utilisation of resources, measured on the [longest] critical path
% lenght [in case of multi project]
% % UTIL_{k}=\frac{\sum_{i=1}^{n}r_{ik}d_{i}}{a_{k} \cdot TPT}    %the single project
% version
% the multi project version:
% % UTIL_{k}=\frac{\sum_{i=1}^{n}r_{ijk}d_{ij}}{a_{k} \cdot TPT_{max}}



function [RS,UTIL,TCON,OFACT,UFACT]=sched_res_inds_sm(PSM,num_r_resources,constr)
n=size(PSM,1);
%w=1;    % number of modes (w) is 1 (one) after the PDM has been decided, the PSM has been defined
r=num_r_resources;  % number of renewable resources 
LD=PSM(:,1:n);
ak=constr(3:3+r-1);     %1-by-r vector, the constraints are considered as constant during the project
rkmin=max(PSM(:,n+2+1:n+2+r),[],1);   %1-by-r vector

T=PSM(:,n+1);    %n-by-1 vector
R=PSM(:,n+3:n+2+r);    %n-by-r matrix
[TPT,SST]=tptfast(LD,T);    % total project time TPT (duration) - the length of the critical path - and scheduled sarting times SST using an earliest start schedule regardless the resource constraints
[BP,RESFUNC]=resfunc(LD,SST,T,R);   % resource loading function
UTIL=(T'*R)./(TPT*ak);
rkmax=max(RESFUNC,[],1);    % maximum individual resource demand for each resource type
RS=(ak-rkmin)./(rkmax-rkmin);
TCON=UTIL./sum(R>0,1); % Resource Constrainedness Over Time
ExResReq=0; % Excess Resource Requirement
UU=0;   % Underutilization
 for i=2:numel(BP)
     ExResReq=ExResReq+max(0,(RESFUNC(i)-ak))*(BP(i)-BP(i-1));
     UU=UU+max(0,-(RESFUNC(i)-ak))*(BP(i)-BP(i-1));
 end
OFACT=ExResReq/(T'*R);   % Obstruction factor of resources
%TOTOFACT=sum(OFACT); % Total obstruction factor by Davis

UFACT=UU/(T'*R);    % Underutilization factor
end
