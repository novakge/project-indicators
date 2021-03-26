%% RESOURCE INDICATORS

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

%% RS: resource strength 
% ~ for each resource type 

% $$ RS_{k}=\frac{a_{k}-r_{k}^{min}}{r_{k}^{max}-r_{k}^{min}} $$
% $$ a_{k} $$: total availability of renewable resource type _k_

% $$ r_{k}^{min} $$ equals to $$ \max{r_{ik}} $$ i=1,...,n (the highest individual resource demand)otherwise the project is infeasible; $$r_{k}^{max}$$ denotes the peak
% demand of resource type _k_ in the precedence preserving the earliest start
% schedule

%% RC: resource constrainedness for each resource type
% $$ RC_{k}=\frac{\overline{r}_{k}}{a_{k}} $$
%
% where
%
% $$ a_{k} $$: total availability of renewable resource type _k_
% $$ \overline{r}_{k}=\sum_{i=1}^{n}\frac{r_{ik}}{\sum_{i=1}^{n}
% \begin{cases} 1 & \text{ if } r_{ik}>0 \\ 0 & \text{ otherwise}
% \end{cases}} $$


function [RF,RU,PCTR,DMND,RS,RC]=res_inds_sm(PSM,num_r_resources,constr)
n=size(PSM,1);
%w=1;    % number of modes
r=num_r_resources;  % number of renewable resources
RD=PSM(:,n+2+1:n+2+r);    %resource domain
%% INDICATORS
PCTR=sum(RD>0,1)/n; %percent of activities that require the given resuorce type
RF=sum(PCTR,2)/r;   %resource factor
RU=sum(RD>0,2); %resource use
a=constr(3:3+r-1); %the first constraint belongs to time, the second belongs to cost
RS=(a-min(RD,[],1))/(max(RD,[],1)-min(RD,[],1));    %TODO: There are 2 RS definitions. Which one is the most apropriate? TODO2: dividing by zero could be an issue
DMND=sum(PSM(:,n+2+1:n+2+r),1)./sum(PSM(:,n+2+1:n+2+r)>0,1);    %average demand form each renewable resource
RC=DMND./a; %resource constrainedness for each resource type
end