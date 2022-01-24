% RESOURCE INDICATORS without scheduling and for an earliest start schedule 

% Prerequisites: (invoked in this function) 
% tptfast.m [TPT,EST,EFT,LST,LFT]=tptfast(DSM,T)
% resfunc.m [BP,RESFUNC]=resfunc(DSM,SST,T,R)
%
% Example:
% >> [RF,RU,PCTR,DMND,XDMND,RS,RC,UTIL,XUTIL,TCON,XCON,OFACT,TOTOFACT,UFACT,TOTUFACT]=indicators_resource([1,1,24,2400,1,1;0,1,8,800,0,1],2,[-1,-1,1,1,3,1,1,9,1],20)

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



function [RF,RU,PCTR,DMND,XDMND,RS,RC,UTIL,XUTIL,TCON,XCON,OFACT,TOTOFACT,UFACT,TOTUFACT]=indicators_resource(PSM,num_r_resources,constr,TPT_max)
n=size(PSM,1);
%w=1; % number of modes (w) is 1 (one) after the PDM has been decided, the PSM has been defined
r=num_r_resources; % number of renewable resources 
LD=PSM(:,1:n);
RD=PSM(:,n+2+1:n+2+r); %resource domain, n-by-r matrix
TD=PSM(:,n+1); %n-by-1 vector
[TPT,SST]=tptfast(LD,TD); % total project time TPT (duration) - the length of the critical path - and scheduled sarting times SST using an earliest start schedule regardless the resource constraints

% evaluate optional input parameter TPT_max, as in case of multiproject, we need global TPT information to calculate separate projects' indicator UTIL
if ~exist('TPT_max', 'var')
    TPT_max = TPT; % TPT is calculated here
end

    
[BP,RESFUNC]=resfunc(LD,SST,TD,RD); % resource loading function


%% INDICATORS without scheduling

PCTR=sum(RD>0,1)/n; % percent of activities that require the given resource type
RF=double(sum(PCTR,2)/r); % resource factor
RU=sum(RD>0,2); % resource use 
%RU=mean(RU); % average version of Demeulemeester, 2003
ak=constr(3:3+r-1); % 1-by-r vector, the constraints are considered as constant during the project, the first 2 constraint are omitted: the first constraint belongs to time, the second belongs to cost
DMND=sum(PSM(:,n+2+1:n+2+r),1)./sum(PSM(:,n+2+1:n+2+r)>0,1); % average demand from each renewable resource
XDMND=mean(DMND); % average version of Patterson, 1976
RC=DMND./ak; % resource constrainedness for each resource type
%RC=mean(RC); % average version of Patterson, 1976
rkmin=max(PSM(:,n+2+1:n+2+r),[],1); % 1-by-r vector, maximum individual resource demand for each resource type

  
%% INDICATORS for an earliest start SCHEDULE

UTIL=(TD'*RD)./(TPT_max*ak);
XUTIL=mean(UTIL); % average version of Patterson, 1976 (XUTIL)
rkmax=max(RESFUNC,[],1); % maximum resource demand for each resource type 
RS=(ak-rkmin)./(rkmax-rkmin); % resource strength
%RS=mean(RS); % average version of Kolisch, 1995
TCON=UTIL./sum(RD>0,1); % Resource Constrainedness Over Time
XCON=mean(TCON); % average version Patterson 1976 (XCON)
ExResReq=0; % Excess Resource Requirement
UU=0; % Underutilization
 for i=2:numel(BP)
     ExResReq=ExResReq+max(0,(RESFUNC(i)-ak))*(BP(i)-BP(i-1));
     UU=UU+max(0,(ak-RESFUNC(i))*(BP(i)-BP(i-1)));
 end
OFACT=ExResReq./(TD'*RD); % Obstruction factor of resources
TOTOFACT=sum(OFACT); % Total obstruction factor by Davis
UFACT=UU./(TD'*RD); % Underutilization factor
TOTUFACT=sum(UFACT); % Total Underutilization factor
end
