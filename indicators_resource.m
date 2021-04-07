% RESOURCE INDICATORS without scheduling and for an earliest start schedule 

% Prerequisites: (invoked in this function) 
% tptfast.m     [TPT,EST,EFT,LST,LFT]=tptfast(DSM,T)
% resfunc.m [BP,RESFUNC]=resfunc(DSM,SST,T,R)
% ------------------------------------------------------------------------

%% RF: resource factor 
% ~: the density of the resource matrix, that is a DMM

%  $$ RF=\frac{1}{nK}\sum_{i=1}^{n}\sum_{k=1}^{K}\begin{cases} 1 & \textnormal{ if } r_{ik}>0 \\ 0 & \textnormal{ otherwise}  \end{cases}=\frac{1}{K}\sum_{k=1}^{K}{PCTR}_{k}
%  $$ r_{ik} $$ denotes the amount of resource type _k_ required by activity i

%% PCTR: percent of activities that require the given resuorce type
%  $$ PCTR_{k}=\frac{\sum_{i=1}^{n}\begin{cases} 1 & \textnormal{ if } r_{ik}>0 \\
%  0 & \textnormal{ otherwise}  \end{cases}}{n} $$

%% RU: resource use 
% ~: resource use for each activiy, i.e. the number of the used resource types

% RU varies between 0 and _r_ (the number of resource types)
%  $$ RU_{i}=\sum_{k=1}^{K}\left\{\begin{matrix} 1 &\textnormal{, if } r_{ik}>0 \\
%  0 &\textnormal{, otherwise} \end{matrix}\right. $$

%% RC: resource constrainedness for each resource type
% $$ RC_{k}=\frac{\overline{r}_{k}}{a_{k}} $$
%
% where
%
% $$ a_{k} $$: total availability of renewable resource type _k_
% $$ \overline{r}_{k}=\sum_{i=1}^{n}\frac{r_{ik}}{\sum_{i=1}^{n}
% \begin{cases} 1 & \text{ if } r_{ik}>0 \\ 0 & \text{ otherwise}
% \end{cases}} $$

%% RS: resource strength for each resource type, i.e. 
% RS_{k}=\frac{a_{k}-r_{k}^{min}}{r_{k}^{max}-r_{k}^{min}}
% a_{k}: total availability of renewable resource type k
% r_{k}^{min} equals to max(r_{ik}) i=1,...,n (the highest individual resource demand); r_{k}^{max} denotes the peak
% demand of resource type k in the precedence preserving the earliest start
% schedule

%% UTIL: utilisation of resources, measured on the [longest] critical path
% lenght [in case of multi project]
% % UTIL_{k}=\frac{\sum_{i=1}^{n}r_{ik}d_{i}}{a_{k} \cdot TPT}    %the single project
% version
% the multi project version:
% % UTIL_{k}=\frac{\sum_{i=1}^{n}r_{ijk}d_{ij}}{a_{k} \cdot TPT_{max}}



function [RF,RU,PCTR,DMND,RS,RC,UTIL,TCON,OFACT,UFACT]=indicators_resource(PSM,num_r_resources,constr)
n=size(PSM,1);
%w=1;    % number of modes (w) is 1 (one) after the PDM has been decided, the PSM has been defined
r=num_r_resources;  % number of renewable resources 
LD=PSM(:,1:n);
RD=PSM(:,n+2+1:n+2+r);    %resource domain, n-by-r matrix
T=PSM(:,n+1);    %n-by-1 vector
[TPT,SST]=tptfast(LD,T);    % total project time TPT (duration) - the length of the critical path - and scheduled sarting times SST using an earliest start schedule regardless the resource constraints
[BP,RESFUNC]=resfunc(LD,SST,T,RD);   % resource loading function


%% INDICATORS without scheduling

PCTR=sum(RD>0,1)/n; %percent of activities that require the given resuorce type
RF=double(sum(PCTR,2)/r);   %resource factor
RU=sum(RD>0,2); %resource use
ak=constr(3:3+r-1); %1-by-r vector, the constraints are considered as constant during the project, the first 2 constraint are omitted: the first constraint belongs to time, the second belongs to cost
DMND=sum(PSM(:,n+2+1:n+2+r),1)./sum(PSM(:,n+2+1:n+2+r)>0,1);    %average demand form each renewable resource
RC=DMND./ak; %resource constrainedness for each resource type
rkmin=max(PSM(:,n+2+1:n+2+r),[],1);   %1-by-r vector

  
%% INDICATORS for an earliest start SCHEDULE
UTIL=(T'*RD)./(TPT*ak);
rkmax=max(RESFUNC,[],1);    % maximum individual resource demand for each resource type
RS=(ak-rkmin)./(rkmax-rkmin);
TCON=UTIL./sum(RD>0,1); % Resource Constrainedness Over Time
ExResReq=0; % Excess Resource Requirement
UU=0;   % Underutilization
 for i=2:numel(BP)
     ExResReq=ExResReq+max(0,(RESFUNC(i)-ak))*(BP(i)-BP(i-1));
     UU=UU+max(0,-(RESFUNC(i)-ak))*(BP(i)-BP(i-1));
 end
OFACT=ExResReq/(T'*RD);   % Obstruction factor of resources
%TOTOFACT=sum(OFACT); % Total obstruction factor by Davis

UFACT=UU/(T'*RD);    % Underutilization factor
end
